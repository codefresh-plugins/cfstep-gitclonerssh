#!/bin/bash

set -e

printenv

CLONE_PATH=${CLONE_PATH:-$(pwd)}
BRANCH=${BRANCH:-master}

# use SSH_KEY environment variable to create key file, if not exists
ssh_key_file="$HOME/.ssh/id_cfstep-gitclonerssh"
if [[ ! -f "$ssh_key_file" ]]; then 
  if [[ ! -z "${SSH_KEY}" ]]; then
    echo "SSH key passed through SSH_KEY environment variable: lenght check ${#SSH_KEY}"
    mkdir -p ~/.ssh
    if [[ ! -z "${SPLIT_CHAR}" ]]; then
      echo "${SSH_KEY}" | tr \'"${SPLIT_CHAR}"\' '\n' > "$ssh_key_file"
    else
      echo "${SSH_KEY}" > "$ssh_key_file"
    fi
    chmod 600 "$ssh_key_file"
  fi
else
  echo "Found $ssh_key_file file"
fi

echo "\$CLONE_PATH var is $CLONE_PATH"
mkdir -p $CLONE_PATH

echo "Cloning $REMOTE_URL"
ssh-agent bash -c "ssh-add $ssh_key_file; git clone $REMOTE_URL $CLONE_PATH"

cd $CLONE_PATH
if [ "$BRANCH" != "master" ]; then
  git checkout $BRANCH && git branch && git status
fi

rm $ssh_key_file