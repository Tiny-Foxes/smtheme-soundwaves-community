local ColorTable = LoadModule("Theme.Colors.lua")( LoadModule("Config.Load.lua")("SoundwavesSubTheme","Save/OutFoxPrefs.ini") );

return Def.ActorFrame {
	BeginCommand=function(self)
		self.isSystemMenu = SCREENMAN:GetTopScreen():GetScreenType() == "ScreenType_SystemMenu"
		if not self.isSystemMenu then
			self:y(SCREEN_BOTTOM+64):decelerate(0.4):y(SCREEN_BOTTOM)
		else
			self:y(SCREEN_BOTTOM)
		end
		self:playcommand("StartTween")
	end,
	OffCommand=function(self)
		if not self.isSystemMenu then
			self:decelerate(0.175):y(SCREEN_BOTTOM+64)
		end
	end,
	Def.Quad {
		StartTweenCommand=function(self) 
			self:vertalign(bottom):zoomto(SCREEN_WIDTH,44)
			:diffuse( ColorTable["swmeFooter"] )
			:diffusealpha(0.86)
		end;
	},
	Def.Quad {
		StartTweenCommand=function(self) 
			self:vertalign(bottom):zoomto(SCREEN_WIDTH,2):addy(-42)
			self:diffuse( ColorTable["headerStripeA"] ):diffuseleftedge( ColorTable["headerStripeB"] ):diffusealpha(0.5)
		end;
	}
};