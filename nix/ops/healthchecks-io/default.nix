{ pkgs, config, ... }:
{
  systemd.services = {
    healthchecks-io = {
      environment = {
        HEALTHCHECKS_KEY = "/run/keys/healthchecks-io";
      };
      path = with pkgs; [
        curl
      ];
      script = builtins.readFile ./check.sh;
      serviceConfig = {
        User = config.users.users.healthchecks.name;
      };
      startAt = "minutely";
    };
  };

  users.users.healthchecks = {
    isSystemUser = true;
    extraGroups = ["keys"];
  };
  # required by NixOS
  users.users.healthchecks.group = "healthchecks";
  users.groups.healthchecks = {};
}
