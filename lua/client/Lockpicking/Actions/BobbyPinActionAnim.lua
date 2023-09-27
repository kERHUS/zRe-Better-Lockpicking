require "TimedActions/ISBaseTimedAction"

BobbyPinActionAnim = ISBaseTimedAction:derive("BobbyPinActionAnim")

function BobbyPinActionAnim:isValid()
	return true
end

function BobbyPinActionAnim:waitToStart()
	local zReBLLO = self.lockpick_object
	if zReBLLO == door or zReBLLO == window then
			self.character:faceThisObject(self.lockpick_object)
			return self.character:shouldBeTurning()
		else
			self.character:faceThisObject(self.lockpick_object:getVehicle())
			return self.character:shouldBeTurning()
	end
end

function BobbyPinActionAnim:update()
	local uispeed = UIManager.getSpeedControls():getCurrentGameSpeed()
    if uispeed ~= 1 then
        UIManager.getSpeedControls():SetCurrentGameSpeed(1)
    end
	
	local zReBLLO = self.lockpick_object
	if zReBLLO == door or zReBLLO == window then
			self.character:faceThisObject(self.lockpick_object)	
		else
			self.character:faceThisObject(self.lockpick_object:getVehicle())
	end
end

function BobbyPinActionAnim:start()
	self:setActionAnim("Picklock")
end

function BobbyPinActionAnim:stop()
	ISBaseTimedAction.stop(self)
end

function BobbyPinActionAnim:perform()
	ISBaseTimedAction.perform(self)
end

function BobbyPinActionAnim:new(character, lockpick_object)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.lockpick_object = lockpick_object
	o.maxTime = 50000
	
	return o
end
