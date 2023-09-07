-- Stat strings
local StatString_BagOfHolding = 'BoH_OBJ_BagOfHolding'
-- Templates
local Template_BagOfHolding = '7471c9a3-e826-4ff2-b04c-b47c5360e46f'
-- Self defined events
local Evt_InitContainerDB = 'Evt_InitContainerDB'
local Evt_InitObjectDB = 'Evt_InitObjectDB'
local Evt_RemoveContainers = 'Evt_RemoveContainers'
-- Status names
local Status_ReduceWeightChar = 'AC_REDUCE_WEIGHT_CHAR'
local Status_WeightDisplayFix = 'BH_REDUCE_WEIGHT_FIX'

-- Osiris Events
local Osi_Evt_AddedTo = 'AddedTo'
local Osi_Evt_RemovedFrom = 'RemovedFrom'
local Osi_Evt_SavegameLoaded = 'SavegameLoaded'
local Osi_Evt_EntityEvent = 'EntityEvent'
local Osi_Evt_CharacterJoinedParty = 'CharacterJoinedParty'
local Osi_Evt_CharacterLeftParty = 'CharacterLeftParty'

-- Bags of Holding
local BagsOfHolding = {}
local WeightLimit = 500

local function InitAddToBag(objectUid, bagUid)
	local bag = BagsOfHolding[bagUid]
	local objectStats = Ext.Stats.Get(Osi.GetStatString(objectUid))

	if Osi.HasActiveStatus(objectUid, Status_ReduceWeightChar) == 1 then
		bag.CollectedWeight	= bag.CollectedWeight + objectStats.Weight
		bag.Objects.Affected[objectUid] = GetObjectEntry(objectStats)
	else
		bag.Objects.InQueue[objectUid] = GetObjectEntry(objectStats)
	end
end

local function ReduceWeight(objectStats, objectUid, bag)
	Log('ReduceWeight: %s + %s <= %s', bag.CollectedWeight, objectStats.Weight, WeightLimit)
	bag.CollectedWeight	= bag.CollectedWeight + objectStats.Weight
	bag.Objects.Affected[objectUid] = GetObjectEntry(objectStats)

	Osi.ApplyStatus(objectUid, Status_ReduceWeightChar, -1, 1, bag.UUID)
	Osi.ApplyStatus(Osi.GetOwner(bag.UUID), Status_WeightDisplayFix, 0, 1, bag.UUID)
end
local function AddObjectToBag(objectUid, bagUid)
	Log('AddObjectToBag: %s | %s', objectUid, bagUid)
	local bag = BagsOfHolding[bagUid]
	local objectStats = Ext.Stats.Get(Osi.GetStatString(objectUid))

	if bag.CollectedWeight + objectStats.Weight > WeightLimit then
		Log('Weights too much: %s + %s > %s', bag.CollectedWeight, objectStats.Weight, WeightLimit)
		bag.Objects.InQueue[objectUid] = GetObjectEntry(objectStats)
		return
	end

	ReduceWeight(objectStats, objectUid, bag)
end
local function RemoveObjectFromBag(objectUid, bagUid)
	Log('RemoveObjectFromBag: %s, %s', objectUid, bagUid)
	local bag = BagsOfHolding[bagUid]
	local objectStats = Ext.Stats.Get(Osi.GetStatString(objectUid))

	if bag.Objects.Affected[objectUid] ~= nil then
		Log('Remove boost')
		bag.CollectedWeight	= bag.CollectedWeight - objectStats.Weight
		bag.Objects.Affected[objectUid] = nil

		Osi.RemoveStatus(objectUid, Status_ReduceWeightChar, bagUid)
		Osi.ApplyStatus(Osi.GetOwner(bagUid), Status_WeightDisplayFix, 0, 1, bagUid)

		local freeWeight = WeightLimit - bag.CollectedWeight
		for key, value in pairs(bag.Objects.InQueue) do
			Log('Free weight left: %s [%s / %s]', freeWeight, key, value.Weight)
			if freeWeight - value.Weight >= 0 then
				freeWeight = freeWeight - value.Weight
				bag.Objects.InQueue[key] = nil
				ReduceWeight(value, key, bag)

				if freeWeight <= 0 then
					break
				end
			end
		end
	else
		Log('Remove from queue')
		bag.Objects.InQueue[objectUid] = nil
	end
end


-- Osiris event listeners
-- event SavegameLoaded()
Ext.Osiris.RegisterListener(Osi_Evt_SavegameLoaded, 0, 'after', function()
	IteratePlayerDB(function(playerUuid)
		Osi.IterateInventoryByTemplate(playerUuid, Template_BagOfHolding, Evt_InitContainerDB, Evt_InitContainerDB .. 'End')
	end)
end)
-- event RemovedFrom((GUIDSTRING)_Object, (GUIDSTRING)_InventoryHolder)
Ext.Osiris.RegisterListener(Osi_Evt_RemovedFrom, 2, 'before', function(entity, container)
	if Osi.GetStatString(entity) == StatString_BagOfHolding and Osi.IsCharacter(container) then
		BagsOfHolding[entity] = nil
		return
	end
	if Osi.GetStatString(container) == StatString_BagOfHolding and BagsOfHolding[container] ~= nil then
		RemoveObjectFromBag(entity, container)
	end
end)
-- event AddedTo((GUIDSTRING)_Object, (GUIDSTRING)_InventoryHolder, (STRING)_AddType)
Ext.Osiris.RegisterListener(Osi_Evt_AddedTo, 3, 'before', function(entity, container, _)
	if Osi.GetStatString(entity) == StatString_BagOfHolding and Osi.IsCharacter(container) then
		BagsOfHolding[entity] = GetBoHEntry(entity)
		Osi.IterateInventory(entity, Evt_InitObjectDB, Evt_InitObjectDB .. 'End')
		return
	end
	if Osi.GetStatString(container) == StatString_BagOfHolding and BagsOfHolding[container] ~= nil then
		AddObjectToBag(entity, container)
	end
end)
-- event EntityEvent((GUIDSTRING)_Object, (STRING)_Event)
Ext.Osiris.RegisterListener(Osi_Evt_EntityEvent, 2, 'after', function(entity, event)
	if event == Evt_InitContainerDB then
		BagsOfHolding[entity] = GetBoHEntry(entity)
		Osi.IterateInventory(entity, Evt_InitObjectDB, Evt_InitObjectDB .. 'End')
	elseif event == Evt_InitObjectDB then
		for bagUid, _ in pairs(BagsOfHolding) do
			if Osi.IsInInventoryOf(entity, bagUid) == 1 then
				InitAddToBag(entity, bagUid)
				break
			end
		end
	elseif event == Evt_RemoveContainers then
		BagsOfHolding[entity] = nil
	end
end)
-- event CharacterJoinedParty((CHARACTER)_Character)
Ext.Osiris.RegisterListener(Osi_Evt_CharacterJoinedParty, 1, 'after', function(character)
	Osi.IterateInventoryByTemplate(character, Template_BagOfHolding, Evt_InitContainerDB, Evt_InitContainerDB .. 'End')
end)
-- event CharacterLeftParty((CHARACTER)_Character)
Ext.Osiris.RegisterListener(Osi_Evt_CharacterLeftParty, 1, 'after', function(character)
	Osi.IterateInventoryByTemplate(character, Template_BagOfHolding, Evt_RemoveContainers, Evt_RemoveContainers .. 'End')
end)