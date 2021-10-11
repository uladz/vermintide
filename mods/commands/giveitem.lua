--[[
ItemDispenser v1.0.0
Author: IamLupo
Adds a chat command that puts an item with specified id into your inventory.
Chat command:
	/giveitem [item_id]
You can use this spreadsheet to find right ids (Key column):
	https://docs.google.com/spreadsheets/d/1phNRw5rXvGQdfcExFH_2jgtemiNeA-bDieCTsSMPods/edit?usp=sharing

Changelog
	1.0.0 - Release
--]]

local args = {...}

if #args == 1 then
	local item_name = args[1]

	-- ItemMasterList can not handle key check. This is a dirty fix
	local found = false
	for key, obj in pairs(ItemMasterList) do
		if key == item_name then
			found = true
		end
	end

	if found then
		EchoConsole("Spawned Item '" .. item_name .. "' in inventory!")

		-- Spawn item in inventory
		ScriptBackendItem.award_item(item_name)
		Managers.backend:commit()
	else
		EchoConsole("Item '" .. item_name .. "' does not exist")
	end

	return true
else
	return false
end
