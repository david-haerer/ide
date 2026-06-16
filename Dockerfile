FROM archlinux:latest
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
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
        helix \
        imagemagick \
        inetutils \
        jq \
        lazydocker \
        lazygit \
        less \
        man \
        marksman \
        nmap \
        opencode \
        openvpn \
        poppler \
        resvg \
        ripgrep \
        rsync \
        rustup \
        shellcheck \
        shfmt \
        starship \
        sudo \
        taplo \
        the_silver_searcher \
        tombi \
        typescript-language-server \
        tzdata \
        uv \
        yazi \
        zig \
        zoxide \
    && pacman -Scc --noconfirm
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /usr/bin/fish $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME
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
# RUN gh extension install dlvhdr/gh-dash
# RUN gh extension install dlvhdr/gh-enhance
RUN rustup default stable
RUN uv tool install poetry
RUN helix --grammar fetch && helix --grammar build
ENTRYPOINT ["entrypoint"]
CMD ["tail", "-f", "/dev/null"]
