-- AwesomeWM configuration
-- Link this file to the path ~/.config/awesome/rc.lua.


-- Load library
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local menubar = require("menubar")
local beautiful = require("beautiful")

-- Load vicious widgets.
local vicious = require("vicious")
vicious.contrib = require("vicious.contrib")

-- Need to load "autofocus" module, if not window will lost focus when change workspace(tag).
require("awful.autofocus")



-- Utils function

-- Run command sync, and get command shell output.
function get_command_output(command)
	local command_pipe = io.popen(command) -- Create a pipe
	local command_output = command_pipe:read("*all"):gsub("%s+", "") -- Get output
	command_pipe:close() -- Close the pipe
	return command_output
end



-- Init
do
	function auto_run(tasks, once)
		function run_once(cmd)
			awful.spawn.with_shell("pgrep -u $USER -x " .. cmd .. "; or " .. cmd)
		end

		local once = once or true
		for i = 1, #tasks do
			if once then run_once(tasks[i]) else awful.spawn.with_shell(tasks[i]) end
		end
	end

	auto_run({
		-- "systemctl --user restart fcitx5", -- Restart fcitx service to avoid some fcitx crash.
		"xset +dpms", -- Use the power manager.
		"xset dpms 600 900 1800", -- Set the power manager suspend timeout(15min), screen off timeout(30min).
		"xset s 600" -- Set screensaver timeout to 10 mintues.
	}, false)

	-- These service should only run once, service can auto run by systemd service.
	auto_run {
		"nm-applet", -- Show network status.
		"picom", -- For transparent and other window effects support.
		"fcitx5",
		-- "blueman-applet", -- Use bluetooth.
	}
end



-- Error handling
do
	-- Check if awesome encountered an error during startup and fell back to
	-- another config (This code will only ever execute for the fallback config).
	if awesome.startup_errors then
		naughty.notify {
			preset = naughty.config.presets.critical,
			title = "Oops, there were errors during startup!",
			text = awesome.startup_errors
		}
	end

	-- Handle runtime errors after startup
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true
		naughty.notify {
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = err
		}
		in_error = false
	end)
end



-- Variable definitions

-- Define the gap size for window and bar.
local standard_dpi = 96
-- Cacaulate the scaling size, use format to solve "screen.primary.dpi" precision problem.
-- The awesomewm api "screen.primary.dpi" return the value like 96.05123456...
local scaling_factor = tonumber(string.format("%.f", screen.primary.dpi) / standard_dpi)
local head_bar_size = 35 * scaling_factor
local border_width = 5 * scaling_factor
local bar_gap_size = 2 * border_width

-- Load the default theme config.
beautiful.init(awful.util.get_themes_dir() .. "default/theme.lua") -- Init theme.

-- Custom theme settings, border and font.
-- All custom settings can find at https://awesomewm.org/doc/api/documentation/06-appearance.md.html.
beautiful.font = "Cascadia Code PL 10"
beautiful.border_width = border_width
beautiful.master_width_factor = 0.6 -- Set the master window percent.
beautiful.useless_gap = beautiful.border_width -- Set the window Gap size (equals to border width).
beautiful.notification_shape = gears.shape.rounded_rect -- Set the notification border shape.

-- Color settings, the last two bits are alpha channels.
beautiful.bg_normal = "#00000000" -- Set background transparency.
beautiful.bg_minimize = beautiful.bg_normal -- Set the minimize color of taskbar.
beautiful.fg_normal = beautiful.fg_focus -- Set foreground color(text).
beautiful.fg_minimize = "#55555500"
beautiful.bg_systray = "#8899AA" -- Systray doesn't support alpha channel (transparency).
beautiful.border_focus = "#445566AA"
beautiful.border_normal = "#00000011"
beautiful.menu_bg_normal = "#33445566"
beautiful.menu_fg_normal = beautiful.fg_focus -- The fg_focus color is white.
beautiful.menu_border_color = beautiful.border_focus
beautiful.taglist_bg_focus = beautiful.border_focus
beautiful.tasklist_bg_focus = beautiful.taglist_bg_focus
beautiful.tasklist_fg_normal = beautiful.fg_minimize
beautiful.notification_bg = beautiful.border_focus

