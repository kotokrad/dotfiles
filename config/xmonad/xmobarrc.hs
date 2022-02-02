Config {
         font = "xft:FantasqueSansMono Nerd Font:size=10:bold:antialias=true"
       , additionalFonts = [ "xft:FantasqueSansMono Nerd Font:size=9:bold:antialias=true" ]
       , allDesktops = True
       , bgColor = "#282c34"
       , fgColor = "#bbc2cf"
       , position = TopW L 100
       , border = FullB
       , borderColor = "#282c34"
       , borderWidth = 2
       , textOffset = 24
       , textOffsets = [23]
       , commands = [ Run UnsafeXMonadLog

                    , Run Alsa "default" "Master"
                          [ "-t", "<fc=#98971a><status> <volume>%</fc>"
                          , "-H", "60"
                          , "--"
                          , "--on", ""
                          , "--off", "婢 "
                          , "--onc", "#98971a"
                          , "--offc", "#7c6f64"
                          , "--lows", "奄 "
                          , "--mediums", "奔 "
                          , "--highs", "墳 " ]

                    , Run Cpu [ "--template", "<fc=#cc241d><fn=1> </fn> <total>%</fc>" ] 50

                    , Run Memory ["-t","<fc=#d79921><fn=1> </fn> <usedratio>%</fc>" ] 50

                    , Run DiskU [("/", "<fc=#458588><fn=1> </fn> <free></fc>")] [] 20

                    , Run Date "%a %b %_d %I:%M" "date" 300

                    , Run Kbd [("us", "US"), ("ru", "RU")]

                    , Run Com "/home/kotokrad/.config/xmonad/padding-icon.sh" ["panel"] "trayerpad" 10

                    , Run BatteryP       [ "BAT0" ]
                                         [ "--template" , "<fc=#427b58><fn=1>  </fn></fc> <acstatus>"
                                         , "--Low"      , "15" -- units: %
                                         , "--High"     , "50" -- units: %
                                         , "--low"      , "#cc241d"
                                         , "--normal"   , "#b57614"
                                         , "--high"     , "#3c3836"

                                         , "--" -- battery specific options
                                         , "-P" -- include a percentage symbol in <left>

                                         -- discharging status
                                         , "-o"        , "<left> (<timeleft>)"
                                         -- AC "on" status
                                         , "-O"        , "<left>"
                                         -- charged status
                                         , "-i"        , "<left>"
                                         -- , "-lows"     , "  <left> (<timeleft>)"
                                         -- , "-mediums"  , "  <left> (<timeleft>)"
                                         -- , "-highs"    , "  <left> (<timeleft>)"
                                         -- , "--off-icon-pattern", "<acstatus>"
                                         ] 50

                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%UnsafeXMonadLog% }{ %alsa:default:Master%  %cpu%  %memory%  %disku%  %battery% <fc=#7c6f64></fc> %kbd% <fc=#7c6f64></fc> %date% %trayerpad%"
       }
