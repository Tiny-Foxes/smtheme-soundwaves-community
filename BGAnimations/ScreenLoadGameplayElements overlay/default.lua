local ColorTable = LoadModule("Theme.Colors.lua")( LoadModule("Config.Load.lua")("SoundwavesSubTheme","Save/OutFoxPrefs.ini") )
local gm = GAMESTATE:GetCurrentGame():GetName()
local showIntro = {
	["be-mu"] = true,
	["po-mu"] = true,
	["gddm"] = true,
	["gdgf"] = true
}

local showBar = {
	["be-mu"] = true,
	["gddm"] = true,
	["gdgf"] = true,
	["po-mu"] = true
}

local LoadMenuBG = Def.ActorFrame{}
local finished = false

if showIntro[gm] == true then 
	LoadMenuBG[#LoadMenuBG+1] = LoadActor("bmsintro")
end

if showBar[gm] == true then 
	LoadMenuBG[#LoadMenuBG+1] = Def.ActorFrame {
		OnCommand=function(self)
			self:xy(SCREEN_CENTER_X,SCREEN_BOTTOM-55)
				:diffusealpha(0):easeinquint(0.2):diffusealpha(1)
		end,
		OffCommand=function(self)
			self:easeoutquint(0.05):diffusealpha(0):addy(24)
		end,
		Def.BitmapText{
			Font="_Condensed Semibold",
			Text="Test",
			InitCommand=function(self) 
				self:horizalign(left):x(-(SCREEN_WIDTH/2)+30):zoom(0.75)
					:vertspacing(-4)
			end,
			LoadingKeysoundMessageCommand=function(self,params)
				self:settext(params.File.."\n"..string.format("%.0f", params.Percent).."%")
			end
		},
		Def.ActorFrame{
			OnCommand=function(self)
				self:y(32)
			end,
			Def.Quad{
				OnCommand=function(self)
					self:zoomto(SCREEN_WIDTH*0.95,4):diffuse(0,0,0,1)
				end
			},
			Def.Quad{
				OnCommand=function(self)
					self:zoomto(SCREEN_WIDTH*0.95,4):diffuse( ColorTable["wheelHighlightA"] ):diffuserightedge( ColorTable["wheelHighlightB"] )
					:cropright(0)
				end,
				LoadingKeysoundMessageCommand=function(self,params)
					self:cropright(1-(params.Percent/100))
				end
			}
		}
	}
end

return Def.ActorFrame {
	Def.Quad {
		InitCommand=function(self) self:diffuse(Color.Black):zoomto(SCREEN_WIDTH,SCREEN_HEIGHT):Center() end,
		OnCommand=function(self)
			if getenv("CurrentlyInSong") == false then
				self:diffusealpha(0):linear(0.2):diffusealpha(1)
			end
		end
	},
	LoadMenuBG,
	Def.Actor {
		LoadingKeysoundMessageCommand=function(self,params)
			if params.Done == true then
				self:queuecommand("NextScreen")
			end
		end,
		NextScreenCommand=function(self)
			if finished == false then
				SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
				finished = true
			end
		end
	},
}
