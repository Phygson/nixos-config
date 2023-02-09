# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here

  nix.package = pkgs.nix;
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    ./../nixos/cachix.nix
    inputs.hyprland.homeManagerModules.default
  ];

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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "phygson";
    homeDirectory = "/home/phygson";
    pointerCursor = {
      name = "Catppuccin-Mocha-Dark-Cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      x11.defaultCursor = "Catppuccin-Mocha-Dark-Cursors";
    };
  };
  #home.sessionVariables = {
  #  LIBVA_DRIVER_NAME = "nvidia";
  #  XDG_SESSION_TYPE = "wayland";
  #  GBM_BACKEND = "nvidia-drm";
  #   __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  #   WLR_NO_HARDWARE_CURSORS = "1";
  #}; 
  fonts.fontconfig.enable = true;
  
  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;
 
  programs.bash.enable = true;
  programs.fish.enable = true;
  programs.fish.plugins = [
    {
      name = "pure";
      src = pkgs.fetchFromGitHub {
        owner = "pure-fish";
        repo = "pure";
        rev = "v4.4.0";
        sha256 = "OlyuCJ1FWCqZqTy+wTUwaTg2RG5VJvhXa+tU+Vtm3uA=";
      };
    }
  ];

  programs.kitty = {
    enable = true;
    font.name = "Fira Code Nerd Font";
    font.package = pkgs.nerdfonts;
    font.size = 12;
    settings = {
      shell = "fish --interactive";
      confirm_os_window_close = "0";
    };
  };

  xsession.enable = true;

  home.packages = with pkgs; [ wofi gtklock tdesktop ];

  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oa: {
      mesonFlags = (oa.mesonFlags or  [ ]) ++ [ "-Dexperimental=true" ];
    });
    style =
    ''
      * {
        font-family: FiraCode Nerd Font; 
	font-size: 12pt;
        padding: 0 8px;
      }
    '';
  };
  
  programs.rofi = {
    enable=true;
    package = pkgs.rofi-wayland;
    plugins = with pkgs; [ rofi-calc ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    nvidiaPatches = true;
    extraConfig = (import ./hyprland.conf.nix {});
  };

  gtk = {
    enable=true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Maroon-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = ["maroon"];
        variant = "mocha";
      };
    };
    cursorTheme = {
      name = "Catppuccin-Mocha-Dark-Cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = [ pkgs.vscode-extensions.jnoortheen.nix-ide ];
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName  = "phygson";
    userEmail = "124876018+Phygson@users.noreply.github.com";
  };
  programs.gh = {
    enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
