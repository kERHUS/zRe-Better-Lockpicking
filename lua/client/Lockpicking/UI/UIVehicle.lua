if BetLock == nil then BetLock = {} end
if BetLock.UI == nil then BetLock.UI = {} end

-- ПРОВЕРКА ПРОЧНОСТИ ПРЕДМЕТА, ВОЗВРАЩАЕТ "-" ЕСЛИ СЛОМАНО
local function predicateNotBroken(item)
	return not item:isBroken();
end--function

-- ДОБАВЛЕНИЕ ОПЦИЙ В РАДИАЛЬНОЕ МЕНЮ
function BetLock.UI.addOutsideOptions(playerObj)

	local endurance = playerObj:getStats():getEndurance() -- zRe
	--local strength = playerObj:getPerkLevel(Perks.Strength) -- zRe

    local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
    if menu == nil then return end

    local vehicle = playerObj:getUseableVehicle()
    if vehicle == nil then return end

    local part = vehicle:getUseablePart(playerObj)
    if part and part:getDoor()then
	
        if part:getDoor():isLocked() then
            local playerSkill = playerObj:getPerkLevel(Perks.Lockpicking)
            if vehicle:getModData().LockpickLevel == nil then
                vehicle:getModData().LockpickLevel = BetLock.Utils.getLockpickingLevelVehicle(vehicle)
            end

            -- ОПЦИЯ ВЗЛОМА МОНТИРОВКОЙ
			local inv = playerObj:getInventory();
			local crowbar = inv:getFirstTagEvalRecurse("zReBLCrow", predicateNotBroken);
            if not crowbar then
                menu:addSlice(getText("ContextMenu_Require", getItemNameFromFullType("Base.Crowbar")), getTexture("media/textures/BetLock_lockpick_Crowbar_Icon.png"))
            elseif endurance <= 0.5 then
				menu:addSlice(getText("UI_enduranceRequireCar"), getTexture("media/textures/BetLock_lockpick_Crowbar_Icon.png"))
			--elseif strength <= 3 then
			--	menu:addSlice(getText("UI_strengthRequireCar"), getTexture("media/textures/BetLock_lockpick_Crowbar_Icon.png"))
			else
                local text = getText("UI_BetLock_LockpickDoorCrowBar") .. " \n(" .. getText(vehicle:getModData().LockpickLevel.name) .. ")" 
                menu:addSlice(text, getTexture("media/textures/BetLock_lockpick_Crowbar_Icon.png"), BetLock.UI.startLockpickingVehicleDoorCrowbar, playerObj, part)
            end
			
			-- ОПЦИЯ ВЗЛОМА ОТМЫЧКАМИ
			if playerObj:getKnownRecipes():contains("Lockpicking") then
				local inv = playerObj:getInventory();
				local screwdriver = inv:getFirstTypeEvalRecurse("Screwdriver", predicateNotBroken);	-- getFirstTagEvalRecurse
				if not (playerObj:getInventory():containsType("BobbyPin") or playerObj:getInventory():containsType("HandmadeBobbyPin")) then
					menu:addSlice(getText("ContextMenu_Require", getItemNameFromFullType("BetLock.BobbyPin")), getTexture("media/textures/BetLock_lockpick_Icon.png"))
				elseif not screwdriver then
					menu:addSlice(getText("ContextMenu_Require", getItemNameFromFullType("Base.Screwdriver")), getTexture("media/textures/BetLock_lockpick_Icon.png"))
				else
					if part:getDoor():isLockBroken() then
						menu:addSlice(getText("IGUI_PlayerText_VehicleLockIsBroken"), getTexture("media/textures/BetLock_lockpick_Icon.png"))
					else
						local text = getText("UI_BetLock_LockpickDoorBobbyPin") .. " \n(" .. getText(vehicle:getModData().LockpickLevel.name) .. ")" 
						menu:addSlice(text, getTexture("media/textures/BetLock_lockpick_Icon.png"), BetLock.UI.startLockpickingVehicleDoorBobbyPin, playerObj, part)
					end
				end
			end
        end

        if part:getId() == "EngineDoor" and playerObj:getKnownRecipes():contains("Alarm check") then
            menu:addSlice(getText("UI_BetLock_CheckAlarm"), getTexture("media/textures/BetLock_alarmIcon.png"), BetLock.UI.alarmCheck, playerObj, vehicle, part)
        end
    end
