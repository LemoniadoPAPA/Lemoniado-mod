function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		--Check if the note is an Shoot
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'ShootSustain' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'SHOOTNOTE_assets'); --Change texture
			setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false); --Miss has no penalties
		end
	end
	--debugPrint('Script started!')
	function noteMiss(id, i, noteType, isSustainNote)
		if noteType == 'ShootSustain' then
			setProperty('health', -500);
		characterPlayAnim('boyfriend', 'hurt', true);

	end
end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'ShootSustain' then
		characterPlayAnim('boyfriend', 'dodge', true);

	end
end