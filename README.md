# Authenticated Private Cargo Registry Demo

This workspace demonstrates:

- a publishable library crate (`hello-world-lib`) intended for a private registry
- an application crate (`hello-world-app`) consuming the library from a named cargo registry
- a script that builds a static private-registry upload artifact (`dist/private-registry-artifact.tar.gz`)
- Dependabot configuration for authenticated private registry access

## Layout

- `crates/hello-world-lib`: private crate to publish
- `apps/hello-world-app`: consumer app using `registry = "private-demo"`
- `apps/hello-world-app/.cargo/config.toml`: registry mapping
- `registry/config.template.json`: editable template for generated index `config.json`
- `scripts/build_registry_artifact.sh`: packages crate and creates upload artifact
- `.github/dependabot.yml`: Dependabot auth + update rules

## Build Registry Artifact

```bash
chmod +x scripts/build_registry_artifact.sh
./scripts/build_registry_artifact.sh
```

Optional overrides:

```bash
DL_URL="https://your-host/crates/{crate}/{version}/{crate}-{version}.crate" \
API_URL="https://your-host/api/v1/crates" \
./scripts/build_registry_artifact.sh
```

The script creates:

- `dist/registry-upload/index/config.json` (from template)
- `dist/registry-upload/index/he/ll/hello-world-lib` (index metadata)
- `dist/registry-upload/crates/hello-world-lib/<version>/hello-world-lib-<version>.crate`
- `dist/private-registry-artifact.tar.gz`

## Consume Dependency From Private Registry

In `apps/hello-world-app/Cargo.toml`, dependency is declared as:

```toml
hello-world-lib = { version = "0.1.0", registry = "private-demo" }
```

Ensure registry auth in your environment before building app, for example:

```bash
export CARGO_REGISTRIES_PRIVATE_DEMO_TOKEN="<token>"
```

Then run:

```bash
cargo run -p hello-world-app
```
