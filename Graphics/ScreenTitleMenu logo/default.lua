local MascotEnabled = LoadModule("Config.Load.lua")("ShowMascotCharacter","Save/OutFoxPrefs.ini")
return Def.ActorFrame{	
	Def.Sprite {
		Texture="_text",
		InitCommand=function(self) 
			self:x(MascotEnabled and 110 or 0)
			:zoom(MascotEnabled and 0.6 or 0.75) 
		end,
		OnCommand=function(self) self:queuecommand("Animate") end,
		AnimateCommand=function(self) 
			if not MascotEnabled then
				self:addx(-20)
			end;
			self:diffusealpha(0):easeoutsine(1):diffusealpha(1):addx(20)
		end
	},
	LoadActor("_mascot") .. {
		InitCommand=function(self) self:x(-250):y(30):zoom(1):diffusealpha(0) end,
		OnCommand=function(self) self:queuecommand("Animate") end,
		AnimateCommand=function(self) 
			if MascotEnabled then
				self:diffusealpha(0):addy(40):easeoutsine(1):diffusealpha(1):addx(-40)
			end
		end
	}
}