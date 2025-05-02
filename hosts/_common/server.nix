#{ config, pkgs, lib, ... }:

{
  lib,
  inputs,
  outputs,
  config,
  pkgs,
  userSettings,
  systemSettings,
  ...
}:

{
  imports =
    [
      ./default.nix
      ../../system/app/k3s.nix
    ];

  config = {

    environment.systemPackages = with pkgs; [

    ];

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      allowSFTP = true;
    };

    security.pam = {
      services.sudo.sshAgentAuth = true;
      sshAgentAuth = {
        enable = true;
        authorizedKeysFiles = [
          "/etc/ssh/authorized_keys.d/%u"
        ];
      };
    };

    users.users.${config.userSettings.username}.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFuv+jzJgJ9hsmEczKo1iSO4NeKthMRJfme+w7rQJlQGGHDJE/yJMeIvZUKuXeR5SeH8E3oTIHW0PVjFYAO+GI9kubakseI9KekMqf9hgFaafyh8TEb4NLTvEzs6l6surZfMI6wK6U5JhJG8bnZSuhCnvg3+qhqLCB9aMKikz5Z5+gH8wMZVno0jXvvT8uV8DQTAoCxobWU/gB+aHCMPevrn0rbmSCS5qEQsuieWmZEKnmnv5eeZ/QU2fd+QZ9xOusJeJFGrvgGN/cpg9y2SqAmhmaLgC0U9WhqOZHd/fBjnMs7CKrWnVpPy4yXPlLqBuJpAuK0t+aPjEfYP+GS6aYYNzOzjd/3q9m3NitQTDFBI20cXi+TpY+vJMaMRCrkcVHBM+k9pgNXjg/OD7a4vqwxpvAKzaR1bPhyEgGKI5fgNbs5jecPre6JvueIbjmez9hgSkiYY9D5iL1AYlVqoTy/08KS6ojNzLRpBKZfiKf53vsJZWzd5qdsRsbZnddKDPi4aQtAwpDJL9/oPKNefNRh4vG0NZGfrpsi1tvcxEAZf5Z8P/p2mCyulQeWdP0mALDm+B+Ko2qZeltPIk0jDk0oeKxMEgZEJt1skZk2ge552ubOz2nlvTBRvEcnALpeFDf+9lIbKFMJDXEili1frZ1c04IDEBe2SM4C+PE4NxZxw== stefanmatic@Mk-IV"
    ];
  };
}
