GLOBAL.setmetatable(
	env,
	{
		__index = function(t, k)
			return GLOBAL.rawget(GLOBAL, k)
		end
	}
)

GLOBAL.STRINGS.AIP = {}
local Vector3 = GLOBAL.Vector3
local STRINGS = GLOBAL.STRINGS

PrefabFiles = 
{
	"incinerator",
}

Assets = 
{
	Asset("IMAGE", "images/inventoryimages/incinerator.tex"),
	Asset("ATLAS", "images/inventoryimages/incinerator.xml"),
	Asset("ANIM", "anim/ui_chest_4x4.zip"),
}

local AIP_ACTION = env.AddAction("AIP_ACTION", "Operate", function(act)

	local doer = act.doer
	local target = act.target

	if target.components.aipc_action ~= nil then
		target.components.aipc_action:DoAction(doer)
		return true
	end
	return false, "INUSE"
end)
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(AIP_ACTION, "doshortaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(AIP_ACTION, "doshortaction"))
local params = {}

params.incinerator =
{
		widget = {
			slotpos = {},
			animbank = "ui_chest_4x4",
			animbuild = "ui_chest_4x4",
			pos = GLOBAL.Vector3(0, 200, 0),
			side_align_tip = 160,
			buttoninfo =
			{
				text = "Burn",
				position = Vector3(0, -165, 0),
		}
	},
	acceptsstacks = true,
	type = "chest"
}

for y = 3, 0, -1 do
	for x = 0, 3 do
		table.insert(params.incinerator.widget.slotpos, GLOBAL.Vector3(80*x-80*2+40, 80*y-80*2+40,0))
	end
end

function params.incinerator.itemtestfn(container, item, slot)
	if item:HasTag("irreplaceable") or item.prefab == "ash" then
		return false, "INCINERATOR_NOT_BURN"
	end

	return true
end

function params.incinerator.widget.buttoninfo.fn(inst)
	if inst.components.container ~= nil then
		GLOBAL.BufferedAction(inst.components.container.opener, inst, AIP_ACTION):Do()
	elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
		GLOBAL.SendRPCToServer(GLOBAL.RPC.DoWidgetButtonAction, AIP_ACTION.code, inst, AIP_ACTION.mod_name)
	end
end

function params.incinerator.widget.buttoninfo.validfn(inst)
	return inst.replica.container ~= nil
end


local tmpConfig = {

	cancelbtn = { text = "Cancel", cb = nil, control = CONTROL_CANCEL },
	acceptbtn = { text = "Confirm", cb = nil, control = CONTROL_ACCEPT },
}


local containers = GLOBAL.require "containers"
local old_widgetsetup = containers.widgetsetup

function containers.widgetsetup(container, prefab, data)
	local pref = prefab or container.inst.prefab

	local containerParams = params[pref]
	if containerParams then
		for k, v in pairs(containerParams) do
			container[k] = v
		end
		container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
		return
	end

	return old_widgetsetup(container, prefab, data)
end

for k, v in pairs(params) do
	containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end

local incinerator =
AddRecipe2("incinerator", 
	{
		Ingredient("cutstone", 						10),
		Ingredient("gears", 						5),
	}, 
	TECH.SCIENCE_ONE, "incinerator_placer", {"CONTAINERS"})
	RegisterInventoryItemAtlas("images/inventoryimages/incinerator.xml", "incinerator.tex")
	STRINGS.NAMES.INCINERATOR = "Incinerator"