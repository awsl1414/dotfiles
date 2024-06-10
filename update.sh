rm -rf .zshrc
rm -rf .p10k.zsh
rm -rf .aria2
rm -rf .config/alacritty
rm -rf .config/zellij

cp -rf ~/.zshrc .
cp -rf ~/.p10k.zsh .
cp -rf ~/.aria2 .
cp -rf ~/.config/alacritty ./.config
cp -rf ~/.config/zellij ./.config

echo "update complete!"
