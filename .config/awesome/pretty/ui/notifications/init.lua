local capi = require("capi")
-- Standard awesome library
local awful = require("awful")
local gears = require("gears")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local dpi = beautiful.xresources.apply_dpi

local helpers = require("helpers")

--------------------------------------------------

local icon_theme = require("pretty.icon_theme")
local widgets = require("pretty.ui._widgets")

local animation_service = require("evil.animation")

--------------------------------------------------

local function get_oldest_notification()
    for _, notif in ipairs(naughty.active) do
        if notif and notif.timeout > 0 then
            return notif
        end
    end
    -- Fallback to first one
    return naughty.active[1]
end
naughty.connect_signal("request::icon", function (notif, context, hints)
    if context ~= "app_icon" then return end

    local path = icon_theme:get_icon_path(hints.app_icon) or icon_theme:get_icon_path(hints.app_icon:lower())
    if path then notif.icon = path end
end)
naughty.connect_signal("request::action_icon", function (action, _, hints)
    action.icon = icon_theme:get_icon_path(hints.id)
end)

-- Do not allow notifications to auto-expire
naughty.expiration_paused = true

naughty.config.defaults.ontop = true
naughty.config.defaults.title = "Notification"
naughty.config.defaults.screen = capi.mouse.screen
naughty.config.defaults.position = "top_middle"

naughty.image_animations_enabled = true
beautiful.notification_spacing = dpi(5)

