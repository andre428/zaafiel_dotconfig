-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
  hl.exec_cmd("dunst")
  hl.exec_cmd("wl-paste --watch clipvault store")
  hl.exec_cmd("waybar & hyprpaper")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "22")
hl.env("HYPRCURSOR_SIZE", "22")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")

----------------
----  MISC  ----
----------------
hl.config({
  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo   = true,
  },
})


---------------
---- INPUT ----
---------------
hl.config({
  input = {
    kb_layout          = "us,pl",
    kb_variant         = "",
    kb_model           = "pc104alt",
    kb_options         = "grp:lctrl_lshift_toggle",
    kb_rules           = "",

    follow_mouse       = 2,

    sensitivity        = 0, -- -1.0 - 1.0, 0 means no modification.

    natural_scroll     = false,
    numlock_by_default = true,

    touchpad           = {
      natural_scroll = false,
    },
  },
})


hl.device({
  name        = "epic-mouse-v1",
  sensitivity = 0,
})