local barSleepIn = 0.9
local songAreaWidth = SCREEN_WIDTH*0.4375
local nativeTitle = tobool(PREFSMAN:GetPreference("ShowNativeLanguage"))
local ColorTable = LoadModule("Theme.Colors.lua")( LoadModule("Config.Load.lua")("SoundwavesSubTheme","Save/OutFoxPrefs.ini") )

local t = Def.ActorFrame {
	-- Global message caller for all the things
    OnCommand=function(self) MESSAGEMAN:Broadcast("Set") end,
    CurrentStepsP1ChangedMessageCommand=function(self) MESSAGEMAN:Broadcast("Set") end,
    CurrentStepsP2ChangedMessageCommand=function(self) MESSAGEMAN:Broadcast("Set") end,
	CurrentTrailP1ChangedMessageCommand=function(self) MESSAGEMAN:Broadcast("Set") end,
	CurrentTrailP2ChangedMessageCommand=function(self) MESSAGEMAN:Broadcast("Set") end,
    CurrentCourseChangedMessageCommand=function(self) MESSAGEMAN:Broadcast("Set") end,
    CurrentSongChangedMessageCommand=function(self) MESSAGEMAN:Broadcast("Set") end
}

	local stpenable = {}

	if GAMESTATE:IsHumanPlayer(PLAYER_1) then
		if LoadModule("Config.Load.lua")("ToastiesDraw",CheckIfUserOrMachineProfile(0).."/OutFoxPrefs.ini") then
			t[#t+1] = LoadModule("Options.SmartToastieActors.lua")(1)
		end
		stpenable[1] = LoadModule("Config.Load.lua")("OverTopGraph",CheckIfUserOrMachineProfile(string.sub(PLAYER_1,-1)-1).."/OutFoxPrefs.ini")
	end
	
	if GAMESTATE:IsHumanPlayer(PLAYER_2) then
		if LoadModule("Config.Load.lua")("ToastiesDraw",CheckIfUserOrMachineProfile(1).."/OutFoxPrefs.ini") then
			t[#t+1] = LoadModule("Options.SmartToastieActors.lua")(2)
		end
		stpenable[2] = LoadModule("Config.Load.lua")("OverTopGraph",CheckIfUserOrMachineProfile(string.sub(PLAYER_2,-1)-1).."/OutFoxPrefs.ini")
	end

	local mast = GAMESTATE:GetMasterPlayerNumber()

	local enabledstp = GAMESTATE:GetNumPlayersEnabled() > 1 and (stpenable[1] or stpenable[2])
	local singlestp = GAMESTATE:GetNumPlayersEnabled() == 1 and LoadModule("Config.Load.lua")("OverTopGraph",CheckIfUserOrMachineProfile(string.sub(mast,-1)-1).."/OutFoxPrefs.ini")

	local songareapos = SCREEN_CENTER_X

	t[#t+1] = Def.ActorFrame {
		OnCommand=function(self) self:addy(-75):sleep(barSleepIn):decelerate(0.5):addy(75) end,
		OffCommand=function(self) self:sleep(0.15):decelerate(0.3):addy(-75) end,

		-- Song title area
		Def.ActorFrame {
				Def.Quad {
					InitCommand=function(self) self:align(0.5,0):xy(songareapos,0):zoomto(0,56) end,
					OnCommand=function(self)
						self:sleep(barSleepIn+0.3):decelerate(0.6):zoomto(songAreaWidth,56)
					end,
					SetMessageCommand=function(self)
						local curStage = GAMESTATE:GetCurrentStage()
						self:diffuse(ColorTable["gameplayTitle"]):diffusealpha(0.5)
					end,
				},

			-- Song meter
			Def.ActorFrame {
			OnCommand=function(self)
				self:diffuseshift():effectclock("beat"):effectcolor1(color("1,1,1,0.5")):effectcolor2(color("1,1,1,0.8"))
			end,	
				Def.Quad {
					InitCommand=function(self) self:xy(songareapos,56):align(0.5,1) end,
					OnCommand=function(self)
						self:zoomto(0,7):sleep(barSleepIn+0.3):decelerate(0.6):zoomto(songAreaWidth,7)
					end,
					SetMessageCommand=function(self)
						local curStage = GAMESTATE:GetCurrentStage()
						self:diffuse(ColorTable["gameplayMeter"]):diffusealpha(0.5)
					end,		
				}
			},
			Def.SongMeterDisplay {
				InitCommand=function(self) self:xy(songareapos,56):align(0.5,1) end,
				StreamWidth=songAreaWidth,
				Stream=LoadActor( THEME:GetPathG( 'SongMeterDisplay', 'stream') )..{
					InitCommand=function(self)
						self:valign(1):diffusealpha(0.4):zoomy(0.5)
					end,
				},
				Tip=Def.ActorFrame{}
			},
			--- Song info
			Def.BitmapText {
				Font="SongTitle font",
				InitCommand=function(self)
					self:xy(SCREEN_CENTER_X,26):zoom(1):maxwidth(SCREEN_WIDTH*0.421875):diffuse(color("#FFFFFF")):horizalign(center)
				end,
				OnCommand=function(self)
					self:diffusealpha(0):sleep(barSleepIn+0.3+0.9):decelerate(0.7):diffusealpha(1)
				end,
				SetMessageCommand=function(self)
					   	local song = GAMESTATE:GetCurrentSong()
					   	self:settext("")
						   if song then
							self:settext(nativeTitle and song:GetDisplayMainTitle() or song:GetTranslitMainTitle(), song:GetTranslitMainTitle() )
							self:y(song:GetDisplaySubTitle() ~= "" and  26-14 or 26-6)
						end
				  end,
			},
			Def.BitmapText {
				Font="SongSubTitle font",
				InitCommand=function(self)
					self:xy(SCREEN_CENTER_X,26+6):zoom(0.6):maxwidth(SCREEN_WIDTH*0.578125):diffuse(color("#FFFFFF")):horizalign(center)
				end,
				OnCommand=function(self)
					self:diffusealpha(0):sleep(barSleepIn+0.3+0.9):decelerate(0.7):diffusealpha(1)
				end,
				SetMessageCommand=function(self)
					local song = GAMESTATE:GetCurrentSong()
					self:settext("")
					if song then
						self:settext(nativeTitle and song:GetDisplaySubTitle() or song:GetTranslitSubTitle())
					end
				end
			},
		}
	}

	
	-- Difficulty
	-- Trim down and move to bottom
	for ip, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
		local pnum = pn == PLAYER_1 and 1 or 2
		local ppos = GAMESTATE:GetNumPlayersEnabled() == 1 and SCREEN_CENTER_X or THEME:GetMetric("ScreenGameplay","PlayerP".. pnum .."OnePlayerOneSideX")
		
		t[#t+1] = Def.Actor{
			CurrentSongChangedMessageCommand=function(s)
				local peak,npst,NMeasure,mcount = LoadModule("Chart.GetNPS.lua")( GAMESTATE:GetCurrentSteps(pn) )
				GAMESTATE:Env()["ChartData"..pn] = {peak,npst,NMeasure,mcount}
			end,
		}
		local stp = LoadModule("Config.Load.lua")("OverTopGraph",CheckIfUserOrMachineProfile(string.sub(pn,-1)-1).."/OutFoxPrefs.ini")
		if stp then
			local maxwidth = scale( SCREEN_WIDTH, 960, 1152, 360, 394 ) > 394 and 394 or scale( SCREEN_WIDTH, 960, 1152, 360, 394 )
			local maxheight = 35
			local SctMargin = {
				Left = -(maxwidth/2),
				Right = (maxwidth/2)
			}
			local verts = {}
		
			t[#t+1] = Def.Quad{
				OnCommand=function(s)
					s:zoomto( maxwidth, maxheight*2 ):MaskDest():halign(0):diffuse( color("#222222") ):xy( ppos+( SctMargin.Left ), SCREEN_BOTTOM-40 ):playcommand("Update")
					:diffusealpha(0):addy(-20):sleep(barSleepIn+3):easeoutquint(0.5):diffusealpha(1):addy(20)
				end,
				OffCommand=function(self) self:sleep(0.15):decelerate(0.3):addy(20):diffusealpha(0) end,
			}
	
			t[#t+1] = Def.ActorMultiVertex{   
				OnCommand=function(s)
					s:xy( ppos, SCREEN_BOTTOM-40)
					s:MaskDest():SetDrawState{Mode="DrawMode_QuadStrip"}
					:diffusealpha(0):addy(-20):sleep(barSleepIn+3):easeoutquint(0.5):diffusealpha(1):addy(20)
				end,
				CurrentSongChangedMessageCommand=function(s)
					if GAMESTATE:GetCurrentSong() then
						local data = GAMESTATE:Env()["ChartData"..pn]
						local tnp, npst = data[1],data[2]
						local SongMargin = {
							Start = math.min(GAMESTATE:GetCurrentSong():GetTimingData():GetElapsedTimeFromBeat(0), 0),
							End = GAMESTATE:GetCurrentSong():GetLastSecond(),
						}
						-- Grab every instance of the NPS data.
						verts = {}
						if npst then
							for k,v in pairs( npst ) do
									-- Each NPS area is per MEASURE. not beat. So multiply the area by 4 beats.
									local t = GAMESTATE:GetCurrentSong():GetTimingData():GetElapsedTimeFromBeat((k-1)*4)
									-- With this conversion on t, we now apply it to the x coordinate.
									local x = scale( t, SongMargin.Start, SongMargin.End, SctMargin.Left, SctMargin.Right )
									-- Now scale that position on v to the y coordinate.
									local y = math.round( scale( v, 0, tnp, maxheight, -maxheight ) )
									if y < -maxheight then y = -maxheight end
									-- And send them to the table to be rendered.
									if x <= SctMargin.Right then
										if #verts > 2 and verts[#verts][1][2] == y and verts[#verts-2][1][2] == y then
											verts[#verts][1][1] = x
											verts[#verts-1][1][1] = x
										else
											verts[#verts+1] = {{x, maxheight, 0}, PlayerColor(pn) }
											verts[#verts+1] = {{x, y, 0}, ColorDarkTone(PlayerColor(pn))}
										end
									end
							end
							s:SetNumVertices( #verts ):SetVertices( verts )
						end
					end
				end,
				OffCommand=function(self) self:sleep(0.15):decelerate(0.3):addy(20):diffusealpha(0) end,
			}

			t[#t+1] = Def.Quad{
				OnCommand=function(s)
					s:zoomto( 0, maxheight*2 ):MaskDest():halign(0):diffuse( color("#00000099") ):xy( ppos+SctMargin.Left, SCREEN_BOTTOM-40 )
				end,
				CurrentSongChangedMessageCommand=function(s)
					s:playcommand("Update")
				end,
				UpdateCommand=function(s)
					if GAMESTATE:GetCurrentSong() then
						local SongMargin = {
							Start = math.min(GAMESTATE:GetCurrentSong():GetTimingData():GetElapsedTimeFromBeat(0), 0),
							End = GAMESTATE:GetCurrentSong():GetLastSecond(),
						}
						local length = scale( GAMESTATE:GetCurMusicSeconds(), SongMargin.Start, SongMargin.End, 0, SctMargin.Right*2 )
						s:zoomtowidth( GAMESTATE:GetCurMusicSeconds() > 0 and (length > SctMargin.Right*2 and SctMargin.Right*2 or length) or 0)
					end
					s:sleep(1/20):queuecommand("Update")
				end,
				OffCommand=function(self) self:sleep(0.15):decelerate(0.3):addy(20):diffusealpha(0) end,
			}
		end

		local life_x_position = string.find(pn, "P1") and SCREEN_LEFT+32 or SCREEN_RIGHT-32
		local difficulty_y = stpenable[pnum] and SCREEN_BOTTOM-92 or SCREEN_BOTTOM-42
		local difficulty_width = scale( SCREEN_WIDTH, 960, 1152, 360, 394 ) > 394 and 394 or scale( SCREEN_WIDTH, 960, 1152, 360, 394 )

		t[#t+1] = Def.ActorFrame {
				InitCommand=function(self) self:xy(ppos,difficulty_y) end,
				OnCommand=function(self) self:diffusealpha(0):addy(-20):sleep(barSleepIn+3):easeoutquint(0.5):diffusealpha(1):addy(20) end,
				OffCommand=function(self) self:sleep(0.15):decelerate(0.3):addy(20):diffusealpha(0) end,
				-- Quad
				Def.ActorFrame {
					["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(self) self:playcommand("Set") end;
						SetCommand=function(self)
							local steps_data = GAMESTATE:GetCurrentSteps(pn)
							if GAMESTATE:GetCurrentSong() then
								if steps_data == nil then return end
								local st = steps_data:GetStepsType();
								local diff = steps_data:GetDifficulty();
								local cd = GetCustomDifficulty(st, diff);
								self:diffuse(ColorMidTone(CustomDifficultyToColor(cd)))
							end
						end,
						
						Def.Quad {
							InitCommand=function(self)
								self:zoomto(difficulty_width,32):diffuse(color("#FFFFFF75"))
							end
						};
				};
				-- Number
				Def.BitmapText {
					Font="_SemiBold",
					InitCommand=function(self) self:maxwidth(difficulty_width/0.8):y(0):zoom(1) end,
					OnCommand=function(self)
						self:playcommand("Set"):diffusealpha(0):sleep(barSleepIn+0.3):linear(0.3):diffusealpha(1)
					end,
					["CurrentSteps"..ToEnumShortString(pn).."ChangedMessageCommand"]=function(self) self:playcommand("Set") end,
					SetCommand=function(self)
						local steps_data = GAMESTATE:GetCurrentSteps(pn)
						if GAMESTATE:GetCurrentSong() and steps_data then
							local diff = steps_data:GetDifficulty();
							self:settext(ToUpper(THEME:GetString("CustomDifficulty",ToEnumShortString(diff))) .. " - " ..   ToUpper(THEME:GetString("StepsType",ToEnumShortString(steps_data:GetStepsType())))  )
						end
					end
				};
			};
	end;

return t;