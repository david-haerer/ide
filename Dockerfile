FROM archlinux:latest
ARG DOCKER_VERSION=29.6.2
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >/etc/timezone
RUN sed -i 's/^#DisableSandbox/DisableSandbox/' /etc/pacman.conf
RUN pacman -Syu --noconfirm \
    7zip \
    base-devel \
    bash-language-server \
    bat \
    btop \
    bun \
    debugedit \
    diffnav \
    docker \
    docker-compose \
    eslint-language-server \
    eza \
    fakeroot \
    fastfetch \
    fd \
    ffmpeg \
    fish \
    fzf \
    git \
    git-delta \
    github-cli \
    go \
    hcloud \
    helix \
    imagemagick \
    inetutils \
    jq \
    kubectl \
    lazydocker \
    lazygit \
    less \
    lilypond \
    man \
    marksman \
    nmap \
    opencode \
    opentofu \
    openvpn \
    pandoc \
    poppler \
    reflector \
    resvg \
    ripgrep \
    rsync \
    rustup \
    shellcheck \
    shfmt \
    starship \
    sudo \
    talosctl \
    taplo \
    tectonic \
    the_silver_searcher \
    tombi \
    typescript-language-server \
    wget \
    tzdata \
    uv \
    yazi \
    zig \
    zoxide \
    && pacman -R docker --noconfirm \
    && pacman -Scc --noconfirm \
    && reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
RUN curl -fsSL "https://download.docker.com/linux/static/stable/aarch64/docker-${DOCKER_VERSION}.tgz" \
    | tar xz --strip-components=1 -C /usr/bin/ \
    && mkdir -p /etc/docker && echo '{"storage-driver": "vfs"}' >/etc/docker/daemon.json
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -G docker -m -s /usr/bin/fish $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/$USERNAME
USER $USERNAME
WORKDIR /home/$USERNAME
ENV COLORTERM="truecolor"
ENV EDITOR="helix"
ENV PATH="/home/$USERNAME/bin:/home/$USERNAME/.local/bin:$PATH"
COPY --chown=$USERNAME:$USERNAME config/fish /home/$USERNAME/.config/fish
COPY --chown=$USERNAME:$USERNAME config/git /home/$USERNAME/.config/git
COPY --chown=$USERNAME:$USERNAME config/helix /home/$USERNAME/.config/helix
COPY --chown=$USERNAME:$USERNAME config/lazydocker /home/$USERNAME/.config/lazydocker
COPY --chown=$USERNAME:$USERNAME config/lazygit /home/$USERNAME/.config/lazygit
COPY --chown=$USERNAME:$USERNAME config/opencode /home/$USERNAME/.config/opencode
COPY --chown=$USERNAME:$USERNAME config/starship.toml /home/$USERNAME/.config/starship.toml
COPY --chown=$USERNAME:$USERNAME --chmod=755 bin/entrypoint /home/$USERNAME/.local/bin/entrypoint
COPY --chown=$USERNAME:$USERNAME --chmod=755 bin/note /home/$USERNAME/.local/bin/note
COPY --chown=$USERNAME:$USERNAME --chmod=755 bin/year /home/$USERNAME/.local/bin/year
RUN helix --grammar fetch \
    && helix --grammar build \
    && mkdir /home/$USERNAME/.config/helix/runtime/queries \
    && cp -r /home/$USERNAME/.config/helix/runtime/grammars/sources/lilypond/queries /home/$USERNAME/.config/helix/runtime/queries/lilypond
RUN rustup default stable
RUN uv tool install poetry \
    && uv tool install python-ly
RUN go install github.com/reteps/dockerfmt@latest
RUN bun add -g --ignore-scripts @earendil-works/pi-coding-agent \
    && bun add -g --ignore-scripts @devcontainers/cli \
    && bun add -g --ignore-scripts @devcontainers/cli \
    && bun add -g --ignore-scripts @oh-my-pi/pi-coding-agent
ENTRYPOINT ["entrypoint"]
CMD ["tail", "-f", "/dev/null"]