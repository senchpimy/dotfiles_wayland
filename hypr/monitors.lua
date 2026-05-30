-- Monitor Configuration
hl.monitor({
    output = "DP-3",
    mode = "2560x1080@75",
    position = "0x0",
    scale = "1"
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@60",
    position = "2560x0",
    scale = "1"
})

hl.monitor({
    output = "eDP-1",
    mode = "preferred",
    position = "auto",
    scale = "1",
    mirror = "DP-2"
})
