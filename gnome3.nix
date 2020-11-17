{ config, pkgs, ... }:
{
	services = {
		xserver = {
			displayManager = {
				gdm = {
					enable = true;
					wayland = true;
				};
			};
			desktopManager = {
				xterm.enable = false;
				gnome3.enable = true;
			};
		};
	};
}
