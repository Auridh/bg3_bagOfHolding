-- Persistent data stored even when the game is quit
PersistentVars = {}

-- Table indices
Idx_InitialItemsGiven = 'InitialItemsGiven'

-- Item uuids
Uid_BagOfHolding = '7471c9a3-e826-4ff2-b04c-b47c5360e46f'

-- Debug Texts
Msg_Debug_SavegameLoaded = 'BoH: Savegame loaded!'
Msg_Debug_ItemsGiven = 'Boh: Items given'
Msg_Debug_ItemsNotGiven = 'BoH: Items already given'

-- Osiris Events
Evt_SavegameLoaded = 'SavegameLoaded'


function CheckInitialItems()
	if not PersistentVars[Idx_InitialItemsGiven] then
		Osi.TemplateAddTo(Uid_BagOfHolding, GetHostCharacter(), 1, 1)
		PersistentVars[Idx_InitialItemsGiven] = true
		Ext.Utils.Print(Msg_Debug_ItemsGiven)
	else
		Ext.Utils.Print(Msg_Debug_ItemsNotGiven)
	end
end

function OnSavegameLoaded()
    Ext.Utils.Print(Msg_Debug_SavegameLoaded)
	CheckInitialItems()
end

Ext.Osiris.RegisterListener(Evt_SavegameLoaded, 0, "after", OnSavegameLoaded)
