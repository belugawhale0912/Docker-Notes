# Summary: Docker Volume Mounting & Ephemeral Storage

## 1. Key Concept: Volume Mounting

Containers are inherently **ephemeral**—when a container is stopped or removed, any data created or saved inside it is permanently lost. Docker solves this using **Volume Mounting**, which links paths on your host machine to paths inside the container.

### The Mnemonic Rule

$$
\text{Volume Mounting Format: } \texttt{-v <Outside>:<Inside>}
$$

* **Outside:** File or directory path on your host machine (your computer).

* **Inside:** File or directory path inside the Docker container.

---

## 2. Step-by-Step Command Workflow

### Step 1: Demonstrating Container Data Ephemerality

Without volume mounting, data created inside a container vanishes when the container exits:

```
docker run --rm --entrypoint sh ubuntu -c "echo 'Hello there.' > /tmp/file && cat /tmp/file"

```

* `--rm`: Automatically removes the container when it exits.

* `--entrypoint sh`: Overrides the default entrypoint to run a shell command.

* *Result:* The file `/tmp/file` is printed to standard output, but trying to read `/tmp/file` on the host machine fails because the file was destroyed along with the container.

### Step 2: Directory Volume Mounting

To persist files generated inside a container onto your host machine, map a host directory to a container directory:

```
docker run --rm -v /tmp/container:/tmp --entrypoint sh ubuntu -c "echo 'Hello there.' > /tmp/file"

```

* `-v /tmp/container:/tmp`: Maps host directory `/tmp/container` to container directory `/tmp`.

* **Verification on Host:**

  ```
  cat /tmp/container/file
  
  ```

  *Output:* `Hello there.`

### Step 3: File Volume Mounting

You can also map an individual existing file on your host to a file path inside the container:

```
# 1. Create the host file first
touch /tmp/change_this_file

# 2. Map the existing host file to the container file path
docker run --rm -v /tmp/change_this_file:/tmp/file --entrypoint sh ubuntu -c "echo 'Hello there.' > /tmp/file"

# 3. Verify changes on host
cat /tmp/change_this_file

```

* *Output:* `Hello there.`

---

## 3. Important Caveat: Non-Existent File Mounting

If you attempt to use `-v` to map a host **file** path that **does not exist**, Docker will assume it is a directory and automatically create a **directory** at that path on both the host and inside the container.

```
# Attempting to mount a non-existent host file:
docker run --rm -v /tmp/this_file_does_not_exist:/tmp/file --entrypoint sh ubuntu -c "echo 'Hello there.' > /tmp/file"

```

### Consequences:
1. Docker creates `/tmp/this_file_does_not_exist/` as a **directory** on your host machine.
2. Inside the container, `/tmp/file` becomes a **directory** instead of a regular file.
3. Command execution fails with a shell error because commands like `echo ... > /tmp/file` cannot overwrite a directory as if it were a file.

> **Rule of Thumb:** Always ensure host files exist (e.g., using `touch`) *before* mounting them as individual files using `-v`.