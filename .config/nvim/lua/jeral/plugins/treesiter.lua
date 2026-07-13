return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    -- import nvim-treesitter plugin
    local treesitter = require("nvim-treesitter.configs")

    -- configure treesitter
    treesitter.setup({ -- enable syntax highlighting
      highlight = {
        enable = true,
      },
      -- enable indentation
      indent = { enable = true },
      -- enable autotagging (w/ nvim-ts-autotag plugin)
      -- autotag = {
      --   enable = true,
      -- },
      -- ensure these language parsers are installed
      ensure_installed = {
        "json",
        "javascript",
        "typescript",
        "tsx",
        "yaml",
        "html",
        "css",
        "prisma",
        "markdown",
        "markdown_inline",
        "svelte",
        "graphql",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "query",
        "vimdoc",
        "c",
        "regex",
        "astro",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })

    local query = require("vim.treesitter.query")
    local directive_opts = { force = true, all = false }

    query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
      local node = match[pred[2]]
      if not node then
        return
      end
      local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)
      if not ok or not text then
        return
      end
      local alias = text:lower()
      local ft_match = vim.filetype.match({ filename = "a." .. alias })
      metadata["injection.language"] = ft_match
        or ({ ts = "typescript", ex = "elixir", pl = "perl", sh = "bash" })[alias]
        or alias
    end, directive_opts)

    query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
      local node = match[pred[2]]
      if not node then
        return
      end
      local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)
      if not ok or not text then
        return
      end
      local configured = ({
        importmap = "json",
        module = "javascript",
        ["application/ecmascript"] = "javascript",
        ["text/ecmascript"] = "javascript",
      })[text]
      if configured then
        metadata["injection.language"] = configured
      else
        local parts = vim.split(text, "/", {})
        metadata["injection.language"] = parts[#parts]
      end
    end, directive_opts)

    query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
      local node = match[pred[2]]
      if not node then
        return
      end
      local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr, { metadata = metadata[pred[2]] })
      if not ok or not text then
        return
      end
      if not metadata[pred[2]] then
        metadata[pred[2]] = {}
      end
      metadata[pred[2]].text = string.lower(text)
    end, directive_opts)
  end,
}
