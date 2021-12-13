return Def.HelpDisplay {
	File = THEME:GetPathF("HelpDisplay", "text"),
	BeginCommand=function(self)
		self:zoom(0.75):maxwidth(SCREEN_WIDTH*0.65):shadowlength(1)
		
		local s = THEME:GetString(Var "LoadingScreen","HelpText")
		self:SetTipsColonSeparated(s)
		self.isSystemMenu = SCREENMAN:GetTopScreen():GetScreenType() == "ScreenType_SystemMenu"
		if not self.isSystemMenu then
			self:addy(64):decelerate(0.4):addy(-64)
		else
			self:diffusealpha(0):accelerate(0.1):diffusealpha(1)
		end
	end,
	OffCommand=function(self)
		self:decelerate(0.175)
		if self.isSystemMenu then
			self:diffusealpha(0)
		else
			self:addy(64)
		end
	end,
	SetHelpTextCommand=function(self, params)
		self:SetTipsColonSeparated( params.Text )
	end
}
