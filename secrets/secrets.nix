let
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMeHSqwJOxDvqA4AX49ipIRKssTxoSrlajc+nEIfxClg REDACTED@example.com";
  users = [ user1 ];

  system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMeHSqwJOxDvqA4AX49ipIRKssTxoSrlajc+nEIfxClg REDACTED@example.com";
  systems = [ system1 ];
in
{
  "secret1.age".publicKeys = [ user1 system1 ];
  "secret2.age".publicKeys = users ++ systems;
}