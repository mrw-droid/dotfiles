if status is-interactive
    pyenv init - fish | source
    fnm env --use-on-cd --shell fish | source
end
