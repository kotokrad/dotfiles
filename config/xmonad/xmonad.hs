-- based on xmonad config used by Malcolm MD
-- https://github.com/randomthought/xmonad-config

import System.IO
import System.Exit
-- import System.Taffybar.Hooks.PagerHints (pagerHints)

import qualified Data.List as L

import XMonad
import XMonad.Actions.Navigation2D
import XMonad.Actions.UpdatePointer
import XMonad.Actions.CycleWS

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops

import XMonad.Layout.Gaps
-- import XMonad.Layout.Fullscreen
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

import XMonad.Util.Run(spawnPipe)
-- import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Cursor
import XMonad.Util.NamedWindows ( getName )

import Graphics.X11.ExtraTypes.XF86
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Control.Monad (liftM2)
import Data.Traversable ( traverse )
import Data.Maybe ( maybeToList )
import Data.List ( (\\) )
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Actions.WorkspaceNames (getWorkspaceName)


----------------------------mupdf--------------------------------------------
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
myManageHook = composeAll
    [
      className =? "Firefox"                      --> viewShift myWs1Web
    , className =? "qutebrowser"                  --> viewShift myWs1Web
    , className =? "kitty"                        --> viewShift myWs2Console
    , className =? "org.wezfurlong.wezterm"       --> viewShift myWs2Console
    , className =? "vim-ide"                      --> viewShift myWs3Code
    , className =? ".thunar-wrapped_"             --> viewShift myWs4FS
    , className =? "Thunar"                       --> viewShift myWs4FS
    , className =? "Transmission-gtk"             --> viewShift myWs4FS
    , className =? "Steam"                        --> viewShift myWs4FS
    , className =? "TelegramDesktop"              --> viewShift myWs5Chat
    , className =? ".blueman-manager-wrapped"     --> viewShift myWs6Misc
    , className =? "File-roller"                  --> doCenterFloat
    , className =? "Mate-calc"                    --> doCenterFloat
    , className =? "feh"                          --> doFullFloat
    , className =? "trayer"                       --> doIgnore
    , resource  =? "desktop_window"               --> doIgnore
    , isFullscreen                                --> (doF W.focusDown <+> doFullFloat)
    -- , isFullscreen                             --> doFullFloat
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
gapper s    = spacingRaw True (uniformBorder s) True (uniformBorder s) True
  where
    uniformBorder n = Border n n n n

layouts     = avoidStruts
                  $ onWorkspace myWs1Web fullFirst
                  $ onWorkspace myWs3Code fullFirst
                  $ onWorkspace myWs5Chat fullFirst
                  tiledFirst
                 where
                   fullFirst  = Full ||| tiled
                   tiledFirst = tiled ||| Full
                   tiled      = gapper gap $ Tall nmaster delta ratio
                   nmaster    = 1
                   ratio      = 1/2
                   delta      = 3/100


myLayout    = smartBorders
              $ mkToggle (NOBORDERS ?? FULL ?? EOT)
              layouts


------------------------------------------------------------------------
-- Colors and borders
red    = "#cc241d"
purple = "#b16286"
blue   = "#458588"

xmobarActiveTitleColor      = "#b16286"
xmobarInactiveTitleColor    = "#3c3836"
xmobarCurrentWorkspaceColor = "#458588"
xmobarHiddenWorkspaceColor  = "#3c3836"
xmobarDefaultColor          = "gray"
xmobarMutedColor            = "#7c6f64"

xmobarSecondaryFont str = "<fn=1>" ++ str ++ "</fn>"

-- borders
myBorderWidth = 1
myNormalBorderColor     = "#000000"
myFocusedBorderColor    = blue

-- sizes
gap         = 6

-- active      = blue
-- activeWarn  = red
-- inactive    = base02
-- focusColor  = blue
-- unfocusColor = base02

emptyTabTheme = def { decoHeight = 0 }

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

  -- Start a terminal.  Terminal to start is specified by myTerminal variable.
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

  -- dmenu: vim sessions
  , ((modMask, xK_s),
     spawn myClipboard)

  -- dmenu: tokens
  , ((modMask, xK_a),
     spawn myTokens)

  -- Spawn the file explorer
  , ((modMask, xK_e),
     spawn myFileExplorer)

  -- Take a selective screenshot using the command specified by mySelectScreenshot.
  , ((0, xK_Print),
     spawn mySelectScreenshot)

  -- Take a full screenshot using the command specified by myScreenshot.
  , ((controlMask, xK_Print),
     spawn myScreenshot)

  -- Toggle current focus window to fullscreen
  , ((modMask, xK_f), sendMessage $ Toggle FULL)

  -- Toggle current focus window to noborders
  , ((modMask, xK_m), sendMessage $ Toggle NOBORDERS)

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
  , ((0, 0x1008FF16),
     spawn "")

  -- Play/pause.
  , ((0, 0x1008FF14),
     spawn "")

  -- Audio next.
  , ((0, 0x1008FF17),
     spawn "")

  -- Eject CD tray.
  -- , ((0, 0x1008FF2C),
  --    spawn "eject -T")

  -- Lock
  , ((modMask, xK_l),
     spawn "xtrlock-pam -b bg")

  --------------------------------------------------------------------
  -- "Standard" xmonad key bindings
  --

  -- Close focused window.
  -- , ((modMask .|. shiftMask, xK_c),
  , ((modMask, xK_q),
     kill)

  -- Cycle through the available layout algorithms.
  , ((modMask, xK_space),
     sendMessage NextLayout)

  --  Reset the layouts on the current workspace to default.
  , ((modMask .|. shiftMask, xK_space),
     setLayout $ XMonad.layoutHook conf)

  -- Resize viewed windows to the correct size.
  , ((modMask, xK_n),
     refresh)

  -- Move focus to the next window.
  , ((modMask, xK_j),
     windows W.focusDown)

  -- Move focus to the previous window.
  , ((modMask, xK_k),
     windows W.focusUp  )

  -- Move focus to the master window.
  -- , ((modMask, xK_m),
  --    windows W.focusMaster  )

  -- Swap the focused window and the master window.
  , ((modMask .|. shiftMask, xK_Return),
     windows W.swapMaster)

  -- Swap the focused window with the next window.
  , ((modMask .|. shiftMask, xK_j),
     windows W.swapDown  )

  -- Swap the focused window with the previous window.
  , ((modMask .|. shiftMask, xK_k),
     windows W.swapUp    )

  -- Shrink the master area.
  -- , ((modMask, xK_h),
  --    sendMessage Shrink)

  -- Push window back into tiling.
  , ((modMask, xK_t),
     withFocused $ windows . W.sink)

  -- Increment the number of windows in the master area.
  , ((modMask, xK_comma),
     sendMessage (IncMasterN 1))

  -- Decrement the number of windows in the master area.
  , ((modMask, xK_period),
     sendMessage (IncMasterN (-1)))

  -- Toggle the status bar gap.
  -- TODO: update this binding with avoidStruts, ((modMask, xK_b),

  -- Quit xmonad.
  , ((modMask .|. shiftMask, xK_q),
     io (exitSuccess))

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

  -- [((m .|. modMask, k), windows $ onCurrentScreen f i)
  --     | (i, k) <- zip (workspaces' conf) [xK_1 .. xK_6]
  --     , (f, m) <- [(W.greedyView, 0), (liftM2 (.) W.greedyView W.shift, shiftMask)]]

  ++

  -- Switch to last workspace
  [
    ((modMask, xK_Escape), toggleWS)
  , ((modMask, xK_Tab), windows W.focusDown)
  , ((modMask .|. shiftMask, xK_Tab), windows W.focusUp)
  ]

  -- ++
  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  -- [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
  --     | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
  --     , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

  -- ++
  -- Some bindings for BinarySpacePartition
  -- https://github.com/benweitzman/BinarySpacePartition
  -- [
  --   ((modMask .|. controlMask,               xK_Right ), sendMessage $ ExpandTowards R)
  -- , ((modMask .|. controlMask .|. shiftMask, xK_Right ), sendMessage $ ShrinkFrom R)
  -- , ((modMask .|. controlMask,               xK_Left  ), sendMessage $ ExpandTowards L)
  -- , ((modMask .|. controlMask .|. shiftMask, xK_Left  ), sendMessage $ ShrinkFrom L)
  -- , ((modMask .|. controlMask,               xK_Down  ), sendMessage $ ExpandTowards D)
  -- , ((modMask .|. controlMask .|. shiftMask, xK_Down  ), sendMessage $ ShrinkFrom D)
  -- , ((modMask .|. controlMask,               xK_Up    ), sendMessage $ ExpandTowards U)
  -- , ((modMask .|. controlMask .|. shiftMask, xK_Up    ), sendMessage $ ShrinkFrom U)
  -- , ((modMask,                               xK_r     ), sendMessage BSP.Rotate)
  -- , ((modMask,                               xK_s     ), sendMessage BSP.Swap)
  -- -- , ((modMask,                               xK_n     ), sendMessage BSP.FocusParent)
  -- -- , ((modMask .|. controlMask,               xK_n     ), sendMessage BSP.SelectNode)
  -- -- , ((modMask .|. shiftMask,                 xK_n     ), sendMessage BSP.MoveNode)
  -- ]

------------------------------------------------------------------------
-- Mouse bindings
--
-- Focus rules
-- True if your focus should follow your mouse cursor.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))
    -- mod-button2, Raise the window to the top of the stack
  , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))
    -- mod-button3, Set the window to floating mode and resize by dragging
  , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]


