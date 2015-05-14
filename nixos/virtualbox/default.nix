# used to be nixops/nix/virtualbox-image-nixops.nix
{ config, pkgs, lib, ... }:

let
  clientKeyPath = "/root/.vbox-nixops-client-key";
in
{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>
    <nixpkgs/nixos/modules/virtualisation/virtualbox-guest.nix>
    <microgram/nixos/cloud-config.nix>
  ];

  services.openssh.authorizedKeysFiles = [ ".vbox-nixops-client-key" ];

  boot.kernelPackages = (import <microgram/pkgs> { inherit pkgs; }).linuxPackages;

  boot.vesa = false;

  boot.loader.grub.timeout = 1;

  # VirtualBox doesn't seem to lease IP addresses persistently, so we
  # may get a different IP address if dhcpcd is restarted.  So don't
  # restart dhcpcd.
  systemd.services.dhcpcd.restartIfChanged = false;
}
