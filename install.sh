#!/bin/bash

set -e

echo "BashBrunch Installer Script"
echo ""

echo "This script will install BashBrunch on $HOME/.bashbrunch\n"
echo "If you do not want to install it there, you have 10 seconds to quit."
echo ""

sleep 10

echo "Continuing with installation...\n"

site="https://bashbrunch.attaditya.space"

echo "Creating installation directory..."

mkdir -p "$HOME/.bashbrunch"

echo "Downloading core files..."

curl -fsSL "$site/brunch.sh" > "$HOME/.bashbrunch/brunch.sh"
curl -fsSL "$site/version.txt" > "$HOME/.bashbrunch/version.txt"
curl -fsSL "$site/system.txt" > "$HOME/.bashbrunch/system.txt"
curl -fsSL "$site/help.txt" > "$HOME/.bashbrunch/help.txt"

echo "Setting up additional directories and downloading providers..."

mkdir -p "$HOME/.bashbrunch/providers"
mkdir -p "$HOME/.bashbrunch/models"
mkdir -p "$HOME/.bashbrunch/sessions"

echo "Downloading provider scripts..."

provider_site="$site/providers"
provider_path="$HOME/.bashbrunch/providers"
provider_list=$(curl -fsSL "$provider_site/list.txt")

for provider in $provider_list; do
  url="$provider_site/$provider.sh"
  path="$provider_path/$provider.sh"

  curl -fsSL "$url" > "$path"
done

echo "Setting up default provider and model..."

provider="unset"
model="unknown"

echo "" > "$HOME/.bashbrunch/history.txt"
echo $provider > "$HOME/.bashbrunch/provider.txt"
echo $model > "$HOME/.bashbrunch/models/$provider.txt"

echo "Installation complete!\n"
echo "Adding execute permissions scripts..."

chmod +x "$HOME/.bashbrunch/brunch.sh"
chmod +x "$HOME/.bashbrunch/providers/"*.sh

echo "Adding alias to your shell configuration file..."

shell_config="$HOME/.zshrc"

if [ -n "$BASH_VERSION" ]; then
  shell_config="$HOME/.bashrc"
fi

echo "" >> "$shell_config"
echo "# BashBrunch alias" >> "$shell_config"
echo "" >> "$shell_config"
echo "alias brunch='$HOME/.bashbrunch/brunch.sh'" >> "$shell_config"
echo "export BRUNCH_ROOT='$HOME/.bashbrunch'" >> "$shell_config"
echo "" >> "$shell_config"

echo "Added alias to $shell_config. Run: source $shell_config"

echo ""
echo "You can now run BashBrunch by typing 'brunch' in your terminal."
echo ""

