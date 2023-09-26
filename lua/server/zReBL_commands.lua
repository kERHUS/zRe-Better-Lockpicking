---THIS IS CALLED IN CLIENT
--sendClientCommand(self.character, 'crowbar', 'vehicleDoor', { vehicle=lockpick_object:getVehicle():getId(), part=lockpick_object:getId() })

---THIS GOES IN /SERVER/
local function crowbarCommands(module, command, player, args)

    if module == "crowbar" and command == "vehicleDoor" then
        local vehicle = getVehicleById(args.vehicle)
        if not vehicle then return end

        local part = vehicle:getPartById(args.part)
        if not part then return end

        if not part:getDoor() then return end

        part:getDoor():setLocked(false)
        part:getDoor():setLockBroken(true)

        vehicle:transmitPartDoor(part)
    end
end
Events.OnClientCommand.Add(crowbarCommands)