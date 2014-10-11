---------------------------------------------------
-- Licensed under the GNU General Public License v2
-- Author: Émile Morel
-- inspired by awesome vicious/obvious scripts
---------------------------------------------------

module("milious.lib.helpers")

-- {{{ Format a string with args
function format(format, args)
    for var, val in pairs(args) do
        format = format:gsub("$" .. var, val)
    end

    return format
end
-- }}}

-- {{{ Escape a string
function escape(text)
    local xml_entities = {
        ["\""] = "&quot;",
        ["&"]  = "&amp;",
        ["'"]  = "&apos;",
        ["<"]  = "&lt;",
        [">"]  = "&gt;"
    }
    return text and text:gsub("[\"&'<>]", xml_entities)
end
-- }}}

function color(color, text)
  return '<span foreground="' .. color .. '">' .. text .. '</span>'
end
