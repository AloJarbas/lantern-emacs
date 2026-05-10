# Language servers Lantern expects

Lantern wires up `eglot`, but it does not pretend language servers install themselves.

That split is intentional: editor config belongs here, toolchain ownership belongs to the machine using it.

## Common installs

### Python

```bash
npm install -g pyright
```

### TypeScript / JavaScript

```bash
npm install -g typescript typescript-language-server
```

### Go

```bash
go install golang.org/x/tools/gopls@latest
```

### Rust

```bash
brew install rust-analyzer
# or use your distro package manager / rustup setup
```

### YAML

```bash
npm install -g yaml-language-server
```

## Sanity check

Run:

```bash
./bin/doctor
```

If a server is missing, Lantern will still open the file. You just will not get the full LSP experience for that language yet.
