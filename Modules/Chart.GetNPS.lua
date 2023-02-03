local allowedNotes = {
	["TapNoteType_Tap"] = true,
	["TapNoteType_Lift"] = true,
	-- Support the heads of the subtypes.
	["TapNoteSubType_Hold"] = true,
	["TapNoteSubType_Roll"] = true,
	-- Stamina players: you'd want to comment this out.
	["TapNoteType_HoldTail"] = true,
}

local minimumNotesInStreamMeasure = 16

return function(steps)
	local chartInt = 1
	local density = {}
	local streamMeasures = {}
	local peakNPS = 0
	-- Keep track of processed measures
	local measureCount = 0

	if steps then
		for k, v in pairs(GAMESTATE:GetCurrentSong():GetAllSteps()) do
			if v == steps then
				chartInt = k
				break
			end
		end
		-- Trace("[GetNPS] Loading Chart... ".. chartInt)
		local timingData = steps:GetTimingData()

		local function CalcNPS(measure)
			-- Some Warp segments can fall into parts where the duration of the lasting beat before its next one
			-- is miniscule, so lets just skip those.
			if measure.duration <= 0.05 then
				return 0
			end

			return measure.notes / measure.duration
		end

		-- Keep track of the number of notes in the current measure while we iterate
		local function NewMeasure(index)
			local endingTime = timingData:GetElapsedTimeFromBeat(index * 4)
			return {
				notes = 0,
				NPS = 0,
				endingTime = endingTime,
				duration = endingTime - timingData:GetElapsedTimeFromBeat((index - 1) * 4)
			}
		end

		local currentMeasure = NewMeasure(measureCount + 1)

		for _, noteData in pairs(GAMESTATE:GetCurrentSong():GetNoteData(chartInt)) do
			noteBeat, _, noteType = unpack(noteData)

			while timingData:GetElapsedTimeFromBeat(noteBeat) > currentMeasure.endingTime do
				local originalValue = currentMeasure.notes == 0 and 0 or CalcNPS(currentMeasure)
				currentMeasure.NPS = math.round(originalValue)
				peakNPS = (currentMeasure.NPS > peakNPS or originalValue > peakNPS) and originalValue or peakNPS

				if (currentMeasure.notes >= minimumNotesInStreamMeasure) then
					streamMeasures[#streamMeasures + 1] = measureCount + 1
				end

				-- Reset stuff
				density[measureCount + 1] = currentMeasure.NPS
				measureCount = measureCount + 1
				currentMeasure = NewMeasure(measureCount + 1)
			end

			if timingData:IsJudgableAtBeat(noteBeat) and allowedNotes[noteType] then
				currentMeasure.notes = currentMeasure.notes + 1
			end
		end

		density[measureCount + 1] = currentMeasure.NPS
		density[measureCount + 2] = 0
	end

	return peakNPS, density, streamMeasures, measureCount
end
