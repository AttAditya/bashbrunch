#!/bin/bash

set -e

echo "BashBrunch Installer Script"
echo ""

echo "This script will install BashBrunch on $HOME/.bashbrunch\n"
echo "If you do not want to install it there, you have 10 seconds to quit."
echo ""

for i in {10..1}; do
  printf "\rContinuing in $i seconds... "
  sleep 1
done

printf "\rContinuing with installation...\n"

site="https://bashbrunch.attaditya.space"
brunch_dir="$HOME/.bashbrunch"

echo "Setting up directories..."

mkdir -p "$brunch_dir"
mkdir -p "$brunch_dir/providers"
mkdir -p "$brunch_dir/config"
mkdir -p "$brunch_dir/config/models"
mkdir -p "$brunch_dir/data"
mkdir -p "$brunch_dir/data/sessions"

echo "Downloading information files..."

curl -fsSL "$site/README.md" > "$brunch_dir/README.md"
curl -fsSL "$site/LICENSE" > "$brunch_dir/LICENSE"
curl -fsSL "$site/version.txt" > "$brunch_dir/version.txt"

echo "Downloading core files..."

curl -fsSL "$site/brunch.sh" > "$brunch_dir/brunch.sh"

echo "Downloading provider scripts..."

provider_path="$brunch_dir/providers"
provider_site="$site/providers"

curl -fsSL "$provider_site/list.txt" > "$provider_path/list.txt"
provider_list=$(cat "$provider_path/list.txt")

for provider in $provider_list; do
  url="$provider_site/$provider.sh"
  path="$provider_path/$provider.sh"

  curl -fsSL "$url" > "$path"
done

echo "Setting up config files..."

config_path="$brunch_dir/config"

if [ ! -f "$config_path/provider.txt" ]; then
  echo "unset" > "$config_path/provider.txt"
fi

for provider in $provider_list; do
  model_file="$config_path/models/$provider.txt"
  
  if [ ! -f "$model_file" ]; then
    echo "unset" > "$model_file"
  fi
done

echo "Downloading config files..."

curl -fsSL "$site/config/system.txt" > "$config_path/system.txt"
curl -fsSL "$site/config/help.txt" > "$config_path/help.txt"

echo "Setting up data files..."

touch "$brunch_dir/data/history.txt"

echo "Installation complete!\n"
echo "Adding execute permissions scripts..."

chmod +x "$brunch_dir/brunch.sh"
chmod +x "$brunch_dir/providers/"*.sh

echo "Adding alias to your shell configuration file..."

shell_config="$HOME/.bashrc"

if [ "$SHELL" = "/bin/zsh" ]; then
  shell_config="$HOME/.zshrc"
fi

echo "" >> "$shell_config"
echo "# BashBrunch alias" >> "$shell_config"
echo "" >> "$shell_config"
echo "alias brunch='$brunch_dir/brunch.sh'" >> "$shell_config"
echo "export BRUNCH_ROOT='$brunch_dir'" >> "$shell_config"
echo "" >> "$shell_config"

echo "Added alias to $shell_config. Run: source $shell_config"

echo ""
echo "You can now run BashBrunch by typing 'brunch' in your terminal."
echo ""

