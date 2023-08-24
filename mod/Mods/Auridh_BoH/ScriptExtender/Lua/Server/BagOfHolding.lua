PersistentVars = {}

function InitialItemsGiven()
	PersistentVars['InitialItemsGiven'] = true
end

function OnSavegameLoaded()
    Ext.Utils.Print("BoH: Savegame loaded!")
	Osi.TemplateAddTo("7471c9a3-e826-4ff2-b04c-b47c5360e46f", GetHostCharacter(), 1, 1)
end

Ext.Osiris.RegisterListener("SavegameLoaded", 0, "after", OnSavegameLoaded)