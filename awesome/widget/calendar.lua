local util = require("awful.util")
local button = require("awful.button")
local calendar = nil
local offset = 0

function remove_calendar()
   if calendar ~= nil then
      naughty.destroy(calendar)
      calendar = nil
      offset = 0
   end
end

function add_calendar(inc_offset)
   local save_offset = offset
   remove_calendar()
   offset = save_offset + inc_offset
   local datespec = os.date("*t")
   day = datespec.day
   datespec = datespec.year * 12 + datespec.month - 1 + offset
   datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
   local cal = awful.util.pread("cal -h -m " .. datespec)
   cal = string.gsub(cal, "%s(" .. day .. ")%s", " <span color='#ff8800'>%1</span> ")
   calendar = naughty.notify({
				text = string.format('<span font_desc="%s">%s</span>', "monospace", cal),
				timeout = 0, hover_timeout = 0.5,
				width = 160,
			     })
end
mytextclock = awful.widget.textclock({ align = "right" }, "%a %e %b %Y %T ", 1)
mytextclock:add_signal("mouse::enter", function()
					  add_calendar(0)
				       end)
mytextclock:add_signal("mouse::leave", remove_calendar)

mytextclock:buttons(util.table.join(
		       button({ }, 3, function () add_calendar(-1) end), -- RIGHT MOUSE: clear highlight
		       button({ }, 1, function () add_calendar(1) end) -- LEFT MOUSE: toggle state
		 ))
