#!/bin/bash

### install homebrew - https://itsfoss.com/homebrew-linux/
NONINTERACTIVE=1  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> $HOME/.profile
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> $HOME/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# install helm and other tools
brew install k3d k9s htop netcat

# install pack
brew install buildpacks/tap/pack

# install knative tools
brew install knative/client/kn
brew tap knative-extensions/kn-plugins
brew install func