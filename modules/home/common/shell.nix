# Configura o shell do usuário: zsh com aliases, variáveis e prompt via Starship.
{ pkgs, ... }: {
  home-manager.sharedModules = [{
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        ll    = "ls -la";
        la    = "ls -A";
        ".."  = "cd ..";
        "..." = "cd ../..";
        gs    = "git status";
        rebuild = "sudo nixos-rebuild switch --flake .#main";
      };
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };
  }];
}
