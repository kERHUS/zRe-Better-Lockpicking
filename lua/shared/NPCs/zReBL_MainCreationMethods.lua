require('NPCs/MainCreationMethods');

local function initzReBLTraits()

	local nimblefingers = TraitFactory.addTrait("nimblefingers", getText("UI_trait_nimblefingers"), 0, getText("UI_trait_nimblefingersDesc"), true);
		nimblefingers:addXPBoost(Perks.Lockpicking, 2)
		nimblefingers:getFreeRecipes():add("Lockpicking");
		nimblefingers:getFreeRecipes():add("Alarm check");
		nimblefingers:getFreeRecipes():add("Create BobbyPin");
		nimblefingers:getFreeRecipes():add("Create BobbyPin2");
	local nimblefingers2 = TraitFactory.addTrait("nimblefingers2", getText("UI_trait_nimblefingers"), 3, getText("UI_trait_nimblefingersDesc"), false);
		nimblefingers2:addXPBoost(Perks.Lockpicking, 2)
		nimblefingers2:getFreeRecipes():add("Lockpicking");
		nimblefingers2:getFreeRecipes():add("Alarm check");
		nimblefingers2:getFreeRecipes():add("Create BobbyPin");
		nimblefingers2:getFreeRecipes():add("Create BobbyPin2");

	TraitFactory.setMutualExclusive("nimblefingers", "nimblefingers2");
end

local function initzReBLProfession()

	local burglar = ProfessionFactory.addProfession("burglar", getText("UI_prof_Burglar"), "profession_burglar2", -4);
	burglar:addXPBoost(Perks.Nimble, 2)
	burglar:addXPBoost(Perks.Sneak, 2)
	burglar:addXPBoost(Perks.Lightfoot, 2)
	burglar:addFreeTrait("Burglar")
	burglar:addFreeTrait("nimblefingers");
	
	
	local profList = ProfessionFactory.getProfessions()
		for i = 1, profList:size() do
		local prof = profList:get(i - 1)
		BaseGameCharacterDetails.SetProfessionDescription(prof)
	end
	
end

Events.OnGameBoot.Add(initzReBLTraits);
Events.OnGameBoot.Add(initzReBLProfession);
Events.OnCreateLivingCharacter.Add(initzReBLProfession);