-- Wallpaper
local wall_paper = "/boot/background.jpg"
for s = 1, screen.count() do
	gears.wallpaper.maximized(wall_paper, s)
end

-- This is used later as the default terminal and editor to run.
local mail = "thunderbird"
local browser = "google-chrome-stable"
local dictionary = "goldendict"
local file_manager = "ranger"
local screen_locker = "dm-tool lock"

-- Kitty terminal is implemented by GLFW, so use GLFW_IM_MODULE to set the IME.
-- Fcitx input method also need to set GLFW_IM_MODULE to ibus.
local terminal = "env GLFW_IM_MODULE=ibus kitty"
-- Set the instance name of Terminal App, use xprop WM_CLASS.
local terminal_instance = "kitty"

-- Use terminal to open a new CLI program.
function terminal_open(program)
	return terminal .. " --hold " .. program
end

-- Set main key.
local mod_key = "Mod4"
-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts = {
	awful.layout.suit.fair, -- equal division
	awful.layout.suit.corner.sw,
	awful.layout.suit.max,

	-- awful.layout.suit.floating,
	-- awful.layout.suit.magnifier, -- focus in center
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
	-- awful.layout.suit.spiral, -- master in left
	-- awful.layout.suit.spiral.dwindle,
	-- awful.layout.suit.fair, -- equal division
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.tile,
	-- awful.layout.suit.tile.left,
	-- awful.layout.suit.tile.bottom, -- master in top
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen,
}



-- Menu

-- Add menu items to main menu
local main_menu = awful.menu {
	items = {
		{ "Awesome", {
			{ "RestartWM", awesome.restart },
			{ "QuitWM", function() awesome.quit() end },
			{ "Suspend", "systemctl suspend" },
			{ "PowerOff", "poweroff" }
		}, beautiful.awesome_icon },
		{ "Develop",  {
			{ "VSCode", "code" },
			{ "IDEA", "idea-ultimate" }
		}},
		{ "Tools", {
			{ "Dictionary", dictionary },
			{ "VLC", "vlc" },
			{ "WeChat", "wechat-uos" }
		}},
		{ "System", {
			{ "Terminal", terminal },
			{ "Top", terminal_open("btop") },
			{ "GParted", "gparted" }
		}},
		{ "Mail", mail },
		{ "Files", terminal_open(file_manager) },
		{ "Browser", browser }
	}
}



-- Wibox

-- Create widgetboxs.
local widget_box, prompt_box, layout_box, tag_list, task_list = {}, {}, {}, {}, {}
-- Create a textclock widget.
local text_clock = wibox.widget.textclock(
	"[<span color='yellow'>%a</span>] %b/%d <span color='cyan'>%H:%M</span>")

do -- Attach a cleandar widget to text_colock widget.
	local month_calendar = awful.widget.calendar_popup.month()
	month_calendar.bg = beautiful.taglist_bg_focus
	month_calendar:attach(text_clock, "tr")
end

-- Mouse bindings
-- Muse moudle https://awesomewm.org/doc/api/libraries/mouse.html

-- Mouse Key definition.
MouseButtons = {
	LEFT = 1,
	MIDDLE = 2,
	RIGHT = 3,
	SCROLL_UP = 4,
	SCROLL_DOWN = 5
}

-- Mouse action on empty desktop.
root.buttons(
	awful.util.table.join(
		awful.button({}, MouseButtons.RIGHT, function() main_menu:toggle() end),
		awful.button({ mod_key }, MouseButtons.SCROLL_UP, awful.tag.viewprev),
		awful.button({ mod_key }, MouseButtons.SCROLL_DOWN, awful.tag.viewnext)
	)
)

