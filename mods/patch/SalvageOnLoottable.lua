SalvageOnLoottable = {}

local mod = SalvageOnLoottable

local mod_name = "SalvageOnLoottable"

oi = OptionsInjector

mod.get = Application.user_setting
mod.set = Application.set_user_setting
mod.save = Application.save_user_settings

mod.widget_settings = {
	ACTIVE = {
		["save"] = "cb_salvage_loottable_active",
		["widget_type"] = "stepper",
		["text"] = "Salvage on Loottable",
		["tooltip"] = "Salvage on Loottable\n" ..
			"Enables you to salvage on loottable on end of a roll dices event.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	},
	salvage_button = UIWidgets.create_dice_game_button("salvage_button")
}

mod.ui_scenegraph = {
	root = {
		is_root = true,
		position = {
			0,
			0,
			UILayer.hud
		},
		size = {
			1920,
			1080
		}
	},
	overlay = {
		vertical_alignment = "center",
		parent = "root",
		horizontal_alignment = "center",
		size = {
			1920,
			1080
		},
		position = {
			0,
			0,
			10
		}
	},
	salvage_button = {
		vertical_alignment = "bottom",
		parent = "overlay",
		horizontal_alignment = "center",
		size = {
			338,
			120
		},
		position = {
			200,
			70,
			400
		}
	}
}

-- ####################################################################################################################
-- ##### Renderer #####################################################################################################
-- ####################################################################################################################
mod.create_renderer = function()
	mod.permanent = {
		ui_renderer = UIRenderer.create(
			Managers.world:world("top_ingame_view"),
			"material", "materials/ui/ui_1080p_ingame_common",
		--	"material", "materials/ui/ui_1080p_ingame_postgame",
			"material", "materials/ui/ui_1080p_popup",
			"material", "materials/ui/ui_1080p_level_images",
			"material", "materials/fonts/gw_fonts"
		),
		
		ui_scenegraph = UISceneGraph.init_scenegraph(mod.ui_scenegraph),
		
		widgets = {
			salvage_button = UIWidget.init(mod.widget_settings.salvage_button)
		}
	}
end

-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
mod.create_options = function()
	Mods.option_menu:add_group("salvage_on_loottable", "Salvage On Loottable")
	
	Mods.option_menu:add_item("salvage_on_loottable", mod.widget_settings.ACTIVE, true)
end

mod.draw_widgets = function(reward_ui, dt)
	safe_pcall(function()
		local ui_renderer = mod.permanent.ui_renderer
		local ui_scenegraph = mod.permanent.ui_scenegraph
		local input_service = Managers.input:get_service("reward_ui")
		
		UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, "root")
		
		-- Roll button
		reward_ui.ui_scenegraph.roll_button.position[1] = -200
		
		-- Salvage button
		local salvage_button = mod.permanent.widgets.salvage_button
		local salvage_button_text = string.lower(Localize("forge_title_salvage"))
		salvage_button_text = salvage_button_text:gsub("^%l", string.upper)
		salvage_button.content.text_field = salvage_button_text
		if salvage_button.content.button_hotspot.on_release then
			local backend_id = reward_ui.reward_results.backend_id
			local melted, item_key, number_of_tokens = ForgeLogic.melt_item(nil, backend_id)
			
			if melted then
				local item = ItemMasterList[item_key]
				local item_name = Localize(item.display_name)
				local token_type = ForgeSettings.melt_reward[item.rarity].token_type
				local token_type_name = (token_type == "iron_tokens" and "Jacinth")
						or (token_type == "bronze_tokens" and "Jade")
						or (token_type == "silver_tokens" and "Hematite")
						or (token_type == "gold_tokens" and "Opal")

				local message = "Salvaged " .. item_name .. " and gained " .. number_of_tokens .. " " .. token_type_name ..  " Upgrade Tokens."
				
				EchoConsole(message)
				if not Managers.chat:chat_is_focused() then
					Managers.chat.chat_gui:show_chat()
				end
			end
			
			reward_ui.is_complete = true
		end
		
		UIRenderer.draw_widget(ui_renderer, salvage_button)
		
		UIRenderer.end_pass(ui_renderer)
	end)
end

-- ####################################################################################################################
-- ##### Hook #########################################################################################################
-- ####################################################################################################################
Mods.hook.set(mod_name, "RewardUI.update", function (func, self, dt)
	func(self, dt)
	
	if mod.get(mod.widget_settings.ACTIVE.save) then
		if self.transition_name == "present_reward" then
			if not self.is_complete then
				if not self.ui_dice_animations.animate_reward_info then
					if (self.reroll_needed or (self.draw_roll_button and self.reward_entry_done)) then
						mod.draw_widgets(self, dt)
					end
				end
			end
		end
	end
end)

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
mod.create_renderer()
mod.create_options()