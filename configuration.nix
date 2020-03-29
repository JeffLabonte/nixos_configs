# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
	unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
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
      # <nixos-unstable/nixos/modules/hardware/video/nvidia.nix>
      # <nixos-unstable/nixos/modules/services/x11/display-managers/gdm.nix>
    ];

    #disabledModules = [ 
    #	"hardware/video/nvidia.nix"
    #    "services/x11/display-managers/gdm.nix"
    #];


  
  boot = {
  	plymouth.enable = true;
	kernelPackages = unstable.linuxPackages_latest;
	kernelModules = [ "kvm-intel" ];
	kernelParams = [ "acpi_rev_override=1" "pcie_pm_port=off" "zswap.enabled=1" "zswap.compressor=lz4" ];
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
			vaapiIntel = unstable.vaapiIntel.override { enableHybridCodec = true; };
			virtualbox = unstable.virtualbox;
			nvidia = unstable.nvidia;
			xfce = unstable.xfce;
	      };
	};
  };

  nix = {
  	autoOptimiseStore = true;
  	gc = {
		automatic = true;
		dates = "12:00";
	};
	binaryCaches = [ "https://hydra.iohk.io" "https://iohk.cachix.org" ];
	binaryCachePublicKeys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo=" ];
  };

  i18n = {
    consoleFont = "latarcyrheb-sun32";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "America/Toronto";

  environment = {
  	systemPackages = with pkgs; [
		cmake
		deja-dup
		firefox
		gcc
		ghc
		gnome3.gedit
		linuxPackages.cpupower
		networkmanagerapplet
		pass
		python37
    		vim
    		wget 
		xfce4-14.thunar
		xfce.xfce4-terminal
		xfce4-14.xfce4-power-manager
		xfce.xfce4-screenshooter
		xfce4-14.xfce4-xkb-plugin
		xfce4-14.xfce4-pulseaudio-plugin
		xsel
  	];
	variables = {
		EDITOR = "nvim";
		TERMINAL = "alacritty";
	};
	
  };

  programs = {
	dconf.enable = true;
	gnupg.agent = { enable = true; enableSSHSupport = true; };
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
	};
	opengl = {
		enable = true;
		driSupport = true;
		extraPackages = with unstable; [
		     	vaapiIntel
	           	vaapiVdpau
	         	libvdpau-va-gl
	       		intel-media-driver # only available starting nixos-19.03 or the current nixos-unstable
		];
	};
	bumblebee.enable = true;
	# nvidia.prime = {
	# 	offload.enable = true;
	# 	# Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
	# 	intelBusId = "PCI:0:2:0";
	# 	# Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
	# 	nvidiaBusId = "PCI:1:0:0";
	# };
	bluetooth = {
		enable = true;
		extraConfig = "
		  [General]
		  Enable=Source,Sink,Media,Socket
		";
	};
  };

  services = {
	blueman.enable = true;
	openssh.enable = true;
	thermald.enable = true;
	printing.enable = true;
	xserver = {
		enable = true;
		videoDrivers = [ "intel" ];
		libinput = {
			enable = true;
			tapping = true;
		};
		displayManager = {
			lightdm.enable = true;
		};
		desktopManager = {
			xterm.enable = false;
			xfce4-14.enable = true;
			default = "xfce4-14";
		};
	
	};
	dbus.packages = with pkgs; [ gnome2.GConf ];
  };

  virtualisation = {
	docker.enable = true;
	virtualbox.host = { 
		enable = true;
		enableExtensionPack = true;
	};
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
    packages = with unstable; [
    	acpi
    	anydesk
	ansible
	brave
	chromium
	discord
	gcc
	ghc
	gitAndTools.bump2version
	gitkraken
	glxinfo
	jetbrains.pycharm-professional
	kubectl
	minikube
	neofetch
	neovim
	postman
	protonvpn-cli-ng
	remmina
	sublime3
	slack-dark
	spotify
	stack
	tdesktop
	teams
	tor-browser-bundle-bin
	tmux
	transmission-gtk
	unzip
	vscodium
    	weechat
	xsel
	zip
    ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

