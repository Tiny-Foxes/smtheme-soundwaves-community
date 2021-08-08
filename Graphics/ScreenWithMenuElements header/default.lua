local ColorTable = LoadModule("Theme.Colors.lua")( LoadModule("Config.Load.lua")("SoundwavesSubTheme","Save/OutFoxPrefs.ini") );

return Def.ActorFrame {
BeginCommand=function(self)
	self.isSystemMenu = SCREENMAN:GetTopScreen():GetScreenType() == "ScreenType_SystemMenu"
	self:playcommand("StartTween")
end,

-- Base bar
Def.ActorFrame {
	InitCommand=function(self)
		self:vertalign(top)
	end,
	StartTweenCommand=function(self)
		if not self:GetParent().isSystemMenu then
			self:addy(-104):decelerate(0.3):addy(104)
		end
	end,
	OffCommand=function(self)
		if not self:GetParent().isSystemMenu then
			self:decelerate(0.175):addy(-105)
		end
	end,
	Def.Quad {
		InitCommand=function(self)
			self:vertalign(top):horizalign(left):zoomto(SCREEN_WIDTH,64):x(0)
		end;
		StartTweenCommand=function(self)
			self:diffuse( ColorTable["swmeHF"] )
		end,
	},
	-- Stripe
	Def.Quad {
		InitCommand=function(self)
			self:vertalign(top):horizalign(left):zoomto(SCREEN_WIDTH,2):y(62):x(0)
		end;
		StartTweenCommand=function(self)
			self:diffuse( ColorTable["headerStripeA"] ):diffuserightedge( ColorTable["headerStripeB"] ):diffusealpha(0.75)
		end;
	}
},

-- Text
Def.BitmapText {
	Font="_Large Bold",
	Name="HeaderTitle",
	Text=ToUpper(Screen.String("HeaderText")),
	InitCommand=function(self)
		self:xy(SCREEN_LEFT+25,32):horizalign(left):zoom(0.8)
		:diffuse( ColorTable["headerTextColor"] ):diffusebottomedge( ColorTable["headerTextGradient"] ):skewx(-0.15)
	end,
	StartTweenCommand=function(self)
		if self:GetParent().isSystemMenu then
			self:diffusealpha(0):accelerate(0.05):diffusealpha(1)
		else
			self:addy(-104):decelerate(0.3):addy(104)
			if SCREENMAN:GetTopScreen() and SCREENMAN:GetTopScreen():GetName() == "ScreenSelectMusic" then
				self:maxwidth( WideScale(10,240) )
			end
		end
	end,
	UpdateScreenHeaderMessageCommand=function(self,param)
		self:settext(param.Header)
	end,
	OffCommand=function(self) 
		if self:GetParent().isSystemMenu then
			self:decelerate(0.1):diffusealpha(0)
		else
			self:decelerate(0.175):addy(-105)
		end
	end
}

}