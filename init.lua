mod_id = "first_person"
base_dir = "mods/"..mod_id.."/"

dofile_once("data/scripts/lib/utilities.lua");
local nxml = dofile_once(base_dir.."lib/nxml.lua")

function OnWorldInitialized()
    local fov = (ModSettingGet(mod_id..".fov") or 120)*math.pi/180
    local screen_dist = 1.0/math.tan(fov/2.0)
    local thickness = (ModSettingGet(mod_id..".thickness") or 2.0)

    GameSetPostFxParameter("screen_dist", screen_dist, 0, 0, 0)
    GameSetPostFxParameter("thickness", thickness, 0, 0, 0)
    GameSetPostFxParameter("aim_dir", 1, 0, 0, 0)
    GameSetPostFxParameter("aim_raw", 1, 0, 0, 0)
    GameSetPostFxParameter("cross_hair_specs",
                           ModSettingGetNextValue(mod_id..".crosshair_thickness") or 0.5,
                           ModSettingGetNextValue(mod_id..".crosshair_spacing") or 2,
                           ModSettingGetNextValue(mod_id..".crosshair_length") or 5,
                           0);
    GameSetPostFxParameter("cross_hair_color",
                           ModSettingGetNextValue(mod_id..".crosshair_r") or 1,
                           ModSettingGetNextValue(mod_id..".crosshair_g") or 1,
                           ModSettingGetNextValue(mod_id..".crosshair_b") or 1,
                           ModSettingGetNextValue(mod_id..".crosshair_a") or 1);
    GameSetPostFxParameter("paused", 0, 0, 0, 0)
end

local biomes_all_xml = ModTextFileGetContent("data/biome/_biomes_all.xml")
local biomes_all = nxml.parse(biomes_all_xml)
for biome_to_load in biomes_all:each_of("Biome") do
    local biome_xml = ModTextFileGetContent(biome_to_load.attr.biome_filename);
    local biome = nxml.parse(biome_xml)
    for topology in biome:each_of("Topology") do
        topology.attr.background_image = ""
        topology.attr.background_edge_left = ""
        topology.attr.background_edge_right = ""
        topology.attr.background_edge_top = ""
        topology.attr.background_edge_bottom = ""
    end
    ModTextFileSetContent(biome_to_load.attr.biome_filename, tostring(biome))
end

function clear_buffered_pixel_scenes_backgrounds(root)
    for buffered_pixel_scenes in root:each_of("mBufferedPixelScenes") do
        for pixel_scene in buffered_pixel_scenes:each_of("PixelScene") do
            pixel_scene.attr.background_filename = ""
        end
    end
end

function clear_pixel_scene_backgrounds(filename)
    local pixel_scenes_xml = ModTextFileGetContent(filename)
    local pixel_scenes = nxml.parse(pixel_scenes_xml)
    for pixel_scene_file in pixel_scenes:each_of("PixelSceneFiles") do
        for file in pixel_scene_file:each_of("File") do
            local spliced_xml = ModTextFileGetContent(file:text());
            local spliced = nxml.parse(spliced_xml)
            clear_buffered_pixel_scenes_backgrounds(spliced)
            ModTextFileSetContent(file:text(), tostring(spliced))
        end

        for background_images in pixel_scene_file:each_of("BackgroundImages") do
            pixel_scene_file:remove(background_images)
        end

        clear_buffered_pixel_scenes_backgrounds(pixel_scene_file)
    end
    ModTextFileSetContent(filename, tostring(pixel_scenes))
end

clear_pixel_scene_backgrounds("data/biome/_pixel_scenes.xml")
clear_pixel_scene_backgrounds("data/biome/_pixel_scenes_newgame_plus.xml")

local director_helpers = ModTextFileGetContent("data/scripts/director_helpers.lua")
local prepend = ModTextFileGetContent(base_dir.."files/append/director_helpers.lua")
ModTextFileSetContent("data/scripts/director_helpers.lua", prepend..director_helpers)

function remove_pixel_aa(filename)
    local text = ModTextFileGetContent(filename)
    text = string.gsub(text, "uv = floor%(uv%) %+ x;", "uv = floor(uv) + vec2(0.5, 0.5);")
    ModTextFileSetContent(filename, text);
end

remove_pixel_aa("data/shaders/imgui_potion_icon.frag")
remove_pixel_aa("data/shaders/imgui_status_icon.frag")
remove_pixel_aa("data/shaders/post_cell_res_blit.frag")
remove_pixel_aa("data/shaders/sprite_cellgrid.frag")
remove_pixel_aa("data/shaders/sprite_cellgrid_preprocessed.frag")
remove_pixel_aa("data/shaders/sprite_damage_critical_hit_highlight.frag")
remove_pixel_aa("data/shaders/sprite_damage_highlight.frag")
remove_pixel_aa("data/shaders/sprite_default.frag")
remove_pixel_aa("data/shaders/sprite_invisible.frag")
remove_pixel_aa("data/shaders/sprite_smooth.frag")
remove_pixel_aa("data/shaders/sprite_stains.frag")
remove_pixel_aa("data/shaders/sprite_stains_no_fade.frag")
remove_pixel_aa("data/shaders/sprite_temple_rock.frag")
remove_pixel_aa("data/shaders/sprite_wand_shot.frag")

