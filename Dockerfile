FROM archlinux:latest
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN sed -i 's/^#DisableSandbox/DisableSandbox/' /etc/pacman.conf
RUN pacman -Syu --noconfirm \
        7zip \
        bash-language-server \
        bat \
        bun \
        diffnav \
        eza \
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
        serie \
        starship \
        sudo \
        sudo \
        taplo \
        the_silver_searcher \
        tombi \
        tzdata \
        uv \
        uv \
        yazi \
        zig \
        zoxide \
    && pacman -Scc --noconfirm
RUN gh extension install dlvhdr/gh-dash
RUN gh extension install dlvhdr/gh-enhance
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
COPY --chown=$USERNAME:$USERNAME config/lazygit /home/$USERNAME/.config/lazygit
COPY --chown=$USERNAME:$USERNAME config/opencode /home/$USERNAME/.config/opencode
COPY --chown=$USERNAME:$USERNAME config/starship.toml /home/$USERNAME/.config/starship.toml
COPY --chown=$USERNAME:$USERNAME --chmod=755 entrypoint.sh /home/$USERNAME/.local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
