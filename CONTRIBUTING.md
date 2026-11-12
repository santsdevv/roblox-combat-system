# Contribuindo

Valeu pelo interesse! 🗡️

1. Faça um fork e crie uma branch: `git checkout -b feature/minha-feature`
2. Instale as ferramentas: `aftman install`
3. Sincronize com o Studio: `rojo serve` e conecte pelo plugin do Rojo
4. Antes do commit, rode `stylua src` e `selene src`
5. Abra um Pull Request explicando o que mudou e, se possível, com um GIF/vídeo

## Padrões
- Um módulo = uma responsabilidade (Service, Controller, Manager...)
- Use `Path:Search(...)` em vez de caminhos fixos sempre que possível
- O servidor é a autoridade: o cliente só **prevê** animações, nunca decide dano
