require "TimedActions/ISBaseTimedAction"

CrowbarActionAnim = ISBaseTimedAction:derive("CrowbarActionAnim")

function CrowbarActionAnim:isValid()
	return true
end

function CrowbarActionAnim:waitToStart()
	local zReBLLO = self.lockpick_object
	if zReBLLO == door or zReBLLO == window then
			self.character:faceThisObject(self.lockpick_object)
			return self.character:shouldBeTurning()
		else
			self.character:faceThisObject(self.lockpick_object:getVehicle())
			return self.character:shouldBeTurning()
	end
end

function CrowbarActionAnim:update()
	local uispeed = UIManager.getSpeedControls():getCurrentGameSpeed()
    if uispeed ~= 1 then
        UIManager.getSpeedControls():SetCurrentGameSpeed(1)
	end
	
	if not self.sound or not self.sound:isPlaying() then
		self.sound = getSoundManager():PlayWorldSound("zReBL_crowbarSound", self.character:getCurrentSquare(), 1, 25, 2, true)
	end
	
	local zReBLLO = self.lockpick_object
	if zReBLLO == door or zReBLLO == window then
			self.character:faceThisObject(self.lockpick_object)	
		else
			self.character:faceThisObject(self.lockpick_object:getVehicle())
	end
end

function CrowbarActionAnim:start()
	if self.isGarage then
		self:setActionAnim("CrowbarGarageAction")
	else
		self:setActionAnim("CrowbarAction")
	end
	--self.sound = getSoundManager():PlayWorldSound("zReBL_crowbarSoundStart", self.character:getCurrentSquare(), 1, 25, 2, true) -- 1, 25, 2
end

function CrowbarActionAnim:stop()
	--if self.sound and self.sound:isPlaying() then
		getSoundManager():StopSound(self.sound)
	--end

	

	ISBaseTimedAction.stop(self)
end

function CrowbarActionAnim:perform()
	--if self.sound and self.sound:isPlaying() then
		getSoundManager():StopSound(self.sound)
    --end
	ISBaseTimedAction.perform(self)
end

function CrowbarActionAnim:new(character, isGarage, lockpick_object)
	local o = {}
	local zReBLLO = self.lockpick_object
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.lockpick_object = lockpick_object
	o.maxTime = 50000
	o.isGarage = isGarage
	
	return o
end
