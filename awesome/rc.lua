-- sbadia config <seb@sebian.fr
--
-- /usr/share/awesome/lib/
-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
require("eminent/eminent")
-- Theme handling library
require("beautiful")
require("milious.battery")
require("widget.calendar")
require("obvious.volume_alsa")
--require("obvious.temp_info")
--require("obvious.keymap_switch")
-- Notification library
require("naughty")
-- Un peu de réglages
--naughty.config.presets.normal.border_color="#712900"
--naughty.config.default_preset.bg="#262626"
--naughty.config.default_preset.fg="#8A825A"
--naughty.config.default_preset.border_width=2
--naughty.config.default_preset.font="Meslo LG S DZ 13"
naughty.config.default_preset.screen=1
--naughty.config.default_preset.width = 400
-- Widgets
require("vicious")
-- Load Debian menu entries
require("debian.menu")

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
    awesome.add_signal("debug::error", function (err)
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
beautiful.init( awful.util.getdir("config") .. "/themes/sbadia-default/theme.lua" )
-- beautiful.init( awful.util.getdir("config") .. "/themes/awesome-solarized/dark/theme.lua" )

-- This is used later as the default terminal and editor to run.
-- terminal = "urxvt -pe tabbed"
terminal = "urxvt"
-- terminal = "urxvt -pe tabbed -e /bin/zsh"
-- terminal = "urxvtc -pe tabbed"
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
layouts =
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
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "s2ram", "s2ram" },
   { "halt", "sudo halt" },
   { "quit", awesome.quit }
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

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
separator = widget({ type = "textbox" })
separator.text  = " | "
-- Mem
memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, "$1% ($2MB)", 13)
-- Load
loadwidget = widget({ type = "textbox" })
vicious.register(loadwidget, vicious.widgets.uptime, "$4 $5 $6")
-- Temp
--hddtempwidget = widget({ type = "textbox" })
--vicious.register(hddtempwidget, vicious.widgets.hddtemp, "${/dev/sda} °C", 19)
-- Cpu
cpufreq = widget({ type = "textbox" })
vicious.register(cpufreq, vicious.widgets.cpufreq, '$5 $2GHz', 20, "cpu0")

-- Initialize widget
-- Create a textclock widget
-- mytextclock = awful.widget.textclock({ align = "right" }, "%a %e %b %Y %T", 1)

-- Create a systray
mysystray = widget({ type = "systray" })

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
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
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
function handle_titlebar(c)
   if awful.client.floating.get(c) then
      if not c.titlebar and not no_titlebar_apps[c.class] and not no_titlebar_apps[c.instance] then
         awful.titlebar.add(c, { modkey = modkey })
      end
   else
      if c.titlebar then
         awful.titlebar.remove(c)
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



for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
	separator,
	memwidget,
	separator,
	loadwidget,
	separator,
        --obvious.temp_info(),
	--separator,
	cpufreq,
	separator,
        milious.battery(),
	separator,
        obvious.volume_alsa(0, "Master").widget,
        separator,
        --obvious.keymap_switch(),
        --separator,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
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
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
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
