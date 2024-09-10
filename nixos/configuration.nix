# NixOS main configuration, LINK this file to /etc/nixos/configuration.nix

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, modulesPath, ... }:

let
  # Use some packages from unstable channel.
  # Need to add unstable channel at first:
  # sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs-unstable
  unstablePkgs = import <nixpkgs-unstable> {
    config = {
      allowUnfree = true; # Allow some unfree software (like VSCode and Chrome).
      allowInsecurePredicate = pkg: true; # Allow all insecure packages (Who care insecure?).
      packageOverrides = pkgs: {
        # Add NUR repo.
        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          inherit pkgs;
        };
      };
    };
  };
in
{
  imports = [
    # Include config detection.
    (modulesPath + "/installer/scan/not-detected.nix")
    # Include other user configurations.
    /etc/nixos/user-configuration.nix
    ./custom-configuration.nix
  ];

  # Set up boot options.
  boot = {
    # Set the custom linux kernel.
    kernelPackages = unstablePkgs.linuxPackages_zen; # Zen Kernel.
    # kernelPackages = unstablePkgs.linuxPackages_latest; # Offical Kernel.
    initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" ]; # Necessary Kernel Module.
    # Set boot loader.
    loader = {
      timeout = 999999;
      systemd-boot.enable = true; # Use the default systemd-boot EFI boot loader. (No GRUB UI)
      efi.canTouchEfiVariables = true;
    };
  };

  # Set up networking.
  networking = {
    networkmanager.enable = true;
    # NixOS enabled firewall by default, so need to allow some ports.
    firewall.allowedUDPPorts = [
      8964 # For custom use.
    ];
    firewall.allowedTCPPorts = [
      8964 # For custom use.
      9999 # For Clash service.
    ];
  };

  # Set your time zone.
  time = {
    timeZone = "Asia/Taipei";
    hardwareClockInLocalTime = true;
  };

  # Container and VM.
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  # Set up some programs' feature.
  programs = {
    vim.defaultEditor = true; # Set up default editor.
    fish.enable = true; # Enable fish feature will set up environment shells (/etc/shells) for Account Service.
    virt-manager.enable = true; # Use virtual machine manager.
    java.enable = true; # Enable Java support.
    git.enable = true;
    screen.enable = true;
    wireshark = {
      enable = true; # Enable wireshark and create wireshark group (Let normal user can use wireshark).
      package = unstablePkgs.wireshark; # Use wireshark-qt as wireshark package (Default package is wireshark-cli).
    };
  };

  # List packages installed in system profile.
  environment.systemPackages = with unstablePkgs; [
    # Nix Language.
    nixpkgs-fmt
    # C/C++/Rust/Haskell compiler and build tools.
    binutils
    gcc
    clang
    rustup
    stack
    go
    cmake
    gnumake
    # Debugger and Reverse Engineering tools.
    gdb
    lldb
    radare2
    # Java and .Net SDK.
    scala
    visualvm
    dotnet-sdk
    # Python SDK, in NixOS, system pip can't install module, set up pip module in configuration or use venv/pipx.
    # Use "python -m venv xxx_dir" to create virtual environments.
    python3 # (python3.withPackages (p: [p.black p.jupyter p.ansible-core]))
    pipx
    # Other SDK and develop tools.
    nodejs
    kubectl
    kubernetes-helm
    # IDE/Editor.
    vscode
    jetbrains.idea-ultimate
    # Android Tools.
    android-tools
    android-file-transfer
    # Base CLI tools.
    file
    tree
    btop
    usbutils
    pciutils
    exfatprogs
    clash-meta
    # Service and command line tools.
    nmap
    fastfetch
    p7zip
    openssh
    opencc
    syncthing
    # GUI tools
    vlc
    gparted
    gimp
    google-chrome
    thunderbird
    blender
    wpsoffice
    bottles
    # Wechat.
    wechat-uos
    # Man pages (Linux/POSIX API and C++ API doc).
    man-pages
    man-pages-posix
    stdmanpages
  ] ++ config.custom.extraPackages;

  # Config services.
  services = {
    dictd = {
      enable = true; # Enable dictionary.
      DBs = with unstablePkgs.dictdDBs; [ wordnet wiktionary eng2jpn ];
    };
    libinput = {
      enable = true; # Enable touchpad support.
      touchpad.naturalScrolling = true;
    };
  };
  systemd = {
    # Set shutdown max systemd service stop timeout.
    extraConfig = "DefaultTimeoutStopSec=5s";
    # Disable autostart of some service.
    services = {
      libvirtd.wantedBy = lib.mkForce [ ];
    };
  };

  # Config fonts.
  fonts = {
    enableDefaultPackages = true;
    packages = with unstablePkgs; [ cascadia-code noto-fonts noto-fonts-cjk-sans ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Sans" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Cascadia Code NF" ];
      };
    };
  };

  # Enable sound.
  #hardware.pulseaudio.enable = true;
  hardware.enableAllFirmware = true;
  sound.enable = true;

  # Power Management Policy.
  powerManagement.cpuFreqGovernor = "ondemand";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell = unstablePkgs.fish;
    users.dainslef = {
      isNormalUser = true;
      # Enable sudo/network/wireshark/docker permission for normal user.
      extraGroups = [ "wheel" "audio" "networkmanager" "wireshark" "libvirtd" "docker" ];
    };
  };

  system = {
    # Set up system.stateVersion to avoid config not set warning.
    # Use default system.stateVersion config will get warning since this commit https://github.com/NixOS/nixpkgs/commit/e2703d269756d27cff92ecb61c6da9d68ad8fdf8.
    stateVersion = config.system.nixos.release;
    # Execute custom scripts when rebuild NixOS configuration.
    activationScripts.text = "
      # Create custom bash symbol link (/bin/bash) for compatibility with most Linux scripts.
      ln -sf /bin/sh /bin/bash
    ";
  };

  nixpkgs.config.allowUnfree = true; # Allow some unfree software (Linux Firmware).
  nix.settings = {
    auto-optimise-store = true; # Enable nix store auto optimise.
    # Replace custom nixos channel with TUNA mirror:
    # sudo nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixos-*
    # or use USTC Mirror:
    # sudo nix-channel --add https://mirrors.ustc.edu.cn/nix-channels/nixos-*
    substituters = [
      # Binary Cache Mirrors.
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
  };
}
