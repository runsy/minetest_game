function player_api.get_base_texture_table(player)
	local meta = player:get_meta()
	local base_texture_str = meta:get_string("base_texture")
	if base_texture_str == nil or base_texture_str == "" then
		player_api.set_base_textures(player)
	end
	local base_texture = minetest.deserialize(base_texture_str)
	return base_texture
end

function player_api.set_base_texture(player, base_texture)
	local meta = player:get_meta()
	meta:set_string("base_texture", minetest.serialize(base_texture))
end

function player_api.set_base_textures(player)
	local meta = player:get_meta()
	local base_texture = {}
	local gender = meta:get_string("gender")
	if gender == "male" then
		base_texture["eyebrowns"] = "player_eyebrowns_default.png"
		base_texture["eyebrowns"] = "player_eyebrowns_default.png"
		base_texture["eye"] = "player_brown_eye.png"
		base_texture["mouth"] = "player_male_mouth_default.png"
		base_texture["hair"] = "player_male_hair_default.png"
	else
		base_texture["eyebrowns"] = "player_eyebrowns_default.png"
		base_texture["eye"] = "player_blue_eye.png"
		base_texture["mouth"] = "player_female_mouth_default.png"
		base_texture["hair"] = "player_female_hair_default.png"
	end
	base_texture["skin_color"] = nil
	player_api.set_base_texture(player, base_texture)
end

function player_api.compose_skin(player, skin)
	local base_texture = player_api.get_base_texture_table(player)
	if base_texture["skin"] then
		return skin .. "\\^\\[colorize\\:\\"..base_texture.skin["color"].."\\:"..tostring(base_texture.skin["ratio"])
	else
		return skin
	end
end

function player_api.compose_base_texture(player, def)
	local base_texture = player_api.get_base_texture_table(player)
	local texture = player_api.compose_skin(player, "[combine:"..def.canvas_size..":0,0="..def.skin_texture)

	local ordered_keys = {}

	for key in pairs(base_texture) do
		table.insert(ordered_keys, key)
	end

	table.sort(ordered_keys)

	for i = 1, #ordered_keys do
		local key, value = ordered_keys[i], base_texture[ordered_keys[i]]
		if key == "eyebrowns" then
			texture = texture .. ":"..def.eyebrowns_pos.."="..value
		elseif key == "eye" then
			texture = texture .. ":"..def.eye_right_pos.."="..value
			texture = texture .. ":"..def.eye_left_pos.."="..value
		elseif key == "mouth" then
			texture = texture .. ":"..def.mouth_pos.."="..value
		elseif key == "hair" then
			if def.hair_preview then
				value = string.sub(value, 0, -5).."_preview.png"
			end
			texture = texture .. ":"..def.hair_pos.."="..value
		end
	end
	return texture
end
