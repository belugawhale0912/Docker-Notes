```markdown
# Docker Volume Mount Command Breakdown

## Command

```bash
docker run --rm --entrypoint sh -v "$PWD/container:/tmp" ubuntu -c "echo 'Hello There.' > /tmp/file && cat /tmp/file"

```

---

## Breakdown

* **`docker run`**: Spawns and starts a new container instance.
* **`--rm`**: Automatically removes the container file system when the container exits to prevent clutter.
* **`--entrypoint sh`**: Overrides the default entrypoint of the `ubuntu` image, forcing it to run the Bourne shell (`sh`).
* **`-v "$PWD/container:/tmp"`**: Mounts a host directory to a container directory (Bind Mount).
* **`$PWD/container`**: Resolves to the absolute path of the `container` directory in your current working directory on the host machine.
* **`/tmp`**: The target path inside the container where the host directory is mounted.


* **`ubuntu`**: The official Ubuntu Docker image used to construct the container.
* **`-c "..."`**: Instructs `sh` to execute the string argument as a shell script:
* **`echo 'Hello There.' > /tmp/file`**: Creates/overwrites `/tmp/file` inside the container with the text `'Hello There.'` (which persists in `$PWD/container/file` on your host).
* **`&&`**: Executes the following command only if the previous command exits successfully.
* **`cat /tmp/file`**: Reads and displays the contents of `/tmp/file` to standard output.



