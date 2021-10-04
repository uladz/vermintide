local mod_name = "NoWobble"

Mods.hook.set(mod_name, "PlayerUnitFirstPerson.update", function (func, self, unit, input, dt, context, t)
	func(self, unit, input, dt, context, t)
	
	local FPU = self.first_person_unit
	local camerabone = Unit.node(FPU, "camera_node")
	
	Unit.set_local_rotation(FPU,camerabone,Quaternion.identity())
	Unit.set_local_position(FPU,camerabone,Vector3.zero())
end)

--[[
if Unit.alive(Managers.player:local_player().player_unit) then -- or when he's dead.
	local first_person_ext = ScriptUnit.extension(Managers.player:local_player().player_unit, "first_person_system") -- Get the first person extension.
	local FPU = first_person_ext.get_first_person_unit(first_person_ext) -- Get the actual first person unit.
	local camerabone = Unit.node(FPU, "camera_node") -- Get the node to which the camera is attached.

	Unit.set_local_rotation(FPU,camerabone,Quaternion.identity()) -- Nullify any rotation the animations might've applied.
	Unit.set_local_position(FPU,camerabone,Vector3.zero()) -- Nullify any offset the animations might've applied.
end
--]]
