i_override="$(gsettings get org.gnome.desktop.interface icon-theme | sed "s/'//g")"
i_override="configuration {icon-theme: \"${i_override}\";}"
rofi -show drun  -config ~/.config/rofi/trasnparente.rasi -show-icons
