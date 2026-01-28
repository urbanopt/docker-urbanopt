# Running on the Cloud

### Option 1: Docker-Based URBANopt Execution

For a single-server cloud deployment (for example, an AWS EC2 instance), the simplest and most reproducible approach is to run **URBANopt inside a Docker container**. This avoids installing URBANopt directly on the cloud instance and makes upgrades, rollbacks, and environment consistency as simple as changing the container tag.

In this workflow, URBANopt runs entirely inside a container, while project files and simulation outputs live on the host filesystem.

**URBANopt CLI commands and workflows are unchanged.** You will still use familiar commands such as `uo create`, `uo run`, `uo process`, and related workflows — the only difference is that these commands are executed inside the container rather than directly on the host operating system.

> **Note on cloud costs**
>
> URBANopt simulations can be CPU- and disk-intensive. Be sure to stop or terminate cloud instances when simulations complete to avoid unnecessary charges.

---

## Step 1: Launch a Cloud Instance

Launch a Linux-based instance on your preferred cloud platform:

- AWS EC2  
- Azure Virtual Machines  
- Google Compute Engine  
- On-premise or HPC cloud nodes  

**Recommended configuration**
- Ubuntu 22.04 LTS  
- Adequate CPUs for parallel simulations  
- Sufficient disk space for OpenStudio/EnergyPlus outputs  

---

## Step 2: Connect via SSH

Once the instance is running, get its IP address and connect a terminal to it using SSH:

```
ssh user@your-instance-ip
```

**All remaining steps are performed inside this SSH session.**

---

## Step 3: Install Docker

Most cloud instances do **not** include Docker by default, so make sure that it is installed so you can run the URBANopt docker container.

On Ubuntu 22.04:

```
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
```

To allow running Docker without `sudo`, add your user to the `docker` group:

```
sudo usermod -aG docker $USER
newgrp docker
```

Log out and back in if Docker commands still require `sudo`.

Managed container services (AWS ECS, AWS Batch, Kubernetes) already include Docker and do not require this step.

---

## Step 4: Obtain Your URBANopt Project Files

This guide assumes your URBANopt project is stored in a Git repository and can be cloned onto the instance:

```
git clone https://github.com/your-org/your-urbanopt-project.git
cd your-urbanopt-project
```

Other transfer methods (for example, SCP, rsync, or cloud storage downloads) may also be used.

---

## Step 5: Pull the URBANopt Docker Image

URBANopt is provided as a prebuilt Docker image on [Docker Hub](https://hub.docker.com/r/nrel/docker-urbanopt).
For example, version 1.1.0 is named:

```
nrel/docker-urbanopt:1.1.0
```

To pull the URBANopt 1.1.0 image locally to the instance, execute the following command:

```
docker pull nrel/docker-urbanopt:1.1.0
```

---

## Step 6: Run URBANopt Using Docker

Run the URBANopt container and mount the project directory into the container, so that URBANopt CLI has access to the project files.

```
docker run --rm -it \
  -v "$(pwd):/work" \
  nrel/docker-urbanopt:1.1.0 \
  uo run -f example_uo/example_project.json \
         -s example_uo/baseline_scenario.csv
```

### Notes

- `docker run` starts a new container from a Docker image.
- `--rm` automatically removes the container after it exits (optional).
- `-it` runs the container in interactive mode with a TTY attached.
- `-v "$(pwd):/work"` mounts the current host directory into the container at `/work`.
- `nrel/docker-urbanopt:1.1.0` is the Docker image containing URBANopt version 1.1.0 and its dependencies.
- `uo run` invokes the URBANopt CLI inside the container.
- `-f example_uo/example_project.json` specifies the URBANopt project definition file.
- `-s example_uo/baseline_scenario.csv` specifies the scenario CSV used for the run.
- `example_project.json` and `baseline_scenario.csv` are **example files provided by URBANopt**
- User projects will typically use different filenames
- URBANopt CLI usage and workflows are unchanged from a native installation
---

## Simulation Outputs

Because the project directory is mounted into the container, **all outputs are written directly to the host filesystem**.


For example:

```
/work/example_uo/run/
```

maps to:

```
your-urbanopt-project/example_uo/run/
```

No results are stored only inside the container.

---

## Parallel Execution

The number of parallel URBANopt simulations is controlled in project config file `runner.conf`:

```
num_parallel = 10
```

The container uses the CPUs available on the host VM. No special Docker configuration is required on Linux-based cloud instances.

---
---

## Troubleshooting and Monitoring

- Use `docker logs <container-id>` to inspect container output if running without `-it`.
- Check `example_uo/run/logs/` for OpenStudio and EnergyPlus logs.
- Monitor CPU and memory usage on the VM during large runs to ensure adequate resources.
