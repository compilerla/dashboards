# Getting Started with Dashboards

This is a tutorial on how to set up your local development environment.

## Local Development (VS Code Dev Containers)

This repository follows Compiler's cross-platform [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) standard to ensure consistent development environments across macOS, Linux, and Windows.

!!! note

    Read our [blog post on Dev Containers](https://compiler.la/blog/2024/devcontainer-platform-agnostic-team/) to learn more about Compiler's cross-platform development philosophy.

### Prerequisites

1. Docker and Docker Compose running locally (check out [Podman](https://podman.io/) for a cross-platform OSS management environment).
2. [Visual Studio Code](https://code.visualstudio.com/).
3. VS Code [Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

### Getting Started

1. Create and configure your local environment file:

   ```bash
   cp .env.example .env
   ```

   Edit `.env` to set your desired values. The `metabase` service will connect to the local `postgres` service using the `MB_DB_TYPE`/`MB_DB_HOST`/`MB_DB_DBNAME` values from this file.

2. Open this folder in VS Code.
3. When prompted, click **"Reopen in Container"** (or press `F1` / `Ctrl+Shift+P` / `Cmd+Shift+P` and run `Dev Containers: Reopen in Container`).
4. VS Code will build the dev container and launch all three services:
   - **`dev`**: Your development shell containing `terraform`, `gcloud`, `pre-commit`, and Postgres client tools.
   - **`postgres`**: Local PostgreSQL 18 database storing Metabase application state.
   - **`metabase`**: Custom Metabase application (socat bridges Cloud SQL Unix socket to TCP 5432 for prod; connects directly to local postgres for dev) connecting to local postgres. Available at [http://localhost:3000](http://localhost:3000).
