local player = Var "Player"
local blinkTime = 1.2
local barWidth = 256;
local barHeight = 32;
local c;
local LifeMeter, MaxLives, CurLives;
local LifeRatio;

return Def.ActorFrame {
	LoadActor("_lives")..{
		InitCommand=function (self) self:pause():horizalign(left):x(-(barWidth/2)):diffuse(PlayerColor(player)) end,
		BeginCommand=function(self,param)
			local screen = SCREENMAN:GetTopScreen()
			local glifemeter = screen:GetLifeMeter(player)
				self:setstate(clamp(glifemeter:GetTotalLives()-1,0,9))
				self:cropright((640-(((glifemeter:GetTotalLives())*64)))/640)
		end,
		LifeChangedMessageCommand=function(self,param)
			if param.Player == player then
				if param.LivesLeft == 0 then
					self:visible(false)
				else
					self:setstate( clamp(param.LivesLeft-1,0,9) )
					self:visible(true)
				end
			end
		end,
		StartCommand=function(self,param)
			if param.Player == player then
				self:setstate( clamp(param.LivesLeft-1,0,9) );			
			end			
		end,
		FinishCommand=function(self) self:playcommand("Start") end
	}
}