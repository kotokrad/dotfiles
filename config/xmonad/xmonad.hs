-- based on xmonad config by Malcolm MD
-- https://github.com/randomthought/xmonad-config

import System.IO
import System.Exit

import qualified Data.List as L

import XMonad
import XMonad.ManageHook
import XMonad.Actions.Navigation2D
import XMonad.Actions.UpdatePointer
import XMonad.Actions.CycleWS

import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.RefocusLast

import XMonad.Layout.Gaps
import XMonad.Layout.BinarySpacePartition as BSP
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Spacing
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoFrillsDecoration
import XMonad.Layout.Renamed
import XMonad.Layout.Simplest
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.ZoomRow
-- import XMonad.Layout.IndependentScreens

import XMonad.Util.Run (spawnPipe)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Cursor
import XMonad.Util.NamedWindows (getName)
import XMonad.Util.ClickableWorkspaces

import Graphics.X11.ExtraTypes.XF86
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Control.Monad (liftM2)
import Data.Traversable (traverse)
import Data.Maybe (maybeToList)
import Data.List ((\\))
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Actions.WorkspaceNames (getWorkspaceName)


------------------------------------------------------------------------
myHomeDir = "/home/kotokrad"

myConfigDir = myHomeDir ++ "/.config/xmonad"

myXmobar = "xmobar " ++ myConfigDir ++ "/xmobarrc.hs"

-- myTerminal = "alacritty"
myTerminal = "wezterm"

myScreensaver = "dm-tool switch-to-greeter"

mySelectScreenshot = "maim -s -u | xclip -selection clipboard -t image/png -i"

myScreenshot = "maim -u | xclip -selection clipboard -t image/png"

myDrun = "rofi -show drun -matching fuzzy"

myRun = "rofi -show run"

myClipboard = "rofi -modi 'clipboard:greenclip print' -show clipboard -run-command '{cmd}'"

myVimSessions = "vim-sessions"

myTokens = "tokens"

myFileExplorer = "thunar"

myScreenLock = "sleep 0.2 && xtrlock-pam"

------------------------------------------------------------------------
-- Workspaces
-- The default number of workspaces (virtual screens) and their names.
--
myWs1Web = "\62057 "
myWs2Console = "\61728 "
myWs3Code = "\61729 "
myWs4FS = "\61563 "
myWs5Chat = "\62150 "
myWs6Misc = "\62532 "

myWorkspaces = [myWs1Web, myWs2Console, myWs3Code, myWs4FS, myWs5Chat, myWs6Misc]


------------------------------------------------------------------------
-- Window rules
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myWindowRules = composeAll
    [
      className =? "firefox"                      --> viewShift myWs1Web
    , className =? "librewolf"                    --> viewShift myWs1Web
    , className =? "qutebrowser"                  --> viewShift myWs1Web
    , className =? "org.wezfurlong.wezterm"       --> viewShift myWs2Console
    , className =? ".thunar-wrapped_"             --> viewShift myWs4FS
    , className =? "Transmission-gtk"             --> viewShift myWs4FS
    , className =? "Steam"                        --> viewShift myWs4FS
    , className =? "TelegramDesktop"              --> viewShift myWs5Chat
    , className =? "Slack"                        --> viewShift myWs5Chat
    , className =? ".blueman-manager-wrapped"     --> viewShift myWs6Misc
    , className =? "File-roller"                  --> doCenterFloat
    , className =? "Mate-calc"                    --> doCenterFloat
    , className =? "feh"                          --> doFullFloat
    , className =? "trayer"                       --> doIgnore
    , resource  =? "desktop_window"               --> doIgnore
    , isFullscreen                                --> (doF W.focusDown <+> doFullFloat)
    ]
  where
    viewShift :: WorkspaceId -> ManageHook
    viewShift = doF . liftM2 (.) W.greedyView W.shift


------------------------------------------------------------------------
-- Layouts
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
gapper s = spacingRaw True (uniformBorder s) True (uniformBorder s) True
  where
    uniformBorder n = Border n n n n

layouts = avoidStruts
            $ onWorkspace myWs1Web fullFirst
            $ onWorkspace myWs3Code fullFirst
            $ onWorkspace myWs5Chat fullFirst
            $ onWorkspace myWs6Misc fullFirst
            tiledFirst
          where
            fullFirst  = Full ||| tiled
            tiledFirst = tiled ||| Full
            tiled      = gapper gap $ Tall nmaster delta ratio
            nmaster    = 1
            ratio      = 1/2
            delta      = 3/100


