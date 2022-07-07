local backers = LoadModule("OF_Backers.lua")
local ColorTable = LoadModule("Theme.Colors.lua")( LoadModule("Config.Load.lua")("SoundwavesSubTheme","Save/OutFoxPrefs.ini") )

local scroller = Def.ActorScroller {
	SecondsPerItem = 0.4,
	NumItemsToDraw = 46,
	TransformFunction = function(self, offset, itemIndex, numItems)
		self:y(24*offset)
	end,
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X,SCREEN_BOTTOM-152)
	end,
	OnCommand = function (self)
		self:scrollwithpadding(8, 15)
	end
}

scroller[#scroller+1] = Def.Actor{}
scroller[#scroller+1] = Def.Actor{}

for i,v in ipairs(backers) do
	scroller[#scroller+1] = Def.BitmapText{
		Font="_Medium",
		Text=v,
	}
end

-- Add empty space for the ending padding
for i = 1,10 do
	scroller[#scroller+1] = Def.Actor{}
end

return Def.ActorFrame{
	Def.BitmapText{
		Font="_Bold",
		Text="We would like to thank our wonderful patreon donors for supporting the project:",
		OnCommand=function(self)
			self:Center():diffuse( ColorTable["titleBGPattern"] ):blend('add')
			:diffusealpha(0):linear(0.2):diffusealpha(1)
			:sleep( scroller.SecondsPerItem * (5 + 8) )
			:linear(1):addy(-50):linear(10):addy( -600 ):diffusealpha(0)
		end
	},
	scroller..{
		BeginCommand=function(self)
			SCREENMAN:GetTopScreen():PostScreenMessage( 'SM_MenuTimer', (scroller.SecondsPerItem * (#scroller + 2) + 10) );
		end
	}
}
