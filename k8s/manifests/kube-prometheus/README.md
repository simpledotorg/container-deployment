# Kube prometheus

## Local jsonnet setup

- Install [go-jsonnet](https://github.com/google/go-jsonnet)
```bash
brew install go-jsonnet
```

- Install [jsonnet-bundler](https://github.com/jsonnet-bundler/jsonnet-bundler)
```bash
brew install jsonnet-bundler
```

- Install dependencies
```bash
jb install
```

- Generate manifests, only for testing purposes (`do not commit generated out.json file`) 
```bash
jsonnet -J vendor monitoring.jsonnet --ext-str ENVIRONMENT=sandbox > out.json
```
