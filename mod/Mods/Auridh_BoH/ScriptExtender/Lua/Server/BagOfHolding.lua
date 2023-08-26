-- Item uuids
local Name_BagOfHolding = 'BoH_OBJ_BagOfHolding'

-- Status names
local Status_ReduceWeightChar = 'AC_REDUCE_WEIGHT_CHAR'

-- Osiris Events
local Osi_Evt_ItemMoved = 'Moved'
local Osi_Evt_AddedTo = 'AddedTo'


-- Osiris event listeners
Ext.Osiris.RegisterListener(Osi_Evt_ItemMoved, 1, 'after', function(entity)
	if Osi.HasActiveStatus(entity, Status_ReduceWeightChar) == 1 then
		Osi.RemoveStatus(entity, Status_ReduceWeightChar, entity)
	end
end)

Ext.Osiris.RegisterListener(Osi_Evt_AddedTo, 3, 'after', function(entity, char, type)
	if Osi.HasActiveStatus(entity, Status_ReduceWeightChar) == 1 then
		Osi.RemoveStatus(entity, Status_ReduceWeightChar, entity)
	end

	if Osi.IsInInventory(entity) == 1 and string.sub(char, 1, 20) == Name_BagOfHolding then
		Osi.ApplyStatus(entity, Status_ReduceWeightChar, -1, 1, entity)
	end
end)
