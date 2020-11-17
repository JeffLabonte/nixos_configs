{ config, pkgs, ... }:

{
	services = {
		blueman.enable = true;
		xserver = {
			displayManager = {
				lightdm = {
					enable = true;
				};
			};
			windowManager = {
				bspwm = {
					enable = true;	
				};
			};
		};
	};
}
