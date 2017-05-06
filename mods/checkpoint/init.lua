local players = {}

local function vdistance(a, b)
	local x, y, z = a.x - b.x, a.y - b.y, a.z - b.z
	return x*x + y*y + z*z
end

local function set_checkpoint(player, pos)
	local name = player:get_player_name()
	local ppos = player:getpos()
	
	--print(tostring(vdistance(pos, ppos)))
	if vdistance(pos, ppos) <= 10 then
		players[name] = ppos
		minetest.sound_play({name="checkpoint_checkpoint", gain=0.75},
				{to_player=name})
		minetest.chat_send_player(name, "Checkpoint saved")
	else
		minetest.chat_send_player(name, "Out of range!")
	end
end

minetest.register_node("checkpoint:checkpoint", {
	description = "Checkpoint",
	tiles = {"checkpoint_teleporter.png"},
	inventory_image = "checkpoint_teleporter.png",
	drawtype = "plantlike",
	sunlight_propagates = true,
	light_source = 8,
	paramtype = "light",
	groups = {cracky = 1, choppy = 1, crumbly = 1, snappy = 1},
	on_rightclick = function(pos, _, clicker)
		set_checkpoint(clicker, pos)
	end,
	on_punch = function(pos, _, puncher)
		set_checkpoint(puncher, pos)
	end
})

minetest.register_craftitem("checkpoint:teleporter", {
	description = "Checkpoint Teleporter",
	inventory_image = "checkpoint_teleporter.png",
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		local pos = players[name]
		if pos then
			user:setpos(pos)
		else
			minetest.chat_send_player(name, "No checkpoint saved")
		end
	end
})

minetest.register_chatcommand("checkpoint", {
	description = "Restore saved checkpoint",
	func = function(name, param)
		local pos = players[name]
		if pos then
			local player = minetest.get_player_by_name(name)
			player:setpos(pos)
		else
			minetest.chat_send_player(name, "No checkpoint saved")
			--return "No checkpoint saved"
		end
	end
})

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	players[name] = nil
end)
