-- LuaRocks
-- Check for LuaRocks. (I don't know what this does)


pcall(require, "luarocks.loader")

-- Libraries

-- Awesome libraries
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

-- Widget & layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification libraries
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Enable hotkey widget for Vim and others
require("awful.hotkeys_popup.keys")

-- Error Handling

-- If awesome encounters errors on startup, throw an error and use fallback config.
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
                   title = "Oops, there were errors during startup!",
                   text = awesome.startup_errors })
end

-- If awesome encounters an error after startup, throw an error.
do
  local in_error = false
  awesome.connect_signal("debug::error",
    function (err)
      -- Prevent infinite loop
      if in_error then return end
      in_error = true

      naughty.notify({ preset = naughty.config.presets.critical,
                       title = "Oops, an error occured!",
                       text = tostring(err) })
      in_error = false
    end
  )
end

-- Variable Definitions

-- Load theme. This takes care of colors, icons, font, and wallpaper.
beautiful.init("/home/justin/.config/awesome/theme.lua")

-- Define default terminal and editor.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Set modkey
modkey = "Mod4"

-- Layouts
-- Define table of layouts to use.


awful.layout.layouts = {
  -- Master/stack on R and L
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,

  -- BSP (like yabai)
  awful.layout.suit.spiral.dwindle,

  -- Fullscreen
  awful.layout.suit.max,
  awful.layout.suit.max.fullscreen,

  -- Floating
  awful.layout.suit.floating,


  -- Other layouts
  -- awful.layout.suit.tile.bottom,
  -- awful.layout.suit.tile.top,
  -- awful.layout.suit.fair,
  -- awful.layout.suit.fair.horizontal,
  -- awful.layout.suit.spiral,
  -- awful.layout.suit.magnifier,
  -- awful.layout.suit.corner.nw,
  -- awful.layout.suit.corner.ne,
  -- awful.layout.suit.corner.sw,
  -- awful.layout.suit.corner.se,
}

-- Menu
-- Creates menu (top left icon/right click on desktop) and launcher widget.


myawesomemenu = {
  { "hotkeys", function() hotkeys_popup.show_help(nil, awful,screen.focused()) end },
  { "manual", terminal .. " -e man awesome" },
  { "edit config", editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                       })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal

-- Keyboard indicator
mykeyboardlayout = awful.widget.keyboardlayout()

-- Wibar

-- Create textclock
mytextclock = wibox.widget.textclock()

-- Create wibox for each screen
local taglist_buttons = gears.table.join(
  awful.button({  }, 1, function(t) t:view_only() end),
  awful.button({ modkey }, 1,
    function(t)
      if client.focus then
        client.focus:toggle_tag(t)
      end
    end
  ),
  awful.button({  }, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button({  }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
  awful.button({  }, 1,
    function(c)
      if c == client.focus then
        c.minimized = true
      else
        c:emit_signal(
          "request::activate",
          "tasklist",
          {raise = true}
        )
      end
    end
  ),
  awful.button({  }, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end),
  awful.button({  }, 4, function() awful.client.focus.byidx(1) end),
  awful.button({  }, 5, function() awful.client.focus.byidx(-1) end)
)

-- Wallpaper

local function set_wallpaper(s)
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Reset wallpaper when screen resolution changes
screen.connect_signal("property::geometry", set_wallpaper)

-- Screen elements

awful.screen.connect_for_each_screen(function(s)
  -- Set wallpaper
  set_wallpaper(s)

  -- Create tag table
  awful.tag({ "1", "2", "3", "4", "5", "6" }, s, awful.layout.layouts[1])

  -- Create promptbox
  s.mypromptbox = awful.widget.prompt()

  -- Create imagebox for layout
  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(gears.table.join(
    awful.button({  }, 1, function() awful.layout.inc(1) end),
    awful.button({  }, 3, function() awful.layout.inc(-1) end),
    awful.button({  }, 4, function() awful.layout.inc(1) end),
    awful.button({  }, 5, function() awful.layout.inc(-1) end)
  ))

  -- Create taglist widget
  s.mytaglist = awful.widget.taglist {
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = taglist_buttons
  }

  -- Create tasklist widget
  s.mytasklist = awful.widget.tasklist {
    screen = s,
    filter = awful.widget.tasklist.filter.currenttags,
    buttons = tasklist_buttons
  }

  -- Create wibox
  s.mywibox = awful.wibar({ postition = "top", screen = s })

  -- Add widgets to wibox
  s.mywibox:setup {
    layout = wibox.layout.align.horizontal,
    { -- Left side widgets
      layout = wibox.layout.fixed.horizontal,
      mylauncher,
      s.mytaglist,
      s.mypromptbox,
    },
    s.mytasklist, -- Middle widget
    { -- Right side widgets
      layout = wibox.layout.fixed.horizontal,
      mykeyboardlayout,
      wibox.widget.systray(),
      mytextclock,
      s.mylayoutbox,
    },
  }
end)

-- Mouse Bindings

root.buttons(gears.table.join(
  awful.button({  }, 3, function() mymainmenu:toggle() end),
  awful.button({  }, 4, awful.tag.viewnext),
  awful.button({  }, 5, awful.tag.viewprev)
))

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
                           c:emit_signal("request::activate", "mouse_click", {raise = true})
                         end),
    awful.button({ modkey }, 1, function (c)
                                  c:emit_signal("request::activate", "mouse_click", {raise = true})
                                  awful.mouse.client.move(c)
                                end),
    awful.button({ modkey }, 3, function (c)
                                  c:emit_signal("request::activate", "mouse_click", {raise = true})
                                  awful.mouse.client.resize(c)
                                end)
)

