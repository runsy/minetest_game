-- Minetest 0.4 mod: player
-- See README.txt for licensing and other information.

-- Load support for MT game translation.
local S = minetest.get_translator("player_api")

player_api = {}

-- Player animation blending
-- Note: This is currently broken due to a bug in Irrlicht, leave at 0
local animation_blend = 0

player_api.registered_models = { }

-- Local for speed.
local models = player_api.registered_models

function player_api.register_model(name, def)
	models[name] = def
end

-- Player stats and animations
local player_model = {}
local player_textures = {}
local player_anim = {}
local player_sneak = {}
player_api.player_attached = {}

function player_api.get_animation(player)
	local name = player:get_player_name()
	return {
		model = player_model[name],
		textures = player_textures[name],
		animation = player_anim[name],
	}
end

function player_api.set_gender(player, gender)
	if not(gender) or gender == "random" then
		if math.random(2) == 1 then
			gender = "male"
		else
			gender = "female"
		end
	end
	local meta = player:get_meta()
	meta:set_string("gender", gender)
	return gender
end

function player_api.get_gender(player)
	local meta = player:get_meta()
	return meta:get_string("gender")
end

function player_api.get_gender_model(gender)
	local model
	if gender == "male" then
		model = "character.b3d"
	else
		model = "female.b3d"
	end
	return model
end

-- Called when a player's appearance needs to be updated
function player_api.set_model(player, model_name)
	local name = player:get_player_name()
	local model = models[model_name]
	if model then
		if player_model[name] == model_name then
			return
		end
		player:set_properties({
			mesh = model_name,
			textures = player_textures[name] or model.textures,
			visual = "mesh",
			visual_size = model.visual_size or {x = 1, y = 1},
			collisionbox = model.collisionbox or {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
			stepheight = model.stepheight or 0.6,
			eye_height = model.eye_height or 1.47,
		})
		player_api.set_animation(player, "stand")
	else
		player:set_properties({
			textures = {"player.png", "player_back.png"},
			visual = "upright_sprite",
			visual_size = {x = 1, y = 2},
			collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.75, 0.3},
			stepheight = 0.6,
			eye_height = 1.625,
		})
	end
	player_model[name] = model_name
end

function player_api.set_textures(player, textures)
	local name = player:get_player_name()
	local model = models[player_model[name]]
	local model_textures = model and model.textures or nil
	player_textures[name] = textures or model_textures
	player:set_properties({textures = textures or model_textures,})
end

function player_api.set_animation(player, anim_name, speed)
	local name = player:get_player_name()
	if player_anim[name] == anim_name then
		return
	end
	local model = player_model[name] and models[player_model[name]]
	if not (model and model.animations[anim_name]) then
		return
	end
	local anim = model.animations[anim_name]
	player_anim[name] = anim_name
	player:set_animation(anim, speed or model.animation_speed, animation_blend)
end

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_model[name] = nil
	player_anim[name] = nil
	player_textures[name] = nil
end)

-- Localize for better performance.
local player_set_animation = player_api.set_animation
local player_attached = player_api.player_attached

-- Prevent knockback for attached players
local old_calculate_knockback = minetest.calculate_knockback
function minetest.calculate_knockback(player, ...)
	if player_attached[player:get_player_name()] then
		return 0
	end
	return old_calculate_knockback(player, ...)
end

-- Check each player and apply animations
minetest.register_globalstep(function()
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local model_name = player_model[name]
		local model = model_name and models[model_name]
		if model and not player_attached[name] then
			local controls = player:get_player_control()
			local animation_speed_mod = model.animation_speed or 30

			-- Determine if the player is sneaking, and reduce animation speed if so
			if controls.sneak then
				animation_speed_mod = animation_speed_mod / 2
			end

			-- Apply animations based on what the player is doing
			if player:get_hp() == 0 then
				player_set_animation(player, "lay")
			-- Determine if the player is walking
			elseif controls.up or controls.down or controls.left or controls.right then
				if player_sneak[name] ~= controls.sneak then
					player_anim[name] = nil
					player_sneak[name] = controls.sneak
				end
				if controls.LMB or controls.RMB then
					player_set_animation(player, "walk_mine", animation_speed_mod)
				else
					player_set_animation(player, "walk", animation_speed_mod)
				end
			elseif controls.LMB or controls.RMB then
				player_set_animation(player, "mine", animation_speed_mod)
			else
				player_set_animation(player, "stand", animation_speed_mod)
			end
		end
	end
end)

function player_api.get_gender_formspec(name)
	local text = S("Select your gender")

	local formspec = {
		"formspec_version[3]",
		"size[3.2,2.476]",
		"label[0.375,0.5;", minetest.formspec_escape(text), "]",
		"image_button_exit[0.375,1;1,1;player_male_face.png;btn_male;"..S("Male").."]",
		"image_button_exit[1.7,1;1,1;player_female_face.png;btn_female;"..S("Female").."]"
	}

	-- table.concat is faster than string concatenation - `..`
	return table.concat(formspec, "")
end

function player_api.select_gender(player_name)
    minetest.show_formspec(player_name, "player_api:gender", player_api.get_gender_formspec(player_name))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "player_api:gender" then
		return
	end
	local player_name = player:get_player_name()
	local gender
	if fields.btn_male or fields.btn_female then
		if fields.btn_male then
			gender = "male"
		else
			gender = "female"
		end
		player_api.set_gender(player, gender)
	else
		gender = player_api.set_gender(player, "random")
	end
	local gender_model = player_api.get_gender_model(gender)
	player_api.set_model(player, gender_model)
	if minetest.get_modpath("3d_armor")~=nil then
		player_api.set_textures(player, models[gender_model].textures)
	end
end)
