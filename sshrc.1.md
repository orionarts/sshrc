% SSHRC(1) 2.0 | sshrc

# NAME

**sshrc** - Bring your dotfiles with you when you ssh

# SYNOPSIS

| **sshrc** \[*OPTION*]... *SSH options and arguments*...
| **sshrc** **-z**

# DESCRIPTION

**sshrc** initiates a normal **ssh** session, but also copies the contents of
your local **\$SSHRC_HOME** directory to the remote server and sources the
remote copy of *\$SSHRC_HOME/sshrc* in lieu of any remote shell files.

    local$ echo "echo welcome" > $SSHRC_HOME/sshrc/sshrc
    local$ sshrc server
    welcome
    server$

    local$ echo "alias ..='cd ..'" > $SSHRC_HOME/sshrc/sshrc
    local$ sshrc server
    server$ type ..
    .. is aliased to `cd ..'

For simplicity, your **\$SSHRC_HOME***/sshrc* file will be referred to as your
*sshrc_file*.  You can use this file to set environment variables, define
functions, and run post-login commands, allowing you to use the same
configuration on multiple remote servers without needing to configure them
individually.

**sshrc** creates a unique remote copy of your local **sshrc** configuration
each time you login.  This makes **sshrc** useful if you share a remote account
with multiple users as each user can login to the same remote account and have a
copy of their local **sshrc** configuration without conflict.

By default the initial shell spawned by **sshrc** does not source login shell
files (*/etc/profile*, *~/.profile*, *~/.bash_profile*, etc.). Use the **-j**
option to load these files.

## Message of the Day

By default **sshrc** will attempt to print the remote message of the day and the
last login time. This can be suppressed by creating a remote *~/.hushlogin* file
(per **login(1)**) or be creating a *$SSHRC_HOME/.hushlogin* file.

## Bash Completion

To enable local **bash** completion for **sshrc**, add **complete -F
comp\_cmd\_ssh sshrc** to your local *~/.bashrc*.

# OPTIONS

Any options or arguments not used by **sshrc** itself are passed directly to
**ssh**. Because of how **ssh** works, the **-t** option is automatically
used.

**-j**
: force **sshrc** to process local login shell files before processing your
*sshrc_file*

**-z**
: print size of the compressed **sshrc** loader and configuration files and
exit.

**-Z** *SIZE*
: use *SIZE* as the maximum size of the compressed **sshrc** loader and
configuartion files in KiB (Default: 1024 KiB). **sshrc** will exit without
connecting if this size is exceeded. See **CAVEATS**

**-u**
: setup **tmux** support using the unique system identifier

**-U** *ID*
: setup **tmux** support using *ID* as the unique identifier

**-d**
: display the unique system identifier used by **sshrc**

**-h**
: display help

# FILES

**\$SSHRC_HOME/sshrc**
: This file will be sourced by the remote server instead of the normal
interactive shell files.  For simplicity, this file is referred to as the
*sshrc_file*

# ENVIRONMENT

**\$SSHRC_HOME**
: The contents of this directory are copied to the remote server. The default
value is **\$XDG_CONFIG_HOME***/sshrc*

# TMUX SUPPORT

Normally, using **tmux** in an **sshrc** session uses the remote *~/.tmux.conf*
and spawns shells that read your remote shell files. **sshrc** can optionally
create a framework that reads **$SSHRC_HOME***/tmux.conf* if found and spawn
shells that read your **sshrc** file.

Simply use the **-u** option when starting **sshrc** and run **tmux** normally.
If you do not have a **$SSHRC_HOME***/tmux.conf* file the local *~/.tmux.conf*
will be read instead.

**NOTE:** Do not set the **tmux** *default-command* option as this is set by
**sshrc**.

Any remote **tmux** sessions created after connecting with **sshrc -u** will
persist across multiple invocations of **sshrc**. These **tmux** sessions will
maintain their own shared copy of your **sshrc** configuration even after the
initial **sshrc** session exists. This shared copy is only after the final
**tmux** session is closed.

When setting up **tmux** support **sshrc** uses a locally stored unique
identifier and provides the remote **tmux_id** and **tmuxrc** commands to
facilitate sharing **tmux** sessions betwee multiple locations or users. See
**EXAMPLES** for specifics.

# CAVEATS

**sshrc** works by passing a loader script and the compressed contents of
**\$SSHRC_HOME** as a base64 encoded as the "remote command" of the **ssh**
session. Because the remote server has limits on the length of the remote
command it will accept, **sshrc** refuses to even attempt to login if it
attempts to upload > 1024 KiB.  This maximum size can be changed with the **-Z**
option.

Even if this limit is not exceeded, a large **\$SSHRC_HOME** will slow down your
login times.

Use the **-z** option to determine the total size of data that **sshrc** will
upload.

# BUGS

**sshrc** should work with any POSIX-compliant Bourne shell derivative except
the BusyBox shell. Any failures with a supported shell are bugs and should be
reported.

# EXAMPLES

### Using $SSHRC

When an **sshrc** session begins the remote environment variable **$SSHRC** is
set to the path to the remote copy of your **\$SSHRC_HOME**. This can be used as
needed to configure environment variables or aliases to force remote commands to
use the **sshrc** version of their configurations.

For example, add an alias to your **sshrc** file to have **vim** use
*\$SSHRC_HOME/vimrc* instead of *~/.vimrc~:

    # $SSHRC_HOME/sshrc
    ...
    alias vim='vim -u $SSHRC/vimrc'

### Tmux

To connect to your own **sshrc**-associated **tmux** session from a different
machine, you first get the unique identifier associated with your **sshrc**
sessions by using the **-d** option locally or the **tmux_id** command remotely.

Then, form a different machine, use the **-U** *ID* option instead of **-u** to
allow connecting to your previous **tmux** sessions.

    # Login with tmux support
    box-1$ sshrc -u server

    # Get your unique identifier prior to detaching
    server$ tmux_id
    ABCDEF

    # From another system, login with tmux support
    # connected to the previous sessions
    box-2$ sshrc -U ABCDEF server
    server$ tmux attach
    # you are attached to the previously detached session

If multiple users use **sshrc** to log into the same remote account and want to
share **tmux** sessions, one user should run **sshrc -u** normally and pass
their unique identifier to the other users. Other uses will then connect
and use the remote **tmuxrc** command instead of **tmux** to connect to any
shared session.

**NOTE:** Each user does not get access to their own **sshrc** configuration
files.

    # Bob gets his local identifier
    bob@local$ sshrc -d
    ABCDEF

    # Bob logs in with tmux support
    bob@local$ sshrc -u server

    # Bob starts a remote tmux session that he wants to share
    bob@server$ tmux
    # inside a tmux session

    # Alice logs in using sshrc but does not use -u
    alice@local$ sshrc server

    # Alice runs tmuxrc remotely with Bob's identifer
    alice@server$ tmuxrc ABCDEF [tmux options and commands]
    # inside the shared tmux session

# REPORTING BUGS

GitHub Issues: <https://github.com/jbrubake/sshrc/issues>

# COPYRIGHT

Copyright © 2026 Jeremy Brubaker. License GPLv3+: GNU GPL version 3 or later
<https://gnu.org/licenses/gpl.html>. This is free software: you are free to
change and redistribute it. There is NO WARRANTY, to the extent permitted by
law.

Original version Copyright © 2014 Russell Stewart

# SEE ALSO

**sh(1)**, **bash(1)**, **ssh(1)**

