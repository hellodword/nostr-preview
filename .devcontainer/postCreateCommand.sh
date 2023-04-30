#! /bin/bash

set -e
set -x

curl -f -o ~/.git-completion.bash \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

cat << EOF >> ~/.bashrc
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi
EOF

echo 'alias npm="echo use yarn"' >> ~/.bashrc
yarn install