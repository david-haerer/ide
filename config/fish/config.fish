if status is-interactive
    fish_vi_key_bindings
    starship init fish | source
    zoxide init fish | source
    eza --icons=always
end

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

abbr c "clear; eza --icons=always"
abbr cmx chmod
abbr cmx chmod +x
abbr dc docker compose
abbr e exit
abbr g git
abbr hx helix
abbr l eza --icons=always
abbr ld lazydocker
abbr lg lazygit
abbr oc opencode

set -g fish_greeting

fish_add_path $HOME/bin

function chpwd --on-variable PWD
    clear
    eza --icons=always
end
