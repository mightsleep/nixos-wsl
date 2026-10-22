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

        # Bold keywords and types, italic strings, comments and parameters;
        # in Rust types go blue, functions green, lifetimes and self teal.
        # On ColorScheme, so it survives a :colorscheme reload.
        luaConfigRC.highlights = ''
          local c = require("catppuccin.palettes").get_palette("mocha")
          local set = vim.api.nvim_set_hl

          local function add_style(group, style)
            local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
            set(0, group, vim.tbl_extend("force", hl, style))
          end

          local function apply()
            set(0, "LineNr", { fg = c.overlay0 })
            set(0, "CursorLineNr", { fg = c.green, bold = true })

            for _, g in ipairs({
              "@keyword", "@keyword.return", "@keyword.function", "@conditional", "@repeat",
              "@type", "@type.builtin", "@boolean", "@constant", "@constant.builtin",
            }) do
              add_style(g, { bold = true })
            end
            for _, g in ipairs({
              "@string", "@parameter", "@variable.parameter", "@tag.attribute", "Comment", "@comment",
            }) do
              add_style(g, { italic = true })
            end
            for _, g in ipairs({
              "@function", "@function.call", "@method", "@method.call", "@keyword.import", "@include",
            }) do
              add_style(g, { bold = true, italic = true })
            end

            set(0, "RainbowDelimiterRed", { fg = c.red })
            set(0, "RainbowDelimiterYellow", { fg = c.yellow })
            set(0, "RainbowDelimiterBlue", { fg = c.blue })
            set(0, "RainbowDelimiterOrange", { fg = c.peach })
            set(0, "RainbowDelimiterGreen", { fg = c.green })
            set(0, "RainbowDelimiterViolet", { fg = c.mauve })
            set(0, "RainbowDelimiterCyan", { fg = c.teal })

            set(0, "SnacksIndent", { fg = c.surface1 })
            set(0, "SnacksIndentScope", { fg = c.blue })
            set(0, "TreesitterContextSeparator", { fg = c.surface1 })
            set(0, "TreesitterContextBottom", { underline = true, sp = c.surface1 })
          end

          local rust = vim.api.nvim_create_namespace("rust_hl")
          local function rust_hl(group, fg, style)
            set(rust, group, vim.tbl_extend("force", { fg = fg }, style or {}))
          end
          for _, g in ipairs({
            "@type", "@type.builtin", "@lsp.type.struct", "@lsp.type.enum",
            "@lsp.type.trait", "@lsp.type.typeAlias", "@lsp.type.interface",
          }) do
            rust_hl(g, c.blue, { bold = true })
          end
          rust_hl("@lsp.type.typeParameter", c.blue, { italic = true })
          rust_hl("@module", c.blue)
          rust_hl("@lsp.type.namespace", c.blue)
          for _, g in ipairs({
            "@function", "@function.call", "@method", "@method.call",
            "@lsp.type.function", "@lsp.type.method",
          }) do
            rust_hl(g, c.green, { bold = true, italic = true })
          end
          rust_hl("@string", c.yellow, { italic = true })
          rust_hl("@operator", c.yellow)
          rust_hl("@lsp.type.decorator", c.peach)
          rust_hl("@function.macro", c.peach)
          rust_hl("@lsp.type.macro", c.peach)
          rust_hl("@lsp.type.parameter", c.peach, { italic = true })
          for _, g in ipairs({
            "@lsp.type.lifetime", "@storageclass.lifetime", "@label", "@variable.builtin",
            "@lsp.type.selfKeyword", "@lsp.type.selfTypeKeyword",
          }) do
            rust_hl(g, c.teal, { italic = true })
          end
          rust_hl("@character", c.teal)
          rust_hl("@constant.builtin", c.teal, { bold = true })

          vim.api.nvim_create_autocmd("FileType", {
            pattern = "rust",
            callback = function() vim.api.nvim_win_set_hl_ns(0, rust) end,
          })
          vim.api.nvim_create_autocmd("ColorScheme", { callback = apply })
          apply()
        '';

        theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
          # Background comes from Windows Terminal (acrylic, image)
          transparent = true;
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
          setupOpts.options.theme = "catppuccin-nvim";
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
              # Default NEOVIM header; no `startup` section, it counts lazy.nvim plugins
              dashboard = {
                enabled = true;
                preset.keys = [
                  {
                    icon = " ";
                    key = "f";
                    desc = "Find file";
                    action = ":Telescope find_files";
                  }
                  {
                    icon = " ";
                    key = "r";
                    desc = "Recent files";
                    action = ":Telescope oldfiles";
                  }
                  {
                    icon = " ";
                    key = "g";
                    desc = "Grep";
                    action = ":Telescope live_grep";
                  }
                  {
                    icon = " ";
                    key = "n";
                    desc = "New file";
                    action = ":ene | startinsert";
                  }
                  {
                    icon = " ";
                    key = "q";
                    desc = "Quit";
                    action = ":qa";
                  }
                ];
                sections = [
                  {section = "header";}
                  {
                    section = "keys";
                    gap = 1;
                  }
                ];
              };
            };
          };
        };

        comments.comment-nvim.enable = true;
        autopairs.nvim-autopairs.enable = true;
      };
    };
  };
}
