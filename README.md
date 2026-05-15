# IDE

_Isolated Development Environments_

## Usage

- Store repositories on the host (e.g. in `~/repos`).
- Configure your development environments with a `compose.yml` (e.g. in `~/envs/compose.yml`)
- Provide secrets and environment specific settings in `.env` files (e.g. `ide.env`)

### Example

```yml
services:
  envs:
    image: ghcr.io/david-haerer/ide:main
    platform: linux/amd64
    working_dir: /home/dev/envs
    env_file: [./envs.env]
    volumes:
      - .:/home/dev/envs
  ide:
    image: ghcr.io/david-haerer/ide:main
    platform: linux/amd64
    working_dir: /home/dev/ide
    env_file: [./ide.env]
    volumes:
      - $REPOS/ide/ide:/home/dev/ide
```
