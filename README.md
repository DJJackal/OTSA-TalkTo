# OTSA-TalkTo

OTSA-TalkTo is a lightweight standalone FiveM staff utility that lets authorised staff temporarily move themselves and another player into a private routing bucket for a one-on-one conversation, then safely return both players to where they came from.

## Features

- Standalone resource with no framework dependency.
- Uses FiveM routing buckets for private staff/player sessions.
- ACE permission protected.
- Saves each participant's original routing bucket, coordinates, and heading.
- Restores both players when the session ends.
- Automatically restores the remaining player if the other participant disconnects.
- Prevents players from joining multiple talk sessions at the same time.
- Rejects invalid/offline player IDs and self-targeting.
- Allocates an unused routing bucket from a configurable range.
- Configurable commands, permission name, bucket range, restore behaviour, delay, and messages.

## Requirements

- A FiveM server with OneSync/routing bucket support.
- An ACE permission setup that grants authorised staff the permission configured in `config.lua`.

No ESX, QBCore, Discord API, or Discord permission resource is required.

## Installation

1. Download or clone this repository.
2. Place the `OTSA-TalkTo` folder in your server's `resources` directory.
3. Add the resource to `server.cfg`:

```cfg
ensure OTSA-TalkTo
```

4. Grant your staff group permission to use the resource:

```cfg
add_ace group.staff otsa.talkto allow
```

5. Make sure your existing permission system assigns the appropriate players to `group.staff`, or grant `otsa.talkto` through your preferred ACE setup.
6. Restart the server or run `ensure OTSA-TalkTo` from the server console.

## Commands

| Command | Description |
| --- | --- |
| `/talkto <playerid>` | Starts a private talk session between the authorised staff member and the target player. |
| `/talktoend` | Ends the session started by that staff member and restores both participants. |

The target player does not need the ACE permission.

## Configuration

Edit `config.lua` to change the resource behaviour.

```lua
Config.TalkToCommand = 'talkto'
Config.TalkToEndCommand = 'talktoend'
Config.Permission = 'otsa.talkto'

Config.StartingBucket = 7000
Config.EndingBucket = 7999

Config.RestoreOriginalBucket = true
Config.RestoreDelayMs = 250
```

### ACE permission

The server checks:

```lua
IsPlayerAceAllowed(source, Config.Permission)
```

This means OTSA-TalkTo works with any permission resource or server configuration that ultimately grants the configured ACE permission.

### Discord permission resources

If you use a Discord-to-ACE resource, simply have that resource place your staff into an ACE group and grant that group `otsa.talkto`.

Example:

```cfg
add_ace group.staff otsa.talkto allow
```

Your Discord integration remains completely separate from OTSA-TalkTo.

## How it works

When an authorised staff member runs `/talkto <playerid>`:

1. OTSA-TalkTo validates the target and checks that neither participant is already in a session.
2. It records each player's current routing bucket, coordinates, and heading.
3. It finds an unused routing bucket inside the configured range.
4. Both players are moved into that private bucket.
5. When the staff member runs `/talktoend`, both players are returned to their original buckets and positions.

If either participant disconnects during the session, the remaining participant is restored automatically.

## Notes

- The staff member who starts the session is the person who uses `/talktoend`.
- Choose a routing bucket range that does not conflict with bucket IDs used by other resources on your server.
- `Config.RestoreOriginalBucket = true` is recommended when your server already uses routing buckets for other systems.

## Contributing

Issues and pull requests are welcome. If you find a bug, please include your server build, relevant console output, and clear reproduction steps.

## License

This project is released under the MIT License. See [LICENSE](LICENSE).