-- Key Bindings

globalkeys = gears.table.join(
  -- Awesome
  awful.key({ modkey }, "s", hotkeys_popup.show_help,
            { description = "show help", group = "awesome" }),
  awful.key({ modkey }, "w", function() mymainmenu:show() end,
            { description = "show main menu", group = "awesome" }),
  awful.key({ modkey, "Control" }, "r", awesome.restart,
            { description = "reload awesome", group = "awesome" }),
  awful.key({ modkey, "Shift" }, "q", awesome.quit,
            { description = "reload awesome", group = "awesome" }),

  -- Tag
  awful.key({ modkey }, "Left", awful.tag.viewprev,
            { description = "view previous tag", group = "tag" }),
  awful.key({ modkey }, "Right", awful.tag.viewnext,
            { description = "view next tag", group = "tag"}),
  awful.key({ modkey }, "Escape", awful.tag.history.restore,
            { description = "view last tag", group = "tag" }),

  -- Client
  awful.key({ modkey }, "j", function() awful.client.focus.byidx(1) end,
            { description = "focus next", group = "client" }),
  awful.key({ modkey }, "k", function() awful.client.focus.byidx(-1) end,
            { description = "focus previous", group = "client" }),

  awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
            { description = "swap with next", group = "client" }),
  awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
            { description = "swap with previous", group = "client" }),

  awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
            { description = "focus next screen", group = "client" }),
  awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
            { description = "focus previous screen", group = "client" }),

  awful.key({ modkey }, "u", awful.client.urgent.jumpto,
            { description = "jump to urgent client", group = "client" }),
  awful.key({ modkey }, "Tab", function()
                                 awful.client.focus.history.previous()
                                 if client.focus then
                                   client.focus:raise()
                                 end
                               end,
            { description = "focus last client", group = "client" }),

  awful.key({ modkey }, "n", function()
                               local c = awful.client.restore()
                               if c then
                                 c:emit_signal(
                                   "request::activate", "key.unminimize", {raise = true}
                                 )
                               end
                             end,
            { description = "restore minimized client", group = "client" }),

  -- Layout
  awful.key({ modkey }, "h", function() awful.tag.incmwfact(-0.05) end,
            { description = "decrease master width", group = "layout" }),
  awful.key({ modkey }, "l", function() awful.tag.incmwfact(0.05) end,
            { description = "increase master width", group = "layout" }),

  awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
            { description = "increase master clients", group = "layout" }),
  awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
            { description = "decrease master clients", group = "layout" }),

  awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
            { description = "increase columns", group = "layout" }),
  awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
            { description = "decrease columns", group = "layout" }),

  awful.key({ modkey }, "space", function() awful.layout.inc(1) end,
            { description = "select next layout", group = "layout" }),
  awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(1) end,
            { description = "select previous layout", group = "layout" }),

  -- Run prompt
  awful.key({ modkey }, "r", function() awful.spawn("/home/justin/.config/rofi/launchers/type-1/launcher.sh") end,
            { description = "run launcher", group = "launcher" }),
  awful.key({ "Control", "Mod1", "Mod4" }, "q", function() awful.spawn("/home/justin/.config/rofi/powermenu/type-1/powermenu.sh") end,
            { description = "run rofi window", group = "launcher" }),

  -- Launcher
  awful.key({ modkey }, "t", function() awful.util.spawn(terminal) end,
            { description = "open terminal", group = "launcher" }),
  awful.key({ modkey }, "b", function() awful.util.spawn("brave") end,
            { description = "open browser", group = "launcher" }),
  awful.key({ modkey }, "e", function() awful.util.spawn("emacsclient -nc") end,
            { description = "open browser", group = "launcher" })
)

