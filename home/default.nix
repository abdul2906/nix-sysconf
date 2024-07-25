{ config, pkgs, ... }:

{
  imports = [
    ./persist.nix
  ];

  environment.variables = {
    ZDOTDIR = "/home/hu/.config/zsh";
    EDITOR = "nvim";
  };

  users.users.hu = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
    shell = pkgs.zsh;
    hashedPasswordFile = "/nix/config/secrets/pass";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.hu = {
      home.username = "hu";
      home.homeDirectory = "/home/hu";
      home.stateVersion = config.system.stateVersion;

      imports = [
        ./packages/zsh.nix
        ./packages/git.nix
        ./packages/gtk.nix
        ./packages/hyprland.nix
        ./packages/foot.nix
        ./packages/firefox.nix
        ./packages/rofi.nix
        ./packages/fastfetch.nix
        ./packages/nvim.nix
        ./packages/waybar.nix
        ./packages/virt-manager.nix
      ];
    };
  };
}

