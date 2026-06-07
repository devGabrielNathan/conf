# Re-exporta todos os helpers da lib/ do hamra.
# Uso: inputs.hamra.lib.mkSpecialisation { ... }
{ ... }:
{
  mkSpecialisation = import ./mkSpecialisation.nix;
}
