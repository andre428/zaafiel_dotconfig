-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
  dwindle = {
    force_split = 2,
    preserve_split = true,
    smart_resizing = true,
    default_split_ratio = 1,
    split_bias = 0,
  },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
  master = {
    new_status = "master",
  },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
  scrolling = {
    fullscreen_on_one_column = true,                 -- true
    column_width = 0.6,                              -- 0.5
    focus_fit_method = 1,                            -- 1
    follow_focus = true,                             -- true
    follow_min_visible = 0.4,                        -- 0.4
    explicit_column_widths = "0.35, 0.5, 0.65, 1.0", -- 0.333, 0.5, 0.667, 1.0
    wrap_focus = true,                               -- true
    wrap_swapcol = true,                             -- true
    direction = "right",                             -- right
  },
})
