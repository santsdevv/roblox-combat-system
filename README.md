# Roblox Combat System

A modular melee combat system for Roblox, written in Luau and managed with Rojo.

The server is authoritative. The client plays animations immediately for responsiveness, and the server validates every action.

## Features

- M1 combo chain defined per weapon, with a finisher on the last hit
- Parry with startup, active window and recovery; hitting a parry stuns the attacker
- Directional dash (front, back, left, right) with shift lock support
- Blade hitbox using spherecasts along the weapon, plus sweeps between frames so fast swings don't skip targets
- Equip and unequip with animations and Motor6D welds
- Hit, parry and dash VFX and sounds
- Keyboard, mouse and gamepad input

## Controls

| Action | Keyboard / Mouse | Gamepad |
|---|---|---|
| Attack | Mouse 1 | R2 |
| Parry | F | B |
| Equip / unequip | 1 | Y, X or D-Pad Up |
| Dash | Q | A |

## Structure

```
src/
├── ReplicatedStorage/
│   ├── Path/                  Central path resolver (Path:Search)
│   ├── Services/              AnimationService
│   ├── Controllers/           SoundController, VFXController
│   ├── Managers/              StateManagerClient
│   └── Others/
│       ├── ClientCombat       Client-side prediction for attacks and parry
│       └── InputHandler/      Key bindings and special keys (Dash)
├── ServerScriptService/
│   ├── Main.server.luau       Entry point
│   ├── Controllers/           CombatController
│   ├── Services/CombatService/StatesManager/
│   │   ├── Attacking/         Combo logic, Hitbox, Cast, knockback
│   │   ├── Parrying
│   │   └── Equip
│   ├── Managers/              WeaponsManager, PlayersManager
│   └── Others/                CombatStateMachine, WeaponsRegistry
└── StarterPlayer/StarterPlayerScripts/
    └── CombatClient.client.luau
```

### Flow

1. `InputHandler` reads the input and `ClientCombat` plays the animation locally.
2. The client fires `SendKey` with the action and the predicted combo index.
3. `CombatController` checks if the player can act, `CombatService` resolves the weapon data, and `StatesManager` runs the matching state (`Attacking`, `Parrying` or `Equip`).
4. `Attacking` validates the combo, compensates for latency, and starts a `Hitbox` driven by the animation markers `HitStart` and `HitEnded`.
5. Hit and parry effects are broadcast to clients through `VFXEvent`.

Combat state is replicated through character attributes (`Stunned`, `AttackStun`, `Parrying`, `WeaponEquipped`, `OnRagdoll`).

## Installation

Requires [Aftman](https://github.com/LPGhatguy/aftman).

```bash
git clone https://github.com/santsdevv/roblox-combat-system.git
cd roblox-combat-system
aftman install
rojo serve
```

Then connect from the Rojo plugin in Roblox Studio.

Rojo only syncs the code and the remote events. Models, VFX, sounds and animations live in the place file. See [`assets/README.md`](assets/README.md) for the required instances.

## Adding a weapon

Add an entry to `src/ServerScriptService/Others/WeaponsRegistry/Weapons.luau`:

```lua
greatsword = {
    Id = "greatsword",
    Damage = 18,
    Animations = {
        idle = "rbxassetid://...",
        equip = "rbxassetid://...",      -- needs an "Equip" marker
        unnequip = "rbxassetid://...",
        attack = {                       -- need "HitStart" and "HitEnded" markers
            attack_1 = "rbxassetid://...",
            attack_2 = "rbxassetid://...",
        },
        blockStart = "rbxassetid://...",
    },
    Cooldown = 1.1,
    ComboCooldown = 2,
    BlockCooldown = 1.5,
    ParryWindow = 0.18,                  -- optional
},
```

Then add:

- the model at `ReplicatedStorage.Assets.CombatSystem.Weapons.greatsword`, with a `Handler` part containing a `HitAttachments` folder with `StartAttachment` and `EndAttachment`
- `HoldingWeld` and `IdleWeld` (Motor6D) at `ReplicatedStorage.Assets.CombatSystem.Welds.Weapons.greatsword`

## Configuration

| Setting | File |
|---|---|
| Stun durations | `Attacking/Utilities.luau` |
| Dash speed, duration and cooldown | `Dash/DashClient.luau` |
| Knockback force | `Attacking/init.luau` (`landHit`) |
| Hitbox radius | `Hitbox/Cast.luau` |
| Key bindings | `InputHandler/init.luau` |

## Roadmap

- Enforce transitions in `CombatStateMachine`
- Full ragdoll on finisher
- Sheathe logic
- Server-side dash validation
- Hold-to-block

## License

[MIT](LICENSE)
