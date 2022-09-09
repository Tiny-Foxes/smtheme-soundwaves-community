local t = LoadFallbackB()

-- This section makes the SpeedMod setting rows work
-- The SpeedModUpdate script works on the "Main" option screen, hence the setting.
-- This needs to be set because it is used to differentiate the screens in standard play mode.
setenv("NewOptions", "Main")
local playerNumbers = GAMESTATE:GetHumanPlayers()
for i=1,#playerNumbers do
	t[#t+1] = loadfile( THEME:GetPathB("","SpeedModUpdate.lua") )( playerNumbers[i] )
end

return t
