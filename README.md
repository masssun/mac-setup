# 🍎 Mac Setup

> **Automated macOS development environment setup**

[![Shell Script](https://img.shields.io/badge/Shell-Script-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](bootstrap.sh)
[![macOS](https://img.shields.io/badge/macOS-Compatible-000000?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Homebrew](https://img.shields.io/badge/Homebrew-FBB040?style=for-the-badge&logo=homebrew&logoColor=black)](https://brew.sh)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

## ⚡ Quick Start

Get your Mac development environment up and running in minutes:

```bash
curl -fsSL https://raw.githubusercontent.com/masssun/mac-setup/main/bootstrap.sh | bash
```

> **⚠️ Important:** Review the script before running. This will install various tools and modify system settings.

## 🛠 What Gets Installed

### Development Tools

| Tool | Description |
|------|-------------|
| **ffmpeg** | Multimedia processing toolkit |
| **fvm** | Flutter version management |
| **fzf** | Command-line fuzzy finder |
| **gh** | GitHub CLI tool |
| **ghq** | Git repository manager |
| **go** | Go programming language |
| **nvm** | Node.js version manager |
| **peco** | Interactive filtering tool |
| **rbenv** | Ruby version manager |

### Shell Experience

- **Oh My Zsh** - Zsh framework with plugins
- **zsh-autosuggestions** - Smart command completion

### Fonts

- **HackGen** - Programming font
- **HackGen Nerd Font** - Programming font with icons

### Security & Git

- **Ed25519 SSH Key** - Modern SSH key generation
- **Git Configuration** - User settings and repository management

## 🚀 Features

- **✨ Zero interaction** - Fully automated installation
- **🔄 Smart detection** - Skips already installed tools
- **📊 Progress tracking** - Clear visual feedback
- **🛡 Error resilient** - Continues on individual failures
- **⚡ Fast execution** - Parallel processing where possible

## 🔧 Installation Steps

The script performs these steps automatically:

1. **Xcode Command Line Tools** - Essential build tools
2. **Homebrew** - Package manager setup
3. **Development Tools** - Core utilities and languages
4. **Fonts** - Programming-optimized typefaces
5. **Shell Configuration** - Zsh as default shell
6. **Oh My Zsh** - Enhanced shell experience
7. **Zsh Plugins** - Auto-suggestions and more
8. **Git & SSH** - Version control and secure authentication

## ⚙️ Customization

Easily customize what gets installed by editing `bootstrap.sh`:

```bash
# Development tools
brews=(
  ffmpeg
  fzf
  # Add your tools here
)

# Fonts
fonts=(
  font-hackgen
  font-hackgen-nerd
)

# Git configuration
git_configs=(
  "user.name Your Name"
  "user.email your.email@example.com"
  "ghq.root ~/ghq"
)
```

## 📋 Requirements

- **macOS 10.15+** (Catalina or later)
- **Internet connection** for downloads
- **Administrator privileges** for system modifications

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Made with ❤️ for Mac developers**

</div>
