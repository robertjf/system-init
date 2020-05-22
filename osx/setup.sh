#! /bin/bash

log() {
    echo $1 >> ~/env-setup.log
}

install_shell() {
    echo -e '\e[0;33mSetting up zsh as the shell\e[0m'

    ## zsh
    sudo apt-get install zsh -y

    curl -L http://install.ohmyz.sh | sh
    {
        CMD="$( sudo chsh -s /bin/zsh ${USER} )"
    } || {
        log "Failed to set zsh as default shell: $CMD"
    }

    ## zsh Spaceship theme. https://github.com/denysdovhan/spaceship-prompt
    git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
    ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
    
    ## tmux
    {
        CMD="$( brew install tmux urlview -y )"
    } || {
        log "Failed to install tmux & urlview: $CMD"
    }
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

install_dotfiles() {
    echo -e '\e[0;33mSetting up standard dotfiles\e[0m'

    git clone https://github.com/robertjf/system-init ~/code/github/system-init

    LINUX_SCRIPTS_DIR="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

    ln -s $LINUX_SCRIPTS_DIR/.zshrc ~/.zshrc
    ln -s $LINUX_SCRIPTS_DIR/.tmux.conf ~/.tmux.conf
    ln -s $LINUX_SCRIPTS_DIR/.vimrc ~/.vimrc
    ln -s $LINUX_SCRIPTS_DIR/.urlview ~/.urlview

    tmux source ~/.tmux/.tmux.conf
}

install_devtools() {
    echo -e '\e[0;33mInstalling dev software/runtimes/sdks\e[0m'

    ## dotnet
    wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    sudo add-apt-repository universe --yes
    sudo apt-get update
    sudo apt-get install dotnet-sdk-2.2 dotnet-sdk-3.1 -y
    
    read -p "Install .NET Preview SDK? (Y/n)" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        sudo docker pull mcr.microsoft.com/dotnet/core/5.0.100-preview
    fi

    ## go
    read -p "Install Golang? (Y/n)" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        gover=1.14.1
        wget "https://storage.googleapis.com/golang/go$gover.linux-amd64.tar.gz" --output-document "$tmpDir/go.tar.gz"
        sudo tar -C /usr/local -xzf "$tmpDir/go.tar.gz"
    fi

    ## Node.js via fnm
    curl https://raw.githubusercontent.com/Schniz/fnm/master/.ci/install.sh | bash
}

echo -e '\e[0;33mPreparing to setup an osx machine from a base install\e[0m'

tmpDir=~/tmp/setup-base

if [ ! -d "$tmpDir" ]; then
    mkdir --parents $tmpDir
fi

# Create standard github clone location
mkdir -p ~/code/github

install_shell
# install_devtools - needs work to convert from apt.

rm -rf $tmpDir
