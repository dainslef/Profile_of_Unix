-- Load library
require("awful.autofocus")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local awful = require("awful")
awful.rules = require("awful.rules")

-- Load vicious widgets
local vicious = require("vicious")
vicious.contrib = require("vicious.contrib")



-- {{{ Init
-- Custom init command
awful.spawn.with_shell("xset s 1800") -- Set screensaver timeout to 30 mintues
-- }}}



-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
			-- Make sure we don't go into an endless error loop
			if in_error then return end
			in_error = true
			naughty.notify({
				preset = naughty.config.presets.critical,
				title = "Oops, an error happened!",
				text = err
			})
			in_error = false
		end)
end
-- }}}



-- {{{ Variable definitions

-- Init theme
beautiful.init(awful.util.get_themes_dir() .. "default/theme.lua")
local theme = beautiful.get()

-- Custom theme settings, border and font
theme.border_width = 2
theme.font = "Dejavu Sans 10"

-- Color settings, the last two bits are alpha channels
local color_transparent = "#00000000"
local color_menu_bg = "#33445566"
local color_task_tag_focus = "#55667788"
local color_naughty_bg = "#00112288"

theme.bg_normal = color_transparent -- Set background transparent
theme.bg_minimize = color_transparent -- Set the minimize color of taskbar
theme.menu_bg_normal = color_menu_bg
theme.menu_fg_normal = theme.fg_focus
theme.taglist_bg_focus = color_task_tag_focus -- Set the focus color of taglist
theme.tasklist_bg_focus = color_task_tag_focus -- Set the focus color of taskbar

-- This is used later as the default terminal and editor to run
local mail = "thunderbird"
local terminal = "vte"
local browser = "google-chrome-stable"
local dictionary = "stardict"
local file_manager = "ranger"
local terminal_args = " -W -P never -g 120x40 -f \"Monaco 10\" -n 5000 --reverse"

-- Set default editor
local editor = os.getenv("EDITOR") or "nano"

-- Set main key
local mod_key = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts = {
	-- awful.layout.suit.floating,
	awful.layout.suit.spiral, -- master in left
	awful.layout.suit.magnifier, -- focus in center
	-- awful.layout.suit.spiral.dwindle,
	-- awful.layout.suit.fair, -- equal division
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.tile,
	-- awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom, -- master in top
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen
}
-- }}}



-- {{{ Load auto run apps.
do
	function run_once(prg)
		awful.spawn.with_shell("pgrep -u $USER -x " .. prg .. " or (" .. prg .. ")")
	end

	local auto_run_list = {
		"fcitx", -- Use input method
		"xcompmgr", -- For transparent support
		"light-locker", -- Lock screen need to load it first
		"nm-applet", -- Show network status
		-- "blueman-applet", -- Use bluetooth
	}

	for _, cmd in pairs(auto_run_list) do
		run_once(cmd)
	end
end
-- }}}



-- {{{ Wallpaper
if beautiful.wallpaper then
	for s = 1, screen.count() do
		gears.wallpaper.maximized("/home/dainslef/Pictures/34844544_p0.png", s, true)
	end
end
-- }}}



-- {{{ Tags

-- Define a tag table which hold all screen tags.
-- local tag_names = { "①", "②", "③", "④" }
local tags = {}
local tag_properties = {
	{ "❶", layouts[1] },
	{ "❷", layouts[2] },
	{ "❸", layouts[2] },
	{ "❹", layouts[3] }
}

-- Each screen has its own tag table.
for s = 1, screen.count() do
	-- Use operate # to get lua table's size.
	for i = 1, #tag_properties do
		tags[i] = awful.tag.add(tag_properties[i][1], {
			screen = s,
			gap_single_client = true,
			gap = 5,
			layout = tag_properties[i][2],
			selected = i == 1 and true or false -- Only focus on index one.
		})
	end
end

-- }}}



