{
  network.description = "PollParty.io";

  main = { pkgs, ... }: let
    vote = pkgs.callPackage ../phoenix {};
  in {
    networking.firewall.allowedTCPPorts = [ 22 80 443 ];

    # sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "vote" ];
      ensureUsers = [{
        name = "vote";
        ensurePermissions = {
          "DATABASE vote" = "ALL PRIVILEGES";
        };
      }];
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts."pollparty.io" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:8989/";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Proto https;
        '';
      };
    };

    security.acme.email = "themichaeleden@gmail.com";
    security.acme.acceptTerms = true;

    systemd.services.vote = let
      passwd_set = "ALTER USER vote PASSWORD 'vote';";
    in {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        EnvironmentFile = ["/run/keys/vote"];
        Environment = [
          "PORT=8989"
          "PHX_HOST=pollparty.io"
          "DATABASE_URL=ecto://vote:vote@localhost/vote"
        ];
        User = "vote";
        Group = "vote";
        ExecStartPre = pkgs.writeShellScript "vote-pre" ''
          set -x
          ${pkgs.postgresql}/bin/psql -c "${passwd_set}"
          ${vote}/bin/migrate
        '';
        ExecStart = "${vote}/bin/server";
      };
    };

    users.users.vote = {
      isSystemUser = true;
      createHome = true;
      group = "vote";
    };
    users.groups.vote = { };
  };
}
