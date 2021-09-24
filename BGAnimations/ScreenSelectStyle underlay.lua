local BGWidth = IsGame("techno") and 800 or 400
return Def.ActorFrame {
	Def.Quad {
		InitCommand=function(self) self:vertalign(top):xy(SCREEN_CENTER_X,SCREEN_TOP):zoomto(BGWidth,0):diffuse(color("#000000")):diffusealpha(0.5) end;
		OnCommand=function(self) self:easeoutquint(0.14):zoomto(BGWidth,SCREEN_HEIGHT) end;
		OffCommand=function(self) self:sleep(0.2):easeoutquint(0.2):addy(SCREEN_HEIGHT) end;
	};
};