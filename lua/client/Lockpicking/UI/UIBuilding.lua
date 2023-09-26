if BetLock == nil then BetLock = {} end
if BetLock.UI == nil then BetLock.UI = {} end

--[[
not should be ToolsOfTheTrade.UtilityBar - это одноручный гвоздодёр


:getFirstTagRecurse("StartFire")
:getFirstTagEvalRecurse	("Hammer", predicateNotBroken)

:getFirstTypeRecurse	("Base.Gravelbag")
:getFirstTypeEvalRecurse("Base.PropaneTank", predicateNotEmpty)


// FOR BODYPIN AND HANDMADE BODYPIN
local bobbypin = playerInv:getFirstTypeRecurse("HandmadeBobbyPin")
	if not bobbypin then
		bobbypin = playerInv:getFirstTypeRecurse("BobbyPin")
	end
	
item:isTwoHandWeapon();
]]--

-- ПРОВЕРКА ПРОЧНОСТИ ПРЕДМЕТА, ВОЗВРАЩАЕТ "-" ЕСЛИ СЛОМАНО
local function predicateNotBroken(item)
	return not item:isBroken(); 
end--function

-- ВЗЛОМ ДВЕРИ ОТМЫЧКАМИ
function BetLock.UI.goToDoorBobbyPin(playerObj, door, goToOpen)
    local sq = door:getSquare()
    if door:getOppositeSquare():DistTo(playerObj:getSquare()) < door:getSquare():DistTo(playerObj:getSquare()) then
        sq = door:getOppositeSquare()
    end
	
	local inv = playerObj:getInventory();
    local screwdriver = inv:getFirstTagEvalRecurse("Screwdriver", predicateNotBroken);
    if playerObj:getSecondaryHandItem() and playerObj:getSecondaryHandItem() ~= playerObj:getPrimaryHandItem() then
        ISTimedActionQueue.add(ISUnequipAction:new(playerObj, playerObj:getSecondaryHandItem(), 50));
    end
	ISInventoryPaneContextMenu.equipWeapon(screwdriver, true, false, playerObj:getPlayerNum());
	
    ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, sq));
    ISTimedActionQueue.add(EmptyAction:new(playerObj, BobbyPinWindow.createBuildingDoor, nil, playerObj, door, goToOpen))
end

-- ВЗЛОМ ДВЕРИ МОНТИРОВКОЙ
function BetLock.UI.goToDoorCrowbar(playerObj, door)
    local sq = door:getSquare()
    if door:getOppositeSquare():DistTo(playerObj:getSquare()) < door:getSquare():DistTo(playerObj:getSquare()) then
        sq = door:getOppositeSquare()
    end

	local inv = playerObj:getInventory();
	local crowbar = inv:getFirstTagEvalRecurse("zReBLCrow", predicateNotBroken);
	ISInventoryPaneContextMenu.equipWeapon(crowbar, true, true, playerObj:getPlayerNum());
	ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, sq));
    ISTimedActionQueue.add(EmptyAction:new(playerObj, CrowbarWindow.createBuildingDoor, nil, playerObj, door))
end

-- ВЗЛОМ ОКНА МОНТИРОВКОЙ
function BetLock.UI.goToWindowCrowbar(playerObj, window)
    local sq = window:getSquare()
    if window:getOppositeSquare():DistTo(playerObj:getSquare()) < window:getSquare():DistTo(playerObj:getSquare()) then
        sq = window:getOppositeSquare()
    end

	local inv = playerObj:getInventory();
	local crowbar = inv:getFirstTagEvalRecurse("zReBLCrow", predicateNotBroken);
	ISInventoryPaneContextMenu.equipWeapon(crowbar, true, true, playerObj:getPlayerNum());
    ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, sq));
    ISTimedActionQueue.add(EmptyAction:new(playerObj, CrowbarWindow.createBuildingWindow, nil, playerObj, window))
end



