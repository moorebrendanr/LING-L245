if arg[1] == nil or arg[2] == nil then
	error("Expects two arguments.\nArg 1: noun\nArg 2: noun class\nArg 3 (optional): tone pattern")
end

local data = {arg[1], arg[2], arg[3]}
local vowels = "aeiouAEIOU"
local prefixes = {
	["1"] = {"umu", "um"},
	["2"] = "aba",
	["1a"] = {"u"},
	["2a"] = "o",
	["3"] = {"umu", "um", "u"},
	["4"] = "imi",
	["5"] = {"ili", "i"},
	["6"] = "ama",
	["7"] = {"isi", "is"},
	["8"] = "izi",
	["9"] = {"i"},
	["10"] = "izin",
	["11"] = {"ulu", "u"}
}

local classes = {
	["1"] = "2", 
	["1a"] = "2a", 
	["3"] = "4", 
	["5"] = "6", 
	["7"] = "8",
	["9"] = "10", 
	["11"] = "10"
}

function agglutinate(prefix, stem)
	local nasal_changes = {
		["ph"] = "p",
		["th"] = "t",
		["kh"] = "k",
		["ch"] = "c",
		["qh"] = "q",
		["xh"] = "x",
		["sh"] = "tsh",
		["c"] = "gc",
		["q"] = "gq",
		["x"] = "gx"
	}

	local pre_len = prefix:len()
	local first_letter = stem:sub(1, 1)
	if prefix:sub(pre_len) == "n" then
		if first_letter == "b" or first_letter == "p" or first_letter == "f" or first_letter == "v" then
			prefix = prefix:gsub("n$", "m")
		end

		for init, changed in pairs(nasal_changes) do
			if stem:find("^" .. init) then
				stem = stem:gsub("^" .. init, changed)
				break
			end
		end
	end

	if stem:find("^["..vowels.."]") then
		prefix = prefix:sub(1, pre_len-1)
	end

	if prefix:sub(pre_len, pre_len) == "n" and (first_letter == "n" or first_letter == "m" or first_letter == "l") then
		prefix = prefix:sub(1, pre_len-1)
	end
	
	return prefix .. stem
end

function apply_tone(word, pattern_str)
	local depressor_consonant = {"bh", "d", "dl", "g", "gc", "gq", "gx", "hh", "j", "mb", "mv", "nd", "ndl", "ng", "ngc", "ngq", "ngx", "nj", "nz", "v", "z"}
	local dep_table = {}
	for _, consonant in ipairs(depressor_consonant) do
		dep_table[consonant] = true
		dep_table[consonant .. "w"] = true
	end

	--Adjust tone pattern for monosyllable prefix -> disyllable prefix
	if data[2] == "5" or data[2] == "9" or data[2] == "11" then
		if pattern_str:find("^F") then -- Class 5 or 11 before H
			pattern_str = "HL"..pattern_str:sub(2)
		elseif pattern_str:find("^HH") then -- Class 9 before H
			pattern_str = "HL"..pattern_str:sub(2)
		else -- H prefix before L becomes LH, or L prefix becomes LL
			pattern_str = "L"..pattern_str
		end
	elseif data[2] == "1a" then --long vowel prefix
		if pattern_str:find("^HH") then
			pattern_str = "F"..pattern_str:sub(2)
		end
	end

	local syllables = {}
	for syll in word:gmatch("[^"..vowels.."]*["..vowels.."]") do
		table.insert(syllables, syll)
	end
	
	local consonants = {}
	for _, syll in ipairs(syllables) do
		consonant = syll:sub(1, #syll-1)
		table.insert(consonants, consonant)
	end

	local pattern = {}
	for tone in pattern_str:gmatch(".") do
		table.insert(pattern, tone)
	end
	
	if #pattern ~= #syllables then
		error("Tone pattern must have the same number of tones as the number of syllables in the given word.")
	end
	
	for i, cons in ipairs(consonants) do
		 --If the syllable is H and has a depressor consonant, and next syllable does not have a depressor consonant
		if pattern[i] == "H" and dep_table[cons] and not dep_table[consonants[i+1]] then
			if #consonants - i > 2 then --next syllable is before the penult
				pattern[i] = "L"
				if pattern[i+1] == "L" then
					pattern[i+1] = "H"
				end
			elseif #consonants - i == 2 then --next syllable is penultimate
				pattern[i] = "L"
				if pattern[i+1] == "L" then
					pattern[i+1] = "F"
				end
			end
		end
	end
	
	shifted = ""
	for _, tone in ipairs(pattern) do
		shifted = shifted .. tone
	end

	return shifted
end

function pluralize(word, class)
	local is_singular = false
	for sg, pl in pairs(classes) do
		if class == sg then is_singular = true end
	end

	if not is_singular then error("Must give word in singular.") end

	local stem

	for _, prefix in ipairs(prefixes[class]) do
		local i, j = word:find("^" .. prefix)
		if j then
			stem = word:sub(j+1)
			break
		end
	end

	if not stem then error("Could not parse stem.") end

	return agglutinate(prefixes[classes[class]], stem)
end

if data[3] then
	local plural = pluralize(data[1], data[2])
	local pattern = apply_tone(plural, data[3])
	io.write(plural.."\t"..pattern, "\n")
else
	io.write(pluralize(data[1], data[2]), "\n")
end
