--[[
	Post a message in flits animation
	Type in the chat: /flits <message>
--]]

local args = {...}

local anim = {
	frames = {},
	_repeat = 0,
	start = 0,
	rev = false
}

local draw = function(start_x, rev)
	for y = 1, #anim.frames do
		local text = ""

		for x = start_x, start_x + 39 do
			if anim.frames[y][x] == 1 then
				if rev then
					text = text .. "Z"
				else
					text = text .. "	"
				end
			else
				if rev then
					text = text .. "	"
				else
					text = text .. "Z"
				end
			end
		end

		Mods.chat.send(text)
	end
end

if #args == 1 then
	anim.frames = TextToGrid.generate(args[1])

	Mods.chat.animation = function(self, dt, t)
		if t - anim.start > 0.05 then
			draw(0, anim.rev)

			anim.start = t;
			anim.rev = not anim.rev
			anim._repeat = anim._repeat + 1

			if anim._repeat >= 50 then
				Mods.chat.animation = nil
			end
		end
	end

	return true
else
	return false
end
