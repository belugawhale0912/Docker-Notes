# Summary: Docker Port Binding & Container Management

## 1. Key Concept: Port Binding
By default, network ports inside a Docker container are isolated from your host machine. **Port binding** maps a port on your host machine to a port inside the container, enabling you to access containerized web services through your host browser (e.g., via `localhost`).

### The Mnemonic Rule
$$\text{Port Binding Format: } \texttt{-p <Outside>:<Inside>}$$

* **Outside:** Port on your host machine (your computer).
* **Inside:** Port exposed within the Docker container.

---

## 2. Step-by-Step Command Workflow

### Step 1: Build Image with Custom Dockerfile
Build an image using a specific Dockerfile other than the default `Dockerfile`:
```bash
docker build -t our-web-server -f web-server.Dockerfile .
```
* `-t`: Tags/names the image (`our-web-server`).
* `-f`: Specifies the file path/name (`web-server.Dockerfile`).
* `.`: Designates the current working directory as the build context.

---

### Step 2: Stop and Force Remove Existing Containers
To clean up running containers in a single command without running `docker stop` followed by `docker rm`:
```bash
docker rm -f our-web-server
```
* `-f` (*force*): Immediately stops and removes the running container by name.

---

### Step 3: Run Container with Port Binding & Custom Name
Start the container in the background with explicit port mapping and a friendly name:
```bash
docker run -d --name our-web-server -p 5001:5000 our-web-server
```
* `-d`: Runs the container detached in the background.
* `--name`: Assigns a custom name (`our-web-server`) to refer to the container instead of its random ID.
* `-p 5001:5000`: Maps host port `5001` to container port `5000`.

---

### Step 4: Verification and Logging
* **Check Running Containers & Port Mappings:**
  ```bash
  docker ps
  ```
  *Look at the `PORTS` column to verify mapping details (e.g., `0.0.0.0:5001->5000/tcp`).*

* **View Logs by Container Name:**
  ```bash
  docker logs our-web-server
  ```

---

## 3. Key Takeaways
1. **Host Isolation:** Simply running a web server inside a container is not enough; you must map the port to access it externally.
2. **Container Naming:** Using `--name` simplifies container management, allowing commands like `docker logs` and `docker rm` to target human-readable names instead of hashes.
3. **Combined Cleanup:** The `-f` flag on `docker rm` saves time by combining the stopping and deletion steps into one action.