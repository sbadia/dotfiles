---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local awful = require("awful")
-- }}}


-- Mem: provides RAM and Swap usage statistics
module("vicious.widgets.mem")

-- {{{ Memory widget type
local function worker(format)
    local free = "free -m | grep '-' | awk '{print $3}'"
    local use = awful.util.pread(free)
    return {use}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
