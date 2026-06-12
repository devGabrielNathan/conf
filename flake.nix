# Ponto de entrada do projeto hamra. Apenas wiring de inputs e outputs,
# sem lógica de configuração — toda lógica fica nos módulos e perfis.
{
  description = "hamra — NixOS modular com specialisations para desktop environments";

  inputs = {
    # Channel unstable — pacotes recentes (Hyprland, Niri, etc.)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager — gerencia dotfiles do usuário (segue o mesmo nixpkgs)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland — compositor Wayland dinâmico
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Caelestia Shell — shell desktop Quickshell para Hyprland
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
  let
    system = "x86_64-linux";
    pkgs   = nixpkgs.legacyPackages.${system};
  in
  {
    # Configuração NixOS principal
    nixosConfigurations.main = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/main/default.nix
        home-manager.nixosModules.home-manager
      ];
    };

    # Dev shell com ferramentas de lint, formatação Nix e wizard
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        statix      # Linter Nix — detecta anti-padrões
        deadnix     # Detecta imports e variáveis mortas
        alejandra   # Formatador Nix opinativo
        nixd        # Language server (nixd LSP)
        gum         # Terminal UI para o wizard interativo
      ];
      shellHook = ''
        echo ""
        echo "  hamra dev environment"
        echo "  ─────────────────────────────────────────────"
        echo "  statix check .    — lint (anti-padrões)"
        echo "  deadnix .         — detectar imports mortos"
        echo "  alejandra .       — formatar"
        echo "  nix flake check   — verificar o flake inteiro"
        echo "  gum              — TUI interativa do wizard"
        echo ""
      '';
    };
  };
}
