-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
awful.mouse.finder = require("awful.mouse.finder")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- User libraries
local revelation = require("revelation")
local vicious = require("vicious")
vicious.contrib = require("vicious.contrib")
local _ = require("underscore")
local lain = require("lain")
-- Eminent dynamic tagging
require("eminent")
-- Pomodoro
local pomodoro = require("pomodoro")
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
                         text = err })
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
terminal = "urxvtcd"
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
local layouts =
{
    awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    awful.layout.suit.floating,
    awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.magnifier
}
--- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
tags[1] = awful.tag({"‽", "✉", "✆", "☮", "✪", "❤", "★", "♫", "✍"}, 1, layouts[1])
for s = 2, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({"➊", "➋", "➌", "➍", "➎", "➏", "➐", "➑", "➒" }, s, layouts[1])
end

-- ♫ ☢ ☯ ★ ❤ ☎ ✍ ✆ ✿ ¤ ♡

-- Customize some tags
-- awful.tag.setmwfact(0.72, tags[1][1])
-- awful.tag.setmwfact(0.72, tags[1][2])
-- awful.tag.setmwfact(0.65, tags[1][3])
-- awful.tag.setmwfact(0.65, tags[1][8])

-- Set last tag of each screen to floating
-- for s = 1, screen.count() do
--    awful.layout.set(layouts[8], tags[s][9])
-- end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit },
   { "s2ram", "s2ram" },
   { "halt", "sudo halt" },
}

myessential = {
	{ "Iceweasel", "iceweasel" },
	{ "Icedove", "icedove" },
	{ "URxvt", "urxvt" },
	{ "Qalculate", "qalculate" },
	{ "ScreenShot", "gnome-screenshot" },
	{ "Thunar", "thunar" },
	{ "Vlc", "vlc" },
	{ "Rhythmbox", "rhythmbox" },
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

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() then
                awful.tag.viewonly(c:tags()[1])
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 3, function ()
        if instance then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ width=250 })
        end
    end),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end))

-- Gestion de la titlebar
local all_titlebars = {}
function titlebar_add(c)
    if c.type == "normal" or c.type == "dialog" then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
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
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
        all_titlebars[c] = true
    end
end
function titlebar_remove(c)
   awful.titlebar(c, { size = 0 })
   all_titlebars[c] = false
end
function toggle_titlebar(c)
   if all_titlebars[c] then
      titlebar_remove(c)
   else
      titlebar_add(c)
   end
end
function handle_titlebar(c)
   if awful.client.floating.get(c) then
      -- TODO
      if not all_titlebars[c] and not no_titlebar_apps[c.class] and not no_titlebar_apps[c.instance] then
         titlebar_add(c)
      end
   else
      if all_titlebars[c] then
         titlebar_remove(c)
      end
   end
end

-- Fenêtres "transient"
function get_transient(c)
   for k, v in pairs(client.get()) do
      if v.transient_for == c then
         return v
      end
   end
   return c
end
function new_transient(c)
   if client.focus == c.transient_for then
      client.focus = c
   end
end
-- }}}

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

-- Localiser le pointeur de la souris
mymousefinder = awful.mouse.finder()

-- {{{ Wibox
markup = lain.util.markup
white  = beautiful.fg_focus
gray   = beautiful.fg_normal

-- Create a textclock widget
mytextclock_icon = wibox.widget.imagebox(beautiful.widget_clock)
mytextclock = awful.widget.textclock(" %a %d %b %H:%M")

-- Calendar
lain.widgets.calendar:attach(mytextclock, { fg = beautiful.fg_focus, font_size = 10})

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

-- Redshift widget
icons_dir = require("lain.helpers").icons_dir
local rs_on = icons_dir .. "/redshift/redshift_on.png"
local rs_off = icons_dir .. "/redshift/redshift_off.png"
local redshift = lain.widgets.contrib.redshift
redshift_widgets = wibox.widget.imagebox(rs_on)
redshift:attach(
    redshift_widgets,
    function ()
        if redshift:is_active() then
            redshift_widgets:set_image(rs_on)
        else
            redshift_widgets:set_image(rs_off)
        end
    end
)

-- Temp
temp_icon = wibox.widget.imagebox(beautiful.widget_temp)
temp_widgets = lain.widgets.temp({
    settings = function()
        widget:set_text(" " .. coretemp_now .. "°C ")
    end
})

-- Bat
bat_widget = wibox.widget.textbox()
vicious.register(bat_widget, vicious.widgets.bat,
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
-- Volume
vol_widget = awful.widget.progressbar()
vol_widget:set_width(10)
vol_widget:set_height(18)
vol_widget:set_vertical(true)
vol_widget:set_background_color("#000000")
vol_widget:set_border_color("#000000")
vicious.register(vol_widget, vicious.contrib.pulse,
                 function (widget, args)
                    local col = "#6666cc"
                    local vol = args[1]
                    if args[2] == "off" then
                       col = "#666666"
                       vol = 100
                    end
                    widget:set_color(col)
                    return vol
                 end, 5)

function volume_up()   vicious.contrib.pulse.add( 5)  vicious.force({vol_widget}) end
function volume_down() vicious.contrib.pulse.add(-5)  vicious.force({vol_widget}) end
function volume_mute() vicious.contrib.pulse.toggle() vicious.force({vol_widget}) end

vol_widget:buttons(awful.util.table.join(
       awful.button({ }, 1, function () awful.util.spawn("pavucontrol") end),
       awful.button({ }, 4, volume_up),
       awful.button({ }, 5, volume_down),
       awful.button({ }, 2, volume_mute)
))
---- }}}

-- Pomodoro widget
pomodoro.init()

-- Revelation
revelation.init()

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", height = "18", screen = s, ontop = nil })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    local my_right_widgets = _.concat(
       pomodoro.icon_widget, redshift_widgets, separator,
       load_widgets, separator, cpu_widgets,
       separator, mem_widgets, separator,
       temp_icon, temp_widgets, separator, bat_widget, vol_widget
    )

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    for i, w in pairs(my_right_widgets) do right_layout:add(w) end
    if screen.count() == 2 then
      if s == 2 then right_layout:add(separator) end
      if s == 2 then right_layout:add(wibox.widget.systray()) end
    else
      if s == 1 then right_layout:add(separator) end
      if s == 1 then right_layout:add(wibox.widget.systray()) end
    end
    right_layout:add(mytextclock_icon)
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
 end
