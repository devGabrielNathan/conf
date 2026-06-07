# Configura Git global do usuário: identidade, aliases e delta como pager.
{ pkgs, ... }: {
  home-manager.sharedModules = [{
    programs.git = {
      enable = true;
      settings = {
        user.name = "Your Name";
        user.email = "your@email.com";

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
  }];
}
