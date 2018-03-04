########################################    app list    ########################################
apps=(
  alfred
  atom
  firefox
  google-chrome
  google-japanese-ime
  iterm2
  visual-studio-code
)

gems=(
  bundle
)

git_configs=(
  "user.name hofzzy"
  "user.email hofzzy@gmail.com"
)

######################################## End of app list ########################################

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
NORMAL="$(tput sgr0)"

prompt () {
  echo "$1? [Y/n]"
  read answer

  case $answer in
      Y)
          "$2"
          ;;
      n)
          ;;
      *)
          echo "${RED}Cannot understand '$answer'...${NORMAL}"
          prompt "$1" "$2"
          ;;
  esac
}

if test ! $(which brew); then
  install_xcode () {
    xcode-select --install
  }
  prompt "Install Xcode" install_xcode
  install_homebrew () {
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  }
  prompt "Install Homebrew" install_homebrew
else
  update_homebrew () {
    brew update
  }
  prompt "Update Homebrew" update_homebrew
fi

install_brew_cask () {
  brew install caskroom/cask/brew-cask
}
prompt "Install Homebrew-Cask" install_brew_cask

install_apps () {
  brew cask install --appdir="/Applications" ${apps[@]}
}
prompt "Install apps with Cask" install_apps

install_zsh () {
  brew install zsh
}
prompt "Install Zsh" install_zsh

install_oh_my_zsh () {
  curl -L http://install.ohmyz.sh | sh
}
prompt "Install Oh My Zsh" install_oh_my_zsh

create_ssh_key () {
  dir=$HOME/.ssh; [ ! -e $dir ] && mkdir -p $dir
  ssh-keygen -t rsa
  eval `ssh-agent`
  ssh-add $HOME/.ssh/id_rsa
}
configure_git () {
  create_ssh_key
  for config in "${git_configs[@]}"
  do
    git config --global ${config}
  done
  git remote set-url origin git@github.com:
}
prompt "Coufigure git defaults" configure_git

printf "🎉  ${GREEN}Setup successfully finished!${NORMAL}"
