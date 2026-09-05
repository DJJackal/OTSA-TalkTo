local sessionsByAdmin = {}
local playerToAdmin = {}
local nextBucket = Config.StartingBucket

local function notify(playerId, message, messageType)
    if playerId and playerId > 0 and GetPlayerName(playerId) then
        TriggerClientEvent('OTSA-TalkTo:client:notify', playerId, message, messageType or 'info')
    end
end

local function playerExists(playerId)
    return playerId and playerId > 0 and GetPlayerName(playerId) ~= nil
end

local function hasPermission(playerId)
    return playerId == 0 or IsPlayerAceAllowed(playerId, Config.Permission)
end

local function getSavedPosition(playerId)
    if not playerExists(playerId) then
        return nil
    end

    local ped = GetPlayerPed(playerId)
    if not ped or ped == 0 or not DoesEntityExist(ped) then
        return nil
    end

    local coords = GetEntityCoords(ped)
    if not coords then
        return nil
    end

    return {
        x = coords.x + 0.0,
        y = coords.y + 0.0,
        z = coords.z + 0.0,
        h = GetEntityHeading(ped) + 0.0
    }
end

local function isBucketInUse(bucket)
    for _, session in pairs(sessionsByAdmin) do
        if session.bucket == bucket then
            return true
        end
    end

    for _, playerId in ipairs(GetPlayers()) do
        local numericPlayerId = tonumber(playerId)
        if numericPlayerId and GetPlayerRoutingBucket(numericPlayerId) == bucket then
            return true
        end
    end

    return false
end

local function allocateBucket()
    local startBucket = Config.StartingBucket
    local endBucket = Config.EndingBucket
    local bucketCount = (endBucket - startBucket) + 1

    for _ = 1, bucketCount do
        local candidate = nextBucket

        nextBucket = nextBucket + 1
        if nextBucket > endBucket then
            nextBucket = startBucket
        end

        if not isBucketInUse(candidate) then
            return candidate
        end
    end

    return nil
end

local function restorePlayer(playerId, participant)
    if not playerExists(playerId) or not participant then
        return
    end

    local destinationBucket = 0
    if Config.RestoreOriginalBucket then
        destinationBucket = participant.originalBucket or 0
    end

    SetPlayerRoutingBucket(playerId, destinationBucket)
    TriggerClientEvent('OTSA-TalkTo:client:restorePosition', playerId, participant.position)
end

local function clearSession(adminId)
    local session = sessionsByAdmin[adminId]
    if not session then
        return nil
    end

    playerToAdmin[session.admin.id] = nil
    playerToAdmin[session.target.id] = nil
    sessionsByAdmin[adminId] = nil

    return session
end

local function endSession(adminId, reason)
    local session = clearSession(adminId)
    if not session then
        return false
    end

    restorePlayer(session.admin.id, session.admin)
    restorePlayer(session.target.id, session.target)

    if reason == 'disconnect' then
        if playerExists(session.admin.id) then
            notify(session.admin.id, Config.Messages.OtherPlayerLeft, 'error')
        end

        if playerExists(session.target.id) then
            notify(session.target.id, Config.Messages.OtherPlayerLeft, 'error')
        end
    else
        notify(session.admin.id, Config.Messages.EndedAdmin, 'success')
        notify(session.target.id, Config.Messages.EndedTarget, 'success')
    end

    print(('[OTSA-TalkTo] Ended session in bucket %s between staff %s [%s] and target %s [%s]. Reason: %s')
        :format(
            session.bucket,
            session.admin.name or 'Unknown',
            session.admin.id,
            session.target.name or 'Unknown',
            session.target.id,
            reason or 'command'
        ))

    return true
end

RegisterCommand(Config.TalkToCommand, function(source, args)
    if source == 0 then
        print(('[OTSA-TalkTo] /%s can only be used by an in-game player.'):format(Config.TalkToCommand))
        return
    end

    if not hasPermission(source) then
        notify(source, Config.Messages.NoPermission, 'error')
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        notify(source, Config.Messages.Usage:format(Config.TalkToCommand), 'error')
        return
    end

    if not playerExists(targetId) then
        notify(source, Config.Messages.InvalidTarget, 'error')
        return
    end

    if targetId == source then
        notify(source, Config.Messages.CannotTargetSelf, 'error')
        return
    end

    if playerToAdmin[source] then
        notify(source, Config.Messages.AlreadyInSession, 'error')
        return
    end

    if playerToAdmin[targetId] then
        notify(source, Config.Messages.TargetAlreadyInSession, 'error')
        return
    end

    local adminPosition = getSavedPosition(source)
    local targetPosition = getSavedPosition(targetId)

    if not adminPosition or not targetPosition then
        notify(source, Config.Messages.PositionError, 'error')
        return
    end

    local bucket = allocateBucket()
    if not bucket then
        notify(source, Config.Messages.NoBucketAvailable, 'error')
        return
    end

    local session = {
        bucket = bucket,
        admin = {
            id = source,
            name = GetPlayerName(source),
            originalBucket = GetPlayerRoutingBucket(source),
            position = adminPosition
        },
        target = {
            id = targetId,
            name = GetPlayerName(targetId),
            originalBucket = GetPlayerRoutingBucket(targetId),
            position = targetPosition
        }
    }

    sessionsByAdmin[source] = session
    playerToAdmin[source] = source
    playerToAdmin[targetId] = source

    SetPlayerRoutingBucket(source, bucket)
    SetPlayerRoutingBucket(targetId, bucket)

    notify(source, Config.Messages.StartedAdmin:format(session.target.name, targetId, Config.TalkToEndCommand), 'success')
    notify(targetId, Config.Messages.StartedTarget, 'info')

    print(('[OTSA-TalkTo] Started private session in bucket %s between staff %s [%s] and target %s [%s].')
        :format(bucket, session.admin.name, source, session.target.name, targetId))
end, false)

RegisterCommand(Config.TalkToEndCommand, function(source)
    if source == 0 then
        print(('[OTSA-TalkTo] /%s can only be used by an in-game player.'):format(Config.TalkToEndCommand))
        return
    end

    if not hasPermission(source) then
        notify(source, Config.Messages.NoPermission, 'error')
        return
    end

    if not sessionsByAdmin[source] then
        notify(source, Config.Messages.NoSession, 'error')
        return
    end

    endSession(source, 'command')
end, false)

AddEventHandler('playerDropped', function()
    local droppedPlayer = source
    local adminId = playerToAdmin[droppedPlayer]

    if adminId and sessionsByAdmin[adminId] then
        endSession(adminId, 'disconnect')
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    local adminIds = {}
    for adminId in pairs(sessionsByAdmin) do
        adminIds[#adminIds + 1] = adminId
    end

    for _, adminId in ipairs(adminIds) do
        endSession(adminId, 'resource_stop')
    end
end)
