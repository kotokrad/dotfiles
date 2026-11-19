return {
    "srcery-colors/srcery-vim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.g.srcery_background = "#191816"
        vim.cmd("colorscheme srcery")
    end,
}
