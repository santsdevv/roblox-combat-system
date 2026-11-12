export type State = {
	[number]: Transitions,
}

export type Transitions = {
	Idle: { "Attacking" | "Blocking" | "Dodging" | "Stunned" | "Dead" },
	Attacking: { "Idle" | "Stunned" | "Dead" },
	Blocking: { "Idle" | "Stunned" | "Dead" },
	Dodging: { "Idle" | "Stunned" | "Dead" },
	Stunned: { "Idle" | "Dead" },
	Dead: {},
}

export type GetState = (player: Player) -> State

export type CanTransition = (player: Player, transition: string) -> boolean

export type SetState = (player: Player, newState: State) -> boolean

return {}
