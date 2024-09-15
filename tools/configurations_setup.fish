# Get base repo path by plantform.
if [ (uname) = Linux ]
    set HOME_PATH /home/dainslef
    set KITTY_CONFIG kitty.conf
else if [ (uname) = Darwin ]
    set HOME_PATH /Users/dainslef
    set KITTY_CONFIG kitty-macos.conf
end

# Set the repo base path.
set REPO_PATH (realpath ../)
echo "Current config repo path is $REPO_PATH."

# Git configurations
echo -n "Set up git config ... "
ln -sf $REPO_PATH/.gitconfig ~/.gitconfig
ln -sf $REPO_PATH/.gitignore ~/.gitignore
echo OK

# SSH configurations.
echo -n "Set up SSH config ... "
mkdir ~/.ssh
ln -sf $REPO_PATH/ssh_config ~/.ssh/config
echo OK

# VIM
echo -n "Set up VIM ... "
if not [ -e ~/.vim/bundle/Vundle.vim ]
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
end
ln -sf $REPO_PATH/.vimrc ~/.vimrc
echo OK

# Ansible
echo -n "Set up Ansible ... "
mkdir ~/.ansible
if not [ -e ~/.ansible/hosts ]
    cp $REPO_PATH/ansible/hosts ~/.ansible/hosts
end
ln -sf $REPO_PATH/ansible/ansible.cfg ~/.ansible.cfg
echo OK

# Window Manager
if type -q qtile
    # Link the Qtile configuration.
    echo -n "Set up Qtile ... "
    mkdir -p ~/.config/qtile
    ln -sf $REPO_PATH/window_manager/qtile/config.py ~/.config/qtile/config.py
    echo OK

    # Link the Dunst configuration.
    echo -n "Set up Dunst ... "
    mkdir -p ~/.config/dunst
    ln -sf $REPO_PATH/dunstrc ~/.config/dunst/dunstrc
    echo OK
end
if type -q awesome
    echo -n "Set up AwesomeWM ... "
    mkdir -p ~/.config/awesome
    ln -sf $REPO_PATH/window_manager/awesome/rc.lua ~/.config/awesome/rc.lua
    echo OK
end

# Link the theme configuration manually only if use Window Manager
if type -q qtile or type -q awesome
    # GTK theme
    echo -ne "Set up GTK theme ... "
    mkdir -p ~/.config/gtk-3.0
    ln -sf $REPO_PATH/theme/settings.ini ~/.config/gtk-3.0/settings.ini
    ln -sf $REPO_PATH/theme/.gtkrc-2.0 ~/.gtkrc-2.0
    echo OK

    # Cursor theme
    echo -n "Set up Cursor theme ... "
    mkdir -p ~/.icons/default
    ln -sf $REPO_PATH/theme/index.theme ~/.icons/default/index.theme
    echo OK
end

# File manager
if type -q ranger
    echo -n "Set up Ranger ... "
    mkdir -p ~/.config/ranger
    ln -sf $REPO_PATH/ranger/rc.conf ~/.config/ranger/rc.conf
    ln -sf $REPO_PATH/ranger/rifle.conf ~/.config/ranger/rifle.conf
    echo OK
end

# Kitty terminal
if type -q kitty
    echo -n "Set up Kitty ... "
    mkdir -p ~/.config/kitty
    ln -sf $REPO_PATH/shell/$KITTY_CONFIG ~/.config/kitty/kitty.conf
    echo OK
end

# Oh ny fish, need to install OMF and theme at first:
#
# curl -L https://get.oh-my.fish | fish
# omf install bobthefish
echo -ne "Set up Fish shell ... "
ln -sf $REPO_PATH/shell/config.fish ~/.config/fish/config.fish
echo OK

# Check if current plantform is Linux.
if [ (uname) = Linux ]
    # Extra setup for Arch Linux.
    set os_name (grep -Po '(?<=NAME=\\")\\w+ \\w+' /etc/os-release | tail -n 1)
    if [ $os_name = "Arch Linux" ]
        echo "Current OS is Arch Linux, set up addition configuration ..."
        mkdir -p ~/.config/fontconfig
        ln -sf $REPO_PATH/xorg/fonts.xml ~/.config/fontconfig/fonts.conf # Fonts configurations.
    end
end
