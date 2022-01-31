(module dotfiles.plugins.nvim-cmp
  {autoload {nvim aniseed.nvim
             lush lush
             hsl lush.hsl
             fennel fennel
             gruvbox gruvbox}})

(fn fg [group color]
  (nvim.ex.hi (.. group " guibg=" color)))

(fn bg [group fgcolor bgcolor]
  (nvim.ex.hi (.. group " guifg=" fgcolor " guibg=" bgcolor)))

(fn link [dest source]
  (nvim.ex.hi_ (.. "link " dest " " source)))

(fn clear [group]
  (nvim.ex.hi (.. "clear " group)))


(link "CmpItemMenu" "CmpItemKind")


;   bright_red = hsl("#fb4934"),
;   bright_green = hsl("#b8bb26"),
;   bright_yellow = hsl("#fabd2f"),
;   bright_blue = hsl("#83a598"),
;   bright_purple = hsl("#d3869b"),
;   bright_aqua = hsl("#8ec07c"),
;   bright_orange = hsl("#fe8019"),)

; \ '#353535','#d83925','#a8a521','#e0a82a',
; \ '#54969a','#c07998','#7aab7d','#c9bba4',
; \ '#8f8277','#fe6143','#c4c431','#fcc73c',
; \ '#94b3a8','#dd9aab','#9ec98e','#efe1bf'

; GruvboxBlue     #83a598 -> #54969a

; GruvboxRed      #fb4632 -> #d83925

(def red (hsl "#d83925"))  ; #54969a
(def blue (hsl "#54969a")) ; #d83925

(def theme
  (fn []
    {:GruvboxRed {:fg red}
     :GruvboxRedBold {:fg red :gui "bold"}
     :GruvboxBlue {:fg blue}
     :GruvboxBlueBold {:fg blue :gui "bold"}
     :GruvboxRedSign {:fg red}
     :GruvboxBlueSign {:fg blue}}))

(defn .> [object method-name ...]
  ((. object method-name) ...))

(defn gruvbox_custom []
  (-> (lush.extends [gruvbox])
      (.>   :with thm)
      (lush)))

; (gruvbox_custom)

; (set _G.gruvbox_custom (fn [] (lush spec)))
       ; :GruvboxRedSign {:fg red :bg sign_column}
       ; :GruvboxBlueSign {:fg blue :bg sign_column}})))

; -- Comments
; if ui.italic_comments then
;    fg("Comment", grey_fg .. " gui=italic")
; else
;    fg("Comment", grey_fg)
; end

; -- Disable cusror line
; cmd "hi clear CursorLine"
; -- Line number
; fg("cursorlinenr", white)

; -- same it bg, so it doesn't appear
; fg("EndOfBuffer", black)

; -- For floating windows
; fg("FloatBorder", blue)
; bg("NormalFloat", one_bg)

; -- Pmenu
; bg("Pmenu", one_bg)
; bg("PmenuSbar", one_bg2)
; bg("PmenuSel", pmenu_bg)
; bg("PmenuThumb", nord_blue)
; fg("CmpItemAbbr", white)
; fg("CmpItemAbbrMatch", white)
; fg("CmpItemKind", white)
; fg("CmpItemMenu", white)

; -- misc

; -- inactive statuslines as thin lines
; fg("StatusLineNC", one_bg2 .. " gui=underline")

; fg("LineNr", grey)
; fg("NvimInternalError", red)
; fg("VertSplit", one_bg2)

; if ui.transparency then
;    bg("Normal", "NONE")
;    bg("Folded", "NONE")
;    fg("Folded", "NONE")
;    fg("Comment", grey)
; end

; -- [[ Plugin Highlights]]

; -- Dashboard
; fg("DashboardCenter", grey_fg)
; fg("DashboardFooter", grey_fg)
; fg("DashboardHeader", grey_fg)
; fg("DashboardShortcut", grey_fg)

; -- Git signs
; fg_bg("DiffAdd", nord_blue, "none")
; fg_bg("DiffChange", grey_fg, "none")
; fg_bg("DiffModified", nord_blue, "none")

; -- Indent blankline plugin
; fg("IndentBlanklineChar", line)

; --

; -- [[ LspDiagnostics]]

; -- Errors
; fg("LspDiagnosticsSignError", red)
; fg("LspDiagnosticsSignWarning", yellow)
; fg("LspDiagnosticsVirtualTextError", red)
; fg("LspDiagnosticsVirtualTextWarning", yellow)

; -- Info
; fg("LspDiagnosticsSignInformation", green)
; fg("LspDiagnosticsVirtualTextInformation", green)

; -- Hints
; fg("LspDiagnosticsSignHint", purple)
; fg("LspDiagnosticsVirtualTextHint", purple)

; --

; -- NvimTree
; fg("NvimTreeEmptyFolderName", blue)
; fg("NvimTreeEndOfBuffer", darker_black)
; fg("NvimTreeFolderIcon", folder_bg)
; fg("NvimTreeFolderName", folder_bg)
; fg("NvimTreeGitDirty", red)
; fg("NvimTreeIndentMarker", one_bg2)
; bg("NvimTreeNormal", darker_black)
; bg("NvimTreeNormalNC", darker_black)
; fg("NvimTreeOpenedFolderName", blue)
; fg("NvimTreeRootFolder", red .. " gui=underline") -- enable underline for root folder in nvim tree
; fg_bg("NvimTreeStatuslineNc", darker_black, darker_black)
; fg("NvimTreeVertSplit", darker_black)
; bg("NvimTreeVertSplit", darker_black)
; fg_bg("NvimTreeWindowPicker", red, black2)

; -- Disable some highlight in nvim tree if transparency enabled
; if ui.transparency then
;    bg("NvimTreeNormal", "NONE")
;    bg("NvimTreeStatusLineNC", "NONE")
;    bg("NvimTreeVertSplit", "NONE")
;    fg("NvimTreeVertSplit", grey)
; end

; -- Telescope
; fg("TelescopeBorder", line)
; fg("TelescopePreviewBorder", grey)
; fg("TelescopePromptBorder", line)
; fg("TelescopeResultsBorder", line)