-- КОНТЕКСТОЕ МЕНЮ ДЛЯ ДВЕРИ / ОКНА
function BetLock.UI.contextMenuOptions(player, context, worldobjects)
    local playerObj = getSpecificPlayer(player)
    local playerSkill = playerObj:getPerkLevel(Perks.Lockpicking)
    local window = nil
    local door = nil
	local endurance = playerObj:getStats():getEndurance() -- zRe
	--local strength = playerObj:getPerkLevel(Perks.Strength) -- zRe

	for _, v in ipairs(worldobjects) do
        if instanceof(v, "IsoDoor") then     
            door = v
        elseif instanceof(v, "IsoWindow") then
            window = v
        end
    end
    
    if door then
        if door:getModData().LockpickLevel == nil then
            door:getModData().LockpickLevel = BetLock.Utils.getLockpickLevelBuildingObj(door)
        end
        
        if playerObj:getKnownRecipes():contains("Alarm check") and door:isExteriorDoor(playerObj) then
            context:addOption(getText("UI_BetLock_CheckAlarm"), playerObj, BetLock.UI.checkBuildingAlarm, door:getSquare(), door:getOppositeSquare(), door)
        end
		
		local lockpickingMenuOption = context:addOption(getText("UI_Lockpick"))
		local subMenuLockpicking = context:getNew(context)
		
-- СУБМЕНЮ ВЗЛОМА ОТМЫЧКАМИ
        if playerObj:getKnownRecipes():contains("Lockpicking") then
            context:addSubMenu(lockpickingMenuOption, subMenuLockpicking)
            local option = subMenuLockpicking:addOption(getText("UI_Lockpick_bobbypin"), playerObj, BetLock.UI.goToDoorBobbyPin, door, true)
            option.toolTip = ISToolTip:new();
            option.toolTip:initialise();
            option.toolTip:setVisible(false);
            option.toolTip:setName(getText(door:getModData().LockpickLevel.name))

            local color
            if playerSkill >= door:getModData().LockpickLevel.num then
                color = " <RGB:1,1,1> "
            else
                color = " <RGB:0.9,0.5,0> "
            end
            option.toolTip.description = color .. getText("Tooltip_vehicle_recommendedSkill", playerSkill .. "/" .. door:getModData().LockpickLevel.num, "") .. " <LINE> "

            if not (playerObj:getInventory():containsType("BobbyPin") or playerObj:getInventory():containsType("HandmadeBobbyPin")) then
                color = " <RGB:0.9,0,0> "
                option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("BetLock.BobbyPin")) .. " <LINE> "
                option.notAvailable = true
            end
-- ДВЕРЬ, КОНТЕКСТНОЕ МЕНЮ, ПРОВЕРКА ОТВЁРТКИ В ИНВЕНТАРЕ, ПОПЫТКИ...
			local inv = playerObj:getInventory();
			local screwdriver = inv:getFirstTagEvalRecurse("Screwdriver", predicateNotBroken);	--zReBLScrew
            if not screwdriver then
                color = " <RGB:0.9,0,0> "
                option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Screwdriver")) .. " <LINE> "
                option.notAvailable = true
            end

            if door:getKeyId() == -3 then
                color = " <RGB:0.9,0,0> "
                option.toolTip.description = option.toolTip.description .. color .. getText("IGUI_LockBroken")
                option.notAvailable = true
            end
        end
		
-- СУБМЕНЮ ВЗЛОМА ЛОМОМ
		context:addSubMenu(lockpickingMenuOption, subMenuLockpicking)
		local option = subMenuLockpicking:addOption(getText("UI_Lockpick_crowbar"), playerObj, BetLock.UI.goToDoorCrowbar, door)
		option.toolTip = ISToolTip:new()
		option.toolTip:initialise()
		option.toolTip:setVisible(false)
		option.toolTip:setName(getText(door:getModData().LockpickLevel.name))

		local color
		if playerSkill >= door:getModData().LockpickLevel.num then
			color = " <RGB:1,1,1> "
		else
			color = " <RGB:0.9,0.5,0> "
		end
		option.toolTip.description = color .. getText("Tooltip_vehicle_recommendedSkill", playerSkill .. "/" .. door:getModData().LockpickLevel.num, "") .. " <LINE> "

