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
  awful.layout.suit.spiral.dwindle

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

local menu_awesome = { "awesome", myawesomemenu, beautful.awesome_icon }
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
