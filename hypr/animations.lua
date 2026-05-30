-- Animations Configuration
hl.curve("myBezier", { type = "bezier", points = { {0, 1}, {0.18, 1.0} } })
hl.curve("wind",     { type = "bezier", points = { {0.25, 0.1}, {0.25, 1.0} } })

hl.animation({ leaf = "windows",     enabled = true, speed = 1.5, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2,   bezier = "myBezier", style = "popin 95%" })
hl.animation({ leaf = "border",      enabled = true, speed = 12,  bezier = "myBezier" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 5,   bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 5,   bezier = "wind" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 2,   bezier = "default" })
