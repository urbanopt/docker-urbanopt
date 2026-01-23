# URBANopt CLI 1.1.0 (installer-based) on Ubuntu 22.04
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Set to either: x86_64 or arm64
ARG UO_ARCH=x86_64

# URBANopt CLI 1.1.0 release details
ARG UO_VERSION=1.1.0
ARG UO_BUILD=117bfcec1a

# Runtime deps (OpenStudio/E+ often need X/GL libs even headless)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl bash unzip zip git \
    libx11-6 libgl1 libxt6 libxext6 libxrender1 libxi6 \
 && rm -rf /var/lib/apt/lists/*

# Download + install URBANopt CLI .deb
RUN set -eux; \
    DEB="URBANoptCLI-${UO_VERSION}.${UO_BUILD}-Ubuntu-22.04-${UO_ARCH}.deb"; \
    URL="https://github.com/urbanopt/urbanopt-cli/releases/download/v${UO_VERSION}/${DEB}"; \
    echo "Downloading ${URL}"; \
    curl -fL "${URL}" -o /tmp/urbanopt.deb; \
    apt-get update; \
    apt-get install -y /tmp/urbanopt.deb; \
    rm -f /tmp/urbanopt.deb; \
    rm -rf /var/lib/apt/lists/*

# Generate the env file (~/.env_uo.sh) in the image
RUN /usr/local/urbanopt-cli-${UO_VERSION}/setup-env.sh

# Provide Ruby globally (helps non-shell invocations that need /usr/bin/env ruby)
RUN ln -sf /usr/local/urbanopt-cli-${UO_VERSION}/ruby/bin/ruby /usr/local/bin/ruby 
# symlink ruby
RUN ln -sf /usr/local/urbanopt-cli-${UO_VERSION}/ruby/bin/ruby  /usr/local/urbanopt-cli-${UO_VERSION}/gems/ruby/3.2.0/bin/ruby


# Robust `uo` wrapper: always sources ~/.env_uo.sh then runs the real uo
RUN set -eux; \
  UO_ROOT="/usr/local/urbanopt-cli-${UO_VERSION}"; \
  UO_REAL="${UO_ROOT}/gems/ruby/3.2.0/bin/uo"; \
  { \
    printf '%s\n' '#!/usr/bin/env bash'; \
    printf '%s\n' 'set -euo pipefail'; \
    printf '%s\n' ''; \
    printf '%s\n' "${UO_ROOT}/setup-env.sh >/dev/null 2>&1 || true"; \
    printf '%s\n' 'if [ -f "$HOME/.env_uo.sh" ]; then'; \
    printf '%s\n' '  . "$HOME/.env_uo.sh"'; \
    printf '%s\n' 'fi'; \
    printf '%s\n' "exec ${UO_REAL} \"\$@\""; \
  } > /usr/local/bin/uo; \
  chmod +x /usr/local/bin/uo

# Convenience for interactive shells
RUN printf '%s\n' \
  'if [ -f "$HOME/.env_uo.sh" ]; then . "$HOME/.env_uo.sh"; fi' \
  > /etc/profile.d/urbanopt.sh \
 && printf '\n# URBANopt\nif [ -f "$HOME/.env_uo.sh" ]; then . "$HOME/.env_uo.sh"; fi\n' \
  >> /etc/bash.bashrc

WORKDIR /work

CMD ["uo", "--version"]