-- {{{ Menu

-- Create menu items
local home = "/home/dainslef"
local awesome_menu = {
	{ "Suspend", "systemctl suspend" },
	{ "RestartWM", awesome.restart },
	{ "QuitWM", awesome.quit },
	{ "PowerOff", "poweroff" }
}
local develop_menu = {
	{ "QtCreator", "qtcreator" },
	{ "QtAssistant", "assistant-qt5" },
	{ "QtDesigner", "designer-qt5" },
	{ "Emacs", "emacs" },
	{ "GVIM", "gvim" },
	{ "VSCode", home .. "/Public/VSCode-linux-x64/code" },
	{ "Eclipse", home .. "/Public/eclipse/eclipse" },
	{ "IDEA", home .. "/Public/idea-IU/bin/idea.sh" }
}
local tools_menu = {
	{ "StarDict", dictionary },
	{ "VLC", "vlc" },
	{ "GIMP", "gimp" }
}
local system_menu = {
	{ "Terminal", terminal },
	{ "VirtualBox", "virtualbox" },
	{ "GParted", "gparted" }
}

-- Add menu items to main menu
local main_menu = awful.menu({
	items = {
		{ "Awesome", awesome_menu, beautiful.awesome_icon },
		{ "Develop", develop_menu },
		{ "Tools", tools_menu },
		{ "System", system_menu },
		{ "Mail", mail },
		{ "Files", terminal .. terminal_args  .. " -c " .. file_manager },
		{ "Browser", browser }
	}
})

-- Create launcher and set menu
local launcher = awful.widget.launcher({
	image = beautiful.awesome_icon,
	menu = main_menu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}



-- {{{ Mouse bindings
root.buttons(
	awful.util.table.join(
		awful.button({ }, 3, function() main_menu:toggle() end),
		awful.button({ }, 4, awful.tag.viewprev),
		awful.button({ }, 5, awful.tag.viewnext)
	)
)
-- }}}



-- {{{ Global key bindings

-- Brightness notify function
function brightness_notify(isBrightnessUp)
	local brightness, status = io.popen("xbacklight -get"):read(), ""
	for i = 1, 10 do
		status = i <= brightness / 10 and status .. " |" or status .. " _"
	end
	naughty.notify({
		title = "Brightness " .. (isBrightnessUp and "up" or "down"),
		text = "Change background brightness ...\n"
				.. "[" .. status ..  " ] " .. brightness.. "%",
		bg = color_naughty_bg,
		fg = beautiful.fg_focus
	})
end

local global_keys = awful.util.table.join(

	awful.key({ mod_key }, "Left", awful.tag.viewprev),
	awful.key({ mod_key }, "Right", awful.tag.viewnext),
	awful.key({ mod_key }, "Escape", awful.tag.history.restore),

	awful.key({ mod_key }, "j", function()
			awful.client.focus.byidx(1)
			if client.focus then client.focus:raise() end
		end),
	awful.key({ mod_key }, "k", function()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end),
	awful.key({ mod_key }, "m", function() main_menu:show() end),

	-- Layout manipulation
	awful.key({ mod_key, "Shift" }, "j", function() awful.client.swap.byidx(1) end),
	awful.key({ mod_key, "Shift" }, "k", function() awful.client.swap.byidx(-1) end),
	awful.key({ mod_key, "Control" }, "j", function() awful.screen.focus_relative(1) end),
	awful.key({ mod_key, "Control" }, "k", function() awful.screen.focus_relative(-1) end),
	awful.key({ mod_key }, "u", awful.client.urgent.jumpto),
	awful.key({ mod_key }, "Tab", function()
			awful.client.focus.history.previous()
			if client.focus then client.focus:raise() end
		end),

	-- Standard program
	awful.key({ mod_key }, "Return", function() awful.spawn(terminal .. terminal_args) end),
	awful.key({ mod_key, "Control" }, "r", awesome.restart),
	awful.key({ mod_key, "Control" }, "q", awesome.quit),

	awful.key({ mod_key }, "l", function() awful.tag.incmwfact(0.05) end),
	awful.key({ mod_key }, "h", function() awful.tag.incmwfact(-0.05) end),
	awful.key({ mod_key, "Shift" }, "h", function() awful.tag.incnmaster(1) end),
	awful.key({ mod_key, "Shift" }, "l", function() awful.tag.incnmaster(-1) end),
	awful.key({ mod_key, "Control" }, "h", function() awful.tag.incncol(1) end),
	awful.key({ mod_key, "Control" }, "l", function() awful.tag.incncol(-1) end),

	awful.key({ mod_key }, "space", function()
			awful.layout.inc(layouts, 1)
			naughty.notify({
				title = 'Layout Change',
				text = "The current layout is " .. awful.layout.getname() .. ".",
				timeout = 1,
				bg = color_naughty_bg,
				fg = beautiful.fg_focus
			})
		end),
	awful.key({ mod_key, "Shift" }, "space", function()
			awful.layout.inc(layouts, -1)
			naughty.notify({
				title = 'Layout Change',
				text = "The current layout is " .. awful.layout.getname() .. ".",
				timeout = 1,
				bg = color_naughty_bg,
				fg = beautiful.fg_focus
			})
		end),

	-- Prompt
	awful.key({ mod_key }, "r", function() prompt_box[mouse.screen.index]:run() end, {
			description = "run prompt", group = "launcher"
		}),
	awful.key({ mod_key }, "x", function()
			awful.prompt.run({ prompt = "Run Lua code: " },
			prompt_box[mouse.screen.index].widget,
			awful.util.eval, nil,
			awful.util.getdir("cache") .. "/history_eval")
		end),

	-- Menubar
	awful.key({ mod_key }, "p", function() menubar.show() end),

	-- Custom key bindings
	awful.key({ mod_key }, "l", function() awful.spawn("xdg-screensaver lock") end),
	awful.key({ mod_key }, "b", function() awful.spawn(browser) end),
	awful.key({ mod_key }, "d", function() awful.spawn(dictionary) end),
	awful.key({ mod_key }, "f", function() awful.spawn(terminal .. terminal_args  .. " -c " .. file_manager) end),
	awful.key({ mod_key, "Control" }, "n", function()
			local c_restore = awful.client.restore() -- Restore the minimize window and focus it
			if c_restore then
				client.focus = c_restore
				c_restore:raise()
			end
		end),
	awful.key({ }, "Print", function()
			os.execute("import -window root ~/Pictures/$(date -Iseconds).png") -- Use imagemagick tools
			naughty.notify({
				title = "Screen Shot",
				text = "Take the fullscreen screenshot success!\n"
						.. "Screenshot saved in ~/Pictures.",
				bg = color_naughty_bg,
				fg = beautiful.fg_focus
			})
		end),
	awful.key({ mod_key }, "Print", function()
			os.execute("import ~/Pictures/$(date -Iseconds).png")
			naughty.notify({
				title = "Screen Shot",
				text = "Please select window to take the screenshot...\n"
						.. "Screenshot will be saved in ~/Pictures.",
				bg = color_naughty_bg,
				fg = beautiful.fg_focus
			})
		end),
	awful.key({ }, "XF86MonBrightnessUp", function()
			os.execute("xbacklight + 10")
			brightness_notify(true)
		end),
	awful.key({ }, "XF86MonBrightnessDown", function()
			os.execute("xbacklight - 10")
			brightness_notify(false)
		end)
)

local client_keys = awful.util.table.join(
	awful.key({ mod_key }, "a", function(c) c.fullscreen = not c.fullscreen end),
	awful.key({ mod_key }, "w", function(c) c:kill() end),
	awful.key({ mod_key, "Control" }, "space", awful.client.floating.toggle),
	awful.key({ mod_key, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end),
	awful.key({ mod_key }, "o", awful.client.movetoscreen),
	awful.key({ mod_key }, "t", function(c) c.ontop = not c.ontop end),
	awful.key({ mod_key }, "n", function(c) c.minimized = true end),
	awful.key({ mod_key }, "s", function(c)
		c.maximized_horizontal = not c.maximized_horizontal
		c.maximized_vertical   = not c.maximized_vertical
	end)
)

-- Bind all key numbers to tags
-- Be careful: we use keycodes to make it works on any keyboard layout
-- This should map on the top row of your keyboard, usually 1 to 9
for i = 1, 4 do
	global_keys = awful.util.table.join(global_keys,
		-- View tag only
		awful.key({ mod_key }, "#" .. i + 9, function()
				local tag = awful.tag.gettags(mouse.screen)[i]
				if tag then awful.tag.viewonly(tag) end
			end),
		-- Toggle tag
		awful.key({ mod_key, "Shift" }, "#" .. i + 9, function()
				local tag = awful.tag.gettags(mouse.screen)[i]
				if tag then awful.tag.viewtoggle(tag) end
			end),
		-- Move client to tag
		awful.key({ mod_key, "Control" }, "#" .. i + 9, function()
				if client.focus then
					local tag = awful.tag.gettags(client.focus.screen)[i]
					if tag then awful.client.movetotag(tag) end
				end
			end),
		-- Toggle tag
		awful.key({ mod_key, "Control", "Shift" }, "#" .. i + 9, function()
				if client.focus then
					local tag = awful.tag.gettags(client.focus.screen)[i]
					if tag then awful.client.toggletag(tag) end
				end
			end))
end

-- }}}



-- {{{ Wibox

-- Create a textclock widget
local text_clock = wibox.widget.textclock(" <span font='Dejavu Sans 10'>" ..
	"[ %b %d <span color='red'>%a</span> ⇔ <span color='yellow'>%H:%M</span> ]</span> ")

-- Create widgetbox
local widget_box = {}
local prompt_box = {}
local layout_box = {}
local tag_list = {}
local task_list = {}

-- Set buttons in widgetbox
tag_list.buttons = awful.util.table.join(
	awful.button({ }, 1, awful.tag.viewonly),
	awful.button({ mod_key }, 1, awful.client.movetotag),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ mod_key }, 3, awful.client.toggletag),
	awful.button({ }, 4, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
	awful.button({ }, 5, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end)
)
task_list.buttons = awful.util.table.join(
	awful.button({ }, 1, function(c)
			if c == client.focus then
				c.minimized = true
			else
				-- Without this, the following
				-- :isvisible() makes no sense
				c.minimized = false
				if not c:isvisible() then awful.tag.viewonly(c:tags()[1]) end
				-- This will also un-minimize
				-- the client, if needed
				client.focus = c
				c:raise()
			end
		end),
	awful.button({ }, 3, function()
			if instance then
				instance:hide()
				instance = nil
			else
				instance = awful.menu.clients({ theme = { width = 250 } })
			end
		end),
	awful.button({ }, 4, function()
			awful.client.focus.byidx(1)
			if client.focus then client.focus:raise() end
		end),
	awful.button({ }, 5, function()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end)
)

-- {{{ Vicious

-- Battery state
local battery_widget = wibox.widget.textbox()

-- Register battery widget
vicious.register(battery_widget, vicious.widgets.bat,
	function(_, args)
		local battery_percent = args[2]
		local battery_color = battery_percent >= 60 and "green" or battery_percent >= 20 and "yellow" or "red"
		return "♨<span color='" .. battery_color .. "'>" .. battery_percent .. "%(" .. args[1] .. ")</span> "
	end, 61, "BAT0"
)

-- Volume state
local volume_widget = wibox.widget.textbox()

-- Register volume widget
vicious.register(volume_widget, vicious.contrib.pulse,
	function(_, args)
		local volume_state = args[1]
		return "♫<span color='white'>" .. volume_state .. "%(" .. args[2] .. ")</span> "
	end
)

-- Volume notify function
function volume_notify(isRaise)
	local volume, status = vicious.contrib.pulse()[1], ""
	for i = 1, 10 do
		status = i <= volume / 10 and status .. " |" or status .. " _"
	end
	naughty.notify({
		title = "Volume changed",
		text = "Volume " .. (isRaise and "rise up" or "lower") .. " ...\n"
				.. "[" .. status ..  " ] " .. volume .. "%",
		bg = color_naughty_bg,
		fg = beautiful.fg_focus
	})
end

-- Volume key binding
global_keys = awful.util.table.join(global_keys,
	awful.key({ }, "XF86AudioMute", function()
		vicious.contrib.pulse.toggle()
		naughty.notify({
			title = "Sound state changed",
			text = "Sound state change to Mute/Unmute...",
			bg = color_naughty_bg,
			fg = beautiful.fg_focus
		})
	end),
	awful.key({ }, "XF86AudioRaiseVolume", function()
		vicious.contrib.pulse.add(5)
		volume_notify(true)
	end),
	awful.key({ }, "XF86AudioLowerVolume", function()
		vicious.contrib.pulse.add(-5)
		volume_notify(false)
	end),
	awful.key({ mod_key }, "XF86AudioRaiseVolume", function()
		vicious.contrib.pulse.add(1)
		volume_notify(true)
	end),
	awful.key({ mod_key }, "XF86AudioLowerVolume", function()
		vicious.contrib.pulse.add(-1)
		volume_notify(false)
	end)
)

-- }}}

-- Add widgetboxs in each screen
for s = 1, screen.count() do

	-- Create a promptbox for each screen
	prompt_box[s] = awful.widget.prompt()

	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	layout_box[s] = awful.widget.layoutbox(s)
	layout_box[s]:buttons(awful.util.table.join(
		awful.button({ }, 1, function() awful.layout.inc(layouts, 1) end),
		awful.button({ }, 3, function() awful.layout.inc(layouts, -1) end),
		awful.button({ }, 4, function() awful.layout.inc(layouts, 1) end),
		awful.button({ }, 5, function() awful.layout.inc(layouts, -1) end)
	))

	-- Create a taglist widget
	tag_list[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, tag_list.buttons)

	-- Create a tasklist widget
	task_list[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, task_list.buttons)

	-- Create the wibar
	widget_box[s] = awful.wibar({ position = "top", screen = s, height = 25 })

	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(layout_box[s])
	left_layout:add(prompt_box[s])

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	right_layout:add(tag_list[s])
	right_layout:add(text_clock)
	right_layout:add(battery_widget)
	right_layout:add(volume_widget)
	right_layout:add(wibox.widget.systray())

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout.left = left_layout
	layout.middle = task_list[s]
	layout.right = right_layout

	widget_box[s].widget = layout

end
-- }}}



-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal)

-- Use mod_key with mouse key to move/resize the window
local client_buttons = awful.util.table.join(
	awful.button({ }, 1, function(c) client.focus = c; c:raise() end),
	awful.button({ mod_key }, 1, function(c)
			c:raise()
			client.focus = c
			awful.mouse.client.move()
		end),
	awful.button({ mod_key, "Control" }, 1, function(c)
			c:raise()
			client.focus = c
			awful.mouse.client.resize()
		end)
)

awful.rules.rules = {
	{
		-- All clients will match this rule
		rule = { },
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = client_keys,
			buttons = client_buttons
		}
	}, {
		-- Start up terminal in floating mode
		rule = { instance = terminal },
		callback = function(c)
			if awful.layout.get() ~= awful.layout.suit.magnifier then
				c.floating = true
			end
		end
	}, {
		rule = { class = "jetbrains-idea" },
		properties = { tag = tags[4] }
	}, {
		rule = { class = "NetBeans IDE 8.1" },
		properties = { tag = tags[4] }
	}, {
		rule = { class = "QtCreator" },
		properties = { tag = tags[4] }
	}, {
		rule = { class = "Eclipse" },
		properties = { tag = tags[4] }
	}
}
-- }}}



-- {{{ Signals

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c, startup)

		-- Set the dialog always on the top
		if c.type == "dialog" then c.ontop = true end

		if not startup then
			-- Set the windows at the slave,
			-- i.e. put it at the end of others instead of setting it master
			awful.client.setslave(c)
			-- Put windows in a smart way, only if they does not set an initial position
			if not c.size_hints.user_position
					and not c.size_hints.program_position then
				awful.placement.no_overlap(c)
				awful.placement.no_offscreen(c)
			end
		end

	end)

client.connect_signal("focus", function(c)

		-- Minimize all floating windows when change the focus to other normal window in tiles layout
		if not c.floating then
			for _, window in pairs(awful.client.visible(c.screen)) do
				if window.floating and not window.ontop then  -- Ingnore when floating window is ontop
					window.minimized = true
				end
			end
		end

		c.border_color = beautiful.border_focus

	end)

client.connect_signal("unfocus", function(c)

		c.border_color = beautiful.border_normal

	end)
-- }}}



-- Set keys
root.keys(global_keys)
