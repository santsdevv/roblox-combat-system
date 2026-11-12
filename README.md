<div align="center">

# ⚔️ Roblox Combat System

**Sistema de combate corpo a corpo modular para Roblox, com servidor autoritativo e predição no cliente.**

Combo M1 · Parry · Dash direcional · Hitbox por spherecast · Equipar/guardar arma · VFX e sons

![Luau](https://img.shields.io/badge/Luau-00A2FF?style=for-the-badge&logo=roblox&logoColor=white)
![Rojo](https://img.shields.io/badge/Rojo-7.4-E13835?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

<!-- Coloque aqui um GIF do combate: ![demo](docs/demo.gif) -->

</div>

---

## ✨ Funcionalidades

| | |
|---|---|
| 🗡️ **Combo M1** | Sequência de N ataques definida por arma; o último golpe é um *finisher* com knockback forte |
| 🛡️ **Parry** | Janela de parry com *startup → window → recovery*; quem bate num parry fica atordoado |
| 💨 **Dash** | Dash em 4 direções (W/A/S/D), com suporte a Shift Lock e animação conforme a direção |
| 🎯 **Hitbox precisa** | Spherecast ao longo da lâmina + varredura entre frames (não "atravessa" alvos em golpes rápidos) |
| ⚡ **Predição no cliente** | A animação toca na hora no cliente; o servidor valida o combo e compensa o ping |
| 🎒 **Equipar arma** | Arma nas costas → na mão via Motor6D, com animações de equip/unequip |
| 🎮 **Controle** | Teclado/mouse e gamepad |
| 🧩 **Modular** | Adicionar uma arma = um item numa tabela + o modelo |

## 🎮 Controles

| Ação | Teclado | Gamepad |
|---|---|---|
| Atacar | `Mouse 1` | `R2` |
| Parry | `F` | `B` |
| Equipar / guardar | `1` | `Y` / `X` / `D-Pad ↑` |
| Dash | `Q` (+ direção) | `A` |

## 🏗️ Arquitetura

```
Cliente                                     Servidor
───────                                     ────────
InputHandler ──► ClientCombat (prediz anim)
     │
     └──── SendKey:FireServer(action, combo) ──► Main.server
                                                   └► CombatController  (pode agir?)
                                                        └► CombatService (arma + dados)
                                                             └► StatesManager ─► CombatStateMachine
                                                                  ├► Attacking ─► Hitbox ─► Cast (spherecast)
                                                                  │                └► ImpactHandlerServer
                                                                  ├► Parrying
                                                                  └► Equip
VFXController ◄──── VFXEvent:FireAllClients ◄──┘
```

O estado de combate é replicado por **atributos do personagem** (`Stunned`, `AttackStun`, `Parrying`, `WeaponEquipped`, `OnRagdoll`...). O cliente lê esses atributos para bloquear inputs e interromper animações, e o servidor tem sempre a palavra final.

```
src/
├── ReplicatedStorage/
│   ├── Path/                  # Resolvedor central de caminhos (Path:Search)
│   ├── Services/AnimationService
│   ├── Controllers/           # SoundController, VFXController
│   ├── Managers/StateManagerClient
│   └── Others/
│       ├── ClientCombat       # Predição de M1/parry
│       └── InputHandler/      # Mapeamento de teclas + EspecialKeys (Dash)
├── ServerScriptService/
│   ├── Main.server.luau       # Bootstrap
│   ├── Controllers/CombatController
│   ├── Services/CombatService/StatesManager/{Attacking, Parrying, Equip}
│   ├── Managers/{WeaponsManager, PlayersManager}
│   └── Others/{CombatStateMachine, WeaponsRegistry}
└── StarterPlayer/StarterPlayerScripts/CombatClient.client.luau
```

## 🚀 Instalação

### Com Rojo (recomendado)

```bash
git clone https://github.com/<seu-usuario>/roblox-combat-system.git
cd roblox-combat-system
aftman install        # instala rojo, stylua e selene
rojo serve
```

No Roblox Studio, abra o plugin **Rojo** e clique em **Connect**.

> ⚠️ O Rojo sincroniza só o **código** e os RemoteEvents. Modelos, VFX, sons e animações ficam no place. Veja o [`assets/README.md`](assets/README.md) para saber o que importar.

### Sem Rojo

Copie cada pasta de `src/` para o serviço de mesmo nome no Studio. Um arquivo `init.luau` vira o próprio ModuleScript da pasta, e os outros arquivos dela viram filhos dele.

## 🔧 Adicionando uma arma

Em `src/ServerScriptService/Others/WeaponsRegistry/Weapons.luau`:

```lua
greatsword = {
    Id = "greatsword",
    Damage = 18,
    Animations = {
        idle = "rbxassetid://...",
        equip = "rbxassetid://...",      -- precisa do marker "Equip"
        unnequip = "rbxassetid://...",
        attack = {                       -- precisam dos markers "HitStart" e "HitEnded"
            attack_1 = "rbxassetid://...",
            attack_2 = "rbxassetid://...",
        },
        blockStart = "rbxassetid://...",
    },
    Cooldown = 1.1,
    ComboCooldown = 2,
    BlockCooldown = 1.5,
    ParryWindow = 0.18,                  -- opcional
},
```

Depois adicione o modelo em `Assets/CombatSystem/Weapons/greatsword` (com `Handler` → `HitAttachments` → `StartAttachment`/`EndAttachment`) e os welds `HoldingWeld`/`IdleWeld` em `Assets/CombatSystem/Welds/Weapons/greatsword`.

## ⚙️ Ajustes rápidos

| O quê | Onde |
|---|---|
| Duração de stuns | `Attacking/Utilities.luau` → `Cooldowns` |
| Velocidade, duração e cooldown do dash | `DashClient.luau` → `DASH_*` |
| Força do knockback | `Attacking/init.luau` → `landHit` |
| Raio da hitbox | `Hitbox/Cast.luau` → `HitRadius` |
| Teclas | `InputHandler/init.luau` → `Keys` / `Types` |

## 🗺️ Roadmap

- [ ] Validar de verdade as transições da `CombatStateMachine` (hoje ela é só informativa)
- [ ] Ragdoll completo no finisher (`ImpactHandlerServer:Ragdoll` já existe)
- [ ] Lógica de bainha (`Sheathe`)
- [ ] Validação do dash no servidor
- [ ] Block contínuo (`blockEnd`)

## 🤝 Contribuindo

PRs são bem-vindos! Leia o [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 Licença

[MIT](LICENSE): use, modifique e distribua à vontade.
