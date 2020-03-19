# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  
  
  # Use the systemd-boot EFI boot loader.
  boot = {
	kernelPackages = pkgs.linuxPackages_latest;
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
			vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
		};
	};
  };

  i18n = {
    consoleFont = "latarcyrheb-sun32";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    	wget 
    	vim
	neovim
	brave
	neofetch
	firefox
	slack-dark
	discord
	jetbrains.pycharm-professional
	vscodium
	deja-dup
	pass
	xfce4-14.xfce4-xkb-plugin
	xfce4-14.xfce4-pulseaudio-plugin
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {
	gnupg.agent = { enable = true; enableSSHSupport = true; };
	dconf.enable = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  
  networking = {
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
		extraPackages = with pkgs; [
		     	vaapiIntel
	           	vaapiVdpau
	         	libvdpau-va-gl
	       		intel-media-driver # only available starting nixos-19.03 or the current nixos-unstable
		];
	};
	bumblebee.enable = true;
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
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

