# docker-urbanopt

Docker container for URBANopt CLI 1.1.0 on Ubuntu 22.04.

## Overview

This repository contains a Dockerfile that builds a Docker container with URBANopt CLI 1.1.0 installed on Ubuntu 22.04. The container is automatically built, tested, and pushed to Docker Hub via GitHub Actions.

## Features

- **URBANopt CLI 1.1.0**: Pre-installed and configured
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
docker build -t docker-urbanopt:x86_64 .

# Build for arm64
docker build --build-arg UO_ARCH=arm64 -t docker-urbanopt:arm64 .
```

## License

See the URBANopt CLI license for details.