myLayout = smartBorders
           $ mkToggle (NOBORDERS ?? FULL ?? EOT)
           layouts


------------------------------------------------------------------------
-- Colors and borders
--
xmobarActiveTitleColor      = "#b16286"
xmobarInactiveTitleColor    = "#3c3836"
xmobarCurrentWorkspaceColor = "#458588"
xmobarHiddenWorkspaceColor  = "#3c3836"
xmobarDefaultColor          = "gray"
-- xmobarMutedColor            = "#7c6f64"

xmobarSecondaryFont str = "<fn=1>" ++ str ++ "</fn>"

-- borders
myBorderWidth         = 1
myNormalBorderColor   = "#000000"
myFocusedBorderColor  = "#458588"

-- sizes
gap = 6


------------------------------------------------------------------------
-- Key bindings
--
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod4Mask
altMask = mod1Mask

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  ----------------------------------------------------------------------
  -- Custom key bindings
  --

  -- Start a terminal
  [ ((modMask, xK_Return),
     spawn $ XMonad.terminal conf)

  -- Lock the screen using command specified by myScreensaver.
  , ((modMask, xK_0),
     spawn myScreensaver)

  -- dmenu: drun
  , ((modMask, xK_w),
     spawn myDrun)

  -- dmenu: run
  , ((modMask, xK_r),
     spawn myRun)

  -- dmenu: clipboard
  , ((modMask, xK_s),
     spawn myClipboard)

  -- dmenu: tokens
  , ((modMask, xK_a),
     spawn myTokens)

  -- Spawn the file explorer
  , ((modMask, xK_e),
     spawn myFileExplorer)

  -- Take a selective screenshot
  , ((0, xK_Print),
     spawn mySelectScreenshot)

  -- Take a full screenshot
  , ((controlMask, xK_Print),
     spawn myScreenshot)

  -- Open Terminal scratchpad
  , ((modMask, xK_grave),
     namedScratchpadAction myScratchpads "terminal")

  -- Open Notes scratchpad
  , ((modMask, xK_n),
     namedScratchpadAction myScratchpads "notes")

  -- Open Music scratchpad
  , ((modMask, xK_m),
     namedScratchpadAction myScratchpads "music")

  -- Mute volume.
  , ((0, xF86XK_AudioMute),
     spawn "amixer -q set Master toggle")

  -- Decrease volume.
  , ((0, xF86XK_AudioLowerVolume),
     spawn "amixer -q set Master 5%-")

  -- Increase volume.
  , ((0, xF86XK_AudioRaiseVolume),
     spawn "amixer -q set Master 5%+")

  -- Audio previous.
  -- , ((0, 0x1008FF16),
  --    spawn "")

  -- Play/pause.
  -- , ((0, 0x1008FF14),
  --    spawn "")

  -- Audio next.
  -- , ((0, 0x1008FF17),
  --    spawn "")

  -- Eject CD tray.
  -- , ((0, 0x1008FF2C),
  --    spawn "eject -T")

  -- Lock
  , ((modMask, xK_l),
     spawn myScreenLock)

  --------------------------------------------------------------------
  -- "Standard" xmonad key bindings
  --

  -- Close focused window.
  , ((modMask, xK_q),
     kill)

  -- Switch to last workspace
  , ((modMask, xK_Escape),
     toggleWS' [scratchpadWorkspaceTag])

  -- Focus next window inside workspace
  , ((modMask, xK_Tab),
     windows W.focusDown)

  -- Focus previous window inside workspace
  , ((modMask .|. shiftMask, xK_Tab),
     windows W.focusUp)

  -- Toggle current focus window to fullscreen
  , ((modMask, xK_f),
     sendMessage $ Toggle FULL)

  -- Cycle through the available layout algorithms.
  , ((modMask, xK_space),
     sendMessage NextLayout)

  --  Reset the layouts on the current workspace to default.
  , ((modMask .|. shiftMask, xK_space),
     setLayout $ XMonad.layoutHook conf)

  -- Move focus to the next window.
  , ((modMask, xK_j),
     windows W.focusDown)

  -- Move focus to the previous window.
  , ((modMask, xK_k),
     windows W.focusUp  )

  -- Swap the focused window and the master window.
  , ((modMask .|. shiftMask, xK_Return),
     windows W.swapMaster)

  -- Swap the focused window with the next window.
  , ((modMask .|. shiftMask, xK_j),
     windows W.swapDown  )

  -- Swap the focused window with the previous window.
  , ((modMask .|. shiftMask, xK_k),
     windows W.swapUp    )

  -- Push window back into tiling.
  , ((modMask, xK_t),
     withFocused $ windows . W.sink)

  -- Increment the number of windows in the master area.
  , ((modMask, xK_comma),
     sendMessage (IncMasterN 1))

  -- Decrement the number of windows in the master area.
  , ((modMask, xK_period),
     sendMessage (IncMasterN (-1)))

  -- Quit xmonad.
  , ((modMask .|. shiftMask, xK_q),
     io exitSuccess)

  -- Restart xmonad.
    -- , ((modMask, xK_q),
  , ((modMask .|. shiftMask, xK_r),
     restart "xmonad" True)
  ]

  ++

  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  [((m .|. modMask, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_6]
      , (f, m) <- [(W.greedyView, 0), (liftM2 (.) W.view W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings
--
-- Focus rules
-- True if your focus should follow your mouse cursor.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myMouseBindings XConfig {XMonad.modMask = modMask} = M.fromList
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1), \w -> focus w >> mouseMoveWindow w)
    -- mod-button2, Raise the window to the top of the stack
  , ((modMask, button2), \w -> focus w >> windows W.swapMaster)
    -- mod-button3, Set the window to floating mode and resize by dragging
  , ((modMask, button3), \w -> focus w >> mouseResizeWindow w)
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]


------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  setWMName "LG3D"
  setDefaultCursor xC_left_ptr


------------------------------------------------------------------------
-- Scratchpads
--
myScratchpads =
  [ NS "terminal"
       (run [bottomLinePrompt, printMemo] "wezterm start --class sp-terminal -- zsh")
       (className =? "sp-terminal")
       quakeFloat
  , NS "notes"
       "wezterm start --class sp-notes --cwd ~/notes -- nvim scratchpad.md"
       (className =? "sp-notes")
       centerFloat
  , NS "music" -- TODO use ncmpcpp?
       ("wezterm start --class sp-music --cwd ~/music -- " ++ lofi)
       (className =? "sp-music")
       centerFloat
  ]
    where
      centerFloat = customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)
      quakeFloat = customFloating $ W.RationalRect 0 0 1 (1/3)
      lofi = "mpv --no-video --volume=70 https://youtu.be/5qap5aO4i9A"
      run commands term = "RUN=\"" ++ L.intercalate " && " commands ++ "\" " ++ term
      bottomLinePrompt = "printf '\\n%.0s' {1..100}"
      printMemo = "bat -p ~/notes/memo.md"


------------------------------------------------------------------------
-- Status bar
--
myPP =
  filterOutWsPP [scratchpadWorkspaceTag]
  $ def { ppCurrent         = xmobarColor xmobarCurrentWorkspaceColor ""
        , ppHidden          = xmobarColor xmobarDefaultColor ""
        , ppHiddenNoWindows = xmobarColor xmobarHiddenWorkspaceColor ""
        , ppTitle           = xmobarColor xmobarActiveTitleColor "" . shorten titleMaxLength
        , ppSep             = "  "
        , ppExtras          = [logTitles]
        , ppOrder           = \(ws:_:t:ts:_) -> xmobarSecondaryFont ws : t : [xmobarColor xmobarInactiveTitleColor "" ts]
        }
  where
    titleMaxLength = 40
    logTitles = withWindowSet $ fmap (Just . unwords) -- fuse window names
                              . traverse (fmap (shorten titleMaxLength . show) . getName) -- show window names
                              . (\ws -> W.index ws \\ maybeToList (W.peek ws))

mySB = statusBarProp "xmobar" (clickablePP myPP)


------------------------------------------------------------------------

-- Run xmonad with all the defaults we set up.
--
main = do
  spawn myXmobar
  xmonad $ docks
         $ ewmhFullscreen
         $ ewmh
         $ withSB mySB
         $ defaults {
             logHook = updatePointer (0.75, 0.75) (0.75, 0.75)
                       >> refocusLastLogHook
                       >> nsHideOnFocusLoss myScratchpads
         }


------------------------------------------------------------------------
-- Combine it all together
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
    -- simple stuff
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,

    -- key bindings
    keys               = myKeys,
    mouseBindings      = myMouseBindings,

    -- hooks, layouts
    layoutHook         = myLayout,
    manageHook         = manageDocks <+> myWindowRules <+> namedScratchpadManageHook myScratchpads,
    startupHook        = myStartupHook
}
