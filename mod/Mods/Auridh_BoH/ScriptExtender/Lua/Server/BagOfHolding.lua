-- Item uuids
local Uid_BagOfHolding = '7471c9a3-e826-4ff2-b04c-b47c5360e46f'

-- Status names
local Status_ReduceWeightChar = 'AC_REDUCE_WEIGHT_CHAR'

-- Self defined events
local Event_BagSearch = 'BoH_BagSearch'
local Event_BagSearchEnd = 'BoH_BagSearchEnd'
local Event_BagSearchSub = 'BoH_BagSearchSub'
local Event_BagSearchSubEnd = 'BoH_BagSearchSubEnd'
local Event_ReduceWeight = 'BoH_ReduceWeight'
local Event_ReduceWeightEnd = 'BoH_ReduceWeightEnd'

-- Osiris Events
local Osi_Evt_EntityEvent = 'EntityEvent'



function ExecuteForPlayerCharacters(action)
	-- Get party members from db
	local partyMembers = Osi.DB_PartyMembers:Get(nil)

	for _, v in pairs(partyMembers) do
		action(v[1])
	end
end

function ApplyReducedWeightToItem(entity)
	Osi.RemoveStatus(entity, Status_ReduceWeightChar, entity)
	Osi.ApplyStatus(entity, Status_ReduceWeightChar, 60, 1, entity)
end

function ApplyReducedWeightByPlayer(player)
	Osi.IterateInventoryByTemplate(player, Uid_BagOfHolding, Event_BagSearch, Event_BagSearchEnd)
end

local tickCounter = 0
function OnTick()
	if tickCounter < 1000 then
		tickCounter = tickCounter + 1
	else
		tickCounter = 0
		ExecuteForPlayerCharacters(ApplyReducedWeightByPlayer)
	end
end

-- Event listeners
Ext.Events.Tick:Subscribe(OnTick)

-- Osiris event listeners
Ext.Osiris.RegisterListener(Osi_Evt_EntityEvent, 2, 'after', function (entity, event)
	local choices = {
		[Event_BagSearch] = function(item)
			--Ext.Utils.Print(Event_BagSearch .. ' | ' .. item)
			Osi.IterateInventory(
					item,
					Event_ReduceWeight,
					Event_ReduceWeightEnd)
		end,
		[Event_BagSearchSub] = function(item)
			--Ext.Utils.Print(Event_BagSearchSub .. ' | ' .. item)
			ApplyReducedWeightToItem(item)
		end,
		[Event_ReduceWeight] = function(item)
			--Ext.Utils.Print(Event_ReduceWeight .. ' | ' .. item)
			if Osi.IsContainer(item) == 1 then
				Osi.IterateInventory(
						item,
						Event_BagSearchSub,
						Event_BagSearchSubEnd)
			else
				ApplyReducedWeightToItem(item)
			end
		end
	}

	local func = choices[event]
	if func then
		func(entity)
	end
end)
