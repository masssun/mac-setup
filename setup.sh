########################################    app list    ########################################
apps=(
  alfred
  android-studio
  deepl
  google-chrome
  google-japanese-ime
  iterm2
  slack
  visual-studio-code
)

brews=(
  dart
  ffmpeg
  gh
  ghq
  go
  nodenv
  rbenv
  ruby-build
  peco
  pyenv
  zsh
)

pubs=(
  fvm
)

gems=(
  bundle
)

git_configs=(
  "user.name hofzzy"
  "user.email hofzzy@gmail.com"
  "ghq.root ~/.ghq"
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
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  }
  prompt "Install Homebrew" install_homebrew
else
  update_homebrew () {
    brew update
  }
  prompt "Update Homebrew" update_homebrew
fi

install_apps () {
  brew install --cask --appdir="/Applications" ${apps[@]}
}
prompt "Install apps with Cask" install_apps

install_brews () {
  brew tap dart-lang/dart
  brew install ${brews[@]}
}
prompt "Install Homebrew packages" install_brews

install_dart_packages () {
  pub global activate ${pubs[@]}
}
prompt "Install Dart packages" install_dart_packages

# Change the login shell to zsh
# chsh -s /bin/zsh

install_oh_my_zsh () {
  curl -L http://install.ohmyz.sh | sh
}
prompt "Install Oh My Zsh" install_oh_my_zsh

create_ssh_key () {
  dir=$HOME/.ssh; [ ! -e $dir ] && mkdir -p $dir
  ssh-keygen -t rsa
  eval `ssh-agent`
  ssh-add -K
}
configure_git () {
  create_ssh_key
  for config in "${git_configs[@]}"
  do
    git config --global ${config}
  done
  git remote set-url origin git@github.com:
  echo "Host github.com\nHostName github.com\nUser git\nIdentityFile ~/.ssh/id_rsa" >> ~/.ssh/config
}
prompt "Coufigure git defaults" configure_git

# Install zsh-autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

printf "🎉  ${GREEN}Setup successfully finished!${NORMAL}"