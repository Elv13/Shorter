-- Allow pango markup
-- Convert key to string
-- allow sections
local setmetatable = setmetatable
local awful        = require "awful"
local glib         = require( "lgi"         ).GLib
local capi         = {root=root}

local shorter = {__real = {}, __pretty={}}

glib.idle_add(glib.PRIORITY_HIGH_IDLE, function()
    local real = shorter.__real
    capi.root.keys(real)
end)

return setmetatable(shorter,{__newindex=function(self,key,value)
    local name,section_desc=key,value.desc
    local real,pretty = self.__real,self.__pretty
    for k,v in ipairs(value) do
        local key,desc,fct,key_name = v.key,v.desc,v.fct,""
        for k2,v2 in ipairs(key[1]) do
            key_name=key_name..v2.."+"
        end

        key_name=key_name..key[2]
        pretty[#pretty+1] = {}
        local awkey = awful.key(key[1],key[2],fct)

        -- Do as util.join, but avoid the N^2 complexity
        local index = #real
        print(key_name)
        for k2,v2 in ipairs(awkey) do
            real[index+k2] = v2
        end
    end
end})