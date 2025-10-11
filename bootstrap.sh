#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════════════════════════╗
# ║                                      Configuration                                       ║
# ╚══════════════════════════════════════════════════════════════════════════════════════════╝
apps=(
  google-cloud-sdk
)

# Fonts (installed via Homebrew Cask)
fonts=(
  font-hackgen
  font-hackgen-nerd
)

brews=(
  asdf
  berglas
  ffmpeg
  fzf
  gh
  ghq
  go
  lcov
  peco
  # ruby-build に必要なパッケージ https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
  openssl@3
  readline
  libyaml
  gmp
  autoconf
)

# Packages that require special taps
tap_packages=(
  "leoafarias/fvm/fvm"
)

git_configs=(
  "user.name masssun"
  "user.email hofzzy@gmail.com"
  "ghq.root ~/ghq"
)

# ╚══════════════════════════════════════════════════════════════════════════════════════════╝

# Colors for output
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
BOLD="$(tput bold)"
NORMAL="$(tput sgr0)"

# Progress tracking
TOTAL_STEPS=9
CURRENT_STEP=0

# Helper functions
print_header () {
  echo ""
  echo "${BOLD}${BLUE}========================================${NORMAL}"
  echo "${BOLD}${BLUE}  $1${NORMAL}"
  echo "${BOLD}${BLUE}========================================${NORMAL}"
  echo ""
}

print_step () {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  echo ""
  echo "${BOLD}${GREEN}[${CURRENT_STEP}/${TOTAL_STEPS}]${NORMAL} ${BOLD}$1${NORMAL}"
  echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NORMAL}"
}

print_success () {
  echo "${GREEN}✓${NORMAL} $1"
}

print_error () {
  echo "${RED}✗ Error:${NORMAL} $1" >&2
}

print_skip () {
  echo "${YELLOW}⊝${NORMAL} $1 (already installed - skipping)"
}

print_warning () {
  echo "${YELLOW}⚠${NORMAL} $1"
}

print_info () {
  echo "${BLUE}→${NORMAL} $1"
}

check_command () {
  if command -v "$1" &> /dev/null; then
    return 0
  else
    return 1
  fi
}

# Main setup process
print_header "Mac Development Environment Setup"
echo "Starting automatic setup of your Mac development environment."
echo "All necessary tools will be installed automatically."
echo ""

# Step 1: Xcode Command Line Tools
print_step "Installing Xcode Command Line Tools"
if xcode-select -p &> /dev/null; then
  print_skip "Xcode Command Line Tools"
else
  print_info "Installing Xcode Command Line Tools..."
  print_warning "A dialog may appear - please click 'Install' when prompted"

  # Try to install, but handle GUI requirement gracefully
  if xcode-select --install 2>/dev/null; then
    print_info "Installation dialog opened. Waiting for completion..."
    print_info "This may take several minutes..."

    # Wait for installation to complete (with timeout)
    timeout=1800  # 30 minutes timeout
    elapsed=0
    while ! xcode-select -p &> /dev/null && [ $elapsed -lt $timeout ]; do
      sleep 10
      elapsed=$((elapsed + 10))
      if [ $((elapsed % 60)) -eq 0 ]; then
        print_info "Still waiting... (${elapsed}s elapsed)"
      fi
    done

    if xcode-select -p &> /dev/null; then
      print_success "Xcode Command Line Tools installed successfully"
    else
      print_error "Installation timed out or failed"
      print_info "Please install manually: xcode-select --install"
    fi
  else
    print_warning "Could not trigger installation (may already be in progress)"
    print_info "Please install manually if needed: xcode-select --install"
  fi
fi

# Step 2: Homebrew
print_step "Installing Homebrew"
if check_command brew; then
  print_skip "Homebrew"
  print_info "Updating Homebrew..."
  if brew update &>/dev/null; then
    print_success "Homebrew updated successfully"
  else
    print_error "Failed to update Homebrew (continuing anyway)"
  fi
