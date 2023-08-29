-- Item uuids
local Name_BagOfHolding = 'BoH_OBJ_BagOfHolding'

-- Status names
local Status_ReduceWeightChar = 'AC_REDUCE_WEIGHT_CHAR'
local Status_WeightDisplayFix = 'BH_REDUCE_WEIGHT_FIX'

-- Osiris Events
local Osi_Evt_AddedTo = 'AddedTo'
local Osi_Evt_RemovedFrom = 'RemovedFrom'


-- Osiris event listeners
Ext.Osiris.RegisterListener(Osi_Evt_RemovedFrom, 2, 'before', function(entity, container)
	if Osi.HasActiveStatus(entity, Status_ReduceWeightChar) == 1 and Osi.GetStatString(container) == Name_BagOfHolding then
		Osi.RemoveStatus(entity, Status_ReduceWeightChar, container)
		Osi.ApplyStatus(Osi.GetOwner(container), Status_WeightDisplayFix, 0, 1, container)
	end
end)

Ext.Osiris.RegisterListener(Osi_Evt_AddedTo, 3, 'before', function(entity, container, type)
	if Osi.HasActiveStatus(entity, Status_ReduceWeightChar) ~= 1 and Osi.GetStatString(container) == Name_BagOfHolding then
		Osi.ApplyStatus(entity, Status_ReduceWeightChar, -1, 1, container)
		Osi.ApplyStatus(Osi.GetOwner(container), Status_WeightDisplayFix, 0, 1, container)
	end
end)
