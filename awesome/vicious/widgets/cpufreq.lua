---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local setmetatable = setmetatable
local string = { match = string.match }
local helpers = require("vicious.helpers")
-- }}}


-- Cpufreq: provides freq, voltage and governor info for a requested CPU
module("vicious.widgets.cpufreq")


-- {{{ CPU frequency widget type
local function worker(format, warg)
    if not warg then return end

    local cpufreq = helpers.pathtotable("/sys/devices/system/cpu/"..warg.."/cpufreq")
    local governor_state = {
       ["ondemand\n"]     = "<span color='orange'>↯</span>",
       ["powersave\n"]    = "<span color='green'>⌁</span>",
       ["userspace\n"]    = "<span color='blue'>¤</span>",
       ["performance\n"]  = "<span color='red'>⚡</span>",
       ["conservative\n"] = "<span color='yellow'>⊚</span>"
    }
    -- Default frequency and voltage values
    local freqv = {
        ["mhz"] = "N/A", ["ghz"] = "N/A",
        ["v"]   = "N/A", ["mv"]  = "N/A",
    }

    -- Get the current frequency
    local freq = tonumber(cpufreq.cpuinfo_cur_freq)
    -- Calculate MHz and GHz
    if freq then
        freqv.mhz = freq / 1000
        freqv.ghz = freqv.mhz / 1000

        -- Get the current voltage
        if cpufreq.scaling_voltages then
            freqv.mv = tonumber(string.match(cpufreq.scaling_voltages, freq.."[%s]([%d]+)"))
            -- Calculate voltage from mV
            freqv.v  = freqv.mv / 1000
        end
    end

    -- Get the current governor
    local governor = cpufreq.scaling_governor
    -- Represent the governor as a symbol
    governor = governor_state[governor] or governor or "N/A"

    return {freqv.mhz, freqv.ghz, freqv.mv, freqv.v, governor}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })