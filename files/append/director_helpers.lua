original_LoadPixelScene = LoadPixelScene
LoadPixelScene = function(materials_filename, colors_filename, x, y, background_file, skip_biome_checks, skip_edge_textures, color_to_material_table, background_z_index)
    original_LoadPixelScene(materials_filename, colors_filename, x, y, "", skip_biome_checks, skip_edge_textures, color_to_material_table, background_z_index)
end

original_LoadBackgroundSprite = LoadBackgroundSprite
LoadBackgroundSprite = function(background_file, x, y, background_z_index, check_biome_corners)
    -- original_LoadPixelScene(background_file, x, y, background_z_index, check_biome_corners)
end
