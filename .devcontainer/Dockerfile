FROM python:3.14-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    USER=compiler \
    USER_UID=1000 \
    USER_GID=1000

# Install system dependencies and patch OS packages to reduce known vulnerabilities
# using the archives and lists cache
RUN --mount=type=cache,id=apt-archives,sharing=locked,target=/var/cache/apt/archives \
    --mount=type=cache,id=apt-lists,sharing=locked,target=/var/lib/apt/lists \
    apt-get update && apt-get upgrade -y --no-install-recommends && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    lsb-release \
    make \
    postgresql-client \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Terraform
ARG TERRAFORM_VERSION="1.16.6"
RUN ARCH="$(dpkg --print-architecture)" && \
    curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" -o /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm /tmp/terraform.zip && \
    chmod +x /usr/local/bin/terraform

# Install Google Cloud CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt-get update && apt-get install -y --no-install-recommends \
    google-cloud-cli \
    && rm -rf /var/lib/apt/lists/*

# Create $USER and home directory
RUN useradd --create-home --shell /bin/bash $USER && \
    chown -R $USER /home/$USER

# Switch to non-root $USER
USER $USER

# Enter src directory
WORKDIR /home/$USER/src

# Update PATH for local pip installs
ENV PATH="$PATH:/home/$USER/.local/bin" \
    # update env for local pip installs
    # see https://docs.python.org/3/using/cmdline.html#envvar-PYTHONUSERBASE
    # since all `pip install` commands are in the context of $USER
    # $PYTHONUSERBASE is the location used by default
    PYTHONUSERBASE="/home/${USER}/.local" \
    # where to store the pip cache (use the default)
    # https://pip.pypa.io/en/stable/cli/pip/#cmdoption-cache-dir
    PIP_CACHE_DIR="/home/${USER}/.cache/pip"

COPY docs/requirements.txt docs/requirements.txt

# Update pip and install Python tooling
RUN --mount=type=cache,id=pipcache,target=${PIP_CACHE_DIR},uid=${USER_UID},gid=${USER_GID} \
    python -m pip install --user --upgrade pip && \
    python -m pip install --user pre-commit && \
    python -m pip install --user -r docs/requirements.txt
