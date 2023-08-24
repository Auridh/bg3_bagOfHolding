-- Persistent data stored even when the game is quit
PersistentVars = {}

-- Table indices
local Idx_InitialItemsGiven = 'InitialItemsGiven'

-- Item uuids
local Uid_BagOfHolding = '7471c9a3-e826-4ff2-b04c-b47c5360e46f'

-- Debug Messages
local Msg_Debug_SavegameLoaded = 'BoH: Savegame loaded!'
local Msg_Debug_SessionLoaded = 'BoH: Session loaded!'
local Msg_Debug_ItemsGiven = 'Boh: Items given'
local Msg_Debug_ItemsNotGiven = 'BoH: Items already given'

-- Osiris Events
local Osi_Evt_SavegameLoaded = 'SavegameLoaded'

function Tests()
	-- Print items in the inventory to console
	--Osi.IterateInventory(Osi.GetHostCharacter(), "DEBUG_CONSOLE_IterateInventory", "DEBUG_CONSOLE_IterateInventoryDone")
	Osi.IterateInventoryByTag(Osi.GetHostCharacter(), "BoH_BAG", "DEBUG_CONSOLE_IterateInventory", "DEBUG_CONSOLE_IterateInventoryDone")
end

local foundItems = {}
Ext.Osiris.RegisterListener("EntityEvent", 2, "after", function (entity, event)
	if event == "DEBUG_CONSOLE_IterateInventory" then
		foundItems[#foundItems+1] = entity
	elseif event == "DEBUG_CONSOLE_IterateInventoryDone" then
		Ext.Utils.Print("Iteration complete!")
		Ext.Utils.PrintWarning("=====")
		Ext.Dump(foundItems)
		foundItems = {}
		Ext.Utils.PrintWarning("=====")
	end
end)


function CheckInitialItemsForCharacter(character)
	local charIdx = Idx_InitialItemsGiven .. '_' .. character

	if not PersistentVars[charIdx] then
		Osi.TemplateAddTo(Uid_BagOfHolding, character, 1, 1)
		PersistentVars[charIdx] = true
		Ext.Utils.Print(Msg_Debug_ItemsGiven)
	else
		Ext.Utils.Print(Msg_Debug_ItemsNotGiven)
	end
end

function CheckInitialItems()
	-- Get party members from db
	local partyMembers = Osi.DB_PartyMembers:Get(nil)

	for _, v in pairs(partyMembers) do
		CheckInitialItemsForCharacter(v[1])
	end
end

function OnSessionLoaded()
	Ext.Utils.Print(Msg_Debug_SessionLoaded)
	Ext.Utils.Print(PersistentVars['Test'])
	PersistentVars['Test'] = 'Something to keep'
	Ext.Utils.Print(Ext.Json.Stringify(PersistentVars))
end

function OnSavegameLoaded()
    Ext.Utils.Print(Msg_Debug_SavegameLoaded)
	CheckInitialItems()
	Tests()
end

-- Event listeners
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)

-- Osiris event listeners
Ext.Osiris.RegisterListener(Osi_Evt_SavegameLoaded, 0, "after", OnSavegameLoaded)
