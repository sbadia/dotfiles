---------------------------
-- Default awesome theme --
---------------------------

local theme = {}

theme.dir = os.getenv('HOME') .. "/.config/awesome/themes/sbadia-default"

theme.menu_awesome_icon             = theme.dir .."/icons/awesome.png"
theme.awesome_icon = "/usr/share/awesome/themes/zenburn/awesome-icon.png"
-- theme.submenu_icon                  = theme.dir .."/icons/submenu.png"
theme.taglist_squares_sel           = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel         = theme.dir .. "/icons/square_unsel.png"

-- http://wmii.suckless.org/themes
-- WMII_FOCUSCOLORS=('#A0FF00' '#686363' '#8c8c8c')
-- WMII_BACKGROUND='#333333'
-- WMII_NORMCOLORS=('#e0e0e0' '#444444' '#666666')

theme.font = "sans 8"
-- couleur barre
theme.bg_normal = "#666666"
theme.bg_focus = "#8c8c8c"
--theme.bg_urgent = "#ff0000"
theme.bg_urgent = "#ee720e"
-- couleur texte
theme.fg_normal = "#e0e0e0"
theme.fg_focus = "#A0FF00"
theme.fg_urgent = "#ffffff"
-- couleur bordure
theme.border_width = "1"
theme.border_normal = "#444444"
--theme.border_focus = "#686363"
-- Ocre
--theme.border_focus = "#DFAF2C"
-- Orange
--theme.border_focus = "#ED7F10"
-- Vert
theme.border_focus = "#60771f"
theme.border_marked = "#ff0000"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
-- theme.taglist_squares_sel   = "/usr/share/awesome/themes/default/taglist/squarefw.png"
-- theme.taglist_squares_unsel = "/usr/share/awesome/themes/default/taglist/squarew.png"
-- theme.tasklist_floating_icon = "/usr/share/awesome/themes/default/tasklist/floating.png"

theme.mouse_finder_color = "#CC9393"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = "/usr/share/awesome/themes/default/submenu.png"
theme.menu_height = "15"
theme.menu_width  = "100"

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = "/usr/share/awesome/themes/default/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = "/usr/share/awesome/themes/default/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal = "/usr/share/awesome/themes/default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = "/usr/share/awesome/themes/default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = "/usr/share/awesome/themes/default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = "/usr/share/awesome/themes/default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = "/usr/share/awesome/themes/default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = "/usr/share/awesome/themes/default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/maximized_focus_active.png"

-- You can use your own command to set your wallpaper
--theme.wallpaper_cmd = { "awsetbg /usr/share/awesome/themes/default/background.png" }
--theme.wallpaper_cmd = { "awsetbg /home/sbadia/Wallpaper/wall_deb_1680.png" }
theme.wallpaper_cmd = { "nitrogen --restore &" }
--theme.wallpaper_cmd = { "awsetbg /home/sbadia/Wallpaper/San_Francisco_bay_bridge.1680x1050.jpg" }

-- You can use your own layout icons like this:
-- theme.layout_fairh      = "/usr/share/awesome/themes/zenburn/layouts/fairh.png"
-- theme.layout_fairv      = "/usr/share/awesome/themes/zenburn/layouts/fairv.png"
-- theme.layout_floating   = "/usr/share/awesome/themes/zenburn/layouts/floating.png"
-- theme.layout_magnifier  = "/usr/share/awesome/themes/zenburn/layouts/magnifier.png"
-- theme.layout_max        = "/usr/share/awesome/themes/zenburn/layouts/max.png"
-- theme.layout_fullscreen = "/usr/share/awesome/themes/zenburn/layouts/fullscreen.png"
-- theme.layout_tilebottom = "/usr/share/awesome/themes/zenburn/layouts/tilebottom.png"
-- theme.layout_tileleft   = "/usr/share/awesome/themes/zenburn/layouts/tileleft.png"
-- theme.layout_tile       = "/usr/share/awesome/themes/zenburn/layouts/tile.png"
-- theme.layout_tiletop    = "/usr/share/awesome/themes/zenburn/layouts/tiletop.png"
-- theme.layout_spiral     = "/usr/share/awesome/themes/zenburn/layouts/spiral.png"
-- theme.layout_dwindle    = "/usr/share/awesome/themes/zenburn/layouts/dwindle.png"

theme.layout_fairh = "/usr/share/awesome/themes/default/layouts/fairhw.png"
theme.layout_fairv = "/usr/share/awesome/themes/default/layouts/fairvw.png"
theme.layout_floating  = "/usr/share/awesome/themes/default/layouts/floatingw.png"
theme.layout_magnifier = "/usr/share/awesome/themes/default/layouts/magnifierw.png"
theme.layout_max = "/usr/share/awesome/themes/default/layouts/maxw.png"
theme.layout_fullscreen = "/usr/share/awesome/themes/default/layouts/fullscreenw.png"
theme.layout_tilebottom = "/usr/share/awesome/themes/default/layouts/tilebottomw.png"
theme.layout_tileleft   = "/usr/share/awesome/themes/default/layouts/tileleftw.png"
theme.layout_tile = "/usr/share/awesome/themes/default/layouts/tilew.png"
theme.layout_tiletop = "/usr/share/awesome/themes/default/layouts/tiletopw.png"
theme.layout_spiral  = "/usr/share/awesome/themes/default/layouts/spiralw.png"
theme.layout_dwindle = "/usr/share/awesome/themes/default/layouts/dwindlew.png"
theme.layout_cornernw = "/usr/share/awesome/themes/default/layouts/cornernww.png"
theme.layout_cornerne = "/usr/share/awesome/themes/default/layouts/cornernew.png"
theme.layout_cornersw = "/usr/share/awesome/themes/default/layouts/cornersww.png"
theme.layout_cornerse = "/usr/share/awesome/themes/default/layouts/cornersew.png"

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
