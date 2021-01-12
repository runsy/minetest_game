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

function player_api.compose_base_texture(player)
	local base_texture = player_api.get_base_texture_table(player)
	local texture = player_api.compose_skin(player, "[combine:128x64:0,0=player_skin.png")
	for key,value in pairs(base_texture) do
		if key == "eyebrowns" then
			texture = texture .. ":16,16="..value
		elseif key == "eye" then
			texture = texture .. ":18,24="..value
			texture = texture .. ":26,24="..value
		elseif key == "mouth" then
			texture = texture .. ":16,28="..value
		elseif key == "hair" then
			texture = texture .. ":0,0="..value
		end
	end
	return texture
end
