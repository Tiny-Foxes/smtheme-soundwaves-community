local ColorTable = LoadModule("Theme.Colors.lua")( LoadModule("Config.Load.lua")("SoundwavesSubTheme","Save/OutFoxPrefs.ini") )
local LoadIntro = Def.ActorFrame{}
local t = Def.ActorFrame{}

LoadIntro[#LoadIntro+1] = Def.ActorFrame {
    -- BG
        Def.Quad {
            InitCommand=function(self) self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y):zoomto(SCREEN_WIDTH,SCREEN_HEIGHT) end,
            OnCommand=function(self) 
                self:diffuse( ColorTable["swmeBGA"] ):diffusetopedge( ColorDarkTone(ColorTable["swmeBGB"]) )
                    :diffusealpha(0):linear(1.5):diffusealpha(0.75)
            end,
            OffCommand=function(self) self:easeinquint(0.25):diffusealpha(0) end
        },
        Def.Sprite {
            Texture = THEME:GetPathG("_bg", "inner ring"),
            InitCommand=function(self)
                self:diffuse( ColorTable["swmeGrid"] ):xy(SCREEN_CENTER_X,SCREEN_CENTER_Y):blend('add')
            end,
            OnCommand=function(self)
                self:rotationz(40):zoom(1.4):diffusealpha(0):easeoutquint(1.5):zoom(1):diffusealpha(0.3):rotationz(0)
            end,
            OffCommand=function(self) self:easeinquint(0.25):zoom(1.4):rotationz(-40):diffusealpha(0) end
        },
        Def.Sprite {
            Texture = THEME:GetPathG("_bg", "outer ring"),
            InitCommand=function(self)
                self:diffuse( ColorTable["swmeGrid"] ):xy(SCREEN_CENTER_X,SCREEN_CENTER_Y):blend('add')
            end,
            OnCommand=function(self)
                self:rotationz(-40):zoom(1.4):diffusealpha(0):easeoutquint(1.5):zoom(1):diffusealpha(0.3):rotationz(0)
            end,
            OffCommand=function(self) self:easeinquint(0.25):zoom(1.4):rotationz(40):diffusealpha(0) end
        },
        Def.Sound{
            Name="BGM",
            File=THEME:GetPathS("ScreenLoadGameplayElements","stinger");
            OnCommand=function(self)
                self:play():sleep(3.5)
            end,
        }
    }

    
    -- Song display
    LoadIntro[#LoadIntro+1] = Def.ActorFrame {
        InitCommand=function(self)
            self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y)
        end,
        OnCommand=function(self)
            self:diffusealpha(0):easeoutquint(1.5):diffusealpha(1)
        end,
        OffCommand=function(self) self:easeinquint(0.25):zoom(1.4):diffusealpha(0) end,
        Def.BitmapText {
            Font="SongSubTitle font";
            InitCommand=function(self)
                self:diffuse(color("#FFFFFF")):zoom(1):maxwidth((SCREEN_WIDTH*0.5)/0.8):y(-36)
                self:horizalign(center)
            end,
            OnCommand=function(self)
                if not GAMESTATE:IsCourseMode() then
                    self:settext(ToUpper(GAMESTATE:GetCurrentSong():GetGenre()))
                end
            end
        },
        Def.BitmapText {
            Font="SongSubTitle font",
            InitCommand=function(self)
                self:diffuse(color("#FFFFFF")):zoom(2):maxwidth(SCREEN_WIDTH*0.5)
                self:horizalign(center)
            end,
            OnCommand=function(self)
                if not GAMESTATE:IsCourseMode() then
                    local text = nativeTitle and GAMESTATE:GetCurrentSong():GetDisplayFullTitle() or GAMESTATE:GetCurrentSong():GetTranslitFullTitle()
                    self:settext( text, GAMESTATE:GetCurrentSong():GetTranslitFullTitle() )

                else
                    self:settext(GAMESTATE:GetCurrentCourse():GetDisplayFullTitle())
                end
            end
        },
        Def.BitmapText {
            Font="SongTitle font";
            InitCommand=function(self)
                self:diffuse(color("#FFFFFF")):zoom(1):maxwidth((SCREEN_WIDTH*0.5)/0.8):y(44)
                self:horizalign(center)
            end,
            OnCommand=function(self)
                if GAMESTATE:IsCourseMode() then
                    self:settext(ToEnumShortString( GAMESTATE:GetCurrentCourse():GetCourseType() ))
                else
                    local text = nativeTitle and GAMESTATE:GetCurrentSong():GetDisplayArtist() or GAMESTATE:GetCurrentSong():GetTranslitArtist()
                    self:settext( text, GAMESTATE:GetCurrentSong():GetTranslitArtist() )
                end
            end
        }
    }

    for ip, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
        local credit_position = string.find(pn, "P1") and SCREEN_LEFT+20 or SCREEN_RIGHT-20
        local credit_alignment = string.find(pn, "P1") and left or right
        local credit_x_start = string.find(pn, "P1") and -20 or 20
        local credit_x_add = string.find(pn, "P1") and 1 or -1
        local profileLoc =  CheckIfUserOrMachineProfile(string.sub(pn,-1)-1).."/OutFoxPrefs.ini"
        local peak,npst,NMeasure,mcount = LoadModule("Chart.GetNPS.lua")( GAMESTATE:GetCurrentSteps(pn) )
        
        t[#t+1] = Def.ActorFrame {
            InitCommand=function(self) self:xy(credit_position,SCREEN_BOTTOM-160) end,
            OnCommand=function(self)
                self:diffusealpha(0):addx(credit_x_start)
                :easeinquint(0.25):diffusealpha(1):addx(20*credit_x_add)
            end,
            OffCommand=function(self) self:easeinquint(0.25):diffusealpha(0) end,
                Def.Sprite {
                    InitCommand=function(self) self:horizalign(credit_alignment):y(10) end,
                    Texture=LoadModule("Options.GetProfileData.lua")(pn)["Image"],
                    OnCommand=function(self)
                        self:zoomto(46,46)
                    end
                },
                Def.BitmapText {
                    Font="_Bold",
                    InitCommand=function(self) self:horizalign(credit_alignment):addx(56*credit_x_add) end,
                    OnCommand=function(self) self:playcommand("Set") end,
                    SetCommand=function(self)
                    local steps_data = GAMESTATE:GetCurrentSteps(pn)
                    local SongOrCourse, StepsOrTrail;
                    if GAMESTATE:IsCourseMode() then
                        SongOrCourse = GAMESTATE:GetCurrentCourse()
                        StepsOrTrail = GAMESTATE:GetCurrentTrail(pn)
                    else
                        SongOrCourse = GAMESTATE:GetCurrentSong()
                        StepsOrTrail = GAMESTATE:GetCurrentSteps(pn)
                    end
                    if GAMESTATE:GetCurrentSong() then 
                        if steps_data ~= nil then
                            local st = steps_data:GetStepsType();
                            local diff = steps_data:GetDifficulty();
                            local courseType = GAMESTATE:IsCourseMode() and SongOrCourse:GetCourseType() or nil;
                            local cd = GetCustomDifficulty(st, diff, courseType);
                                if steps_data:IsAnEdit() then
                                    self:settext(steps_data:GetChartName() .. "  " .. steps_data:GetMeter());
                                else
                                    self:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff)) .. "  " .. steps_data:GetMeter());
                                end;
                            self:diffuse(ColorLightTone(CustomDifficultyToColor(cd)));
                        else
                            self:settext("")
                        end
                    else
                        self:settext("")
                    end
                 end
                },
                Def.BitmapText {
                    Font="_Condensed MedBold";
                    InitCommand=function(self) 
                        self:y(24):horizalign(credit_alignment):zoom(1):addx(56*credit_x_add)
                        :diffuse(color("#FFFFFF")):strokecolor(color("#000000")):maxwidth(300) end;
                    OnCommand=function(self) 
                    self:playcommand("Set") end;
                    SetCommand=function(self)
                    local steps_data = GAMESTATE:GetCurrentSteps(pn)
                    if GAMESTATE:GetCurrentSong() then
                        if steps_data ~= nil then
                            self:settext(steps_data:GetAuthorCredit())
                        end
                    else
                        self:settext("")
                    end
                 end
                },
                Def.Quad {
                    InitCommand=function(self) 
                        self:y(49):horizalign(credit_alignment):diffuse(PlayerColor(pn)):zoomto(200,3)
                        if pn == PLAYER_1 then self:faderight(0.6) else self:fadeleft(0.6) end
                    end
                }
            }
        end

return Def.ActorFrame {
    LoadIntro,
    t
}