-- ДВЕРЬ, КОНТЕКСТНОЕ МЕНЮ, ПРОВЕРКА ЛОМА В ИНВЕНТАРЕ, ПОПЫТКИ...
		local inv = playerObj:getInventory();
		local crowbarinv = inv:getFirstTagEvalRecurse("zReBLCrow", predicateNotBroken);
		if not crowbarinv then
			color = " <RGB:0.9,0,0> "
			option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Crowbar")) .. " <LINE> "
			option.notAvailable = true
		end
		if endurance <= 0.5 then
			color = " <RGB:0.9,0,0> "
			option.toolTip.description = option.toolTip.description .. color .. getText("UI_enduranceRequire") .. " <LINE> "
			option.notAvailable = true
		end
		--if strength <= 3 then
		--	color = " <RGB:0.9,0,0> "
		--	option.toolTip.description = option.toolTip.description .. color .. getText("UI_strengthRequire")
		--	option.notAvailable = true
		--end
    elseif window then
        if window:getModData().LockpickLevel == nil then
            window:getModData().LockpickLevel = BetLock.Utils.getLockpickLevelBuildingObj(window)
        end
        
        if playerObj:getKnownRecipes():contains("Alarm check") then
            context:addOption(getText("UI_BetLock_CheckAlarm"), playerObj, BetLock.UI.checkBuildingAlarm, window:getSquare(), window:getOppositeSquare(), window)
        end

        if not window:isPermaLocked() then
            local lockpickingMenuOption = context:addOption(getText("UI_Lockpick"))
            local subMenuLockpicking = context:getNew(context)
            context:addSubMenu(lockpickingMenuOption, subMenuLockpicking)

            local option = subMenuLockpicking:addOption(getText("UI_Lockpick_crowbar"), playerObj, BetLock.UI.goToWindowCrowbar, window)
            option.toolTip = ISToolTip:new()
            option.toolTip:initialise()
            option.toolTip:setVisible(false)
            option.toolTip:setName(getText(window:getModData().LockpickLevel.name))

            local color
            if playerSkill >= window:getModData().LockpickLevel.num then
                color = " <RGB:1,1,1> "
            else
                color = " <RGB:0.9,0.5,0> "
            end
            option.toolTip.description = color .. getText("Tooltip_vehicle_recommendedSkill", playerSkill .. "/" .. window:getModData().LockpickLevel.num, "") .. " <LINE> "

            option.toolTip.description = option.toolTip.description .. " <RGB:1,1,1> " .. getText("UI_chance_break_window") .. BetLock.Utils.getChanceBreakLock(playerSkill, window:getModData().LockpickLevel.num) .. "%" .. " <LINE> "
			
			local inv = playerObj:getInventory();	--try
			local crowbarinv = inv:getFirstTagEvalRecurse("zReBLCrow", predicateNotBroken);-- try
            if not crowbarinv then
                color = " <RGB:0.9,0,0> "
                option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Crowbar")) .. " <LINE> "
                option.notAvailable = true
            end
			--- zRe
			if endurance <= 0.5 then
			    color = " <RGB:0.9,0,0> "
                option.toolTip.description = option.toolTip.description .. color .. getText("UI_enduranceRequire") .. " <LINE> "
                option.notAvailable = true
            end
			--if strength <= 3 then
			--	color = " <RGB:0.9,0,0> "
            --    option.toolTip.description = option.toolTip.description .. color .. getText("UI_strengthRequire")
            --    option.notAvailable = true
            --end
			----
        end
    else
    end
end

Events.OnFillWorldObjectContextMenu.Add(BetLock.UI.contextMenuOptions);


function BetLock.UI.checkBuildingAlarm(playerObj, sq1, sq2, obj)
    local sq = sq1
    if sq2:DistTo(playerObj:getSquare()) < sq1:DistTo(playerObj:getSquare()) then
        sq = sq2
    end

    ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, sq));
    ISTimedActionQueue.add(CheckAlarmBuildingAction:new(playerObj, sq1, sq2, obj));
end