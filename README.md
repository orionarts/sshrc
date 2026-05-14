# sshrc

`sshrc` initiates a normal `ssh` session, but also copies the contents of
your local `$SSHRC_HOME` directory to the remote server and sources the
remote copy of `$SSHRC_HOME/sshrc` in lieu of any remote shell files.

`$SSHRC_HOME` defaults to `$XDG_CONFIG_HOME/sshrc`.

You can use this to set environment variables, define functions, and run
post-login commands, allowing you to use the same configuration on multiple
remote servers without needing to configure them individually.

## Usage

    local$ echo "echo welcome" > $SSHRC_HOME/sshrc/sshrc
    local$ sshrc server
    welcome
    server$

    local$ echo "alias ..='cd ..'" > $SSHRC_HOME/sshrc/sshrc
    local$ sshrc server
    server$ type ..
    .. is aliased to `cd ..'

`sshrc` creates a unique remote copy of your local `sshrc` configuration for
each login.  This makes `sshrc` useful if you share a remote account with
multiple users as each user can login to the same remote account and have a copy
of their local `sshrc` configuration without conflict.

`sshrc` also has support for `tmux` sessions that persist across `sshrc`
sessions. 

See the manpage for full documentation.
