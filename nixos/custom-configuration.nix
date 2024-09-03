# This config provide the custom option definitions
# and custom settings according to the custom option values.

{ lib, pkgs, config, ... }:

# Use some unstable packages.
let unstablePkgs = import <nixpkgs-unstable> { }; in
with lib; {
  # Use 'options' object to define custom options.
  options = {
    custom = {
      # Use mk* fuctions to define custom options.
      desktop = {
        wm = mkEnableOption "wm";
        kde = mkEnableOption "kde";
        xfce = mkEnableOption "xfce";
        gnome = mkEnableOption "gnome";
        pantheon = mkEnableOption "pantheon";
      };
      platform = {
        amd = mkEnableOption "amd";
        intel = mkEnableOption "intel";
      };
      extraPackages = with types; mkOption {
        type = listOf package;
        default = [ ];
      };
    };
  };

  # Custom releation configurations.
  config = mkMerge [
    (mkIf config.custom.platform.intel {
      boot.kernelModules = [ "kvm-intel" ];
      # Intel driver haven't been updated in years, use default "modesetting" currently.
      services.xserver.videoDrivers = [ "modesetting" ];
      hardware.cpu.intel.updateMicrocode = true;
    })
    (mkIf config.custom.platform.amd {
      boot = {
        # Use KVM kernel module.
        kernelModules = [ "kvm-amd" ];
        # Newer AMD CPU require "amdgpu" kernel module.
        initrd.kernelModules = [ "amdgpu" ];
      };
      services.xserver.videoDrivers = [ "amdgpu" ];
      hardware.cpu.amd.updateMicrocode = true;
    })
    (mkIf (config.custom.desktop.gnome || config.custom.desktop.pantheon) {
      # Set up the input method.
      i18n.inputMethod = {
        # Use ibus for Gnome and Pantheon.
        enabled = "ibus";
        ibus.engines = with pkgs.ibus-engines; [ libpinyin mozc ];
      };
    })
    (mkIf (!(config.custom.desktop.gnome || config.custom.desktop.pantheon)) {
      services.gnome.gnome-keyring.enable = true; # For syncing VSCode configuration.
      i18n.inputMethod = {
        # Use fcitx5 for most desktop/wm.
        enabled = "fcitx5";
        fcitx5.addons = with pkgs; [ fcitx5-chinese-addons fcitx5-mozc ];
      };
    })
    (mkIf config.custom.desktop.wm {
      # Csutom packages for window manager.
      custom.extraPackages = with unstablePkgs; [
        xdg-user-dirs
        networkmanagerapplet
        kitty
        ranger
        ueberzug
        flameshot
        brightnessctl # For brightness control.
        dunst # Provide notification (some WM like Qtile and XMonad don't have a built-in notification service).
      ];
      services = {
        # Set up the compositor.
        picom = {
          enable = true;
          fade = true; # Enable window animation.
          shadow = true; # Enable window shadow.
          backend = "glx";
          inactiveOpacity = 0.9;
          shadowExclude = [ "!focused" ]; # Only shadow the current focus window.
        };
        # Set up the XServer.
        xserver = {
          enable = true;
          displayManager.lightdm = {
            enable = true;
            greeters.gtk.extraConfig = "background=/boot/background.jpg";
          };
          # Set up display manager.
          windowManager = {
            # Enable Qtile.
            qtile.enable = true;
            # Enable AwesomeWM.
            awesome = {
              enable = true;
              luaModules = [ pkgs.luaPackages.vicious ];
            };
          };
        };
      };
    })
    (mkIf config.custom.desktop.kde {
      # Custom packages for KDE.
      custom.extraPackages = with pkgs.kdePackages; [
        yakuake
        # kmix # Enable for ALSA volume.
      ];
      services = {
        displayManager.sddm = {
          wayland.enable = true;
          enable = true; # Plasma use SDDM as display manager.
          enableHidpi = false;
        };
        desktopManager.plasma6 = {
          enable = true;
        };
      };
    })
    (mkIf config.custom.desktop.gnome {
      # Set up Qt look style.
      qt = {
        enable = true; # Enable Qt theme config.
        style = "adwaita"; # Let Qt use Adwaita style.
        platformTheme = "gnome";
      };
      # Custom packages for GNOME.
      custom.extraPackages = with pkgs;
        [ kitty ] ++ # Use btop and kitty instead of gnome-system-monitor and gnome-terminal.
        (with gnome; [ nautilus file-roller eog gnome-tweaks ]) ++
        (with gnomeExtensions; [ blur-my-shell ddterm net-speed-simplified ]);
      services = {
        gnome.core-utilities.enable = false; # Disable useless default Gnome apps.
        xserver = {
          displayManager.gdm.enable = true; # Gnome use GDM as display manager.
          desktopManager.gnome.enable = true;
        };
      };
    })
    (mkIf config.custom.desktop.pantheon {
      # Custom packages for Pantheon.
      custom.extraPackages = with pkgs.pantheon; [ elementary-terminal elementary-files ];
      services = {
        pantheon.apps.enable = false;
        xserver = {
          # Patheon use custom lightdm greeter.
          displayManager.lightdm.greeters.pantheon.enable = true;
          desktopManager.pantheon.enable = true;
        };
      };
    })
    (mkIf config.custom.desktop.xfce {
      # Set up Qt look style.
      qt = {
        enable = true; # Enable Qt theme config.
        style = "gtk2"; # Let Qt use GTK style.
        platformTheme = "gtk2";
      };
      # Set the Xfce GTK themes.
      # Other good GTK themes: arc-theme whitesur-gtk-theme
      custom.extraPackages = with pkgs; [ ant-theme mojave-gtk-theme ];
      services.xserver = {
        desktopManager.xfce.enable = true;
        displayManager.lightdm.greeters.gtk.enable = true;
      };
    })
  ];
}
