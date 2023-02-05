# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    ./cachix.nix
    ./hardware-configuration.nix

    inputs.hyprland.nixosModules.default
  ];
  fileSystems = {
    "/".options = [ "discard=async" "space_cache=v2" "compress=zstd" "noatime" ];
    "/home".options = [ "discard=async" "space_cache=v2" "compress=zstd" "noatime" ];
    "/nix".options = [ "discard=async" "space_cache=v2" "compress=zstd" "noatime" ];
  };


  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays your own flake exports (from overlays dir):
      # outputs.overlays.modifications
      # outputs.overlays.additions
      inputs.nixpkgs-wayland.overlay
      # Or overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix.settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
  };

  # FIXME: Add the rest of your current configuration

  networking.hostName = "grob";
  # networking.wireless.enable = true;
  networking.networkmanager.enable = true;

  # TODO: This is just an example, be sure to use whatever bootloader you prefer
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  console = {
    font = "cyr-sun16";
    keyMap = "ru";
    #   useXkbConfig = true; # use xkbOptions in tty.
  };

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  
  security.pam.services.gtklock = {};

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.xserver.displayManager.startx.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  programs.hyprland = {
    enable = true;
    nvidiaPatches = true;
  };

  services.xserver.layout = "us,ru";
  services.xserver.xkbOptions = "grp:alt_shift_toggle";

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.nvidia.open = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  environment.systemPackages = with pkgs; [
    neovim
    wget
    firefox-wayland
    git
    github-cli
    #home-manager
    fish
    any-nix-shell
    libreoffice
    hunspell
    hunspellDicts.ru_RU
    hunspellDicts.en_US
  ];

  programs.fish.enable = true;
  programs.fish.promptInit = ''
    any-nix-shell fish --info-right | source
  '';

  services.gnome.gnome-keyring = {
    enable = true;
  };


  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    # FIXME: Replace with your username
    phygson = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.11";
}
