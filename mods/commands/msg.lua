--[[
	Type in the chat: /msg <message>
	Post a message in big bold letters
--]]

local args = {...}

local anim = {
	frames = {},
	_repeat = 0,
	start = 0,
	x = 1
}

local draw = function(start_x)
	for y = 1, #anim.frames do
		local text = ""

		for x = start_x, start_x + 39 do
			if anim.frames[y][x] == 1 then
				text = text .. "Z"
			else
				text = text .. "	"
			end
		end

		Mods.chat.send(text)
	end
end

if #args == 1 then
	anim.frames = TextToGrid.generate(args[1])

	Mods.chat.animation = function(self, dt, t)
		if t - anim.start > 0.05 then

			draw(anim.x)

			anim.start = t;
			anim.x = anim.x + 1

			if #anim.frames[1] < anim.x + 39 then
				anim._repeat = anim._repeat + 1
				anim.x = 1
			end

			if anim._repeat >= 1 then
				Mods.chat.animation = nil
			end
		end
	end

	return true
else
	return false
end