clientkeys = gears.table.join(
  awful.key({ modkey }, "f", function(c)
                               c.fullscreen = not c.fullscreen
                               c:raise()
                             end,
            { description = "toggle fullscreen", group = "client" }),
  awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
            { description = "close", group = "client" }),
  awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
            { description = "toggle floating", group = "client" }),
  awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
            { description = "move to master", group = "client" }),
  awful.key({ modkey }, "o", function(c) c:move_to_screen() end,
            { description = "move to screen", group = "client" }),
  awful.key({ modkey }, "t", function(c) c.ontop = not c.ontop end,
            { description = "toggle on top", group = "client" }),
  awful.key({ modkey }, "n", function(c)
                               c.minimized = true
                             end,
            { description = "minimize", group = "client" }),
  awful.key({ modkey }, "m", function(c)
                               c.maximized = not c.maximized
                               c:raise()
                             end,
            { description = "(un)maximize", group = "client"}),
  awful.key({ modkey, "Control" }, "m", function(c)
                                          c.maximized_vertical = not c.maximized_vertical
                                          c:raise()
                                        end,
            { description = "(un)maximize vertical", group = "client" }),
  awful.key({ modkey, "Shift" }, "m", function(c)
                                          c.maximized_horizontal = not c.maximized_horizontal
                                          c:raise()
                                        end,
            { description = "(un)maximize horizontal", group = "client" })
)

-- Bind keys to tags
for i = 1, 6 do
  globalkeys = gears.table.join(globalkeys,
    -- View tag only
    awful.key({ modkey },"#" .. i + 9, function()
                                         local screen = awful.screen.focused()
                                         local tag = screen.tags[i]
                                         if tag then
                                           tag:view_only()
                                         end
                                       end,
              { description = "view tag #"..i, group = "tag" }),
    -- Toggle tag
    awful.key({ modkey, "Control" },"#" .. i + 9, function()
                                                    local screen = awful.screen.focused()
                                                    local tag = screen.tags[i]
                                                    if tag then
                                                      awful.tag.viewtoggle(tag)
                                                    end
                                                  end,
              { description = "toggle tag #"..i, group = "tag" }),
    -- Move client to tag
    awful.key({ modkey, "Shift" },"#" .. i + 9, function()
                                                  if client.focus then
                                                    local tag = client.focus.screen.tags[i]
                                                    if tag then
                                                      client.focus:move_to_tag(tag)
                                                    end
                                                  end
                                                end,
              { description = "move focused client to tag #"..i, group = "tag" }),
    -- Toggle tag on focused client
    awful.key({ modkey, "Control", "Shift" },"#" .. i + 9, function()
                                                  if client.focus then
                                                    local tag = client.focus.screen.tags[i]
                                                    if tag then
                                                      client.focus:toggle_tag(tag)
                                                    end
                                                  end
                                                end,
              { description = "toggle focused client on tag #"..i, group = "tag" })
  )
end

-- Set keys
root.keys(globalkeys)

-- Rules

awful.rules.rules = {
  -- All client match this rule
  { rule = {  },
    properties = { border_width = beautiful.border_width,
                   border_color = beautiful.border_normal,
                   focus = awful.client.focus.filter,
                   raise = true,
                   keys = clientkeys,
                   buttons = clientbuttons,
                   screen = awful.screen.preferred,
                   placement = awful.placement.no_overlap+awful.placement.no_offscreen
    }
  },

  -- Floating clients
  { rule_any = {
      instance = {
        -- Window names
      },
      class = {
        -- Window classes
      },
      name = {
        -- Window names
      },
      role = {
        "AlarmWindow",
        "ConfigManager",
        "pop-up",
        "Popup",
      }
  }, properties = { floating = true }},
  { rule_any = { type = { "normal", "dialog" }
    }, properties = { titlebars_enabled = false }
  },
}

-- Signals

client.connect_signal("manage",
  function(c)
    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
  end
)

-- Add titlebar if set in rules
client.connect_signal("request::titlebars",
  function(c)
    local buttons = gears.table.join(
      awful.button({  }, 1,
        function()
          c:emit_signal("request::activate", "titlebar", { raise = true })
          awful.mouse.client.move(c)
        end
      ),
      awful.button({  }, 3,
        function()
          c:emit_signal("request::activate", "titlebar", { raise = true })
          awful.mouse.client.resize(c)
        end
      )
    )

    awful.titlebar(c) : setup {
      { -- Left
        awful.titlebar.widget.iconwidget(c),
        buttons = buttons,
        layout = wibox.layout.fixed.horizontal
      },
      { -- Middle
        { -- Title
          align = "center",
          widget = awful.titlebar.widget.titlewidget(c)
        },
        buttons = buttons,
        layout = wibox.layout.fixed.horizontal
      },
      { -- Right
        awful.titlebar.widget.floatingbutton(c),
        awful.titlebar.widget.maximizedbutton(c),
        awful.titlebar.widget.stickybutton(c),
        awful.titlebar.widget.ontopbutton(c),
        awful.titlebar.widget.closebutton(c),
        layout = wibox.layout.align.horizontal()
      },
      layout = wibox.layout.align.horizontal
    }
  end
)

-- Sloppy focus & focus follows mouse
client.connect_signal("mouse::enter",
  function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = true })
  end
)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Autostart

awful.util.spawn("picom -b")
awful.util.spawn("1password --silent")
