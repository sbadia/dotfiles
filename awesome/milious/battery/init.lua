--------------------------------
-- Author: Gregor Best        --
-- Copyright 2009 Gregor Best --
--------------------------------
local tonumber = tonumber
local tostring = tostring
local setmetatable = setmetatable
local string = {
    match = string.match
}
local io = {
    popen = io.popen
}
local os = {
    execute = os.execute
}
local capi = {
    widget = widget,
    mouse = mouse
}
local print = print
local naughty = require("naughty")
local beautiful = require("beautiful")

local awful = require("awful")
local lib = {
    hooks = require("obvious.lib.hooks"),
    helpers = require("milious.lib.helpers")
}
module("milious.battery")

widget = capi.widget({ type = "textbox" })

status = {
    ["charged"] = "↯",
    ["full"] = "↯",
    ["high"] = "↯",
    ["discharging"] = "↓",
    ["charging"] = "↑",
    ["unknown"] = "⌁"
}
local data = {}

local function get_data()
    local acpi = "acpi -bat"
    data = {}
    data.state= "unknown"
    data.charge = nil
    data.time = "00:00"
    local read = awful.util.pread(acpi)
    data = {}
    local line = string.match(read,"Battery #?[0-9] *: ([^\n]*)")
    data.state = string.match(line,"([%a]*),.*"):lower()
    data.charge = tonumber(string.match(line,".*, ([%d]?[%d]?[%d]%.?[%d]?[%d]?)%%"))
    data.time = string.match(line,".*, ([%d]?[%d]?:?[%d][%d]:[%d][%d])")
    data.ada = string.match(read,"Adapter #?[0-9] *: ([^\n]*)")
    data.state = status[data.state]
end

local function format()
    local color = "#900000"
    if data.charge > 35 and data.charge < 60 then
        color = "#909000"
    elseif data.charge >= 40 then
        color = "#009000"
    end
    if data.time ~= nil then
        local time = data.time:gsub(":", "")
        time = tonumber(time)
        --if time < 1500 then
        --    naughty.notify({ text = "batterie faible !!! \n reste: " .. data.time  })
        --end
    end
    widget.text = lib.helpers.color(color, tostring(data.state)) .. " " .. awful.util.escape(tostring(data.charge)) .. "%"
end

local function update()
    get_data()
    format()
end

--local function detail()
--    local d = awful.util.pread("acpi -ba")
--    naughty.notify({
--        text = d,
--        screen = capi.mouse.screen
--    })
--end

local function status(st)
    local d = awful.util.pread("acpi -ba")
    st._status = naughty.notify({
        text = d,
        timeout = 0,
    })
end

--widget:buttons(awful.util.table.join(
--    awful.button({ }, 1, detail)
--))

local st = {}
st._status = nil
widget:add_signal("mouse::enter", function () status(st) end)
widget:add_signal("mouse::leave", function () if st._status then naughty.destroy(st._status); st._status = nil end end)

widget:buttons(awful.util.table.join(
    awful.button({ }, 1, detail)
))

update()
lib.hooks.timer.register(60, 300, update)
lib.hooks.timer.start(update)

setmetatable(_M, { __call = function ()
    return widget
end })


