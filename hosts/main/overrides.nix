# ═══════════════════════════════════════════════════════════════
# OVERRIDES DO USUÁRIO — Escreva suas customizações aqui!
# ═══════════════════════════════════════════════════════════════
# Este é o único arquivo seguro para aplicar overrides e instalar
# pacotes extras sem modificar a estrutura e as configurações de
# fábrica/default do projeto Hamra.
#
# Isso ajuda a evitar quebras de sistema e facilita a atualização
# do framework.
#
# Exemplos de uso comuns:
#
# 1. Adicionar pacotes adicionais do sistema (NixOS):
#    environment.systemPackages = with pkgs; [
#      discord
#      vscode
#      gimp
#    ];
#
# 2. Habilitar um serviço extra do NixOS (ex: Docker):
#    virtualisation.docker.enable = true;
#
# 3. Sobrescrever opções do Hamra (ex: mudar o navegador padrão):
#    hamra.apps.browser = "google-chrome-stable";
#
# 4. Modificar configurações do Home Manager para o seu usuário:
#    home-manager.users.${config.hamra.userName} = {
#      programs.git.userName = "Nome Sobrenome";
#      programs.git.userEmail = "seuemail@exemplo.com";
#    };
# ═══════════════════════════════════════════════════════════════
{ config, pkgs, lib, ... }:
{
  # Insira suas customizações adicionais abaixo:

}
