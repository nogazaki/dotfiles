-- Standard awesome library
local awful = require("awful")
local gears = require("gears")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")

local capi = require("capi")

local dpi = beautiful.xresources.apply_dpi

--------------------------------------------------

local path = ...

local widgets = require("pretty.ui._widgets")
local animation = require("evil.animation")

local width = { normal = dpi(50), expand = dpi(550) }

local _bar = { _private = {} }
_bar.arrange = awful.placement.left + awful.placement.maximize_vertically
function _bar:expand()
    if self.width == width.expand then return end
    self.expander:set(width.expand)
end
function _bar:collapse()
    if self.width == width.normal then return end
    self.expander:set(width.normal)
end
function _bar:toggle()
    if self.width < width.expand then
        self:expand()
    else
        self:collapse()
    end
end

function _bar:set_panel(panel)
    if not panel then return end

    self.panel_queue = panel
    self.switcher:connect_signal("ended", self.switcher.fade_in)
    self.switcher:fade_out()
end
function _bar:get_panel()
    return self.widget:get_children_by_id("panel")[1].widget
end
function _bar:reset_panel()
    self:set_panel(require("pretty.ui.dashboard"))
end

capi.screen.connect_signal("request::desktop_decoration", function (screen)
    local bar = wibox {
        screen  = screen,
        bg      = beautiful.bg_normal .. "FF",
        width   = width.normal,
        visible = true,
        ontop   = true,
        type    = "dock",
        widget  = {
            {
                {
                    nil,
                    -- Panel
                    {
                        {
                            id           = "panel",
                            left         = dpi(10),
                            forced_width = width.expand - width.normal,
                            widget       = wibox.container.margin,
                        },
                        halign       = "right",
                        fit_vertical = true,
                        widget       = widgets.declarative.overflow,
                    },
                    -- Bar
                    {
                        require(path .. ".clock"),
                        {
                            require(path .. ".taglist")(screen),
                            left   = dpi(5),
                            right  = dpi(5),
                            widget = wibox.container.margin,
                        },
                        {
                            require(path .. ".layoutbox")(screen),
                            left   = dpi(10),
                            right  = dpi(10),
                            widget = wibox.container.margin,
                        },
                        forced_width = width.normal,
                        expand       = "none",
                        layout       = wibox.layout.align.vertical,
                    },
                    layout = wibox.layout.align.horizontal,
                },
                top    = dpi(10),
                bottom = dpi(10),
                widget = wibox.container.margin,
            },
            layout = wibox.layout.stack,
        },
    }
    gears.table.crush(bar, _bar, true)
    -- Place the bar on screen
    bar:struts { left = width.normal }
    bar:arrange { parent = screen }

    -- Panel expanding/collapsing animation
    bar.expander = animation {
        initial  = width.normal,
        duration = 0.2,
        easing   = "in_cubic",
        update   = function (_, pos) bar.width = pos end
    }
    -- Panel expanding/collapsing activator
    bar.activator = wibox.widget.background()
    bar.activator.forced_width = dpi(2)
    bar.widget:add {
        bar.activator,
        content_fill_vertical = true,
        halign                = "left",
        widget                = wibox.container.place,
    }
    bar.activator:connect_signal("mouse::enter", function (self)
        if self.timer then self.timer:stop(); self.timer = nil return end
        self.timer = gears.timer.start_new(0.25, function ()
            self.timer = nil
            bar:expand()
        end)
    end)
    bar.activator:connect_signal("mouse::leave", function (self)
        if self.timer then self.timer:stop(); self.timer = nil end
        self.timer = gears.timer.start_new(0.5, function ()
            self.timer = nil
            bar:collapse()
        end)
    end)
    bar:connect_signal("property::width", function ()
        bar.activator.forced_width = bar.width > width.normal and bar.width or dpi(1)
    end)

    -- Panel switching animation
    bar.switcher = animation {
        initial  = bar:get_children_by_id("panel")[1].opacity,
        duration = 0.5,
        update   = function (_, pos) bar:get_children_by_id("panel")[1].opacity = pos end,
    }
    function bar.switcher:fade_out() self:set(0) end
    function bar.switcher:fade_in()
        self:disconnect_signal("ended", self.fade_in)
        bar.widget:get_children_by_id("panel")[1].widget = bar.panel_queue
        self:set(self.initial)
        bar.panel_queue = nil
    end

    bar:reset_panel()

    screen:connect_signal("property::geometry", function (self)
        bar:arrange { parent = self }
    end)
    screen:connect_signal("removed", function ()
        bar.visible = false; bar = nil
    end)

    screen.bar = bar
end)

local function ontop_handle(client)
    if not client.screen.bar then return end
    client.screen.bar.ontop = not (capi.client.focus and (capi.client.focus == client) and client.fullscreen)
end
capi.client.connect_signal("property::fullscreen", ontop_handle)
capi.client.connect_signal("focus", ontop_handle)
capi.client.connect_signal("unfocus", ontop_handle)
