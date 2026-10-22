# Neovim via nvf: LSP for what you edit on a work box, no Node.js in the closure
{inputs, ...}: {
  flake.modules.homeManager.neovim = {pkgs, ...}: {
    imports = [inputs.nvf.homeManagerModules.default];

    home.packages = [pkgs.nixd pkgs.alejandra];

    programs.nvf = {
      enable = true;
      settings.vim = {
        viAlias = true;
        vimAlias = true;
        preventJunkFiles = true;
        searchCase = "smart";

        options = {
          tabstop = 2;
          shiftwidth = 2;
          expandtab = true;
          wrap = false;
          scrolloff = 8;
          signcolumn = "yes";
          cursorline = true;
          mouse = "a";
          splitbelow = true;
          splitright = true;
          undofile = true;
          updatetime = 250;
          timeoutlen = 300;
          foldlevel = 99;
          foldlevelstart = 99;
        };

        clipboard = {
          enable = true;
          registers = "unnamedplus";
        };

        # No win32yank in nixpkgs. Copy via OSC 52 (Windows Terminal handles it,
        # UTF-8 safe unlike clip.exe), paste through PowerShell in UTF-8.
        luaConfigRC.wsl-clipboard = ''
          local osc52 = require("vim.ui.clipboard.osc52")
          local paste = {
            "powershell.exe", "-NoLogo", "-NoProfile", "-Command",
            "[Console]::OutputEncoding = [Text.Encoding]::UTF8; [Console]::Out.Write((Get-Clipboard -Raw) -replace \"`r\", \"\")",
          }
          vim.g.clipboard = {
            name = "wsl",
            copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
            paste = { ["+"] = paste, ["*"] = paste },
          }
        '';

        theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          lspkind.enable = true;
          trouble.enable = true;
        };

        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = false;

          nix = {
            enable = true;
            lsp.servers = ["nixd"];
            format = {
              enable = true;
              type = ["alejandra"];
            };
          };
          python = {
            enable = true;
            lsp.servers = ["ty"];
            format = {
              enable = true;
              type = ["ruff"];
            };
          };
          rust.enable = true;
          lua.enable = true;
          toml.enable = true;
          # Treesitter only: their LSPs and formatters pull in Node.js
          bash = {
            enable = true;
            lsp.enable = false;
          };
          markdown = {
            enable = true;
            lsp.enable = false;
            format.enable = false;
          };
          yaml = {
            enable = true;
            lsp.enable = false;
          };
          json = {
            enable = true;
            lsp.enable = false;
            format.enable = false;
          };
          sql = {
            enable = true;
            lsp.enable = false;
            format.enable = false;
          };
        };

        treesitter = {
          enable = true;
          fold = true;
          context.enable = true;
        };

        autocomplete.blink-cmp = {
          enable = true;
          friendly-snippets.enable = true;
          setupOpts.signature.enabled = true;
        };
        snippets.luasnip.enable = true;

        visuals = {
          nvim-web-devicons.enable = true;
          rainbow-delimiters.enable = true;
        };
        statusline.lualine = {
          enable = true;
          setupOpts.options.theme = "catppuccin";
        };
        telescope.enable = true;
        filetree.neo-tree.enable = true;
        binds.whichKey.enable = true;

        git = {
          enable = true;
          gitsigns.enable = true;
        };

        utility = {
          surround.enable = true;
          snacks-nvim = {
            enable = true;
            setupOpts = {
              bigfile.enabled = true;
              indent.enabled = true;
            };
          };
        };

        comments.comment-nvim.enable = true;
        autopairs.nvim-autopairs.enable = true;
      };
    };
  };
}
