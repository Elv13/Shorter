-- Allow pango markup
-- Convert key to string
-- allow sections
-- quit on escape
-- never show again button
--round corner
-- beautiful support
-- fix all themes
local setmetatable = setmetatable
local awful        = require "awful"
local wibox        = require( "wibox"       )
local beautiful    = require( "beautiful"   )
local glib         = require( "lgi"         ).GLib
local capi         = {root=root,screen=screen}

local shorter = {__real = {}, __pretty={}}
local font = nil

local function limit_fit(l,w)
    l._fit = l.fit
    l.fit = function(self,w3,h3)
        local w2,h2 = l._fit(self,w3,h3)
        return w+15,h2
    end
end

local function create_wibox()
    local geo = capi.screen[1].geometry
    local w = wibox {x=geo.x + 50,y=geo.y+50,width=geo.width-100,height=geo.height-100}
    local left = geo.width
    w.visible = true
    w:set_bg("#000022")
    w:set_fg("#ff0000")
    return w, left,geo.height
end

local function gen_groups()
    local ret = {}
    for name,section in pairs(shorter.__pretty) do
        local cat_keys,cat_desc="",""
        for k,v in ipairs(section) do
            cat_keys = cat_keys .. "\n" .. v.key
            cat_desc = cat_desc .. "\n -- " .. v.desc
        end
        ret[name] = {cat_keys,cat_desc}
    end
    return ret
end

local function gen_groups_widgets()
    -- Remove the bold if the theme use it
    if not font then
        font = (beautiful.font or ""):gsub("( [Dd]emi[Bb]old)",""):gsub("( [Bb]old)","")
    end
    local groups,ret = gen_groups(),{}
    for name,content in pairs(groups) do
        local tb3 = wibox.widget.textbox("<tt>"..name:upper().."</tt>")
        tb3:set_align("center")
        tb3:set_valign("bottom")
        local hw,hh = tb3:fit(99999,99999)
        tb3.fit = function(self,w,h) return wibox.widget.textbox.fit(self,w,h),hh+20 end

        local tb1 = wibox.widget.textbox("<b>"..content[1].."</b>")
        local tb2 = wibox.widget.textbox("<i>"..content[2].."</i>")
        tb1:set_font(font)
        tb2:set_font(font)
        local l2 = wibox.layout.fixed.horizontal()
        l2:add(tb1)
        l2:add(tb2)

        local w1,h1 = tb1:fit(999999,999999)
        local w2,h2 = tb2:fit(999999,999999)
        local width = w1+w2+15

        local l = wibox.layout.fixed.vertical()
        l:add(tb3)
        l:add(l2)
        limit_fit(l,width)
        l.width = width
        l.height = math.max(h1,h2) + hh+20
        ret[#ret+1] = l
    end

    table.sort(ret, function(a,b) return a.width > b.width end)

    return ret
end

local function show()
    local w,left,height = create_wibox()

    local l = wibox.layout.fixed.horizontal()

    local cols = {}

    local groups = gen_groups_widgets()
    for _,group in ipairs(groups) do
        local width = group.width

        if left > width then
            table.insert(l.widgets, 1, group)
            group:connect_signal("widget::updated", l._emit_updated)
            l._emit_updated()
            cols[#cols+1] = group
        else
            local best,dx = nil,99999
            for k,v in ipairs(cols) do
                local cw = v.width
                print("HERE",v.height , group.height,v.height + group.height < height)
                if cw > width and (width-cw) < dx and v.height + group.height < height - 100 then
                    dx = width-cw
                    best = v
                end
            end
            if best then
                best:add(group)
                best.height = best.height + group.height
            end
        end

        left = left - width
    end

    w:set_widget(l)
end

glib.idle_add(glib.PRIORITY_HIGH_IDLE, function()
    local real = shorter.__real
    capi.root.keys(real)
    show()
end)

function shorter.toMarkDown()
    
end

function shorter.toManPage()
    
end

function shorter.print()
    
end

return setmetatable(shorter,{__newindex=function(self,key,value)
    local name,section_desc=key,value.desc
    local real,pretty = self.__real,self.__pretty
    for k,v in ipairs(value) do
        local key,desc,fct,key_name = v.key,v.desc,v.fct,""
        for k2,v2 in ipairs(key[1]) do
            key_name=key_name..v2.."+"
        end

        key_name=key_name..key[2]
        local sec = pretty[name]
        if not sec then
            sec = {}
            pretty[name] = sec
        end
        sec[#sec+1] = {key=key_name,desc=desc}
        local awkey = awful.key(key[1],key[2],fct)

        -- Do as util.join, but avoid the N^2 complexity
        local index = #real
        for k2,v2 in ipairs(awkey) do
            real[index+k2] = v2
        end
    end
end})