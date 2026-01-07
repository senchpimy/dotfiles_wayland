#ags &
ags run-js 'tabletMode();' &
hyprpm disable hyprbars &
killall iio-hyprland &
QML_XHR_ALLOW_FILE_READ=1 QML_XHR_ALLOW_FILE_WRITE=1  qs -p ~/.config/quickshell/pendientes.qml &
qs -p ~/.config/quickshell/activate.qml &
qs -p ~/.config/quickshell/calendario.qml  &
qs -p ~/.config/quickshell/bat.qml & 