else
  print_info "Installing Homebrew..."
  print_warning "Administrator access required - please enter your password when prompted"

  # Establish sudo session first
  print_info "Requesting administrator privileges..."
  if ! sudo -v; then
    print_error "Administrator access denied"
    print_info "Please ensure you have administrator privileges and try again"
    exit 1
  fi

  print_success "Administrator access granted"

  # Install Homebrew with proper environment
  print_info "Downloading and installing Homebrew..."
  export NONINTERACTIVE=1

  if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    print_success "Homebrew installed successfully"

    # Add Homebrew to PATH for current session and zsh config
    print_info "Configuring Homebrew in PATH..."

    # Determine Homebrew path (Apple Silicon vs Intel)
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
      BREW_PREFIX="/opt/homebrew"
    elif [[ -f "/usr/local/bin/brew" ]]; then
      BREW_PREFIX="/usr/local"
    else
      print_error "Could not find Homebrew installation"
      exit 1
    fi

    # Add to current session
    eval "$($BREW_PREFIX/bin/brew shellenv)"

    # Add to .zprofile for zsh (permanent)
    if ! grep -q "$BREW_PREFIX/bin/brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
      print_info "Adding Homebrew to .zprofile..."
      echo '' >> "$HOME/.zprofile"
      echo '# Homebrew' >> "$HOME/.zprofile"
      echo 'eval "$('$BREW_PREFIX'/bin/brew shellenv)"' >> "$HOME/.zprofile"
      print_success "Homebrew PATH configured for zsh"
    else
      print_skip "Homebrew already in .zprofile"
    fi
  else
    print_error "Failed to install Homebrew"
    print_info "You can also install Homebrew manually: https://brew.sh"
    exit 1
  fi
fi

# Step 3: Applications via Homebrew Cask
print_step "Installing Applications"
print_info "Installing applications with Homebrew Cask..."
echo ""

for app in "${apps[@]}"; do
  if brew list --cask 2>/dev/null | grep -q "^$app\$"; then
    print_skip "$app"
  else
    print_info "Installing $app..."
    if brew install --cask --appdir="/Applications" "$app" &>/dev/null; then
      print_success "$app installed"
    else
      print_error "Failed to install $app (continuing)"
    fi
  fi
done

# Step 4: Homebrew packages
print_step "Installing Development Tools"
print_info "Installing Homebrew packages..."
echo ""

# Install regular packages
for pkg in "${brews[@]}"; do
  if brew list 2>/dev/null | grep -q "^$pkg\$"; then
    print_skip "$pkg"
  else
    print_info "Installing $pkg..."
    if brew install "$pkg" &>/dev/null; then
      print_success "$pkg installed"
    else
      print_error "Failed to install $pkg (continuing)"
    fi
  fi
done

