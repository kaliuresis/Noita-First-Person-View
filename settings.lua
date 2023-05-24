dofile("data/scripts/lib/mod_settings.lua")

function mod_setting_set_fov( mod_id, gui, in_main_menu, setting, old_value, new_value  )
    local fov = new_value*math.pi/180;
    local screen_dist = 1.0/math.tan(fov/2.0)
    GameSetPostFxParameter("screen_dist", screen_dist, 0, 0, 0)
end

function mod_setting_set_thickness( mod_id, gui, in_main_menu, setting, old_value, new_value  )
    GameSetPostFxParameter("thickness", new_value, 0, 0, 0)
end

function mod_setting_set_crosshair_specs( mod_id, gui, in_main_menu, setting, old_value, new_value  )
    GameSetPostFxParameter("cross_hair_specs",
                           ModSettingGetNextValue(mod_id..".crosshair_thickness") or 0.5,
                           ModSettingGetNextValue(mod_id..".crosshair_spacing") or 2,
                           ModSettingGetNextValue(mod_id..".crosshair_length") or 5,
                           0);
end

function mod_setting_set_crosshair_color( mod_id, gui, in_main_menu, setting, old_value, new_value  )
    GameSetPostFxParameter("cross_hair_color",
                           ModSettingGetNextValue(mod_id..".crosshair_r") or 1,
                           ModSettingGetNextValue(mod_id..".crosshair_g") or 1,
                           ModSettingGetNextValue(mod_id..".crosshair_b") or 1,
                           ModSettingGetNextValue(mod_id..".crosshair_a") or 1);
end

local mod_id = "first_person" -- This should match the name of your mod's folder.
mod_settings_version = 1 -- This is a magic global that can be used to migrate settings to new mod versions. call mod_settings_get_version() before mod_settings_update() to get the old value.

mod_settings =
{
        {
            id = "fov",
            ui_name = "FOV",
            ui_description = "The vertical field of view in degrees",
            value_default = 120,
            value_min = 30,
            value_max = 170,
            ui_fn = mod_setting_number,
            change_fn = mod_setting_set_fov,
            scope = MOD_SETTING_SCOPE_RUNTIME,
        },
        -- { --don't want to fix the fog of war offsets to make this work, but other mods that change the virtual resolution should somewhat work
        --     id = "virtual_resolution_scale",
        --     ui_name = "view distance",
        --     ui_description = "this changes the view distance by setting the virtual resolution before\nthe first person effect is applied.",
        --     value_default = 1.0,
        --     value_min = 0.1,
        --     value_max = 4.0,
        --     value_display_multiplier = 100,
        --     value_display_formatting = " $0%",
        --     ui_fn = mod_setting_number,
        --     scope = mod_setting_scope_runtime_restart,
        -- },
        {
            id = "sensitivity",
            ui_name = "sensitivity",
            ui_description = "controls how far the cursor needs to be to looking directly east/west,\nthis is not equivalent to mouse sensitiviy",
            value_default = 1,
            value_min = 0.5,
            value_max = 2.0,
            value_display_multiplier = 10,
            ui_fn = mod_setting_number,
            scope = mod_setting_scope_runtime,
        },
        {
            id = "thickness",
            ui_name = "thickness",
            ui_description = "changes the thickness of the world, high values may reduce performance",
            value_default = 2,
            value_min = 0.1,
            value_max = 20.0,
            value_display_multiplier = 10,
            ui_fn = mod_setting_number,
            change_fn = mod_setting_set_thickness,
            scope = mod_setting_scope_runtime,
        },
        {
            id = "crosshair_thickness",
            ui_name = "crosshair thickness",
            ui_description = "the thickness of the crosshair lines",
            value_default = 0.5,
            value_min = 0,
            value_max = 5.0,
            value_display_multiplier = 2,
            ui_fn = mod_setting_number,
            change_fn = mod_setting_set_crosshair_specs,
            scope = mod_setting_scope_runtime,
        },
        {
            id = "crosshair_spacing",
            ui_name = "crosshair spacing",
            ui_description = "the center spacing between crosshair lines",
            value_default = 2,
            value_min = 0.5,
            value_max = 25.0,
            value_display_multiplier = 2,
            ui_fn = mod_setting_number,
            change_fn = mod_setting_set_crosshair_specs,
            scope = mod_setting_scope_runtime,
        },
        {
            id = "crosshair_length",
            ui_name = "crosshair length",
            ui_description = "the length of the cross hair lines",
            value_default = 5,
            value_min = 0.5,
            value_max = 50.0,
            value_display_multiplier = 2,
            ui_fn = mod_setting_number,
            change_fn = mod_setting_set_crosshair_specs,
            scope = mod_setting_scope_runtime,
        },
        {
            id = "crosshair_r",
            ui_name = "crosshair red",
            ui_description = "red value of the crosshair",
            value_default = 1,
            value_min = 0.0,
            value_max = 1.0,
            value_display_multiplier = 100,
            value_display_formatting = " $0%",
            ui_fn = mod_setting_number,
            change_fn = mod_setting_set_crosshair_color,
            scope = mod_setting_scope_runtime,
        },
        {
            id = "crosshair_g",
            ui_name = "crosshair green",
            ui_description = "green value of the crosshair",
            value_default = 1,
            value_min = 0.0,
            value_max = 1.0,
            value_display_multiplier = 100,
            value_display_formatting = " $0%",
            ui_fn = mod_setting_number,
            change_fn = mod_setting_set_crosshair_color,
            scope = mod_setting_scope_runtime,
        },
        {
            id = "crosshair_b",
            ui_name = "crosshair blue",
            ui_description = "blue value of the crosshair",
            value_default = 1,
            value_min = 0.0,
            value_max = 1.0,
            value_display_multiplier = 100,
            value_display_formatting = " $0%",
            ui_fn = mod_setting_number,
            change_fn = mod_setting_set_crosshair_color,
            scope = mod_setting_scope_runtime,
        },
        {
            id = "crosshair_a",
            ui_name = "crosshair alpha",
            ui_description = "alpha value (opacity) of the crosshair",
            value_default = 1,
            value_min = 0.0,
            value_max = 1.0,
            value_display_multiplier = 100,
            value_display_formatting = " $0%",
            ui_fn = mod_setting_number,
            change_fn = mod_setting_set_crosshair_color,
            scope = mod_setting_scope_runtime,
        },
}

function ModSettingsUpdate( init_scope )
    local old_version = mod_settings_get_version( mod_id )
    mod_settings_update( mod_id, mod_settings, init_scope )
end

function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

function ModSettingsGui( gui, in_main_menu )
    GameSetPostFxParameter("paused", 1, 0, 0, 0)
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end
