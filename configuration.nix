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
    ];

  i18n.defaultLocale = "en_CA.UTF-8";

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
		luks.devices."luks-286c7b51-a3c0-4613-93d4-2341619ac926".device = "/dev/disk/by-uuid/286c7b51-a3c0-4613-93d4-2341619ac926";
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
  	settings = {
		auto-optimise-store = true;
	};
  	gc = {
		automatic = true;
		dates = "12:00";
	};
  };

  console = {
    font = "latarcyrheb-sun32";
    keyMap = "us";
  };

  time.timeZone = "America/Toronto";

  environment = {
  	systemPackages = with pkgs; [
		cmake
		firefox
		gcc
		gnome3.adwaita-icon-theme
		gnomeExtensions.appindicator
		gvfs
		linuxPackages.cpupower
		pciutils
		powertop
		python311
		rofi
		vulkan-tools
		vulkan-loader
		vulkan-headers
    		vim
    		wget
		xsel
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
	mosh.enable = true;
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
			offload = {
				enable = true;
				enableOffloadCmd = true;
			};
			intelBusId = "PCI:0:2:0";
			nvidiaBusId = "PCI:1:0:0";
		};
		package = config.boot.kernelPackages.nvidiaPackages.production;
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
	tailscale.enable = true;
	gnome.gnome-keyring.enable = true;
	xserver = {
		xkbOptions = "caps:swapescape";
    		layout = "us";
    		xkbVariant = "";
		enable = true;
		videoDrivers = [ "modeset" "nvidia" ];
		libinput = {
			enable = true;
			touchpad.tapping = true;
		};
  		displayManager.gdm.enable = true;
  		desktopManager.gnome.enable = true;

	};
	udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
	dbus.packages = with pkgs; [ gnome2.GConf ];
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
 	rtkit.enable = true;
  };


  users.users.jflabonte = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Jean-Francois Labonte";
    extraGroups = [
	 "wheel"
	 "sudo"
	 "docker"
	 "audio"
	 "video"
	 "networkmanager"
 	];
    packages = with pkgs; [
    	alacritty
    	acpi
	ansible
	bitwarden
	black
	unstable.brave
	chromium
	cmake
	docker-compose
	discord
	fzf
	gcc
	git
	glxinfo
	gnumake
	gnome.gnome-terminal
	kubectl
	minikube
	ncurses
	ncdu
	neofetch
	neovim
	# unstable.postman
	protonvpn-gui
	protonmail-bridge
	python311Packages.jedi
	remmina
	signal-desktop
	slack-dark
	stack
	starship
	thefuck
	tdesktop
	tmux
	transmission-gtk
	unzip
	vscode
	xsel
	zip
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