-- Set buttons in widgetbox.
tag_list.buttons = awful.util.table.join(
	awful.button({}, MouseButtons.LEFT, awful.tag.viewonly),
	awful.button({}, MouseButtons.RIGHT, awful.tag.viewtoggle),
	awful.button({}, MouseButtons.SCROLL_UP, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
	awful.button({}, MouseButtons.SCROLL_DOWN, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
	awful.button({ mod_key }, MouseButtons.LEFT, awful.client.movetotag),
	awful.button({ mod_key }, MouseButtons.RIGHT, awful.client.toggletag)
)
task_list.buttons = awful.util.table.join(
	awful.button({}, MouseButtons.LEFT, function(c)
		if c == client.focus then
			c.minimized = true
		else
			-- This will also un-minimize the client, if need
			c.minimized = false
			if not c:isvisible() then c.first_tag:view_only() end
			client.focus = c
		end
	end),
	awful.button({}, MouseButtons.RIGHT, function()
		if task_menu then
			task_menu:hide()
		else
			task_menu = awful.menu.clients { theme = { width = 250 } }
		end
	end),
	awful.button({}, MouseButtons.SCROLL_UP, function() awful.client.focus.byidx(1) end),
	awful.button({}, MouseButtons.SCROLL_DOWN, function() awful.client.focus.byidx(-1) end)
)



-- Vicious Plugins

local net_widget, battery_widget, volume_widget =
	wibox.widget.textbox(), wibox.widget.textbox(), wibox.widget.textbox()

-- Vicious plugin basic usage:
-- vicious.register(widget, wtype, format, interval, warg)

-- These variables need to place at global scope, some other function need these variables.
local widget_refresh_span = 1 -- Time span for refresh widget (seconds).
-- Get SINK device index, the current used sound device will have '*'' mark.
local volume_device_index

do
	-- Net state
	-- Get default net device name, sometimes there are more than one default route, so use "tail -n 1".
	local net_device = get_command_output("ip route list default | tail -n 1 | grep -Po '(?<=dev )(\\S+)'")
	if net_device == "" then
		-- If current route is empty, then get wifi net device name.
		-- Use Regex Lookarounds feature to find 'w*' net device.'
		net_device = get_command_output("ip addr | grep -oP '(?<=: )w[\\w]+'")
	end
	if net_device == "" then
		-- If current wifi is empty, then get ethernet net device name.
		-- Use Regex Lookarounds feature to find 'e*' net device.'
		net_device = get_command_output("ip addr | grep -oP '(?<=: )e[\\e]+'")
	end
	local net_format = "🌐 ${" .. net_device .. " down_kb}KB "
	vicious.register(net_widget, vicious.widgets.net, net_format, widget_refresh_span)

	-- Battery state
	-- In some device (the fuck HUAWEI MateBook), the battery device isn't BAT0,
	-- so get the correct battery device name under /sys/class/power_supply.
	local battery_name = get_command_output("ls /sys/class/power_supply | grep BAT")
	-- Register battery widget.
	vicious.register(battery_widget, vicious.widgets.bat, function(_, args)
		local status, percent = args[1], args[2]
		return "🔋" .. percent .. "%(" .. status .. ") "
	end, widget_refresh_span, battery_name)

	-- Volume with ALSA
	vicious.register(volume_widget, vicious.widgets.volume, "$2$1% ", 1, "Master")
end



-- Tags

-- Define a tag table which hold all screen tags.
local tags, tag_properties = {}, {
	{ "➊", layouts[1] },
	{ "➋", layouts[2] },
	{ "➌", layouts[2] },
	{ "➍", layouts[3] }
}

-- Add widgetboxs in each screen.
for s = 1, screen.count() do

	-- Each screen has its own tag table, use operate # to get lua table's size.
	for i, tag_propertie in ipairs(tag_properties) do
		tags[i] = awful.tag.add(tag_propertie[1], {
			screen = s,
			layout = tag_propertie[2],
			selected = i == 1 -- Only focus on index one.
		})
	end

	-- Create a promptbox for each screen.
	prompt_box[s] = awful.widget.prompt()

	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	layout_box[s] = awful.widget.layoutbox(s)

	-- Create a taglist widget.
	tag_list[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, tag_list.buttons)

	-- Create a tasklist widget.
	task_list[s] = awful.widget.tasklist {
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = task_list.buttons,
		style = { -- Change the task list style.
			shape_border_width = 2,
			shape = gears.shape.rounded_bar
		},
		layout = {
			spacing = bar_gap_size,
			layout  = wibox.layout.flex.horizontal
		}
	}

	-- Gap sequence: Lef Right Top Down.
	function create_bar_layout(widget, color)
		return wibox.container.margin(
			wibox.container.background(
				wibox.container.margin(widget, bar_gap_size, bar_gap_size),
				color, gears.shape.rounded_bar), bar_gap_size)
	end

	-- Widgets that are aligned to the left.
	local left_bar = create_bar_layout(wibox.widget {
		layout_box[s], prompt_box[s], tag_list[s],
		layout = wibox.layout.fixed.horizontal
	}, beautiful.border_focus)

	-- Create systray.
	-- local sys_tray = wibox.container.margin(create_bar_layout(
	-- 	wibox.widget.systray(), beautiful.bg_systray), 0, bar_gap_size)
	local sys_tray = create_bar_layout(wibox.widget.systray(), beautiful.bg_systray)

	-- Create user custom tray.
	local custom_tray = create_bar_layout(wibox.widget {
		net_widget, battery_widget, volume_widget, text_clock,
		layout = wibox.layout.fixed.horizontal
	}, beautiful.border_focus)

	-- Widgets that are aligned to the right.
	local right_bar = wibox.widget {
		sys_tray, custom_tray, layout = wibox.layout.fixed.horizontal
	}

	-- Now bring it all together (with the tasklist in the middle).
	-- Margin container args: widget, left padding, right padding.
	local middle_bar = wibox.container.margin(
		-- Place container args: widget, horizontal alignment.
		wibox.container.place(task_list[s], "left"), bar_gap_size)

	-- Create the wibar.
	widget_box[s] = awful.wibar {
		position = "top",
		screen = s,
		height = head_bar_size,
		widget = wibox.container.margin(wibox.widget {
			left_bar, middle_bar, right_bar,
			layout = wibox.layout.align.horizontal
		}, 0, bar_gap_size, bar_gap_size) -- Set top bar gap (left, right, top)
	}

end



-- Global key bindings.

function build_progress(value)
	local status = ""
	for i = 1, 20 do
		status = i <= value / 5 and status .. "█" or status .. "▂"
	end
	return "\n┣ " .. status .. " ┫" .. " " .. tonumber(value) .. "%"
end

-- Brightness change function.
function brightness_change(change)
	local is_brightness_up = change > 0
	local prefix = is_brightness_up and "+" or ""
	local suffix = is_brightness_up and "" or "-"
	local change_brightness_command = "brightnessctl set " .. prefix .. math.abs(change) .. "%" .. suffix
	local output = awful.spawn(change_brightness_command)

	-- Check if brightnessctl has been installed.
	if string.match(output, "Failed") then
		naughty.notify {
			title = "Tool not found!",
			text = output
		}
	end

	-- Execute async brightness config (need run command with shell).
	local get_brightness_command = "brightnessctl | grep -Po '\\d+(?=\\%\\))'"
	awful.spawn.easy_async_with_shell(get_brightness_command, function(brightness, _, _, _)
		-- Use 'destroy' instead of 'replaces_id' (replaces_id api sometimes doesn't take effects).
		naughty.destroy(brightness_notify)
		brightness_notify = naughty.notify {
			title = "💡 Brightness Change",
			text = "Background brightness "
				.. (is_brightness_up and "up ⬆️" or "down ⬇️")
				.. build_progress(brightness)
		}
	end)
end

-- Volume change function
function volume_change(change)
	-- Use amixer to get ALSA volume (use "-M" argument to get natural volume value).
	local alsa_get_volume_command = "amixer -M get Master | grep -Po '\\d+(?=%\\])'"
	awful.spawn.easy_async_with_shell(alsa_get_volume_command, function(volume)
		volume = math.floor(volume + change)
		awful.spawn("amixer -M set Master " .. volume .. "%")
		naughty.destroy(volume_notify)
		volume_notify = naughty.notify {
			title = "🔈 Volume Change",
			text = "Volume "
				.. (change > 0 and "rise up ⬆️" or "lower ⬇️")
				.. build_progress(volume)
		}
	end)
end

-- Layout change function
function layout_change(change)
	awful.layout.inc(layouts, change)
	layout_notify_id = naughty.notify {
		title = "🔁 Layout Change",
		text = "Layout has been changed ...\n"
			.. "The current layout is [" .. awful.layout.getname() .. "]!",
		replaces_id = layout_notify_id
	}.id
end

-- Change current focus window except in fullscreen mode.
function focus_change(change)
	if client.focus then
		if client.focus.fullscreen then
			naughty.notify {
				title = "🔁 Can't change window",
				text = "Can't change focus window in fullscreen mode!"
			}
		else
			awful.client.focus.byidx(change)
		end
	else
		naughty.notify {
			title = "🔁 Now active window",
			text = "No active window currently!"
		}
	end
end

local global_keys = awful.util.table.join(
	-- Window navigation.
	awful.key({ mod_key }, "Left", function() awful.client.focus.bydirection("left") end),
	awful.key({ mod_key }, "Right", function() awful.client.focus.bydirection("right") end),
	awful.key({ mod_key }, "Up", function() awful.client.focus.bydirection("up") end),
	awful.key({ mod_key }, "Down", function() awful.client.focus.bydirection("down") end),
	awful.key({ mod_key, "Control"}, "Left", function() awful.client.swap.byidx(1) end),
	awful.key({ mod_key, "Control"}, "Right", function() awful.client.swap.byidx(-1) end),

	awful.key({ mod_key }, "Escape", awful.tag.history.restore),

	-- Layout manipulation.
	awful.key({ mod_key }, "j", awful.client.urgent.jumpto),
	awful.key({ mod_key }, "Tab", function() focus_change(1) end),
	awful.key({ mod_key }, "`", function() focus_change(-1) end),

	-- Change layout.
	awful.key({ mod_key }, "space", function() layout_change(1) end),
	awful.key({ mod_key, "Control" }, "space", function() layout_change(-1) end),

	-- Run prompt.
	awful.key({ mod_key }, "r", function() prompt_box[mouse.screen.index]:run() end, {
		description = "run prompt", group = "launcher"
	}),

	-- Menu, menubar and system operation.
	awful.key({ mod_key }, "o", function() main_menu:show() end),
	awful.key({ mod_key }, "p", function() menubar.show() end),
	awful.key({ mod_key, "Control" }, "r", awesome.restart),
	awful.key({ mod_key, "Control" }, "q", awesome.quit),

	-- Brightness key bindings.
	awful.key({}, "XF86MonBrightnessUp", function() brightness_change(5) end),
	awful.key({}, "XF86MonBrightnessDown", function() brightness_change(-5) end),
	awful.key({ mod_key }, "XF86MonBrightnessUp", function() brightness_change(1) end),
	awful.key({ mod_key }, "XF86MonBrightnessDown", function() brightness_change(-1) end),

	-- Volume key bindings.
	awful.key({}, "XF86AudioMute", function()
		local alsa_get_volume_command = "amixer set Master toggle"
		awful.spawn.easy_async_with_shell(alsa_get_volume_command, function(stdout)
			local volume, state = string.match(stdout, "%[([%d]+)%%%].*%[([%l]*)%]")
			local state = state == "on" and "🔊ON" or "🔇OFF"
			naughty.destroy(volume_notify_id)
			volume_notify_id = naughty.notify {
				title = "🔈 Volume changed",
				text = "Sound state has been changed ...\n"
						.. "Current sound state is [" .. state .. "]!"
			}
		end)
	end),
	awful.key({}, "XF86AudioRaiseVolume", function() volume_change(5) end),
	awful.key({}, "XF86AudioLowerVolume", function() volume_change(-5) end),
	awful.key({ mod_key }, "XF86AudioRaiseVolume", function() volume_change(1) end),
	awful.key({ mod_key }, "XF86AudioLowerVolume", function() volume_change(-1) end),

	-- Open terminal by need.
	awful.key({ mod_key }, "Return", function()
		local last_terminal, terminal_before_current, find_terminal_before_current
		-- First try to find the terminal instance which aready existed in current tag (workspace).
		for _, c in ipairs(awful.screen.focused().selected_tag:clients()) do
			-- Find the last terminal in current workspace.
			-- If current window is a terminal, find the lastest terminal before current.
			if c.instance == terminal_instance then
				last_terminal = c -- Save the last terminal.
				-- The nearby window should before the current terminal.
				if c ~= client.focus and not find_terminal_before_current then
					terminal_before_current = c
				else
					find_terminal_before_current = true
				end
			end
		end
		-- Use the existed terminal if possible.
		if terminal_before_current or last_terminal then
			-- If the nearby terminal doesn't exist, use the last terminal.
			client.focus = terminal_before_current or last_terminal
		else
			-- Create a terminal if there is no terminal.
			awful.spawn.spawn(terminal)
		end
	end),
	awful.key({ mod_key, "Control" }, "Return", function() awful.spawn(terminal) end),

	-- Custom application key bindings.
	awful.key({ mod_key }, "l", function() awful.spawn(screen_locker) end), -- Lock screen
	awful.key({ mod_key }, "b", function() awful.spawn(browser) end),
	awful.key({ mod_key }, "m", function() awful.spawn(mail) end),
	awful.key({ mod_key }, "d", function() awful.spawn(dictionary) end),
	awful.key({ mod_key }, "f", function() awful.spawn(terminal_open(file_manager)) end),
	awful.key({ mod_key }, "t", function() awful.spawn(terminal_open("btop")) end),
	-- Screen shot key bindings.
	awful.key({}, "Print", function() awful.spawn("flameshot screen") end),
	awful.key({ mod_key }, "Print", function() awful.spawn("flameshot gui") end),
	-- Destory notifications.
	awful.key({ mod_key }, "BackSpace", naughty.destroy_all_notifications),
	-- Global window manage keys (Specific window manage should use awful.rules).
	awful.key({ mod_key, "Control" }, "h", function()
		-- Minimize all floating windows in current tag (workspace).
		for _, c in ipairs(awful.screen.focused().selected_tag:clients()) do
			if c.floating then c.minimized = true end
		end
	end),
	awful.key({ mod_key, "Control" }, "b", function()
		local c_restore = awful.client.restore() -- Restore the minimize window and focus it.
		if c_restore then client.focus = c_restore; c_restore:raise() end
	end)
)

-- Bind all key numbers to tags (Work Space).
-- Be careful: Use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, #tags do
	global_keys = awful.util.table.join(global_keys,
		-- View tag only
		awful.key({ mod_key }, "#" .. i + 9, function()
			local tag = mouse.screen.tags[i]
			if tag then tag:view_only() end
		end),
		-- Move client to target tag, then jump to target tag.
		awful.key({ mod_key, "Control" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					-- Move the current focused window to the target tag.
					client.focus:move_to_tag(tag)
					-- Jump to the target tag.
					tag:view_only()
				 end
			end
		end),
		-- Let current window both show in current and target tag.
		awful.key({ mod_key, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then client.focus:toggle_tag(tag) end
			end
		end),
		-- Combine both clients in current and target tag.
		awful.key({ mod_key, "Control", "Shift" }, "#" .. i + 9, function()
			local tag = mouse.screen.tags[i]
			if tag then awful.tag.viewtoggle(tag) end
		end)
	)
end

-- Set global keys.
root.keys(global_keys)



-- Rules

-- Rules to apply to new clients (through the "manage" signal).
-- Get X-Client props need to install tool "xorg-prop", use command "xprop" to check window props.
awful.rules.rules = {
	{
		-- All clients will match this rule.
		rule = {},
		properties = {
			raise = true,
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			-- Client key bindings.
			keys = awful.util.table.join(
				awful.key({ mod_key }, "w", function(c) c:kill() end),
				-- Window state key bindings, window title will add some charator for specific window state:
				-- '+' maxmized, '^' ontop
				-- awful.key({ mod_key, "Alt_L" }, "m", function(c) awful.client.setmaster(c) end),
				awful.key({ mod_key, "Shift" }, "m", function(c) c.maximized = not c.maximized end),
				awful.key({ mod_key, "Control" }, "m", function(c) c.fullscreen = not c.fullscreen end),
				awful.key({ mod_key, "Control" }, "n", function(c) c.minimized = not c.minimized end),
				awful.key({ mod_key, "Control" }, "t", function(c) c.ontop = not c.ontop end),
				awful.key({ mod_key, "Control" }, "f", function(c) c.floating = not c.floating end)
			),
			-- Use mod_key with mouse key to move/resize the window.
			buttons = awful.util.table.join(
				awful.button({}, MouseButtons.LEFT, function(c) client.focus = c; c:raise() end),
				awful.button({ mod_key }, MouseButtons.LEFT, function(c)
					c:raise()
					client.focus = c
					awful.mouse.client.move()
				end),
				awful.button({ mod_key, "Control" }, MouseButtons.LEFT, function(c)
					c:raise()
					client.focus = c
					awful.mouse.client.resize()
				end)
			)
		}
	}, {
		rule = { instance = terminal_instance },
		properties = {
			floating = true,
			-- Make terminal open at mouse position.
			callback = function(c) awful.placement.under_mouse(c) end
		}
	}, {
		rule = { class = "jetbrains-idea" },
		properties = { tag = tags[2] } -- Oper IDEA at workspace 2.
	}
}



-- Signals

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c, startup)
	-- Set the dialog always on the top
	if c.type == "dialog" then c.ontop = true end
	if not startup then
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		awful.client.setslave(c)
		-- Put windows in a smart way, only if they does not set an initial position.
		if not c.size_hints.user_position
				and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	end
end)

client.connect_signal("unfocus", function(c)
	-- Set back window color.
	c.border_color = beautiful.border_normal
end)

function update_floating_state(c)
	if not c.floating then
		-- Minimize all floating windows in current tag when focus to a unfloating window.
		for _, window in pairs(c.screen.clients) do
			if window.instance == terminal_instance
				and window.floating
				and not window.ontop then
				window.minimized = true -- Minimized other terminal windows.
			end
		end
	else
		c:raise() -- Raise the floating window.
	end
end

client.connect_signal("focus", function(c)
	update_floating_state(c)
	-- Set the border color when window is focused.
	c.border_color = beautiful.border_focus
end)

-- Callback when window size is changed
client.connect_signal("property::size", function(c)
	update_floating_state(c)
end)

-- Callback when window size is changed.
client.connect_signal("property::geometry", function(c)
	-- Set up the window border shape when window is not fullscreen.
	c.shape = not c.fullscreen and gears.shape.rounded_rect or nil
	-- !!
	-- In Lua, nil will be treat as false,
	-- so expression "xxx and nil or xxx" don't work as ternary operator.
end)

client.connect_signal("mouse::enter", function(c)
	main_menu:hide() -- Hide main menu when focus other window.
	if task_menu then task_menu:hide() end -- Hide task menu when focus other window.
end)