------------------------------------------------------------------------
-- Status bars and logging
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--


------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  setWMName "LG3D"
  -- spawn     "bash ~/.xmonad/startup.sh"
  setDefaultCursor xC_left_ptr

logTitles :: X (Maybe String) -- this is a Logger
logTitles = withWindowSet $ fmap (Just . unwords) -- fuse window names
                          . traverse (fmap (shorten 40 . show) . getName) -- show window names
                          . (\ws -> W.index ws \\ maybeToList (W.peek ws))

------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
--
main = do
  xmproc <- spawnPipe myXmobar
  -- xmproc <- spawnPipe "taffybar"
  xmonad $ docks
         $ ewmhFullscreen
         $ ewmh
         --  $ pagerHints -- uncomment to use taffybar
         $ defaults {
             logHook = dynamicLogWithPP xmobarPP {
                           ppCurrent         = xmobarColor xmobarCurrentWorkspaceColor ""
                         , ppHidden          = xmobarColor xmobarDefaultColor ""
                         , ppHiddenNoWindows = xmobarColor xmobarHiddenWorkspaceColor ""
                         , ppTitle           = xmobarColor xmobarActiveTitleColor "" . shorten 40
                         , ppSep             = "  "
                         , ppOutput          = hPutStrLn xmproc
                         , ppExtras          = [logTitles]
                         , ppOrder           = \(ws:_:t:ts:_) -> xmobarSecondaryFont ws : t : [xmobarColor xmobarInactiveTitleColor "" ts]
                       }
                       >> updatePointer (0.75, 0.75) (0.75, 0.75)
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
    -- handleEventHook    = E.fullscreenEventHook,
    handleEventHook    = fullscreenEventHook,
    manageHook         = manageDocks <+> myManageHook,
    startupHook        = myStartupHook
}
