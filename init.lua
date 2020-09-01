ranks = {}

local input, errstr = io.open(minetest.get_worldpath().."/ranks.dat", "r")
if input then
	ranks = minetest.deserialize(input:read("*a") or {})
	io.close(input)
else
	print("[rank] "..minetest.get_worldpath().."/ranks.dat failed to load! ("..errstr..")")
end

function color(hex)
	return core.get_color_escape_sequence(hex)
end

rank_colors = {
	Builder = "#d87d1c",
	Helper = "#fff52b",
	Moderator = "#1e83f7",
	Admin = "#ff0000",
}

minetest.register_privilege("rank", {description = "Can change ranks.", give_to_singleplayer = false})

minetest.register_chatcommand("rank", {
	description = "Set a player's rank",
	params = "<name> Builder|Helper|Moderator|Admin",
	privs = {server = true, rank = true},
	func = function(name, param)
		local target = param:split(' ')[1]
		local param = param:split(' ')[2]
		if not param then return false, "Invalid Usage. See /help rank." end
--		param = param:lower()
		if param == "Builder" or param == "Helper" or param == "Moderator" or param == "Admin" then
			if minetest.get_player_by_name(target) then
				minetest.get_player_by_name(target):set_nametag_attributes({text = ""..color(rank_colors[param]).."["..param.."]"..color("#ffffff").." "..target})
				ranks[target] = param
				minetest.chat_send_player(name, target.."'s rank has been changed to "..param..".")
			end
		else
			minetest.chat_send_player(name, minetest.colorize("#FF0000", "Invalid Rank: "..param))
		end
	end
})

minetest.register_on_joinplayer(function(player)
	minetest.after(0, function()
		local name = player:get_player_name()
		if ranks[name] and name ~= minetest.setting_get("name") then
			player:set_nametag_attributes({text = ""..color(rank_colors[ranks[name]]).."["..ranks[name].."]"..color("#ffffff").."  "..name})
		elseif name == minetest.setting_get("name") then
			ranks[name] = "Admin"
			player:set_nametag_attributes({text = " "..color(rank_colors["Admin"]).."[Admin]"..color("#ffffff").." "..name})
--		else
--			ranks[name] = "wood"
--			player:set_nametag_attributes({text = "["..color(rank_colors[ranks[name]])..ranks[name]..color("#ffffff").."]: "..name})
		end
	end)
end)

minetest.register_on_shutdown(function()
	print("[rank] Shutting down. Saving ranks.")
	local stream, err = io.open(minetest.get_worldpath().."/ranks.dat", "w")
	if stream then
		stream:write(minetest.serialize(ranks))
		io.close(stream)
	else
		print("[rank] "..minetest.get_worldpath().."/ranks.dat failed to load! ("..err..")")
	end
end)

minetest.register_on_chat_message(function(name, message)
	if message:sub(1,1) == "/" then
		return false
	end
--	local pname = name
--	if minetest.get_modpath("morecommands") then
--		if nicked_players[name] then
--			pname = "~" .. nicked_players[name]
--		else
--			pname = name
--		end
--	else
--		pname = name
--	end
	if ranks[name] ~= nil then
	minetest.chat_send_all(""..minetest.colorize(rank_colors[ranks[name]], "[" ..ranks[name].. "]").." <"..name.."> "..message)
	else
	minetest.chat_send_all("<"..name.."> "..message)
	end
	return true
end)

--API
rank = {}
function rank.getRankName(name)

	local rname = ranks[name]
	if rname == nil then
		rname = ""
	else rname = minetest.colorize(rank_colors[ranks[name]], "[" ..ranks[name].. "]")
	end
	return rname
end


