# Mullvad + Tailscale side by side; see VPN.md
{ pkgs, ... }:

{
  services.resolved.enable = true;
  services.mullvad-vpn.enable = true;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client"; # sets checkReversePath = "loose"
    # netfilter off: Tailscale's ts-input drops 100.64.0.0/10 from other interfaces,
    # which kills replies from Mullvad's content-blocking DNS (100.64.0.x)
    extraSetFlags = [ "--accept-dns=true" "--accept-routes=true" "--netfilter-mode=off" ];
  };

  # Ports this machine serves to the tailnet (nothing open by default)
  # networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];

  # Reload only NixOS's own tables; flushing (default before stateVersion 23.11)
  # wipes Mullvad's kill switch on every rebuild
  networking.nftables.flushRuleset = false;

  # Mullvad's firewall passes ct mark 0xf41; its ip rule 5209 sends everything
  # not marked 0x6d6f6c65 into wg0-mullvad
  networking.nftables.tables.mullvad-tailscale = {
    family = "inet";
    content = ''
      chain output {
        type route hook output priority -100; policy accept;
        # tailscaled's own sockets (control, DERP, peers) skip Mullvad too; Mullvad
        # masquerades them onto the physical interface. ip rule 5260 keeps its
        # WireGuard UDP out of table 52, which Tailscale's 0x80000 rules did before
        meta mark 0x00080000 ct mark set 0x00000f41 meta mark set 0x6d6f6c65 return
        # Mullvad's content-blocking DNS (100.64.0.1-63) stays in the tunnel
        ip daddr 100.64.0.0/26 return
        # tailnet + subnet routes
        ip daddr { 100.64.0.0/10, 10.10.0.0/16 } ct mark set 0x00000f41 meta mark set 0x6d6f6c65
        ip6 daddr fd7a:115c:a1e0::/48 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
      }
      chain input {
        type filter hook input priority -100; policy accept;
        iifname "tailscale0" ct mark set 0x00000f41 meta mark set 0x6d6f6c65
      }
    '';
  };

  # Loop guard for tailscaled's re-marked WireGuard UDP: a peer endpoint inside an
  # accepted subnet route must not go into tailscale0 (table 52, pref 5270).
  # Mullvad puts its own rules ahead of the lowest existing one, so no rule can
  # beat it to the 0x80000 traffic; this one only has to come before 5270.
  systemd.services.tailscale-direct = {
    description = "Keep tailscaled's own UDP out of Tailscale's routes";
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.iproute2 ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ip -4 rule add fwmark 0x6d6f6c65 ipproto udp sport 41641 lookup main pref 5260
      ip -6 rule add fwmark 0x6d6f6c65 ipproto udp sport 41641 lookup main pref 5260
      ip -4 rule add to 10.10.0.0/16 lookup main suppress_prefixlength 0 pref 5265 # local 10.10 LAN beats the subnet route
    '';
    preStop = ''
      ip -4 rule del pref 5260
      ip -6 rule del pref 5260
      ip -4 rule del pref 5265
    '';
  };
}
