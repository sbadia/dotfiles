-- Author: Émile Morel
-- inspired by awesome vicious/obvious wifi scripts
--
-- TODO: -Add other interfaces


local setmetatable = setmetatable
local lib = {
    hooks = require("obvious.lib.hooks"),
    helpers = require("milious.lib.helpers")
}
local capi = {
       widget = widget
}

local io = {
       open = io.open,
       popen = io.popen
}
local pairs = pairs
local print = print
local table = table
local string = {
       find = string.find,
       match = string.match,
       format = string.format
}
local tonumber = tonumber
local math = { ceil = math.ceil }
local awful = require("awful")
local widget = capi.widget({ type = "textbox" })

-- add your interfaces
-- eth and wlan
local interfaces = {
        eth = "eth0",
        wlan = "wlan0"
}
local data = {}
local naughty = require("naughty")
local beautiful = require("beautiful")

module("milious.network")

local function get_data()
    local ifconfig = "/sbin/ifconfig"
    local iwconfig = "/sbin/iwconfig"
    data = {}
    -- search from interfaces list those was up
    for k,v in pairs(interfaces) do
         -- Get data from ifconfig to find device up (with IP address)
        local read = awful.util.pread(ifconfig .. " " .. v .. " 2>&1")
        local match = string.match(read, "inet adr:([^%s]*)")
        if match ~= nil then
                if k == "wlan" then 
                    local iw = awful.util.pread(iwconfig .. " " .. v .. " 2>&1")
                    read = read .. iw
                end
                data[k] = read 
        end
    end
end

local function detail()
    for k,v in pairs(data) do
        naughty.notify({ text = v, timeout = 0 })
    end
end

local function formatwlan(v)
    local ssid = awful.util.escape(string.match(v, 'ESSID[=:]"(.-)"'))
    local link = tonumber(string.match(v, "Link Quality[=:]([%d]+)"))
    local color = "#009000"
    if link < 50 and link > 10 then
        color = "#909000"
    elseif link <= 10 then
        color = "#900000"
    end
    widget.text = lib.helpers.color(color,"☢") .. " " .. ssid .. " " .. link .. "%"
end

local function formateth(k)
    local color = "#009000"
   widget.text = lib.helpers.color(color,"☢") .. k
end

local function update()
    get_data()
    for k,v in pairs(data) do
        if k == "wlan" then 
            formatwlan(v)
        else
            formateth(k)
        end
    end
end

local function status(st)
    local dev = {} 
    for k,v in pairs(data) do
         table.insert(dev,k .. ": " .. string.match(v, "inet adr:([^%s]*)"))
    end
    dev = table.concat(dev, "\n")
    st._status = naughty.notify({
        text = dev,
        timeout = 0,
    })
end

widget:buttons(awful.util.table.join(
    awful.button({ }, 1, detail)
))

local st = {}
st._status = nil
widget:add_signal("mouse::enter", function () status(st) end)
widget:add_signal("mouse::leave", function () if st._status then naughty.destroy(st._status); st._status = nil end end)

update()
lib.hooks.timer.register(60, 300, update)
lib.hooks.timer.start(update)

setmetatable(_M, { __call = function ()
    return widget
end })

