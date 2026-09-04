# VSCode Extensions

Install all:

```sh
cat extensions.md | grep -oE '`[a-z0-9.-]+`' | tr -d '`' | xargs -L1 code --install-extension
```

## Editing

- `vscodevim.vim` — Vim
- `esbenp.prettier-vscode` — Prettier
- `dbaeumer.vscode-eslint` — ESLint
- `dsznajder.es7-react-js-snippets` — ES7+ React/Redux/React-Native snippets
- `bradlc.vscode-tailwindcss` — Tailwind CSS IntelliSense
- `golang.go` — Go

## Tooling

- `anthropic.claude-code` — Claude Code
- `mhutchie.git-graph` — Git Graph
- `amazonwebservices.aws-toolkit-vscode` — AWS Toolkit

## Themes

- `nikharso.kashi` — Kashi
- `kvrohit.mellow-theme` — Mellow
- `mvllow.rose-pine` — Rosé Pine
- `mohdzaid.vscode-cursor-theme` — Cursor Theme
- `qvist.jetbrains-new-ui-dark-theme` — JetBrains New UI Dark

## Icons

- `chadalen.vscode-jetbrains-icon-theme` — JetBrains Icon Theme
- `miguelsolorio.symbols` — Symbols
- `yatasun.jetbrains-product-icons` — JetBrains Product Icons
