# Configura o shell do usuário: zsh, starship, zoxide, direnv.
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
      };
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  }];
}
