## Using GPG authentication key as SSH key.

Note that `--enable-ssh-support` is not needed on UNIX.
According to https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html
when `--enable-ssh-support` is specified, gpg-agent will set `SSH_AUTH_SOCK`.
But I have no idea how gpg-agent can set that variable for me,
as I never give it a chance to modify my shell environment.

### Tell GPG which authentication keys can be used as SSH key.

You do this by running the following command.

```sh
gpg-connect-agent 'keyattr A2355A25DE63972C8BAB8A2DA178DAE4A35B6BC6 Use-for-ssh: true' /bye
gpg-connect-agent 'keyattr E52092BF6E4AD398140149FCBFC806E9B36430AD Use-for-ssh: true' /bye
```

You verify the keys by running

```sh
SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)" ssh-add -l
```

In the past, this can also be done with ~/.gnupg/sshcontrol,
But that is considered deprecated.

If you wonder what command is available in gpg-connect-agent, run the following command.

```sh
gpg-connect-agent "help" /bye
```

### Tell SSH to use gpg-agent as ssh-agent.

You do this with ~/.ssh/config

```sshconfig
Host githubuser1
  Hostname github.com
  # Use ONLY the identity indicated by IdentityFile.
  IdentitiesOnly yes
  # IdentityFile points to a public key, instead of a private key.
  # Providing a public key let ssh to select the corresponding private key from the agent.
  IdentityFile ~/.ssh/gpg-keygrip-A2355A25DE63972C8BAB8A2DA178DAE4A35B6BC6.pub
  IdentityAgent ~/.gnupg/S.gpg-agent.ssh

Host githubuser2
  Hostname github.com
  # Use ONLY the identity indicated by IdentityFile.
  IdentitiesOnly yes
  # IdentityFile points to a public key, instead of a private key.
  # Providing a public key let ssh to select the corresponding private key from the agent.
  IdentityFile ~/.ssh/gpg-keygrip-E52092BF6E4AD398140149FCBFC806E9B36430AD.pub
  IdentityAgent ~/.gnupg/S.gpg-agent.ssh
```
