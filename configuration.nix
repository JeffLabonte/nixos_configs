# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
	unstable = import <nixpkgs-unstable> { config = { allowUnfree = true; }; };
  	nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
	      export __NV_PRIME_RENDER_OFFLOAD=1
              export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
	      export __GLX_VENDOR_LIBRARY_NAME=nvidia
              export __VK_LAYER_NV_optimus=NVIDIA_only
	      exec -a "$0" "$@"
        '';
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./bspwm.nix
      # ./gnome3.nix
    ];

    #disabledModules = [ 
    #	"hardware/video/nvidia.nix"
    #    "services/x11/display-managers/gdm.nix"
    #];


  
  boot = {
  	plymouth.enable = true;
	kernelPackages = pkgs.linuxPackages_latest;
	kernelModules = [ "kvm-intel" ];
	kernelParams = [ 
		"zswap.enabled=1"
		"zswap.compressor=lz4" 
		"hid_apple.fnmode=2"
		"hid_apple.swap_opt_cmd=1"
		"nvidia.NVreg_DynamicPowerManagement=2"
	];
	initrd = {
		availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];
		kernelModules = [ "lz4" "lz4_compress" "nvme" "usb_storage" "xhci_pci" "ahci" "sd_mod" "rtsx_pci_sdmmc" ];
	};
	loader = {
		systemd-boot.enable = true;
		efi.canTouchEfiVariables = true;
	};
	extraModulePackages = [ ];
  };

  nixpkgs = {
	config = {
	      allowUnfree = true;
	      packageOverrides = pkgs: {
			vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
	      };
	};
  };

  nix = {
  	autoOptimiseStore = true;
	trustedUsers = [ "root" "jflabonte" ];
  	gc = {
		automatic = true;
		dates = "12:00";
	};
	binaryCaches = [ "https://hydra.iohk.io" "https://iohk.cachix.org" ];
	binaryCachePublicKeys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo=" ];
  };

  console = {
    font = "latarcyrheb-sun32";
    keyMap = "us";
  };

  time.timeZone = "America/Toronto";

  environment = {
  	systemPackages = with pkgs; [
		brightnessctl
		cmake
		compton
		deja-dup
		evince
		firefox
		gcc
		ghc
		gnome3.adwaita-icon-theme
		gnome3.gedit
		gvfs
		i3lock-fancy
		linuxPackages.cpupower
		networkmanagerapplet
		nvidia-offload
		pass
		pciutils
		playerctl
		polybar
		powertop
		python38
		rofi
		steam
		vulkan-tools
		vulkan-loader
		vulkan-headers
    		vim
    		wget
		wmctrl
		xfce.thunar
		# xfce.xfce4-terminal
		# xfce.xfce4-power-manager
		# xfce.xfce4-xkb-plugin
		# xfce.xfce4-pulseaudio-plugin
		xsel
		xorg.xbacklight
		xss-lock
  	];
	variables = {
		EDITOR = "nvim";
	};
  };

  programs = {
	dconf.enable = true;
	gnupg.agent = { 
		enable = true;
		enableSSHSupport = true;
	};
	zsh.enable = true;
  };

  networking = {
  	enableIPv6 = false;
  	networkmanager.enable = true;
	hostName = "tuxbox-xps15";
  	firewall = {
		allowedTCPPorts = [  ];
  		allowedUDPPorts = [  ];
  		enable = false;
	};
  };

  sound.enable = true;
  hardware = {
	pulseaudio = {
		enable = true;
		extraModules = [ pkgs.pulseaudio-modules-bt ];
		package = pkgs.pulseaudioFull;
		support32Bit = true;
	};
	opengl = {
		enable = true;
		driSupport = true;
		driSupport32Bit = true;
		extraPackages32 = with pkgs.pkgsi686Linux; [ libva vulkan-headers vulkan-loader ];
		extraPackages = with pkgs; [
		     	vaapiIntel
	           	vaapiVdpau
	         	libvdpau-va-gl
	       		intel-media-driver # only available starting nixos-19.03 or the current nixos-unstable
		];
	};
	nvidia = {
		powerManagement.enable = true;
		prime = {
			offload.enable = true;
			intelBusId = "PCI:0:2:0";
			nvidiaBusId = "PCI:1:0:0";
		};
	};
	bluetooth = {
		enable = true;
		# extraConfig = "
		#   [General]
		#   Enable=Source,Sink,Media,Socket
		# ";
	};
  };

  services = {
	openssh.enable = true;
	thermald.enable = true;
	printing.enable = true;
	flatpak.enable = true;
	tlp = {
		enable = true;
	};
	xserver = {
		enable = true;
		videoDrivers = [ "modeset" "nvidia" ];
		libinput = {
			enable = true;
			tapping = true;
		};

	};
	dbus.packages = with pkgs; [ gnome2.GConf ];
  };
  xdg.portal = {
  	enable = true;
  	extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  virtualisation = {
	docker.enable = true;
	libvirtd.enable = true;
  };

  security = {
  	sudo = {
		extraConfig = ''
		  Defaults env_reset,pwfeedback
		'';
	};
  };


  users.users.jflabonte = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
	 "wheel"
	 "sudo"
	 "docker"
	 "vboxusers"
	 "audio"
	 "video"
	 "networkmanager"
 	];
    packages = with pkgs; [
    	alacritty
    	acpi
    	anydesk
	ansible
	black
	unstable.brave
	chromium
	cmake
	docker-compose
	discord
	emacs
	gcc
	ghc
	git
	git-lfs
	gitAndTools.bump2version
	glxinfo
	gnumake
	gnome3.gnome-tweak-tool
	gnome3.gnome-boxes
	unstable.insomnia
	jetbrains.pycharm-professional
	unstable.joplin-desktop
	kubectl
	minikube
	ncurses
	ncdu
	neofetch
	neovim
	postman
	protonvpn-gui
	protonmail-bridge
	python38Packages.jedi
	python38Packages.cx_Freeze
	remmina
	signal-desktop
	sublime3
	slack-dark
	spotify
	stack
	unstable.typora
	tdesktop
	unstable.lutris
	tmux
	transmission-gtk
	unzip
	vscodium
    	weechat
	unstable.wineStaging
	xsel
	xscreensaver
	zip
    ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?

}