-- }}}
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
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey, "Control" }, "i", win_info),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    --awful.key({ }, "XF86Display",    function () awful.util.spawn("") end),
    --awful.key({ }, "XF86Sleep", function () awful.util.spawn ("s2ram") end),
    --awful.key({ }, "XF86Battery", function () awful.util.spawn ("s2disk") end),
    awful.key({ }, "Print",   function () awful.util.spawn ("scrot -u") end),
    awful.key({ }, "Pause",   function () awful.util.spawn ("i3lock -d -c 000000") end),
    --awful.key({ }, "XF86AudioRaiseVolume",    function () awful.util.spawn("amixer set Master 2+ > /dev/null") end),
    awful.key({ }, "XF86AudioRaiseVolume",    function () awful.util.spawn("amixer -q -c 0 sset Master 5+") end),
    --awful.key({ }, "XF86AudioLowerVolume",    function () awful.util.spawn("amixer set Master 2- > /dev/null") end),
    awful.key({ }, "XF86AudioLowerVolume",    function () awful.util.spawn("amixer -q -c 0 sset Master 5-") end),
    awful.key({ }, "XF86AudioMute",    function () awful.util.spawn("amixer -q sset Master toggle") end),

    -- Perso
    awful.key({ modkey }, "c", function () awful.util.spawn("xfce4-popup-clipman") end),
    awful.key({ modkey }, "g", function () awful.util.spawn("gajim") end),

    -- Prompt
    -- Anciennement "r"
    awful.key({ modkey }, "e", revelation),
    awful.key({ modkey }, "p", function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "d", function () awful.util.spawn('dmenu_run') end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    --{ rule = { class = "firefox" },
    --  properties = { tag = tags[1][1] } },

    --{ rule = { class = "Gajim", role = "roster" },
    --properties = {switchtotag = true,
    --              floating=true,
    --              maximized_vertical=true,
    --              maximized_horizontal=false,
    --              tag = tags[1][3]},
    --callback = function (c)
    --    local cl_width = 240    -- width of buddy list window
    --    local def_left = false  -- default placement (false = roster on right side,
    --                            --                    true = roster on left side)
    --    local scr_area = screen[c.screen].workarea
    --    local cl_strut = c:struts()
    --    local geometry = nil
    --    -- adjust scr_area for this client's struts
    --    if cl_strut ~= nil then
    --        if cl_strut.left ~= nil and cl_strut.left > 0 then
    --            geometry = {x=scr_area.x-cl_strut.left, y=scr_area.y,
    --                        width=cl_strut.left}
    --        elseif cl_strut.right ~= nil and cl_strut.right > 0 then
    --            geometry = {x=scr_area.x+scr_area.width, y=scr_area.y,
    --                        width=cl_strut.right}
    --        end
    --    end
    --    -- scr_area is unaffected, so we can use the naive coordinates
    --    if geometry == nil then
    --        if def_left then
    --            c:struts({left=cl_width, right=0})
    --            geometry = {x=scr_area.x, y=scr_area.y,
    --                        width=cl_width}
    --        else
    --            c:struts({right=cl_width, left=0})
    --            geometry = {x=scr_area.x+scr_area.width-cl_width, y=scr_area.y,
    --                        width=cl_width}
    --        end
    --    end
    --    c:geometry(geometry)
    --end },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = get_transient(c)
        end
    end)
    new_transient(c)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    -- Add a titlebar
    -- handle_titlebar(c)
    c:connect_signal("property::floating", handle_titlebar)
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
    --clistats.focus(c)
end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{
-- Gestion des programmes au lancement
os.execute("nitrogen --restore &")
-- os.execute("system-config-printer-applet &")
os.execute("setxkbmap fr -variant oss")
os.execute("xrdb -load ~/.Xdefaults")
os.execute("xmodmap ~/.Xmodmap")
-- os.execute("mail-notification &")
os.execute("wmname LG3D")
-- os.execute("kerneloops-applet &")

-- disable startup-notification globally
local oldspawn = awful.util.spawn
awful.util.spawn = function (s)
  oldspawn(s, false)
end