function OnPlayerSpawned(player)
    local sprite_components = EntityGetComponent(player, "SpriteComponent")
    for i,sprite in ipairs(sprite_components) do
        ComponentSetValue2(sprite, "alpha", 0)
    end

    local children = EntityGetAllChildren(player)
    for i,child in ipairs(children) do
        if EntityGetName(child) == "cape" then
            EntityKill(child)
        end
    end
end

function OnWorldPostUpdate()
    GameSetPostFxParameter("paused", 0, 0, 0, 0)

    local player = EntityGetWithTag( "player_unit" )[1]
    local x = 0
    local y = 0

    local px,py = EntityGetTransform(player)
    -- x = px
    -- y = py

    if player ~= nil then
        local px,py = EntityGetTransform(player)
        x = px
        y = py
    else
        local polymorphed = EntityGetWithTag("polymorphed")
        for i,e in ipairs(polymorphed) do
            local gsc = EntityGetFirstComponent(e, "GameStatsComponent")
            if gsc~=nil then
                local is_player = ComponentGetValue2(gsc, "is_player")
                if is_player then
                    local px,py = EntityGetTransform(e);
                    player = e
                    x = px
                    y = py

                    local sprite_components = EntityGetComponent(e, "SpriteComponent")
                    if sprite_components ~= nil then
                        for j,sprite in ipairs(sprite_components) do
                            ComponentSetValue2(sprite, "alpha", 0)
                        end
                    end
                end
            end
        end
    end

	local SCREEN_W = 427.0
	local SCREEN_H = 242.0

    local controls_component = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")

    local sensitivity = (ModSettingGet(mod_id..".sensitivity") or 1.0)*math.pi

    if GameGetIsGamepadConnected() then
        local aim_x, aim_y = ComponentGetValueVector2(controls_component, "mAimingVectorNonZeroLatest")
        local aim_dir_x, aim_dir_y = vec_normalize(aim_x, aim_y)
        if aim_dir_x == 0 and aim_dir_y == 0 then
            aim_dir_x = 1
        end
        GameSetPostFxParameter("aim_dir", math.abs(aim_dir_x), -aim_dir_y, 0, clamp(6*aim_dir_x, -math.pi/2, math.pi/2))
    else
        local aim_x, aim_y = ComponentGetValueVector2(controls_component, "mAimingVector")
        aim_x = aim_x*2.0/SCREEN_W
        aim_y = aim_y*2.0/SCREEN_H
        local aim_dir_x, aim_dir_y = vec_normalize(0.5*math.pi/sensitivity*SCREEN_W/SCREEN_H, -aim_y);
        if aim_dir_x == 0 and aim_dir_y == 0 then
            aim_dir_x = 1
        end
        GameSetPostFxParameter("aim_dir", aim_dir_x, aim_dir_y, 0, clamp(sensitivity*aim_x, -math.pi, math.pi))
    end

    local aim_raw_x, aim_raw_y = ComponentGetValueVector2(controls_component, "mAimingVectorNormalized")
    aim_raw_x, aim_raw_y = vec_normalize(aim_raw_x, aim_raw_y)
    if aim_raw_x == 0 and aim_raw_y == 0 then
        aim_raw_x = 1
    end
    GameSetPostFxParameter("aim_raw", aim_raw_x, -aim_raw_y, 0, 0)

    y = y-10
    x = x+0;

    local platform_shooter_component = EntityGetFirstComponent(player, "PlatformShooterPlayerComponent")

    if platform_shooter_component ~= nil then
        ComponentSetValue2(platform_shooter_component, "center_camera_on_this_entity", false)
        ComponentSetValueVector2(platform_shooter_component, "mDesiredCameraPos", x, y)
        GameSetCameraFree(false)
    else
        GameSetCameraPos(x, y)
        GameSetCameraFree(true)
    end

    -- Set all sprites to be non-emissive
    local entities = EntityGetInRadius(x, y, 0.7*SCREEN_W)
    for i, e in ipairs(entities) do
        local sprite_components = EntityGetComponent(e, "SpriteComponent")
        if sprite_components ~= nil then
            for i,sprite in ipairs(sprite_components) do
                if ComponentGetValue2(sprite, "emissive") then
                    ComponentSetValue2(sprite, "emissive", false)
                    EntityRefreshSprite(e, sprite)
                end
            end
        end

        local particle_components = EntityGetComponent(e, "SpriteParticleEmitterComponent")
        if particle_components ~= nil then
            for i,sprite in ipairs(particle_components) do
                if ComponentGetValue2(sprite, "emissive") then
                    ComponentSetValue2(sprite, "emissive", false)
                end
            end
        end
    end


    local inventory = EntityGetFirstComponent(player, "Inventory2Component")
    local active_item = ComponentGetValue2( inventory, "mActiveItem" )

    local min_alpha = 0.1
    local alpha = clamp(math.abs(4*aim_raw_x), min_alpha, 1)

    if active_item ~= nil then
        local sprite_components = EntityGetComponent(active_item, "SpriteComponent")
        if sprite_components ~= nil then
            for i,sprite in ipairs(sprite_components) do
                ComponentSetValue2(sprite, "alpha", alpha)
            end
        end
    end

    local children = EntityGetAllChildren(player)
    for i,child in ipairs(children) do
        if EntityGetName(child) == "arm_r" then
            local sprite_components = EntityGetComponent(child, "SpriteComponent")
            if sprite_components ~= nil then
                for i,sprite in ipairs(sprite_components) do
                    ComponentSetValue2(sprite, "alpha", alpha)
                end
            end
        end
    end
end

--TODO: settings menu (add invert horizontal look)
