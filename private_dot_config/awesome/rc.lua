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

-- Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

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
  awesome.connect_signal("debug::error", function (err)
    -- Prevent infinite loop
    if in_error then return end
    in_error = true

    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, an error occured!",
                     text = tostring(err) })
    in_error = false
  end)
end

-- Variable Definitions

-- Load theme. This takes care of colors, icons, font, and wallpaper.
beautiful.init("/home/justin/.config/awesome/theme.lua")

-- Define default terminal and editor.
terminal = "x-terminal-emulator"
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
  awful.layout.suit.floating
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

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
  mymainmenu = freedesktop.menu.build({
      before = { menu_awesome },
      after = { menu_terminal }
  })
else
  mymainmenu = awful.menu({
      items = {
        menu_awesome,
        { "Debian", debian.menu.Debian_menu.Debian },
        menu_terminal,
      }
  })
end

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar option
menubar.utils.terminal = terminal

-- Keyboard indicator
mykeyboardlayout = awful.widget.keyboardlayout()

-- Wibar

-- Create textclock
mytextclock = wibox.widget.textclock()

-- Create wibox for each screen
local taglist_buttons = gears.table.join(
  awful.button({  }, 1, function(t) t:view_only() end),
  awful.button({ modkey }, 1, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
      end
  end),
  awful.button({  }, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button({  }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
  awful.button({  }, 1, function(c)
    if c == client.focus then
      c.minimized = true
    else
      c:emit_signal(
        "request::activate",
        "tasklist",
        {raise = true}
      )
    end
  end),
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

-- Add screen elements

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

  -- Client
  awful.key({ modkey }, "j", function() awful.client.focus.byidx(1) end,
            { description = "focus next by index", group = "client" }),
  awful.key({ modkey }, "k", function() awful.client.focus.byidx(-1) end,
            { description = "focus previous by index", group = "client" }),

  awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
            { description = "swap with next client by index", group = "client" }),
  awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
            { description = "swap with previous client by index", group = "client" }),

  awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
            { description = "focus the next screen", group = "client" }),
  awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
            { description = "focus the previous screen", group = "client" }),

  awful.key({ modkey }, "u", awful.client.urgent.jumpto,
            { description = "jump to urgent client", group = "client" }),
  awful.key({ modkey }, "Tab", function()
                                 awful.client.focus.history.previous()
                                 if client.focus then
                                   client.focus:raise()
                                 end
                               end,
            { description = "go back to previous client", group = "client" }),

  -- awful.key({ modkey }, "n" )

  -- Layout
  awful.key({ modkey }, "h", function() awful.tag.incmwfact(-0.05) end,
            { description = "decrease master width factor", group = "layout" }),
  awful.key({ modkey }, "l", function() awful.tag.incmwfact(0.05) end,
            { description = "increase master width factor", group = "layout" }),

  awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
            { description = "increase number of master clients", group = "layout" }),
  awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
            { description = "decrease number of master clients", group = "layout" }),

  awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
            { description = "increase number of columns", group = "layout" }),
  awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
            { description = "decrease number of columns", group = "layout" }),

  awful.key({ modkey }, "space", function() awful.layout.inc(1) end,
            { description = "select next layout", group = "layout" }),
  awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(1) end,
            { description = "select previous layout", group = "layout" }),

  -- Programs
  awful.key({ modkey }, "t", function() awful.spawn(terminal) end,
            { description = "open terminal", group = "launcher" })
)
