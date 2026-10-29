return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000 ,
  config = function()
    require("gruvbox").setup({
      -- overrides = {
      --   SignColumn = {bg = "#ff9900"}
      -- }
    })
    vim.cmd("colorscheme gruvbox")
  end
}
