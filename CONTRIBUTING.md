# Contributing

1. Fork the repository and create a branch.
2. Install the tools with `aftman install`.
3. Run `rojo serve` and connect from the Rojo plugin in Studio.
4. Run `stylua src` and `selene src` before committing.
5. Open a pull request describing the change.

## Guidelines

- Keep one responsibility per module.
- Prefer `Path:Search(...)` over hardcoded paths.
- The server decides damage and state. The client only predicts animations.
