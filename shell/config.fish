# Link this file to the path '~/.config/fish/config.fish'.

# This fish config need to install "Oh-My-Fish" and "bobthefish" theme:
# $ curl -L https://get.oh-my.fish | fish
# $ omf install bobthefish

# Fish shell and Oh-My-Fish file and directory:
# ~/.config/fish/conf.d/omf.fish
# ~/.local/share/omf
# ~/.cache/omf



# Set the custom environment variables.
function env_config

    # Set language environment.
    # Use "set -x" to create a environment variable.
    # Use "-xg" to set this environment variable as a global environment variable.
    set -xg LANG en_US.UTF-8
    set -xg LC_ALL en_US.UTF-8

    # Append local path.
    set PATH $PATH /usr/local/bin /usr/local/sbin ~/.local/bin

    # Don't set envrionment for root.
    if [ (whoami) = root ]
        return
    end

    # Check OS type and set the different environment variables
    if [ (uname) = Darwin ] # Darwin kernel means in macOS

        # Add Homebrew path for macOS ARM plantform.
        set PATH $PATH /opt/homebrew/bin

    else if [ (uname) = Linux ]

        # Remember "alias" is synatx candy for "function" in fish shell,
        # alias command can not run at background like "xxx &".
        # function idea
        #     ~/Public/idea-IU/bin/idea.sh $argv &
        # end

        # Select input method by desktop environment.
        # Gnome XDG_SESSION_DESKTOP will be gnome-xorg or gnome-wayland
        # By default, string match will return match content to standard output,
        # use output redirection to ignore this output.
        string match 'gnome*' "$XDG_SESSION_DESKTOP" >/dev/null # match return 0 (normal)
        if [ $status = 0 -o "$DESKTOP_SESSION" = pantheon ]
            set input_method ibus
        else
            set input_method fcitx
        end

        # Set the input environment variables.
        set -gx GTK_IM_MODULE $input_method
        set -gx QT_IM_MODULE $input_method
        set -gx XMODIFIERS "@im=$input_method"
        set -gx CLASSPATH $CLASSPATH:.

        # Disable Qt auto scaling, to fix VLC UI scaling problem.
        set -gx QT_AUTO_SCREEN_SCALE_FACTOR 0

        # Set Qt style.
        if [ "$XDG_SESSION_DESKTOP" = xfce ]
            # Need to set both environment variables,
            # only set QT_STYLE_OVERRIDE=gtk2 will cause application crash.
            set -gx QT_STYLE_OVERRIDE gtk2
            set -gx QT_QPA_PLATFORMTHEME gtk2
        end

    end

    # Add Python pip package binary path (Use Python venv).
    if [ -e ~/Public/Python/bin ]
        set PATH $PATH $pip_bin
    end

    # Add Haskell GHCup binary path.
    if [ -e ~/.ghcup/bin ]
        set PATH $PATH ~/.ghcup/bin
    end

    # Add DotNet Core tools path.
    if [ -e ~/.dotnet/tools ]
        set PATH $PATH ~/.dotnet/tools
    end

    # Set the environment variable for rustup mirror (no longer need when use clash tun).
    # Install rust stable toolchain: $ rustup toolchain install stable.
    set -xg RUSTUP_DIST_SERVER https://mirrors.ustc.edu.cn/rust-static

    # Add Rust Cargo binary path.
    if [ -e ~/.cargo/bin ]
        set PATH $PATH ~/.cargo/bin
    end

    # Set preferred editor.
    if [ -n "$DISPLAY" -o (uname) = Darwin ]
        and type -q code
        set -xg EDITOR "code --wait"
    else if type -q vim
        set -xg EDITOR vim
    else
        set -xg EDITOR vi
    end

    # For VSCode shell integration support.
    string match -q "$TERM_PROGRAM" vscode and . (code --locate-shell-integration-path fish)

end

# Set the theme configuration.
function theme_config
    # Set the theme, only in Linux GUI and macOS.
    if [ -n "$DISPLAY" -o (uname) = Darwin ]
        omf theme bobthefish
        # Theme bobthefish configs, more theme configs see https://github.com/oh-my-fish/theme-bobthefish.
        # Override the default greeting at ~/.config/fish/functions/fish_greeting.fish or refine function.
        set -g theme_color_scheme nord # Set theme color for bobthefish.
        set -g theme_title_display_process yes # Set progress name in title bar.
        set -g theme_date_format "+%b/%d/%Y [%a] %R:%S"
    else # Use default in Non-GUI environment.
        omf theme default
    end
end

# Call function if oh-my-posh is installed.
if [ -n "$OMF_PATH" ]
    and status is-interactive
    # Set environment config.
    env_config
    # Set the theme.
    theme_config
end

# Delete defined functions and variables.
# Use "-e" means to erase a function/variable.
functions -e env_config theme_config



# --- Override functions  ---
# In fish shell, function which named with "fish_greeting" will override default greeting.
function fish_greeting

    if [ (uname) = Darwin ]
        set show_os_version (uname -srnm)
    else if [ -n "$DISPLAY" ]
        set show_os_version (uname -ornm)
    end

    # Print welcome message in macOS or Linux GUI.
    if [ -n "$show_os_version" -a (whoami) != root ]
        set_color $fish_color_autosuggestion # Set greet color.
        echo (uptime)
        echo " $show_os_version"
        echo --- Welcome, (whoami)! Today is (date +"%B %d %Y, %A"). ---
        switch (random 1 7)
            case 1
                echo "--- あなたもきっと、誰かの奇跡。 ---"
            case 2
                echo "--- 一日は貴い一生である。これを空費してはならない。 ---"
            case 3
                echo "--- 世界は美しくなんかない。そしてそれ故に、美しい。 ---"
            case 4
                echo "--- 春は夜桜、夏には星、秋に満月、冬には雪。 ---"
            case 5
                echo "--- 井の中の蛙大海を知らず、されど空の青さを知る。 ---"
            case 6
                echo "--- 前を向けばきっと会える。 ---"
            case 7
                echo "--- 周りの人や時代に流されず、自分らしく生きるだけでいい。 ---"
        end
        echo "" # Add a empty new line.
        set_color $fish_color_normal # Reset the color.
    end

end
