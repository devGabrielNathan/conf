# Configura Git global: aliases, delta, gh.
# Identidade (user.name/user.email) é definida pelo perfil via config.hamra.
{ pkgs, ... }: {
  home-manager.sharedModules = [{
    programs.git = {
      enable = true;
      settings = {
        alias = {
          st  = "status";
          co  = "checkout";
          br  = "branch";
          lg  = "log --oneline --graph --decorate";
          undo = "reset HEAD~1 --mixed";
        };

        pull.rebase = true;
        init.defaultBranch = "main";
        core.editor = "nvim";
        credential.helper = "store";
      };
    };

    programs.delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
      };
    };

    programs.gh = {
      enable = true;
      gitCredentialHelper = { enable = true; };
    };
  }];
}
