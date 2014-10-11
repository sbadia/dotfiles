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
module("milious.imap")

widget = capi.widget({ type = "textbox" })

local data = {}

local function get_data()
    local findnew = "find .Mail/*/*/new/ -name *, | wc -l"
    data = {}
    data.readnew = awful.util.pread(findnew)
end

local function format()
    local color = "#900000"
    if tonumber(data.readnew) > 1 then 
       color = "#909000"
    end
    widget.text = lib.helpers.color(color, "✉") .. " " .. data.readnew 
end

local function update()
    get_data()
    format()
end

update()
lib.hooks.timer.register(120, 300, update)
lib.hooks.timer.start(update)

setmetatable(_M, { __call = function () 
    return widget 
end })
