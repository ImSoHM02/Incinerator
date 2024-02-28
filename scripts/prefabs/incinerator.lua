require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/incinerator.zip"),
	Asset("ATLAS", "images/inventoryimages/incinerator.xml"),
}

local prefabs =
{
	"collapse_small",
}

local modname = KnownModIndex:GetModActualName("Incinerator")
local AOC = GetModConfigData("AshOrCharcoal", modname)

local function onBurnItems(inst)
	local hasItems = false
	local returnItems = {}

	if inst.components.aipc_action and inst.components.container then
		local ings = {}
		for k, item in pairs(inst.components.container.slots) do
			local stackSize = item.components.stackable and item.components.stackable:StackSize() or 1
			local lootItem -- Declare lootItem here
			if AOC == 1 then
				lootItem = "ash"
			else
				lootItem = "charcoal"
			end
			returnItems[lootItem] = (returnItems[lootItem] or 0) + stackSize
			hasItems = true
		end
	end

    if hasItems then
        local light = SpawnPrefab("heatrocklight")
        light.Transform:SetPosition(inst.Transform:GetWorldPosition())
        light.Light:Enable(true)

		inst.AnimState:PlayAnimation("idle")
		inst.AnimState:PushAnimation("idle", false)
		inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")

		inst.components.container:Close()
		inst.components.container:DestroyContents()

		inst.components.burnable:Extinguish()
		inst:DoTaskInTime(0, function ()
			inst.components.burnable:Ignite()
			inst.components.burnable:SetFXLevel(1)
		end)

		inst:DoTaskInTime(10, function() -- Add a delay of 10 seconds
			for prefab, prefabCount in pairs(returnItems) do
				local currentCount = prefabCount
				local loot = inst.components.lootdropper:SpawnLootPrefab(prefab)
				local lootMaxSize = 1

				if loot.components.stackable then
					lootMaxSize = loot.components.stackable.maxsize
				end
				loot:Remove()

				while(currentCount > 0)
				do
					local dropCount = math.min(currentCount, lootMaxSize)
					local dropLootItem = inst.components.lootdropper:SpawnLootPrefab(prefab)
					if dropLootItem.components.stackable then
						dropLootItem.components.stackable:SetStackSize(dropCount)
					end

					currentCount = currentCount - dropCount
				end
			end
			light.Light:Enable(false)
            light:Remove()
		end)
	end
end

local function onextinguish(inst)
end

local function onhammered(inst, worked)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("/common/destroy_metal")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:PushAnimation("idle")
end

local function onbuilt(inst)
	inst.AnimState:PushAnimation("idle", false)
	inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
end

local function OnInit(inst)
	if inst.components.burnable ~= nil then
		inst.components.burnable:FixFX()
	end
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeObstaclePhysics(inst, 1)

	inst.AnimState:SetBank("incinerator")
	inst.AnimState:SetBuild("incinerator")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("structure")

	MakeSnowCoveredPristine(inst)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("burnable")
	inst.components.burnable:SetBurnTime(10)
	inst:ListenForEvent("onextinguish", onextinguish)

	inst:AddComponent("container")
	inst.components.container:WidgetSetup("incinerator")

	inst:AddComponent("aipc_action")
	inst.components.aipc_action.onDoAction = onBurnItems


	inst:AddComponent("lootdropper")

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst:AddComponent("hauntable")

	inst:AddComponent("inspectable")

	inst:ListenForEvent("onbuilt", onbuilt)
	inst:DoTaskInTime(0, OnInit)

	return inst
end

local function lightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetRadius(5)
    inst.Light:SetFalloff(0.9)
    inst.Light:SetIntensity(0.8)
    inst.Light:SetColour(235 / 255, 165 / 255, 12 / 255)
    inst.Light:Enable(false)
end

return Prefab("incinerator", fn, assets, prefabs),
	Prefab("heatrocklight", lightfn),
	MakePlacer("incinerator_placer", "incinerator", "incinerator", "idle")