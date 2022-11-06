{
  inputs,
  config,
  lib,
  pkgs,
  username,
  ...
}: with lib; let
  cfg = config.nixchad.zsh;
  rg = "${pkgs.ripgrep}/bin/rg";
  fzf = "${pkgs.fzf}/bin/fzf";
  bat = "${pkgs.bat}/bin/bat";
in {
  imports = [./aliases.nix];

  options.nixchad.zsh = {
    enable = mkEnableOption "zsh";
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      autosuggestions = {
        enable = true;
        async = true;
      };
      vteIntegration = true;
      zsh-autoenv.enable = true;
      syntaxHighlighting.enable = true;
    };
    users.defaultUserShell = pkgs.zsh;

    hm = {config, ...}: {
      programs.zsh = {
        enable = true;
        autocd = true;
        history.expireDuplicatesFirst = true;
        history.extended = true;
        completionInit = ''
          source ${pkgs.openvpn3}/share/bash-completion/completions/openvpn3
        '';
        initExtra = ''
          # Search Files and Edit
          fe() {
            ${rg} --files ''${1:-.} | ${fzf} --preview '${bat} -fp {}' | xargs $EDITOR
          }

          # Search content and Edit
          se() {
            fileline=$(${rg} -n ''${1:-.} | ${fzf} | awk '{print $1}' | sed 's/.$//')
            $EDITOR ''${fileline%%:*} +''${fileline##*:}
          }

          # Search git log, preview shows subject, body, and diff
          fl() {
            git log --oneline --color=always | ${fzf} --ansi --preview="echo {} | cut -d ' ' -f 1 | xargs -I @ sh -c 'git log --pretty=medium -n 1 @; git diff @^ @' | ${bat} --color=always" | cut -d ' ' -f 1 | xargs git log --pretty=short -n 1
          }

          # Autocomplete "flake" to "flake.nix"
            zstyle ":completion:*:*:vim:*:*files" ignored-patterns '*.lock'

          # Highlight --help with bat
          help() {
              "$@" --help 2>&1 | ${bat} -pl help
            }

          batcopy() {
            bat "$@" | ${pkgs.wl-clipboard}/bin/wl-copy
            }

          battail() {
              tail -f "$@" | ${bat} --paging=never -pl log
            }

          ns() {
            nix shell $(printf "nixpkgs#%s " "$@")
          }

          gri() {
            git rebase -i "HEAD~$1"
          }



          SAVEIFS=$IFS
          IFS=$(echo -en "\n\b")

          function extract {
           if [ -z "$1" ]; then
              # display usage if no parameters given
              echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
              echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
           else
              for n in "$@"
              do
                if [ -f "$n" ] ; then
                    case "''${n%,}" in
                      *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                                   tar xvf "$n"       ;;
                      *.lzma)      unlzma ./"$n"      ;;
                      *.bz2)       bunzip2 ./"$n"     ;;
                      *.cbr|*.rar)       ${pkgs.unrar}/bin/unrar x -ad ./"$n" ;;
                      *.gz)        gunzip ./"$n"      ;;
                      *.cbz|*.epub|*.zip)       ${pkgs.unzip}/bin/unzip ./"$n"       ;;
                      *.z)         uncompress ./"$n"  ;;
                      *.7z|*.arj|*.cab|*.cb7|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
                                   ${pkgs.p7zip}/bin/7z x ./"$n"        ;;
                      *.xz)        unxz ./"$n"        ;;
                      *.exe)       ${pkgs.cabextract}/bin/cabextract ./"$n"  ;;
                      *.cpio)      cpio -id < ./"$n"  ;;
                      # *.cba|*.ace)      unace x ./"$n"      ;;
                      *)
                                   echo "extract: '$n' - unknown archive method"
                                   return 1
                                   ;;
                    esac
                else
                    echo "'$n' - file does not exist"
                    return 1
                fi
              done
          fi
          }

          IFS=$SAVEIFS
        '';
        plugins = [
          {
            name = "you-should-use";
            src = inputs.zsh-you-should-use;
          }
        ];
      };
    };
  };
}
