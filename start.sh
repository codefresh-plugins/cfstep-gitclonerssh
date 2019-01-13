#!/bin/bash

set -e

printenv

# CLONE_PATH doesn't include the repo-dir
# Repo-dir is $CLONE_PATH/$REPO_NAME
CLONE_PATH=${CLONE_PATH:-$(pwd)}
BRANCH=${BRANCH:-master}
REPO_NAME=${REMOTE_URL##*/}

if [ "$( echo ${REPO_NAME: -4} )" = ".git" ]; then
  REPO_NAME=$( $REPO_NAME | rev | cut -c 5- | rev )
fi

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
echo $CLONE_PATH/$REPO_NAME/
rm -rf $CLONE_PATH/$REPO_NAME/
mkdir -p $CLONE_PATH

echo "Cloning $REMOTE_URL"
ssh-agent bash -c "ssh-add $ssh_key_file; git clone $REMOTE_URL $CLONE_PATH/$REPO_NAME"
cd $CLONE_PATH/$REPO_NAME
if [ "$BRANCH" != "master" ]; then
  git checkout $BRANCH && git branch && git status
fi

echo "ls -alh $CLONE_PATH/$REPO_NAME"
ls -alh $CLONE_PATH/$REPO_NAME

echo "ls -alh $CLONE_PATH"
ls -alh $CLONE_PATH

rm $ssh_key_file

# echo "\$CLONE_PATH var is $CLONE_PATH"
# Check if the cloned dir already exists from previous builds
# if [ -d "$CLONE_PATH/$REPO_NAME" ]; then
#   # Cloned dir already exists from previous builds so just fetch all the changes
#   echo "Preparing to update $REMOTE_URL"
#   cd $CLONE_PATH/$REPO_NAME

#   # Make sure the CLONE_PATH/REPO_NAME folder is a git folder
#   if git status &> /dev/null ; then
#     # Reset the remote URL because the embedded user token may have changed
#     git remote set-url origin $REPO_NAME

#     echo "Cleaning up the working directory"
#     git reset -q --hard
#     git clean -df
#     git gc
#     git_retry git remote prune origin

#     echo "Fetching the updates from origin"
#     ssh-agent bash -c "ssh-add $ssh_key_file; git_retry git fetch --tags"

#     if [ "$BRANCH" != "master" ]; then
#       git checkout $BRANCH && git branch && git status
#     fi
#   else
#     # The folder already exists but it is not a git repository
#     # Clean folder and clone a fresh copy on current directory
#     cd ..
#     rm -rf $CLONE_PATH/$REPO_NAME
#     echo "cloning $REPO_NAME"
#     ssh-agent bash -c "ssh-add $ssh_key_file; git clone $REMOTE_URL $CLONE_PATH"
#     git_retry git clone $REPO $CLONE_PATH/$REPO_NAME
#     cd $CLONE_PATH/$REPO_NAME

#     if [ "$BRANCH" != "master" ]; then
#       git checkout $BRANCH && git branch && git status
#     fi
#   fi
# else
#   mkdir -p $CLONE_PATH
#   # Clone a fresh copy
#   echo "Cloning $REMOTE_URL"
#   ssh-agent bash -c "ssh-add $ssh_key_file; git clone $REMOTE_URL $CLONE_PATH"
#   cd $CLONE_PATH

#   if [ "$BRANCH" != "master" ]; then
#     git checkout $BRANCH && git branch && git status
#   fi
# fi



