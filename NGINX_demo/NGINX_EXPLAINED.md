# 🐳 Docker + NGINX: Command Breakdown & How It Works

---

## The Command

```sh
docker run --name website -v $PWD/website:/usr/share/nginx/html -p 8081:80 --rm nginx
```

---

## 🔍 Flag-by-Flag Breakdown

| Flag / Argument | What it does |
|---|---|
| `docker run` | Creates and starts a new container |
| `--name website` | Names the container `website` (instead of a random name) |
| `-v $PWD/website:/usr/share/nginx/html` | **Volume mount** — links a local folder into the container |
| `-p 8081:80` | **Port mapping** — exposes the container's port to your machine |
| `--rm` | **Auto-remove** — deletes the container when it stops |
| `nginx` | The Docker image to use (pulled from Docker Hub if not cached) |

---

## 📂 The Volume Mount: `-v $PWD/website:/usr/share/nginx/html`

This is the most important flag. It has two parts separated by `:`:

```
-v <host path>:<container path>
    │                │
    │                └── Where NGINX looks for files INSIDE the container
    └── Your local folder on YOUR machine
```

| Side | Path | Meaning |
|---|---|---|
| **Host** (your machine) | `$PWD/website` | The `website/` folder in your current directory |
| **Container** (NGINX) | `/usr/share/nginx/html` | NGINX's default web root — where it serves files from |

> [!NOTE]
> `$PWD` is a shell variable meaning "Print Working Directory" — i.e., wherever your terminal currently is.
> So if you're in `/home/user/Docker-Notes/NGINX_demo`, the full path becomes `/home/user/Docker-Notes/NGINX_demo/website`.

**The result:** Any file you put in your local `website/` folder is **instantly visible** to NGINX inside the container — no rebuild needed. Changes are reflected live.

---

## 🔌 Port Mapping: `-p 8081:80`

Docker containers are **isolated** — their ports are not accessible from outside by default.
The `-p` flag punches a hole through that isolation:

```
Your Browser  ──►  localhost:8081  ──►  Container port 80  ──►  NGINX
                   (your machine)        (inside Docker)
```

| Port | Who owns it | Purpose |
|---|---|---|
| `8081` | **Your machine** | What you type in the browser (`http://localhost:8081`) |
| `80` | **The container** | Where NGINX listens by default (standard HTTP port) |

> [!IMPORTANT]
> The format is always `-p <HOST_PORT>:<CONTAINER_PORT>`.
> The **left** side is what you access from your browser.
> The **right** side is what the app listens on inside Docker.

You can change the host port freely (e.g. `-p 3000:80`, `-p 9090:80`), but the container port `80` is fixed to what NGINX listens on.

---

## 🗑️ Auto-Remove: `--rm`

Without `--rm`, stopped containers linger on your system and take up disk space. The `--rm` flag tells Docker:

> "When this container exits, delete it automatically."

Useful for development/testing. If you want to **inspect logs after it stops**, omit `--rm` and use `docker rm website` manually later.

---

## 🏷️ Naming: `--name website`

Without this flag, Docker assigns a random name like `quirky_turing` or `epic_lovelace`.

Naming the container lets you reference it easily:

```sh
docker stop website      # Stop it
docker logs website      # View logs
docker exec -it website sh  # Open a shell inside it
```

---

## 🌐 How NGINX Hosting Works

NGINX is a **web server** — its job is to listen for HTTP requests and respond with files.

```
                        ┌─────────────────────────────────┐
                        │         NGINX Container          │
                        │                                  │
Browser ──► :8081 ──►  :80 ──► NGINX process              │
                        │          │                       │
                        │          ▼                       │
                        │  /usr/share/nginx/html/          │
                        │  ├── index.html   ◄── serves /  │
                        │  ├── 404.html                   │
                        │  ├── css/                       │
                        │  │   └── bundle.min.css         │
                        │  └── js/                        │
                        │      └── bundle.min.js          │
                        └─────────────────────────────────┘
```

### Request Flow

1. You open `http://localhost:8081` in your browser
2. The OS routes port `8081` → Docker's port mapping → container port `80`
3. NGINX receives the request for `/`
4. NGINX looks in its **web root** (`/usr/share/nginx/html/`) for `index.html`
5. It reads the file and sends it back as an HTTP response
6. Your browser parses the HTML, then makes **more requests** for CSS and JS files
7. NGINX serves those too from the same web root

### Why Relative Paths Matter

When your browser loads `index.html` and encounters:

```html
<!-- ❌ Hardcoded — breaks if port changes -->
<link rel="stylesheet" href="http://localhost:8080/css/bundle.min.css">

<!-- ✅ Relative — always works -->
<link rel="stylesheet" href="/css/bundle.min.css">
```

A relative path like `/css/bundle.min.css` means:
> "Fetch from the **same host and port** the page was loaded from."

So it automatically resolves to `http://localhost:8081/css/bundle.min.css` — correct every time, regardless of the port.

---

## 🔄 Full Lifecycle Summary

```
docker run ...
    │
    ├── 1. Pull `nginx` image from Docker Hub (if not cached)
    ├── 2. Create a new container named `website`
    ├── 3. Mount your local `website/` → container's `/usr/share/nginx/html`
    ├── 4. Map host port 8081 → container port 80
    ├── 5. Start NGINX inside the container
    │        └── NGINX begins listening on port 80
    │
    │   [You browse http://localhost:8081 — NGINX serves your files]
    │
    └── 6. When you Ctrl+C / stop the container:
             └── --rm → container is automatically deleted
```

---

## 📝 Quick Reference

```sh
# Run the container
docker run --name website -v $PWD/website:/usr/share/nginx/html -p 8081:80 --rm nginx

# Stop it (from another terminal)
docker stop website

# See running containers
docker ps

# See ALL containers (including stopped, if you omitted --rm)
docker ps -a
```