end

-- СОХРАНЕНИЕ ДЕФОЛТНЫХ ФУНКЦИЙ РАДИАЛ-МЕНЮ for wrap it?!
if BetLock.UI.defaultShowRadialMenu == nil then
    BetLock.UI.defaultShowRadialMenu = ISVehicleMenu.showRadialMenu
end
  
-- Wrap?! ДЕФОЛТНЫХ ФУНКЦИЙ РАДИАЛ-МЕНЮ
function ISVehicleMenu.showRadialMenu(playerObj)
    BetLock.UI.defaultShowRadialMenu(playerObj)
    
    if not playerObj:getVehicle() then
        BetLock.UI.addOutsideOptions(playerObj)
    end
end


-- ВЗЛОМ ЗАМКА ЗАЖИГАНИЯ (ПРОВОДА)
function ISVehicleMenu.onHotwire(playerObj)
	HotwireWindow:createWindow(playerObj)
end

-- ВЗЛОМ ОТМЫЧКАМИ -- Работает только на базовую отвёртку, для других отвёрток и модовых мультитулов нужно допиливать скрипт.
function BetLock.UI.startLockpickingVehicleDoorBobbyPin(playerObj, part)
    local vehicle = part:getVehicle()
    playerObj:facePosition(vehicle:getX(), vehicle:getY())
	
	local inv = playerObj:getInventory();
    local screwdriverzRe = inv:getFirstTypeEvalRecurse("Screwdriver", predicateNotBroken);	--getFirstTagEvalRecurse
	local primaryhand = playerObj:getPrimaryHandItem();
	
    if primaryhand and primaryhand:getType() == "Screwdriver" then
		ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, part:getArea()))
		ISTimedActionQueue.add(EmptyAction:new(playerObj, BobbyPinWindow.createVehicleDoor, nil, playerObj, part))
		else
		ISInventoryPaneContextMenu.equipWeapon(screwdriverzRe, true, false, playerObj:getPlayerNum())
	end
		
end

-- ВЗЛОМ МОНТИРОВКОЙ -- Работает на тегирование двуручных монтировок, выставленных вручную в adjuster
function BetLock.UI.startLockpickingVehicleDoorCrowbar(playerObj, part)
    local vehicle = part:getVehicle()
    playerObj:facePosition(vehicle:getX(), vehicle:getY())
	local inv = playerObj:getInventory();
	local crowbar = inv:getFirstTagEvalRecurse("zReBLCrow", predicateNotBroken);
	
	if not playerObj:isItemInBothHands(crowbar) then
		ISInventoryPaneContextMenu.equipWeapon(crowbar, true, true, playerObj:getPlayerNum())
		return
	end

	ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, vehicle, part:getArea()))
    ISTimedActionQueue.add(EmptyAction:new(playerObj, CrowbarWindow.createVehicleDoor, nil, playerObj, part))
end 

-- ПРОВЕРКА СИГНАЛИЗАЦИИ
function BetLock.UI.alarmCheck(playerObj, vehicle, part)
    if not part:getDoor():isLocked() then
        ISTimedActionQueue.add(CheckAlarmVehicleAction:new(playerObj, vehicle));
    else
        playerObj:facePosition(vehicle:getX(), vehicle:getY())
        playerObj:getEmitter():playSound("DoorIsLocked")
    end
end

--- БЛОКИРОВКА ОТКРЫТИЯ БАГАЖНИКА
--[[        \<.<\        ┏(-Д-┏)～        ]]
do
    local original = ISVehicleMenu.onToggleTrunkLocked
    function ISVehicleMenu.onToggleTrunkLocked(playerObj)
        local vehicle = playerObj:getVehicle()
        if not vehicle then return end
        local doorPart = vehicle:getPartByID("TrunkDoor") or vehicle:getPartByID("DoorRear")
        if doorPart ~= nil and doorPart:getDoor():isLockBroken() then
            playerObj:Say(getText("IGUI_PlayerText_VehicleLockIsBroken"))
            return
        end
        original(playerObj)
    end
end
