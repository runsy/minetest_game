local S = minetest.get_translator("player_api")

function player_api.has_cloths(player)
	local inv = player:get_inventory()
	if inv:is_empty("cloths") then
		return false
	else
		return true
	end
end

function player_api.register_cloth(name, def)
	if not(def.inventory_image) then
		def.wield_image = def.texture
	end
	if not(def.wield_image) then
		def.wield_image = def.inventory_image
	end
	minetest.register_craftitem(name, {
		description = def.description,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		stack_max = def.stack_max or 16,
		_cloth_texture = def.texture,
		_cloth_genre = def.genre,
		groups = def.groups,
	})
end

player_api.register_cloth("player_api:cloth_female_upper_default", {
	description = S("Purple Stripe Summer T-shirt"),
	inventory_image = "cloth_female_upper_default_inv.png",
	wield_image = "cloth_female_upper_default.png",
	texture = "cloth_female_upper_default.png",
	genre = "female",
	groups = {cloth = 2},
})

player_api.register_cloth("player_api:cloth_female_lower_default", {
	description = S("Fresh Summer Denim Shorts"),
	inventory_image = "cloth_female_lower_default_inv.png",
	wield_image = "cloth_female_lower_default_inv.png",
	texture = "cloth_female_lower_default.png",
	genre = "female",
	groups = {cloth = 3},
})

player_api.register_cloth("player_api:cloth_female_head_default", {
	description = S("Pink Bow"),
	inventory_image = "cloth_female_head_default_inv.png",
	wield_image = "cloth_female_head_default_inv.png",
	texture = "cloth_female_head_default.png",
	genre = "female",
	groups = {cloth = 1},
})

player_api.register_cloth("player_api:cloth_male_upper_default", {
	description = S("Classic Green Sweater"),
	inventory_image = "cloth_male_upper_default_inv.png",
	wield_image = "cloth_male_upper_default_inv.png",
	texture = "cloth_male_upper_default.png",
	genre = "male",
	groups = {cloth = 2},
})

player_api.register_cloth("player_api:cloth_male_lower_default", {
	description = S("Fine Blue Pants"),
	inventory_image = "cloth_male_lower_default_inv.png",
	wield_image = "cloth_male_lower_default_inv.png",
	texture = "cloth_male_lower_default.png",
	genre = "male",
	groups = {cloth = 3},
})

function player_api.set_cloths(player)
	local gender = player:get_meta():get_string("gender")
	--Create the "cloths" inventory
	local inv = player:get_inventory()
	inv:set_size("cloths", 3)

	if gender == "male" then
		inv:add_item("cloths", 'player_api:cloth_male_upper_default')
		inv:add_item("cloths", 'player_api:cloth_male_lower_default')
	else
		inv:add_item("cloths", 'player_api:cloth_female_head_default')
		inv:add_item("cloths", 'player_api:cloth_female_upper_default')
		inv:add_item("cloths", 'player_api:cloth_female_lower_default')
	end
end

function player_api.compose_cloth(player)
	local gender = player:get_meta():get_string("gender")
	if not(player_api.has_cloths(player)) then
		player_api.set_cloths(player)
	end
	local inv = player:get_inventory()
	local inv_list = inv:get_list("cloths")
	local upper_ItemStack
	local lower_ItemStack
	local head_ItemStack
	for i = 1, #inv_list do
		local item_name = inv_list[i]:get_name()
		--minetest.chat_send_all(item_name)
		local cloth_type = minetest.get_item_group(item_name, "cloth")
		--if cloth_type then minetest.chat_send_all(cloth_type) end
		if cloth_type == 1 then
			head_ItemStack = minetest.registered_items[item_name]._cloth_texture
		elseif cloth_type == 2 then
			upper_ItemStack = minetest.registered_items[item_name]._cloth_texture
		elseif cloth_type == 3 then
			lower_ItemStack = minetest.registered_items[item_name]._cloth_texture
		end
	end
	local base_texture
	if gender == "male" then
		base_texture = "player_male_base.png"
	else
		base_texture = "player_female_base.png"
	end
	local cloth = "[combine:128x64:0,0="..base_texture
	if upper_ItemStack then
		cloth = cloth .. ":32,32="..upper_ItemStack
	end
	if lower_ItemStack then
		cloth = cloth .. ":0,32="..lower_ItemStack
	end
	if head_ItemStack then
		cloth = cloth .. ":48,0="..head_ItemStack
	end
	return cloth
end
