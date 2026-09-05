local function notify(message, messageType)
    local colour = { 255, 255, 255 }

    if messageType == 'success' then
        colour = { 80, 200, 120 }
    elseif messageType == 'error' then
        colour = { 235, 80, 80 }
    elseif messageType == 'info' then
        colour = { 80, 160, 235 }
    end

    TriggerEvent('chat:addMessage', {
        color = colour,
        multiline = true,
        args = { '[OTSA TalkTo]', message }
    })
end

RegisterNetEvent('OTSA-TalkTo:client:notify', function(message, messageType)
    notify(message, messageType)
end)

RegisterNetEvent('OTSA-TalkTo:client:restorePosition', function(position)
    if type(position) ~= 'table' then
        return
    end

    Wait(Config.RestoreDelayMs or 250)

    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then
        return
    end

    SetEntityCoordsNoOffset(
        ped,
        tonumber(position.x) or 0.0,
        tonumber(position.y) or 0.0,
        tonumber(position.z) or 0.0,
        false,
        false,
        false
    )

    SetEntityHeading(ped, tonumber(position.h) or 0.0)
end)
