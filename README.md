# 🐳 Docker Notes

## 📋 Prerequisites
- **Docker Engine** (v20.10+ recommended) installed and running.
- **Bash Shell** for executing build scripts and interacting with containers.

---

## 🗺️ Learning Roadmap

| Stage | Topic | Directory | Core Concepts & Highlights |
|---|---|---|---|
| **01** | **Docker Basics** | [`docker_basics/`](docker_basics/) | `Dockerfile` directives (`FROM`, `COPY`, `RUN`, `USER`, `ENTRYPOINT`), least-privilege security |
| **02** | **Simple Server** | [`simple_server_example/`](simple_server_example/) | Persistent background loops, custom Dockerfile naming with `-f` |
| **03** | **Port Binding** | [`binding_ports_to_contaner/`](binding_ports_to_contaner/) | Host-to-container port mapping (`-p`), detached mode (`-d`), `--name`, `docker rm -f` |
| **04** | **Volume Mounting** | [`volume_mounting/`](volume_mounting/) | Container ephemerality, directory & file mounting (`-v`), missing file caveats |
| **05** | **NGINX Web Demo** | [`NGINX_demo/`](NGINX_demo/) | Serving static sites, live asset reloading via volumes, auto-cleanup (`--rm`) |

---

## 📚 Module Deep-Dives

### 1. Docker Basics & First Image
* **Directory**: [`docker_basics/`](docker_basics/)
* **Files**: [Dockerfile](docker_basics/Dockerfile), [entrypoint.bash](docker_basics/entrypoint.bash)
* **Key Concepts**:
  * `FROM ubuntu`: Bases the image on Ubuntu pulled from Docker Hub.
  * `USER root` vs `USER nobody`: Shifts execution from root to an unprivileged user before starting the container to prevent potential container breakout exploits.
  * `COPY ./entrypoint.bash /`: Injects files from the build context into the image layer.
  * `RUN apt -y update && apt -y install curl bash`: Executes layer installation commands during image build.
  * `ENTRYPOINT [ "/entrypoint.bash" ]`: Defines the default executable when launching a container.
* **Commands**:
  ```bash
  # Build image
  docker build -t docker-basics ./docker_basics

  # Run container
  docker run --rm docker-basics
  ```

---

### 2. Simple Background Service
* **Directory**: [`simple_server_example/`](simple_server_example/)
* **Files**: [server.Dockerfile](simple_server_example/server.Dockerfile), [server.bash](simple_server_example/server.bash)
* **Key Concepts**:
  * Running daemon/loop processes inside a container.
  * Using the `-f` flag to target custom Dockerfile filenames instead of the default `Dockerfile`.
* **Commands**:
  ```bash
  # Build using custom Dockerfile name
  docker build -t simple-server -f simple_server_example/server.Dockerfile ./simple_server_example

  # Run interactively
  docker run --rm simple-server
  ```

---

### 3. Port Binding & Container Management
* **Directory**: [`binding_ports_to_contaner/`](binding_ports_to_contaner/)
* **Files**: [NOTE.md](binding_ports_to_contaner/NOTE.md), [web-server.Dockerfile](binding_ports_to_contaner/web-server.Dockerfile), [web-server.bash](binding_ports_to_contaner/web-server.bash)
* **Key Concepts**:
  * **Isolation**: Container networks are isolated by default; external traffic cannot reach internal ports unless explicitly mapped.
  * **The Mnemonic Rule**:
    $$\text{Port Binding Format: } \texttt{-p <Outside>:<Inside>}$$
    * **Outside**: Port exposed on host machine (`localhost`).
    * **Inside**: Port listened to by service inside container.
  * **Container Management**: Giving friendly identifiers with `--name` allows targeted logging (`docker logs`) and instant stopping/removal (`docker rm -f`).
* **Commands**:
  ```bash
  # Build
  docker build -t our-web-server -f binding_ports_to_contaner/web-server.Dockerfile ./binding_ports_to_contaner

  # Run detached with port binding
  docker run -d --name our-web-server -p 5001:5000 our-web-server

  # Inspect ports and logs
  docker ps
  docker logs our-web-server

  # Stop and remove immediately
  docker rm -f our-web-server
  ```

---

### 4. Volume Mounting & Ephemeral Storage
* **Directory**: [`volume_mounting/`](volume_mounting/)
* **Files**: [NOTE.md](volume_mounting/NOTE.md), [web-server.Dockerfile](volume_mounting/web-server.Dockerfile), [web-server.bash](volume_mounting/web-server.bash)
* **Key Concepts**:
  * **Ephemerality**: Container file systems are destroyed when the container stops or is removed.
  * **The Mnemonic Rule**:
    $$\text{Volume Mounting Format: } \texttt{-v <Outside>:<Inside>}$$
    * **Outside**: Path on host machine.
    * **Inside**: Path inside the container filesystem.
  * **Important Caveat**: If you mount a host file that **does not exist**, Docker creates a **directory** at that path instead of a file, causing write errors inside the container.
* **Commands**:
  ```bash
  # Persist container data to host directory
  docker run --rm -v /tmp/container:/tmp --entrypoint sh ubuntu -c "echo 'Hello there.' > /tmp/file"

  # Verify persistence on host
  cat /tmp/container/file
  ```

---

### 5. Practical NGINX Web Server Demo
* **Directory**: [`NGINX_demo/`](NGINX_demo/)
* **Files**: [NGINX_EXPLAINED.md](NGINX_demo/NGINX_EXPLAINED.md), [website/index.html](NGINX_demo/website/index.html)
* **Key Concepts**:
  * Mounting host files directly into NGINX default document root: `/usr/share/nginx/html`.
  * Live updates: Changes to host HTML/CSS/JS files immediately reflect in the running container without rebuilding.
  * Relative asset paths (`/css/...`, `/js/...`): Ensure assets load accurately regardless of which host port is mapped.
* **Commands**:
  ```bash
  # Run NGINX hosting local static site
  cd NGINX_demo
  docker run --name website -v $PWD/website:/usr/share/nginx/html -p 8081:80 --rm nginx
  ```

---

## ⚡ Essential Docker Command Cheat Sheet

| Task | Command | Description |
|---|---|---|
| **Build (Default)** | `docker build -t <tag> .` | Build image from `Dockerfile` in current context |
| **Build (Custom File)** | `docker build -t <tag> -f <filename> .` | Build image using specific Dockerfile name |
| **Run Detached + Port** | `docker run -d --name <name> -p <host>:<cont> <tag>` | Start background container with mapped port |
| **Run with Volume** | `docker run --rm -v <host_path>:<cont_path> <tag>` | Mount storage; auto-delete container on exit |
| **List Running** | `docker ps` | View running containers and port mappings |
| **List All** | `docker ps -a` | View all containers (including stopped) |
| **View Logs** | `docker logs -f <name>` | Follow live log output of named container |
| **Stop Container** | `docker stop <name>` | Gracefully send SIGTERM to container process |
| **Force Clean** | `docker rm -f <name>` | Force stop and remove container in one command |

### Common Flags Reference
- `-d`: Detached mode (runs container asynchronously in background).
- `-p <host>:<container>`: Publish container's port(s) to host interface.
- `-v <host>:<container>`: Bind mount a volume.
- `--name <name>`: Assign a custom identifier to the container.
- `--rm`: Automatically remove container upon process exit.
- `-f`: Specify alternate file (during `build`) or force operation (during `rm`).
