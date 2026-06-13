{ pkgs, lib, exclude_packages ? [ ], }:
let
  hyprlandPackages = with pkgs; [
    hyprshot hyprpicker hyprsunset brightnessctl pamixer playerctl
    gnome-themes-extra pavucontrol
  ];
  systemPackages = with pkgs; [
    git vim libnotify nautilus alejandra blueberry clipse fzf zoxide
    ripgrep eza fd curl unzip wget gnumake
  ];
  discretionaryPackages = with pkgs; [
    lazygit lazydocker btop powertop fastfetch
    chromium obsidian vlc signal-desktop
    github-desktop gh
    docker-compose ffmpeg
  ] ++ lib.optionals (pkgs.system == "x86_64-linux") [
    typora dropbox spotify
  ];
  filteredDiscretionaryPackages = lib.lists.subtractLists exclude_packages discretionaryPackages;
  allSystemPackages = hyprlandPackages ++ systemPackages ++ filteredDiscretionaryPackages;
in {
  systemPackages = allSystemPackages;
  homePackages = with pkgs; [ ];
}