# Install packages that require special taps
if [ ${#tap_packages[@]} -gt 0 ]; then
  for tap_pkg in "${tap_packages[@]}"; do
    # Extract tap name and package name
    # Format: "tap_owner/tap_repo/package_name"
    IFS='/' read -r owner repo pkg_name <<< "$tap_pkg"
    tap_name="$owner/$repo"

    if brew list 2>/dev/null | grep -q "^$pkg_name\$"; then
      print_skip "$pkg_name"
    else
      print_info "Adding tap $tap_name..."
      if ! brew tap "$tap_name" &>/dev/null; then
        print_error "Failed to add tap $tap_name"
        continue
      fi

      print_info "Installing $pkg_name..."
      if brew install "$tap_pkg" &>/dev/null; then
        print_success "$pkg_name installed"
      else
        print_error "Failed to install $pkg_name (continuing)"
      fi
    fi
  done
fi

# Step 5: Install fonts
print_step "Installing Fonts"
if [ ${#fonts[@]} -gt 0 ]; then
  print_info "Installing fonts for terminal applications..."
  echo ""

  # Add Homebrew Cask font tap
  print_info "Adding font tap..."
  brew tap homebrew/cask-fonts &>/dev/null

  for font in "${fonts[@]}"; do
    if brew list --cask 2>/dev/null | grep -q "^$font\$"; then
      print_skip "$font"
    else
      print_info "Installing $font..."
      if brew install --cask "$font" &>/dev/null; then
        print_success "$font installed"
      else
        print_error "Failed to install $font (continuing)"
      fi
    fi
  done
else
  print_skip "No fonts to install"
fi

# Step 6: Set default shell to zsh
print_step "Setting default shell to zsh"
if [ "$SHELL" = "/bin/zsh" ]; then
  print_skip "Default shell already set to zsh"
else
  print_info "Changing default shell to zsh..."
  if chsh -s /bin/zsh; then
    print_success "Default shell changed to zsh"
    print_info "Shell change will take effect on next login"
  else
    print_error "Failed to change default shell (continuing)"
    print_info "You can manually change it with: chsh -s /bin/zsh"
  fi
fi

# Step 7: Oh My Zsh
print_step "Installing Oh My Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
  print_skip "Oh My Zsh"
else
  print_info "Installing Oh My Zsh..."
  # Install with proper input handling for curl + bash execution
  if RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &>/dev/null; then
    print_success "Oh My Zsh installed successfully"
  else
    print_error "Failed to install Oh My Zsh (continuing)"
  fi
fi

# Install zsh-autosuggestions plugin
if [ -d "$HOME/.oh-my-zsh" ]; then
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_skip "zsh-autosuggestions plugin"
  else
    print_info "Installing zsh-autosuggestions plugin..."
    if git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" &>/dev/null; then
      print_success "zsh-autosuggestions plugin installed"

      # Check if plugin is already in .zshrc
      if [ -f "$HOME/.zshrc" ] && ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
        print_warning "Add 'zsh-autosuggestions' to plugins in your .zshrc"
      fi
    else
      print_error "Failed to install zsh-autosuggestions plugin"
    fi
  fi
fi

# Step 8: macOS System Settings
print_step "Configuring macOS Settings"

# Show hidden files in Finder
print_info "Enabling hidden files in Finder..."
if defaults read com.apple.finder AppleShowAllFiles 2>/dev/null | grep -q "1"; then
  print_skip "Hidden files already visible in Finder"
else
  print_info "Setting Finder to show hidden files..."
  if defaults write com.apple.finder AppleShowAllFiles true; then
    print_success "Hidden files enabled in Finder"
    print_info "Restarting Finder to apply changes..."
    if killall Finder 2>/dev/null; then
      print_success "Finder restarted successfully"
    else
      print_warning "Could not restart Finder automatically"
      print_info "Please restart Finder manually or press Cmd+Option+Esc"
    fi
  else
    print_error "Failed to enable hidden files in Finder (continuing)"
  fi
fi

# Step 9: Git configuration
print_step "Configuring Git"

# Check for existing SSH key
if [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then
  print_skip "SSH key"
else
  print_info "Creating SSH key (Ed25519)..."
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  # Ed25519 with 100 rounds of key derivation for enhanced security
  ssh-keygen -t ed25519 -a 100 -f "$HOME/.ssh/id_ed25519" -N "" -C "${git_configs[1]#*user.email }" &>/dev/null
  print_success "SSH key created (Ed25519)"

  # Set proper permissions
  chmod 600 "$HOME/.ssh/id_ed25519"
  chmod 644 "$HOME/.ssh/id_ed25519.pub"
fi

# Configure git settings
print_info "Applying git configurations..."
for config in "${git_configs[@]}"; do
  current_value=$(git config --global --get ${config%% *} 2>/dev/null)
  expected_value=${config#* }

  if [ "$current_value" = "$expected_value" ]; then
    print_skip "git config $config"
  else
    if git config --global $config; then
      print_success "Set: git config --global $config"
    else
      print_error "Failed to set: $config (continuing)"
    fi
  fi
done

# Add SSH config for GitHub
if grep -q "Host github.com" "$HOME/.ssh/config" 2>/dev/null; then
  print_skip "GitHub SSH configuration"
else
  print_info "Adding GitHub SSH configuration..."
  mkdir -p "$HOME/.ssh"
  cat >> "$HOME/.ssh/config" <<EOF

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  IdentityFile ~/.ssh/id_rsa
  AddKeysToAgent yes
  UseKeychain yes
EOF
  chmod 600 "$HOME/.ssh/config"
  print_success "GitHub SSH configuration added"
fi

# Show public key
echo ""
if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
  print_info "Your SSH public key (add this to GitHub):"
  echo ""
  echo "${YELLOW}$(cat "$HOME/.ssh/id_ed25519.pub")${NORMAL}"
elif [ -f "$HOME/.ssh/id_rsa.pub" ]; then
  print_info "Your SSH public key (add this to GitHub):"
  echo ""
  echo "${YELLOW}$(cat "$HOME/.ssh/id_rsa.pub")${NORMAL}"
fi

# Final summary
echo ""
print_header "Setup Complete!"

# Count what was installed vs skipped
installed_count=0
skipped_count=0

echo "${GREEN}${BOLD}🎉 Your Mac development environment is ready!${NORMAL}"
echo ""
echo "${BOLD}Summary:${NORMAL}"
echo "  • Applications: ${#apps[@]} configured"
echo "  • Development tools: ${#brews[@]} configured"
echo "  • Git: Configured with SSH key"
echo ""
echo "${BOLD}Next steps:${NORMAL}"
echo "  1. Add your SSH key to GitHub (shown above)"
echo "  2. Restart your terminal or run: ${BLUE}source ~/.zshrc${NORMAL}"
echo "  3. Verify installations: ${BLUE}brew list${NORMAL}"
echo ""
print_info "Happy coding! 🚀"
