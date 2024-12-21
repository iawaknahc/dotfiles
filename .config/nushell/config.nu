print $"sourcing ($nu.config-path)"
if $nu.is-login {
  print "login shell: true"
} else {
  print "login shell: false"
}

alias nu-open = open
alias open = ^open
