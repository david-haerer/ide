FROM archlinux:latest
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >/etc/timezone
RUN sed -i 's/^#DisableSandbox/DisableSandbox/' /etc/pacman.conf
RUN pacman -Syu --noconfirm \
    7zip \
    azure-cli \
    base-devel \
    bash-language-server \
    bat \
    bind \
    btop \
    bun \
    debugedit \
    diffnav \
    docker-compose \
    eslint-language-server \
    eza \
    fakeroot \
    fastfetch \
    fd \
    ffmpeg \
    fish \
    fluxcd \
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
    openai-codex \
    opentofu \
    openvpn \
    pandoc \
    podman \
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
    tzdata \
    uv \
    wget \
    yazi \
    zig \
    zoxide \
    && pacman -Scc --noconfirm \
    && reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
ENV CONTAINER_HOST=unix:///run/podman/podman.sock
ARG HERDR_CACHE_BUST=1
RUN set -eux; \
    url="$(curl -fsSL https://api.github.com/repos/herdrdev/herdr/releases/latest \
        | jq -r '.assets[] | select(.name == "herdr-linux-x86_64") | .browser_download_url')"; \
    curl -fsSL "$url" -o /usr/local/bin/herdr; \
    chmod 755 /usr/local/bin/herdr
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /usr/bin/fish $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/$USERNAME
USER $USERNAME
WORKDIR /home/$USERNAME
ENV SHELL=/usr/bin/fish
ENV COLORTERM="truecolor"
ENV EDITOR="helix"
ENV DISABLE_TELEMETRY="1"
ENV PATH="/home/$USERNAME/bin:/home/$USERNAME/.local/bin:$PATH"
COPY --chown=$USERNAME:$USERNAME config/fish /home/$USERNAME/.config/fish
COPY --chown=$USERNAME:$USERNAME config/git /home/$USERNAME/.config/git
COPY --chown=$USERNAME:$USERNAME config/helix /home/$USERNAME/.config/helix
COPY --chown=$USERNAME:$USERNAME config/lazydocker /home/$USERNAME/.config/lazydocker
COPY --chown=$USERNAME:$USERNAME config/lazygit /home/$USERNAME/.config/lazygit
COPY --chown=$USERNAME:$USERNAME config/omp /home/$USERNAME/.omp
COPY --chown=$USERNAME:$USERNAME config/starship.toml /home/$USERNAME/.config/starship.toml
COPY --chown=$USERNAME:$USERNAME --chmod=755 bin/entrypoint /home/$USERNAME/.local/bin/entrypoint
COPY --chown=$USERNAME:$USERNAME --chmod=755 bin/note /home/$USERNAME/.local/bin/note
COPY --chown=$USERNAME:$USERNAME --chmod=755 bin/year /home/$USERNAME/.local/bin/year
COPY --chown=$USERNAME:$USERNAME --chmod=755 bin/arbeitszeit /home/$USERNAME/.local/bin/arbeitszeit
ARG SKILLS_CACHE_BUST=1
RUN set -eux; \
    base=https://github.com/mattpocock/skills/tree/main/skills; \
    bunx skills add "$base/engineering/domain-modeling" -g -a cline -y; \
    bunx skills add "$base/engineering/grill-with-docs" -g -a cline -y; \
    bunx skills add "$base/productivity/grilling" -g -a cline -y; \
    bunx skills add "$base/productivity/to-questionnaire" -g -a cline -y; \
    pstack=https://github.com/cursor/plugins/tree/main/pstack/skills; \
    bunx skills add "$pstack/unslop" -g -a cline -y; \
    bunx skills add "$pstack/technical-writing" -g -a cline -y; \
    bunx skills add JuliusBrussee/caveman -g -a cline -y
COPY --chown=$USERNAME:$USERNAME skills/meeting-briefing /home/$USERNAME/.agents/skills/meeting-briefing
RUN helix --grammar fetch \
    && helix --grammar build \
    && mkdir /home/$USERNAME/.config/helix/runtime/queries \
    && cp -r /home/$USERNAME/.config/helix/runtime/grammars/sources/lilypond/queries /home/$USERNAME/.config/helix/runtime/queries/lilypond
RUN rustup default stable \
    && cargo install emeraldian
RUN uv tool install python-ly \
    && uv tool install ptai
RUN go install github.com/reteps/dockerfmt@latest \
    && go install github.com/antopolskiy/kanban-md/cmd/kanban-md@latest
RUN bun add -g --ignore-scripts @earendil-works/pi-coding-agent \
    && bun add -g --ignore-scripts @devcontainers/cli \
    && bun add -g --ignore-scripts @oh-my-pi/pi-coding-agent
ENTRYPOINT ["entrypoint"]
CMD ["tail", "-f", "/dev/null"]