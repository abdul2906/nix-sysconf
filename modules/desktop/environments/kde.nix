{ pkgs, ... }:

let
  sddm-background-drv = pkgs.stdenvNoCC.mkDerivation {
    name = "sddm-background-drv";
    src = ../../../assets/wallpapers;
    dontUnpack = true;
    installPhase = ''
      cp $src/kde.png $out
    '';
  };
in {
  imports = [
    ../../system/fonts.nix
  ];

  environment.persistence."/nix/persist".directories = [
    "/var/lib/AccountsService/"
  ];

  environment.persistence."/nix/persist".users.hu.directories = [
    ".local/share/kwalletd"
    ".local/share/baloo"
    ".local/share/dolphin"
  ];

  environment.persistence."/nix/persist".users.hu.files = [
    ".config/kwinoutputconfig.json" # https://github.com/nix-community/plasma-manager/issues/172
    ".local/state/konsolestaterc"
  ];

  networking.networkmanager.enable = true;
  users.users.hu.extraGroups = [ "networkmanager" ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
    NIXOS_OZONE_WL = 1;
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    khelpcenter
    krdp
  ];

  environment.systemPackages = with pkgs; [
    nvidia-vaapi-driver
    kdePackages.sddm-kcm
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background=${sddm-background-drv}
    '')
    networkmanager-openvpn
    wl-clipboard
  ];

  home-manager.users.hu = {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

    gtk = {
      gtk2.configLocation = "/home/hu/.config/gtk-2.0/gtkrc";
      enable = true;
      theme = {
        name = "Breeze";
        package = pkgs.kdePackages.breeze-gtk;
      };
    };

    programs.konsole = {
      enable = true;
      defaultProfile = "custom";
      customColorSchemes = {
        "custom" = ../../packages/konsole/custom.colorscheme;
      };
      profiles = {
        custom = {
          name = "custom";
          colorScheme = "custom";
          font = {
            name = "Go Mono Nerd Font";
            size = 12; 
          };
        };
      };
    };

    programs.plasma = {
      enable = true;
      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
        wallpaper = "/nix/config/assets/wallpapers/kde.png";
      };

      panels = [
        {
          location = "left";
          floating = true;
          widgets = [
            {
              kickoff = {
                icon = "nix-snowflake-white";
              };
            }
            {
              iconTasks = {
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "applications:org.kde.konsole.desktop"
                  "applications:firefox-esr.desktop"
                ];
              };
            }
            "org.kde.plasma.marginsseparator"
            {
              systemTray = {
                icons = {
                  spacing = "small";
                };
              };
            }
            {
              digitalClock = {
                calendar.firstDayOfWeek = "monday";
                time.format = "24h";
                date.enable = false;
              };
            }
            "org.kde.plasma.pager"
          ];
        }
      ];

      powerdevil = {
        AC = {
          autoSuspend.action = "nothing";
          dimDisplay.enable = false;
          powerButtonAction = "hibernate";
        };
      };

      shortcuts = {
        kwin = {
          "Switch to Desktop 1" = "Meta+1";
          "Switch to Desktop 2" = "Meta+2";
          "Switch to Desktop 3" = "Meta+3";
          "Switch to Desktop 4" = "Meta+4";
          "Switch to Desktop 5" = "Meta+5";
          "Switch to Desktop 6" = "Meta+6";
          "Switch to Desktop 7" = "Meta+7";
          "Switch to Desktop 8" = "Meta+8";
          "Switch to Desktop 9" = "Meta+9";

          # Don't blame me for this. This is all the doing of kwin.
          # You're going to have to adjust this to your layout.
          "Window to Desktop 1" = "Meta+!";
          "Window to Desktop 2" = "Meta+\"";
          "Window to Desktop 3" = "Meta+£";
          "Window to Desktop 4" = "Meta+$";
          "Window to Desktop 5" = "Meta+%";
          "Window to Desktop 6" = "Meta+^";
          "Window to Desktop 7" = "Meta+&";
          "Window to Desktop 8" = "Meta+*";
          "Window to Desktop 9" = "Meta+(";
        };
      };

      configFile = {
        kwinrc = {
          Desktops = {
            Number = {
              value = 9;
            };
            Rows = {
              value = 3;
            };
          };
        };

        plasmaashellrc = {
          PlasmaViews = {
            panelOpacity = 2;
          };
        };

        kxkbrc = {
          Layout = {
            LayoutList = "gb";
            Use = true;
          };
        };
      };
    };
  };
}

