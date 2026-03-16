# Kitodo Workflow Editor × Kitodo.Production — Integration Dev Environment

> **Note:** The workflow test suite is currently expected to fail. Workflow editor
> 2.1.0 is not yet merged into kitodo-production — once the upstream PR lands,
> the tests should pass and this notice will be removed.

This repo is a **dev environment for working on the [Kitodo Workflow Editor](https://github.com/Erikmitk/kitodo-workflow-editor)**. It lets you spin up a fully integrated [Kitodo.Production](https://github.com/slub/kitodo-production) instance in Docker with your local editor changes applied — without needing to set up or maintain a local production environment. Run `./integrate.sh`, open the browser, and verify your editor changes against a real Kitodo.Production stack.

## Repository layout

```
kitodo-integration/
├── kitodo-production/       # submodule → slub/kitodo-production @ main
├── kitodo-workflow-editor/  # submodule → Erikmitk/kitodo-workflow-editor @ master
├── docker/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── smoke-test.sh        # health checks after stack comes up
│   ├── deploy.sh
│   └── startup.sh
├── hooks/
│   └── pre-commit           # submodule branch guard (install via sync-submodules.sh)
├── integrate.sh             # full build + Docker deploy (local dev)
└── sync-submodules.sh       # init/update submodules + install git hook
```

## Prerequisites

- Java 21
- Node 18+
- Maven 3.x
- Docker with Compose plugin

## Getting started

```sh
git clone --recurse-submodules https://github.com/Erikmitk/kitodo-integration
cd kitodo-integration
./sync-submodules.sh     # initialises submodules and installs the pre-commit hook
./integrate.sh           # build editor + Kitodo.Production + start Docker stack
```

The app will be available at **http://localhost:8080/kitodo**.

Default test accounts (password `test`): `testAdmin`, `testScanning`, `testQC`, `testImaging`, `testMetaData`, `testProjectmanagement`.

## Updating submodules

**Pin to recorded commits** (normal day-to-day):
```sh
./sync-submodules.sh
```

**Bump to latest remote tip**:
```sh
git submodule update --init --remote --recursive
git add kitodo-production kitodo-workflow-editor
git commit -m "Bump submodules to latest"
```

## Docker stack

| Service | Image | Port |
|---------|-------|------|
| `kitodo-app` | built from `docker/Dockerfile` | 8080 |
| `kitodo-db` | mysql:8.0.32 | — |
| `kitodo-es` | opensearchproject/opensearch:2.15.0 | 9200 |

```sh
# Start
docker compose -f docker/docker-compose.yml up -d

# Stop + remove containers (data volumes preserved)
docker compose -f docker/docker-compose.yml down

# Smoke test
bash docker/smoke-test.sh
```

## CI

| Workflow | Trigger | What it tests |
|----------|---------|---------------|
| `integration.yml` | push / PR to `main` | pinned submodule commits |
| `integration-canary.yml` | 1st of each month + manual | latest tip of each upstream branch |

The canary workflow opens a GitHub Issue automatically if the build fails, so upstream breakage is caught without watching CI dashboards.

## Git hook

`hooks/pre-commit` blocks any commit at the integration root if a submodule is on the wrong branch or in detached HEAD. It is **not** installed automatically by git — run `./sync-submodules.sh` once after cloning.
