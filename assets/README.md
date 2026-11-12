# Assets

Rojo only syncs code. The system also needs these instances, which live in the place file:

| Location | Contents |
|---|---|
| `ReplicatedStorage.Assets.CombatSystem.Animations.Combat` | `Hit`, `Parry` (Animation) |
| `ReplicatedStorage.Assets.CombatSystem.Animations.Dash` | `DashFront`, `DashBack`, `DashLeft`, `DashRight` (Animation) |
| `ReplicatedStorage.Assets.CombatSystem.Weapons.katana` | Model with a `Handler` MeshPart → `HitAttachments` folder with `StartAttachment` / `EndAttachment` |
| `ReplicatedStorage.Assets.CombatSystem.Welds.Weapons.katana` | `HoldingWeld`, `IdleWeld` (Motor6D) |
| `ReplicatedStorage.VFX.CombatSystem` | `HitBlood`, `Impact`, `Dash` folders of ParticleEmitters (each with an `EmitCount` attribute) |
| `SoundService.Sounds.CombatSystem` | `successful_hit`, `slash`, `weapon_equip`, `parry`, `dash` (Sound) |
| `ServerStorage.Weapons.katana` | `Weapon`, `Sheathe` (Model) |

## Exporting them

In Roblox Studio, select `ReplicatedStorage.Assets`, `ReplicatedStorage.VFX`, `SoundService.Sounds` and
`ServerStorage.Weapons`, right-click → **Save to File…** and save each one here as `.rbxm`
(`Assets.rbxm`, `VFX.rbxm`, `Sounds.rbxm`, `ServerWeapons.rbxm`). Then drag them back into a fresh place.

The animation IDs are owned by the original author's account. If they don't load in your game,
re-upload your own animations and replace the IDs in
`src/ServerScriptService/Others/WeaponsRegistry/Weapons.luau` and in the `Animations` folder.
