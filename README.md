# docker-urbanopt

Docker container for URBANopt CLI on Ubuntu 22.04.

## Overview

This repository contains a Dockerfile that builds a Docker container with URBANopt CLI installed on Ubuntu 22.04. The container is automatically built, tested, and pushed to Docker Hub via GitHub Actions.

## Features

- **URBANopt CLI**: Pre-installed and configured
- **Ubuntu 22.04**: Base image with all required dependencies
- **Automated CI/CD**: GitHub Actions workflow for building, testing, and publishing
- **Versioning**: Automatic semantic versioning via Git tags

## Usage

### Pull from Docker Hub

```bash
docker pull nrel/docker-urbanopt:latest
```

### Run the Container

```bash
# Run with default command (shows version)
docker run --rm nrel/docker-urbanopt:latest

# Run interactively
docker run -it --rm nrel/docker-urbanopt:latest bash

# Run with a mounted workspace
docker run -it --rm -v $(pwd):/work nrel/docker-urbanopt:latest
```

### Build Locally

```bash
docker build -t docker-urbanopt:latest .
```

# Running on the Cloud

### Option 1: Docker-Based URBANopt Execution

For a single-server cloud deployment (for example, an AWS EC2 instance), the simplest and most reproducible approach is to run **URBANopt inside a Docker container**. This avoids installing URBANopt directly on the cloud instance and makes upgrades, rollbacks, and environment consistency as simple as changing the container tag.

In this workflow, URBANopt runs entirely inside a container, while project files and simulation outputs live on the host filesystem.

**URBANopt CLI commands and workflows are unchanged.** You will still use familiar commands such as `uo create`, `uo run`, `uo process`, and related workflows — the only difference is that these commands are executed inside the container rather than directly on the host operating system.

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
In this example, we assume that the :

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
- `nrel/docker-urbanopt:1.1.0` is the Docker image containing UrbanOpt version 1.1.0 and its dependencies.
- `uo run` invokes the UrbanOpt CLI inside the container.
- `-f example_uo/example_project.json` specifies the UrbanOpt project definition file.
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

## Running Locally on Windows (Docker Desktop)

The same container can be used on Windows with Docker Desktop:

```
docker run --rm -it ^
  -v "C://path//to//urbanopt-project://work" ^
  nrel/docker-urbanopt:1.1.0 ^
  uo run -f example_uo/example_project.json ^
         -s example_uo/baseline_scenario.csv
```

Ensure Docker Desktop is configured with enough CPUs to match `num_parallel`.


## GitHub Actions Workflow

The repository includes a GitHub Actions workflow that:

1. **Builds** the Docker container
2. **Tests** the container by running `uo --version`
3. **Pushes** to Docker Hub with appropriate tags:
   - `latest` - for commits to main/master branch
   - `<branch>` - for branch commits
   - `v1.0.0`, `v1.0`, `v1` - for semantic version tags
   - `<branch>-<sha>` - for commit SHA references

### Docker Hub Configuration

To enable automatic pushing to Docker Hub, configure the following repository secrets:

1. Go to your repository **Settings** → **Secrets and variables** → **Actions**
2. Click **"New repository secret"**
3. Add the following secrets:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub password or access token

### Versioning

To create a new versioned release:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

## Architecture Support

The Dockerfile supports both x86_64 (default) and arm64 architectures. To build for a specific architecture, use the `UO_ARCH` build argument:

```bash
# Build for x86_64 (default)
docker build -t urbanopt-cloud:x86_64 .

# Build for arm64
docker build --build-arg UO_ARCH=arm64 -t urbanopt-cloud:arm64 .
```

## License

See the URBANopt CLI license for details.
