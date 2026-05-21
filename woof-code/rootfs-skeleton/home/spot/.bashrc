[ -f /etc/bash_completion ] && . /etc/bash_completion
if [ -x /usr/lib/command-not-found ]; then
 command_not_found_handle() {
  if [ -f /var/lib/command-not-found/commands.db ]; then
   /usr/lib/command-not-found -- "$1"
  else
   echo "bash: $1: command not found" >&2
  fi
  return 127
 }
fi

export no_proxy="localhost,127.0.0.1,192.168.0.0/16,.customercaresolutions.local,ag,ag.customercaresolutions.local,dc,dco"
export NO_PROXY="$no_proxy"