naughty.connect_signal("request::display", function (n)
    if #naughty.active > 5 then
        get_oldest_notification():destroy(naughty.notification_closed_reason.too_many_on_screen)
    end

    local accent_color = (n.urgency == "critical") and beautiful.xcolor3 or beautiful.xcolor4
    local notif_box

    local app_name = wibox.widget {
        markup = n.app_name and n.app_name:gsub("^%l", string.upper) or "Notification",
        font   = "Iosevka Bold 12",
        widget = wibox.widget.textbox,
    }
    local dismiss = widgets.button {
        bg_hover = beautiful.xcolor1,
        bg_press = beautiful.xcolor1 .. "88",
        on_button_release = function () n:destroy(naughty.notification_closed_reason.dismissed_by_user) end,
    }
    local timeout_arc = wibox.widget {
        dismiss,
        max_value     = 100,
        min_value     = 0,
        value         = 0,
        start_angle   = math.pi / 2,
        thickness     = dpi(4),
        colors        = { accent_color },
        forced_width  = dpi(20),
        forced_height = dpi(20),
        widget        = wibox.container.arcchart,
    }

    local icon = wibox.widget {
        image      = n.icon,
        resize     = true,
        fit_policy = "fill",
        halign     = "center",
        valign     = "center",
        widget     = wibox.widget.imagebox,
    }
    local app_icon = wibox.widget {
        {
            markup = "",
            font   = "FiraCode Nerd Font Mono 12",
            align  = "center",
            widget = wibox.widget.textbox,
        },
        bg            = accent_color,
        fg            = beautiful.bg_normal,
        shape         = gears.shape.circle,
        forced_width  = dpi(20),
        forced_height = dpi(20),
        widget        = wibox.container.background,
    }

    local title = wibox.widget {
        markup = helpers.string.lines_combine(gears.string.xml_escape(n.title)),
        font   = "Iosevka Bold 15",
        widget = wibox.widget.textbox,
    }
    local message = wibox.widget {
        markup  = helpers.string.lines_combine(gears.string.xml_escape(n.message)),
        font    = "Iosevka 14",
        opacity = 0.8,
        widget  = wibox.widget.textbox,
    }

    local actions = wibox.widget {
        notification = n,
        base_layout  = wibox.widget {
            spacing = dpi(3),
            layout  = wibox.layout.flex.horizontal,
        },
        widget_template = setmetatable({}, { __call = function ()
            return widgets.button {
                {
                    id     = "text_role",
                    font   = "Iosevka 8",
                    align  = "center",
                    widget = wibox.widget.textbox,
                },
                paddings      = { left = dpi(6), right = dpi(6) },
                bg            = beautiful.fg_normal .. "11",
                bg_hover      = accent_color .. "44",
                bg_press      = accent_color .. "33",
                shape         = helpers.ui.rrect(beautiful.border_radius / 2),
                forced_width  = dpi(70),
                forced_height = dpi(25),
            }
        end }),
        style = {
            underline_normal   = false,
            underline_selected = true,
        },
        widget = naughty.list.actions,
    }
    actions._private.default_buttons = {
        awful.button {
            modifiers = {},
            button    = 1,
            on_release = function (a) a:invoke(n) end,
        },
    }

    notif_box = naughty.layout.box {
        notification  = n,
        type          = "notification",
        minimum_width = n.screen.geometry.width * 0.2,
        maximum_width = n.screen.geometry.width * 0.4,
        -- For antialiasing: The real shape is set in widget_template
        shape         = gears.shape.rectangle,
        bg            = "#00000000",
        widget_template = n.widget_template or {
            {
                {
                    {
                        {
                            app_name,
                            nil,
                            {
                                timeout_arc,
                                reflection = { vertical = true },
                                layout     = wibox.container.mirror,
                            },
                            layout = wibox.layout.align.horizontal,
                        },
                        top    = dpi(10),
                        bottom = dpi(10),
                        left   = dpi(15),
                        right  = dpi(15),
                        widget = wibox.container.margin,
                    },
                    bg     = accent_color .. "22",
                    fg     = accent_color,
                    widget = wibox.container.background,
                },
                {
                    {
                        {
                            {
                                icon,
                                border_width  = dpi(2),
                                border_color  = accent_color,
                                shape         = gears.shape.circle,
                                widget        = wibox.container.background,
                            },
                            {
                                app_icon,
                                halign = "right",
                                valign = "bottom",
                                widget = wibox.container.place,
                            },
                            forced_width  = dpi(60),
                            forced_height = dpi(60),
                            layout        = wibox.layout.stack,
                        },
                        {
                            {
                                {
                                    title,
                                    fps           = 60,
                                    speed         = 75,
                                    extra_space   = 50,
                                    step_function = helpers.ui.wait_linear_increase_scrolling,
                                    widget        = widgets.declarative.scroll.horizontal,
                                },
                                {
                                    message,
                                    fps           = 60,
                                    speed         = 75,
                                    extra_space   = 50,
                                    step_function = helpers.ui.wait_linear_increase_scrolling,
                                    widget        = widgets.declarative.scroll.horizontal,
                                },
                                layout  = wibox.layout.fixed.vertical,
                            },
                            halign = "left",
                            widget = wibox.container.place,
                        },
                        spacing = dpi(10),
                        layout = wibox.layout.fixed.horizontal,
                    },
                    top    = dpi(10),
                    bottom = dpi(10),
                    left   = dpi(10),
                    right  = dpi(10),
                    widget = wibox.container.margin,
                },
                {
                    actions,
                    bottom  = dpi(10),
                    left    = dpi(10),
                    right   = dpi(10),
                    visible = n.actions and #n.actions > 0 or false,
                    widget  = wibox.container.margin,
                },
                layout = wibox.layout.fixed.vertical,
            },
            shape        = helpers.ui.rrect(beautiful.border_radius),
            bg           = beautiful.bg_normal,
            border_width = dpi(1),
            border_color = accent_color .. "44",
            widget       = wibox.container.background,
        },
    }
    -- Clicking on the notif won't destroy it, use the dismiss button
    notif_box.buttons = {}

    local anim = animation_service {
        duration = n.timeout > 0 and n.timeout or math.huge,
        target   = 100,
        update   = function (_, pos) timeout_arc.value = pos end,
    }
    anim:connect_signal("ended", function () n:destroy() end)

    notif_box:connect_signal("mouse::enter", function () anim:stop(); timeout_arc.value = 0 end)
    notif_box:connect_signal("mouse::leave", function () anim:restart() end)

    local function notif_update(notif)
        icon:set_image(notif.icon)
        title:set_markup_silently(helpers.string.lines_combine(gears.string.xml_escape(notif.title)))
        message:set_markup_silently(helpers.string.lines_combine(gears.string.xml_escape(notif.message)))

        if capi.mouse.current_wibox == notif_box then return end
        anim:restart()
    end
    n:connect_signal("property::icon", notif_update)
    n:connect_signal("property::title", notif_update)
    n:connect_signal("property::message", notif_update)

    anim:start()
end)
