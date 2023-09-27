-- (c) Chuckleberry "GOD OF GODS" Finn

---THIS IS CALLED IN CLIENT
--sendClientCommand(self.character, 'crowbar', 'vehicleDoor', { vehicle=lockpick_object:getVehicle():getId(), part=lockpick_object:getId() })
local function crowbarCommands(module, command, player, args)

    if module == "crowbar" and command == "vehicleDoor" then
        local vehicle = getVehicleById(args.vehicle)
        if not vehicle then return end

        local part = vehicle:getPartById(args.part)
        if not part then return end

        if not part:getDoor() then return end

        part:getDoor():setLocked(false)
		part:getDoor():setOpen(true)
        --part:getDoor():setLockBroken(true)

        vehicle:transmitPartDoor(part)
    end
end
Events.OnClientCommand.Add(crowbarCommands)



---THIS IS CALLED IN CLIENT
--sendClientCommand(self.character, 'screwdriver', 'vehicleDoor', { vehicle=lockpick_object:getVehicle():getId(), part=lockpick_object:getId() })
local function screwdriverCommands(module, command, player, args)

    if module == "screwdriver" and command == "vehicleDoor" then
        local vehicle = getVehicleById(args.vehicle)
        if not vehicle then return end

        local part = vehicle:getPartById(args.part)
        if not part then return end

        if not part:getDoor() then return end

        part:getDoor():setLocked(false)

        vehicle:transmitPartDoor(part)
    end
end
Events.OnClientCommand.Add(screwdriverCommands)
