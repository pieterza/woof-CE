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

export http_proxy="http://CCS%5Coutbound:outbound@192.168.0.101:80"
export https_proxy="http://CCS%5Coutbound:outbound@192.168.0.101:80"
export HTTP_PROXY="http://CCS%5Coutbound:outbound@192.168.0.101:80"
export HTTPS_PROXY="http://CCS%5Coutbound:outbound@192.168.0.101:80"
export no_proxy="localhost,127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12"
export NO_PROXY="localhost,127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12"
