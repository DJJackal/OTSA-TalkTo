Config = {}

-- Commands
Config.TalkToCommand = 'talkto'
Config.TalkToEndCommand = 'talktoend'

-- Permission checked by the server with IsPlayerAceAllowed.
-- Grant this ACE permission to whichever staff group your server uses.
-- Example for server.cfg:
-- add_ace group.staff otsa.talkto allow
Config.Permission = 'otsa.talkto'

-- Private routing buckets are allocated from this range.
Config.StartingBucket = 7000
Config.EndingBucket = 7999

-- Restore each participant to the routing bucket they were in before the session.
-- This is safer than always forcing bucket 0.
Config.RestoreOriginalBucket = true

-- Delay before restoring the saved coordinates after returning to the original bucket.
Config.RestoreDelayMs = 250

Config.Messages = {
    NoPermission = 'You do not have permission to use this command.',
    Usage = 'Usage: /%s <playerid>',
    InvalidTarget = 'That player ID is not online.',
    CannotTargetSelf = 'You cannot start a private talk session with yourself.',
    AlreadyInSession = 'You are already part of a private talk session.',
    TargetAlreadyInSession = 'That player is already part of another private talk session.',
    NoSession = 'You do not have an active private talk session.',
    NoBucketAvailable = 'No private routing bucket is currently available.',
    PositionError = 'Could not save one or both player positions. The session was not started.',
    StartedAdmin = 'Private talk started with %s [%s]. Use /%s when finished.',
    StartedTarget = 'A staff member has moved you into a private talk session.',
    EndedAdmin = 'Private talk ended. You have been returned to your original position.',
    EndedTarget = 'The private talk has ended. You have been returned to your original position.',
    OtherPlayerLeft = 'The other participant left the server. You have been returned to your original position.'
}
