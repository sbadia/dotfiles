-- baloo.sebian.fr (T440s)
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- User libraries
local revelation = require("revelation")
local vicious = require("vicious")
vicious.contrib = require("vicious.contrib")
local _ = require("underscore")
local lain = require("lain")
-- Eminent dynamic tagging
require("eminent")
-- Debian menu
require("debian.menu")
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- Date en francais
os.setlocale("fr_FR.utf8")
os.setlocale("C", "numeric")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
local config_dir = awful.util.getdir("config")
beautiful.init(config_dir .. "/themes/sbadia-default/theme.lua" )

-- This is used later as the default terminal and editor to run.
-- terminal = "urxvtcd"
terminal = "urxvt"
-- terminal = "urxvt -pe tabbed -e /bin/zsh"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod1"
-- modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.max,
    awful.layout.suit.corner.nw,
}
--- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

-- {{{ Wallpaper
local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit },
   { "s2ram", "s2ram" },
   { "halt", "sudo halt" },
}

myessential = {
  { "Firefox", "firefox" },
  { "URxvt", "urxvt" },
  { "Qalculate", "qalculate" },
  { "Vlc", "vlc" },
  { "Gajim", "gajim" }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal },
                                    { "Essentiel", myessential, beautiful.awesome_icon }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Afficher des infos sur le client qui a le focus
-- d'après http://github.com/MajicOne/awesome-configs/blob/master/rc.lua
function win_info ()
   local c = client.focus

   -- Quick little short-circuit.
   if c == nil then return end

   local title, class, instance, role, type = nil, nil, nil, nil, nil
   title    = c.name
   class    = c.class
   instance = c.instance
   role     = c.role
   type     = c.type

   -- We don't want to error on nil.
   if title    == nil then title    = markup.fg.focus('nil') end
   if class    == nil then class    = markup.fg.focus('nil') end
   if instance == nil then instance = markup.fg.focus('nil') end
   if role     == nil then role     = markup.fg.focus('nil') end
   if type     == nil then type     = markup.fg.focus('nil') end

   naughty.notify({
      text = markup.fg.focus('      Role: ') .. role  .. '\n' ..
             markup.fg.focus('      Type: ') .. type  .. '\n' ..
             markup.fg.focus('      Title: ') .. title .. '\n' ..
             markup.fg.focus('    Class: ') .. class .. '\n' ..
             markup.fg.focus('Instance: ') .. instance,
      timeout = 5,
      hover_timeout = 0.5
   })
end

-- {{{ Wibox
local markup = lain.util.markup
white  = beautiful.fg_focus
gray   = beautiful.fg_normal

-- Create a textclock widget
mytextclock_icon = wibox.widget.imagebox(beautiful.widget_clock)
mytextclock = wibox.widget.textclock(" %a %d %b %H:%M")

-- Calendar
-- FIXME lain
-- lain.widgets.calendar:attach(mytextclock, { fg = beautiful.fg_focus, font_size = 10})

-- Separator
separator = wibox.widget.textbox()
separator:set_text(" | ")

-- Mem
vicious.cache(vicious.widgets.mem)
mem_widgets = wibox.widget.textbox()
vicious.register(mem_widgets, vicious.widgets.mem, "$1% ($2MB)", 13)

-- Load
vicious.cache(vicious.widgets.uptime)
load_widgets = wibox.widget.textbox()
vicious.register(load_widgets, vicious.widgets.uptime, "$4 $5 $6")

-- Cpu freq
vicious.cache(vicious.widgets.cpufreq)
cpu_widgets = wibox.widget.textbox()
vicious.register(cpu_widgets, vicious.widgets.cpufreq, '$5 $2GHz', 20, 'cpu0')

-- Temp
-- temp_icon = wibox.widget.imagebox(beautiful.widget_temp)
-- temp_widgets = lain.widgets.temp({
--     settings = function()
--         widget:set_text(" " .. coretemp_now .. "°C ")
--     end
-- })

-- Bat
bat_widget1 = wibox.widget.textbox()
vicious.register(bat_widget1, vicious.widgets.bat,
                 function (widget, args)
                    local ret = ""
                    local state = args[1]
                    local pct = args[2]
                    local time = args[3]
                    local colors = {
                       LOW  = "#ac7373", -- red-2
                       low  = "#dfaf8f", -- orange
                       med  = "#f0dfaf", -- yellow
                       high = "#afd8af", -- green+3
                       ok   = "lightblue"
                    }
                    local col
                    if state == "⌁" or state == "↯" then
                       -- Unknown or full
                       ret = markup.fg.color(colors["ok"], pct .. "% " .. state)
                    elseif state == "+" then
                       -- Charging
                       ret = markup.fg.color(colors["high"], pct .. "% ↗")
                       if time ~= "N/A" then
                          if pct >= 75 then col = "high"
                          elseif pct < 10 then col = "med"
                          else col = "ok" end
                          ret = ret .. markup.fg.color(colors[col], " (" .. time .. ")")
                       end
                    else
                       -- Discharging
                       if pct <= 25 then col = "LOW" else col = "low" end
                       ret = markup.fg.color(colors[col], pct .. "% ↘")
                       if time ~= "N/A" then
                          if pct <= 25 then col = "LOW"
                          elseif pct <= 50 then col = "low"
                          else col = "ok" end
                          ret = ret .. markup.fg.color(colors[col], " (" .. time .. ")")
                       end
                    end
                    return " " .. ret .. " "
                 end,
                 5, "BAT0")

-- TODO : Manage bat2 with a function
bat_widget2 = wibox.widget.textbox()
vicious.register(bat_widget2, vicious.widgets.bat,
                 function (widget, args)
                    local ret = ""
                    local state = args[1]
                    local pct = args[2]
                    local time = args[3]
                    local colors = {
                       LOW  = "#ac7373", -- red-2
                       low  = "#dfaf8f", -- orange
                       med  = "#f0dfaf", -- yellow
                       high = "#afd8af", -- green+3
                       ok   = "lightblue"
                    }
                    local col
                    if state == "⌁" or state == "↯" then
                       -- Unknown or full
                       ret = markup.fg.color(colors["ok"], pct .. "% " .. state)
                    elseif state == "+" then
                       -- Charging
                       ret = markup.fg.color(colors["high"], pct .. "% ↗")
                       if time ~= "N/A" then
                          if pct >= 75 then col = "high"
                          elseif pct < 10 then col = "med"
                          else col = "ok" end
                          ret = ret .. markup.fg.color(colors[col], " (" .. time .. ")")
                       end
                    else
                       -- Discharging
                       if pct <= 25 then col = "LOW" else col = "low" end
                       ret = markup.fg.color(colors[col], pct .. "% ↘")
                       if time ~= "N/A" then
                          if pct <= 25 then col = "LOW"
                          elseif pct <= 50 then col = "low"
                          else col = "ok" end
                          ret = ret .. markup.fg.color(colors[col], " (" .. time .. ")")
                       end
                    end
                    return " " .. ret .. " "
                 end,
                 5, "BAT1")

-- Volume
--vol_widget = awful.widget.progressbar()
--vol_widget:set_width(10)
--vol_widget:set_height(18)
--vol_widget:set_vertical(true)
--vol_widget:set_background_color("#000000")
--vol_widget:set_border_color("#000000")
--vicious.register(vol_widget, vicious.contrib.pulse,
--                 function (widget, args)
--                    local col = "#6666cc"
--                    local vol = args[1]
--                    if args[2] == "off" then
--                       col = "#666666"
--                       vol = 100
--                    end
--                    widget:set_color(col)
--                    return vol
--                 end, 5, "alsa_output.pci-0000_00_1b.0.analog-stereo")
--
--function volume_up()   vicious.contrib.pulse.add( 5,"alsa_output.pci-0000_00_1b.0.analog-stereo") vicious.force({vol_widget}) end
--function volume_down() vicious.contrib.pulse.add(-5,"alsa_output.pci-0000_00_1b.0.analog-stereo") vicious.force({vol_widget}) end
--function volume_mute() vicious.contrib.pulse.toggle("alsa_output.pci-0000_00_1b.0.analog-stereo") vicious.force({vol_widget}) end
--
--vol_widget:buttons(awful.util.table.join(
--       awful.button({ }, 1, function () awful.util.spawn("pavucontrol") end),
--       awful.button({ }, 4, volume_up),
--       awful.button({ }, 5, volume_down),
--       awful.button({ }, 2, volume_mute)
--))
---- }}}

-- Taskwarrior
-- FIXME lain
--lain.widgets.contrib.task:attach(widget, args)

-- Revelation
revelation.init()

--for s = 1, screen.count() do
awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({"‽", "✉", "✆", "☮", "✪", "❤", "★", "♫", "✍"}, s, awful.layout.layouts[1])
    -- awful.tag({"➊", "➋", "➌", "➍", "➎", "➏", "➐", "➑", "➒" }, s, awful.layout.layouts[1])
    -- ♫ ☢ ☯ ★ ❤ ☎ ✍ ✆ ✿ ¤ ♡

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", height = "18", screen = s, ontop = nil })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(s.mytaglist)
    left_layout:add(s.mypromptbox)

    local my_right_widgets = _.concat(
       mykeyboardlayout,
       load_widgets, separator, cpu_widgets,
       separator, mem_widgets, separator,
       -- temp_icon, temp_widgets, separator, bat_widget1, bat_widget2, vol_widget
       bat_widget1, bat_widget2
    )

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    for i, w in pairs(my_right_widgets) do right_layout:add(w) end
    --if screen.count() == 2 then
    --  if s == 2 then right_layout:add(separator) end
    --  if s == 2 then right_layout:add(wibox.widget.systray()) end
    --else
    --  if s == 1 then right_layout:add(separator) end
    --  if s == 1 then right_layout:add(wibox.widget.systray()) end
    --end
    right_layout:add(separator)
    right_layout:add(wibox.widget.systray())
    right_layout:add(mytextclock_icon)
    right_layout:add(mytextclock)
    right_layout:add(s.mylayoutbox)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(s.mytasklist)
    layout:set_right(right_layout)

    s.mywibox:set_widget(layout)
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    --awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    --awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),
    awful.key({ modkey, "Control" }, "i", win_info),
    awful.key({ }, "Print",   function () awful.util.spawn ("scrot -u") end),
    awful.key({ }, "XF86LaunchA",   function () awful.util.spawn ("/home/sbadia/bin/lock.sh") end),
    awful.key({ }, "XF86AudioMicMute",   function () awful.util.spawn ("amixer -q sset Capture toggle") end),
    awful.key({ }, "XF86MonBrightnessDown",   function () awful.util.spawn ("xbacklight -10") end),
    awful.key({ }, "XF86MonBrightnessUp",   function () awful.util.spawn ("xbacklight +10") end),
    awful.key({ }, "XF86Display",   function () awful.util.spawn ("arandr") end),
    awful.key({ }, "XF86WLAN",   function () awful.util.spawn ("wifi_togle.sh") end),
    --awful.key({ }, "XF86Tools", function () lain.widgets.contrib.task.show(scr) end),
    --awful.key({ modkey, }, "XF86Tools", lain.widgets.contrib.task.prompt_add),
    --XF86Search
    --XF86MyComputer
    awful.key({ }, "XF86AudioRaiseVolume",    function () awful.util.spawn("amixer -q -c 1 sset Master 5+") end),
    awful.key({ }, "XF86AudioLowerVolume",    function () awful.util.spawn("amixer -q -c 1 sset Master 5-") end),
    awful.key({ }, "XF86AudioMute",    function () awful.util.spawn("amixer -q sset Master toggle") end),

    -- Perso
    awful.key({ modkey }, "e", revelation),

    -- Menubar
    -- Prompt
    awful.key({ modkey },            "u",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),

    awful.key({ modkey }, "z", function () awful.util.spawn('passmenu') end),
    awful.key({ modkey }, "g", function () awful.util.spawn("passmenu_gitoyen") end),
    awful.key({ modkey }, "r", function () awful.util.spawn("passmenu_ldn") end),
    awful.key({ modkey }, "b", function () awful.util.spawn("passmenu_clustree") end),
    awful.key({ modkey }, "d", function () awful.util.spawn('rofi -show run -font "snap 10" -hlbg "#000000" -hlfg "#ffb964" -o 85') end),
    awful.key({ modkey }, "c", function () awful.util.spawn('rofi -show ssh -font "snap 10" -hlbg "#000000" -hlfg "#ffb964" -o 85') end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"})
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Compute the maximum number of digit we need, limited to 9
-- keynumber = 0
-- for s = 1, screen.count() do
--    keynumber = math.min(9, math.max(#tags[s], keynumber));
-- end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     size_hints_honor = false,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Nagstamon",
          "Sxiv",
          "Wpa_gui",
          "Pinentry",
          "pinentry",
          "pinentry-gnome3",
          "MPlayer",
          "veromix",
          "xtightvncviewer"},
        type = {
          "dialog",
        },
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true },
         callback = awful.placement.centered
    },

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal" }
      }, properties = { titlebars_enabled = false }
    },
    { rule_any = {
        type = { "dialog" },
        class = { "pinentry", "Pinentry" }
      }, properties = { titlebars_enabled = true },
         callback = awful.placement.centered
    },


    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{
-- Gestion des programmes au lancement
os.execute("nitrogen --restore &")
