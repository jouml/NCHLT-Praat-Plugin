# searchNCHLT.praat
# v1.0, 2018-12-04
# Copyright (C) 2018 Joerg Mayer
# jmayer@lingphon.net
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# de-select everything
nocheck selectObject: ""

# read corpus base directory from setting or let the user choose it
corpusdir$ = ""
settings$ = defaultDirectory$ + "/CorpusDir"
settings$ = replace$ (settings$, "//", "/", 0)

if fileReadable (settings$)
	corpusdir$ = readFile$ (settings$)
endif
if not fileReadable (settings$) or corpusdir$ = ""
	nocheck deleteFile: settings$
	corpusdir$ = chooseDirectory$: "Choose the base directory of the corpus"
	nocheck writeFile: settings$, corpusdir$
endif
if corpusdir$ = ""
	exitScript ()
endif

# detect installed languages and convert ISO 639-3 codes to human readable
langlistID = Create Strings as directory list: "langlist", corpusdir$ + "/nchlt*"
nos = Get number of strings
if nos < 1
	nocheck deleteFile: settings$
	exitScript: "Couldn't find any installed languages. Verify your corpus base directory and/or install at least one language."
endif
for l to nos
	langdirname$[l] = Get string: l
	if langdirname$[l] = "nchlt_afr" or langdirname$[l] = "nchlt.speech.corpus.afr"
		langcode$[l] = "nchlt_afr"
		lang$[l] = "Afrikaans (nchlt_afr)"
	elsif langdirname$[l] = "nchlt_eng" or langdirname$[l] = "nchlt.speech.corpus.eng"
		langcode$[l] = "nchlt_eng"
		lang$[l] = "English (nchlt_eng)"
	elsif langdirname$[l] = "nchlt_nbl" or langdirname$[l] = "nchlt.speech.corpus.nbl"
		langcode$[l] = "nchlt_nbl"
		lang$[l] = "isiNdebele (nchlt_nbl)"
	elsif langdirname$[l] = "nchlt_xho" or langdirname$[l] = "nchlt.speech.corpus.xho"
		langcode$[l] = "nchlt_xho"
		lang$[l] = "isiXhosa (nchlt_xho)"
	elsif langdirname$[l] = "nchlt_zul" or langdirname$[l] = "nchlt.speech.corpus.zul"
		langcode$[l] = "nchlt_zul"
		lang$[l] = "isiZulu (nchlt_zul)"
	elsif langdirname$[l] = "nchlt_tsn" or langdirname$[l] = "nchlt.speech.corpus.tsn"
		langcode$[l] = "nchlt_tsn"
		lang$[l] = "Setswana (nchlt_tsn)"
	elsif langdirname$[l] = "nchlt_nso" or langdirname$[l] = "nchlt.speech.corpus.nso"
		langcode$[l] = "nchlt_nso"
		lang$[l] = "Sesotho sa Leboa (nchlt_nso)"
	elsif langdirname$[l] = "nchlt_sot" or langdirname$[l] = "nchlt.speech.corpus.sot"
		langcode$[l] = "nchlt_sot"
		lang$[l] = "Sesotho (nchlt_sot)"
	elsif langdirname$[l] = "nchlt_ssw" or langdirname$[l] = "nchlt.speech.corpus.ssw"
		langcode$[l] = "nchlt_ssw"
		lang$[l] = "siSwati (nchlt_ssw)"
	elsif langdirname$[l] = "nchlt_ven" or langdirname$[l] = "nchlt.speech.corpus.ven"
		langcode$[l] = "nchlt_ven"
		lang$[l] = "Tshivenda (nchlt_ven)"
	elsif langdirname$[l] = "nchlt_tso" or langdirname$[l] = "nchlt.speech.corpus.tso"
		langcode$[l] = "nchlt_tso"
		lang$[l] = "Xitsonga (nchlt_tso)"
	endif
endfor
removeObject: langlistID

# prepare first dialog (language selection and search pattern)
language = 1
lMsg$ = "- Language selection -"
sMsg$ = "Example: The pattern VpV matches a /p/ between any two vowels."
search_pattern$ = "VpV"
repeat
	beginPause: "Language selection and search pattern"
		comment: lMsg$
		optionMenu: "Language", language
		for l to nos
			option: lang$[l]
		endfor
		optionMenu: "Suite (training / test / both)", 1
			option: "trn"
			option: "tst"
			option: "both"
		comment: "- Search pattern -"
		optionMenu: "Mode", 1
			option: "simple"
			option: "regex"
		comment: "Simple search pattern:"
		comment: "You may only use lower-case characters a-z"
		comment: "and V as a placeholder for vowels (aeiou)."
		comment: sMsg$
		comment: "Regex search pattern:"
		comment: "Regular expression search; see Praat regex tutorial:"
		comment: "http://www.fon.hum.uva.nl/praat/manual/Regular_expressions.html."
		sentence: "Search pattern", search_pattern$
	clicked = endPause: "Cancel", "Search", 2, 1
	# user clicked Cancel
	if clicked = 1
		exitScript ()
	endif
	# evaluate simple search pattern
	if mode = 1
		idx = index_regex (search_pattern$, "[^a-zV]")
		if search_pattern$ = "" || idx <> 0
			idx = 1
			sMsg$ = "*** ERROR: There's something wrong with your pattern (see rules above)."
		else
			spattern$ = replace$ (search_pattern$, "V", "[aeiou]+", 0)
			sMsg$ = "Example: The pattern VpV matches a /p/ between any two vowels."
		endif
	else
		spattern$ = search_pattern$
		idx = 0
	endif
	# evaluate transcription (XML file)
	lMsg$ = "- Language selection -"
	if suite < 3 and idx = 0
		xmlfile$ = corpusdir$ + "/" + langdirname$[language] + "/transcriptions/" + langcode$[language] + "." + suite$ + ".xml"
		if not fileReadable (xmlfile$)
			lMsg$ = "*** ERROR: Can't open selected transcription."
			idx = 1
		else
			xml = Read Strings from raw text file: xmlfile$
		endif
	elsif suite = 3 and idx = 0
		tmpxml1$ = corpusdir$ + "/" + langdirname$[language] + "/transcriptions/" + langcode$[language] + ".trn.xml"
		tmpxml2$ = corpusdir$ + "/" + langdirname$[language] + "/transcriptions/" + langcode$[language] + ".tst.xml"
		if not fileReadable (tmpxml1$) and not fileReadable (tmpxml2$)
			lMsg$ = "*** ERROR: Can't open selected transcription."
			idx = 1
		elsif fileReadable (tmpxml1$) and fileReadable (tmpxml2$)
			tmpxml1 = Read Strings from raw text file: tmpxml1$
			nos = Get number of strings
			Remove string: nos
			tmpxml2 = Read Strings from raw text file: tmpxml2$
			Remove string: 1
			Remove string: 1
			selectObject: tmpxml1, tmpxml2
			xml = Append
			removeObject: tmpxml1, tmpxml2
		else
			if fileReadable (tmpxml1$)
				xmlfile$ = corpusdir$ + "/" + langdirname$[language] + "/transcriptions/" + langcode$[language] + ".trn.xml"
			else
				xmlfile$ = corpusdir$ + "/" + langdirname$[language] + "/transcriptions/" + langcode$[language] + ".tst.xml"
			endif
			xml = Read Strings from raw text file: xmlfile$
		endif
	endif
until idx = 0

searchName$ = langcode$[language] + "-" + suite$ + "-" + search_pattern$
tableID = Create Table with column names: searchName$, 0, "audio orth id age gender location"
selectObject: xml
nos = Get number of strings
row = 0
count = 0
clearinfo
stopwatch
for s from 3 to nos - 1
	selectObject: xml
	string$ = Get string: s
	string$ = replace_regex$ (string$, "^\s+", "", 1)
	if startsWith (string$, "<speaker")
		sp_id$ = replace_regex$ (string$, ".* id=""([^""]+)"" .*", "\1", 1)
		sp_age$ = replace_regex$ (string$, ".* age=""([^""]+)"" .*", "\1", 1)
		sp_gen$ = replace_regex$ (string$, ".* gender=""([^""]+)"" .*", "\1", 1)
		sp_loc$ = replace_regex$ (string$, ".* location=""([^""]+)""\>", "\1", 1)
		appendInfo: "."
		if number (sp_id$)/40 = round (number (sp_id$) / 40)
			appendInfo: newline$
		endif
	elsif startsWith (string$, "<recording")
		audio$ = replace_regex$ (string$, ".* audio=""([^""]+)"" .*", "\1", 1)
		audio$ = replace$ (audio$, langcode$[language], langdirname$[language], 1)
	elsif startsWith (string$, "<orth")
		count = count + 1
		orth$ = replace_regex$ (string$, ".*\>([^<]+)\<.*", "\1", 1)
		found = index_regex (orth$, spattern$)
		if found > 0
			selectObject: tableID
			Append row
			row = row + 1
			Set string value: row, "audio", audio$
			Set string value: row, "orth", orth$
			Set string value: row, "id", sp_id$
			Set string value: row, "age", sp_age$
			Set string value: row, "gender", sp_gen$
			Set string value: row, "location", sp_loc$
		endif
	endif
endfor
time = stopwatch
appendInfoLine: newline$ + "evaluated " + string$ (count) + " recordings in " + fixed$ (time, 1) + " sec."
removeObject: xml

selectObject: tableID
nor = Get number of rows
if nor < 1
	appendInfoLine: newline$ + "------------------------------------------------"
	appendInfoLine: "Sorry, the following search produced no results:"
	appendInfoLine: "------------------------------------------------"
	appendInfoLine: "      Language: " + lang$[language]
	appendInfoLine: "         Suite: " + suite$
	appendInfoLine: "Search pattern: " + search_pattern$ + " (" + mode$ + ")"
	appendInfoLine: "------------------------------------------------"
	removeObject: tableID
	exitScript ()
endif
# convert "-1" to "unknown"
Formula: "location", "if self$=""-1"" then ""unknown"" else self$ fi"
# copy the original table to rtable (necessary for refined search);
# rtable will be our working table, but we'll still need the original
# table from time to time
rtableID = Copy: searchName$

# default settings for unrefined search
select_gender$ = "all"
select_gender = 1
select_age$ = "all"
select_age = 1
select_location$ = "all"
select_location = 1
selectObject: rtableID
# table with refined results jumps in here
label SecondDialog
# analyze table
# number of recordings
nResults = Get number of rows
# number of speakers
collapsed = Collapse rows: "id", "", "", "", "", ""
numOfSpeakers = Get number of rows
removeObject: collapsed
# per gender
numOfFemale = 0
numOfMale = 0
selectObject: rtableID
collapsed = Collapse rows: "gender id", "", "", "", "", ""
extracted = nowarn Extract rows where column (text): "gender", "is equal to", "female"
numOfFemale = Get number of rows
removeObject: extracted
selectObject: collapsed
extracted = nowarn Extract rows where column (text): "gender", "is equal to", "male"
numOfMale = Get number of rows
removeObject: collapsed, extracted
# per age
# because extraction of non-existing rows will fail we need to set the result (0) manually
numOfUnknown = 0
numOfLT20 = 0
numOf2030 = 0
numOf3140 = 0
numOfGT40 = 0
selectObject: rtableID
# auxiliary table with ages transformed to ranges
table2ID = Copy: "aux"
Formula: "age", "if self=-1 then ""unknown"" else if self<20 and self>0 then ""below 20"" else if self>=20 and self <=30 then ""20-30"" else if self>30 and self<=40 then ""31-40"" else ""above 40"" fi fi fi fi"
collapsed = Collapse rows: "age id", "", "", "", "", ""
# count speakers per age range
extracted = nowarn Extract rows where column (text): "age", "is equal to", "unknown"
numOfUnknown = Get number of rows
removeObject: extracted
selectObject: collapsed
extracted = nowarn Extract rows where column (text): "age", "is equal to", "below 20"
numOfLT20 = Get number of rows
removeObject: extracted
selectObject: collapsed
extracted = nowarn Extract rows where column (text): "age", "is equal to", "20-30"
numOf2030 = Get number of rows
removeObject: extracted
selectObject: collapsed
extracted = nowarn Extract rows where column (text): "age", "is equal to", "31-40"
numOf3140 = Get number of rows
removeObject: extracted
selectObject: collapsed
extracted = nowarn Extract rows where column (text): "age", "is equal to", "above 40"
numOfGT40 = Get number of rows
removeObject: extracted, collapsed, table2ID
# per locations
# initialize comment strings for dialog
locLocString$ = ""
locNumString$ = ""
# count locations in the original table
selectObject: tableID
locTable = Collapse rows: "location", "", "", "", "", ""
numOfLoc = Get number of rows
for i from 1 to numOfLoc
	selectObject: locTable
	locations$ [i] = Get value: i, "location"
	# count number of speakers per location in rtable
	selectObject: rtableID
	extracted = nowarn Extract rows where column (text): "location", "is equal to", locations$ [i]
	collapsed = Collapse rows: "id", "", "", "", "", ""
	speakersPerLoc [i] = Get number of rows
	removeObject: extracted, collapsed
	# assemble comment strings
	locLocString$ = locLocString$ + locations$ [i] + "/"
	locNumString$ = locNumString$ + string$ (speakersPerLoc [i]) + "/"
endfor
# truncate final slash
locLocString$ = left$ (locLocString$, length (locLocString$) - 1)
locNumString$ = left$ (locNumString$, length (locNumString$) - 1)
removeObject: locTable

selectObject: rtableID

# prepare second dialog (managing results)
recording_index = 1
table_on = 0
remove_previous = 0
aMsg$ = "To analyze a recording select its index and click ANALYZE below."
# show second dialog until finished
repeat
	beginPause: searchName$
		comment: "- Search parameters -"
		comment: "Language/Suite: "+ lang$[language] + "/" + suite$
		comment: "Search pattern: "+ search_pattern$
		comment: "Attributes (gender/age/location): " + select_gender$ + "/" + select_age$ + "/" + select_location$
		comment: "- Search results -"
		comment: "Number of recordings: " + string$ (nResults)
		comment: "Number of speakers: " + string$ (numOfSpeakers)
		comment: tab$ + "Gender (male/female): " + string$ (numOfMale) + "/" + string$ (numOfFemale)
		comment: tab$ + "Age (below 20/20-30/31-40/above 40/unknown): " + string$ (numOfLT20) + "/" + string$ (numOf2030) + "/" + string$ (numOf3140) + "/" + string$ (numOfGT40) + "/" + string$ (numOfUnknown)
		comment: tab$ + "Location (" + locLocString$ + "): " + locNumString$
		comment: ""
		comment: "To refine your search select attributes and click REFINE below."
		optionMenu: "select gender", select_gender
			option: "all"
			option: "male"
			option: "female"
		optionMenu: "select age", select_age
			option: "all"
			option: "below 20"
			option: "20-30"
			option: "31-40"
			option: "above 40"
			option: "unknown"
		optionMenu: "select location", select_location
			option: "all"
			for i from 1 to numOfLoc
				option: locations$ [i]
			endfor
		comment: ""
		comment: "To toggle the table view of all recordings click TABLE below."
		comment: aMsg$
		natural: "recording index (between 1 and " + string$ (nResults) + ")", recording_index
		comment: "Remove previous Sound+TextGrid objects when loading a new recording?"
		boolean: "remove previous", remove_previous
		comment: "When you are finished click EXIT."
	clicked = endPause: "EXIT", "REFINE", "TABLE", "ANALYZE", 4, 1
	# user clicked Exit
	if clicked = 1
		goto END
	endif
	# refine search
	if clicked = 2
		# remove old rtable
		nocheck removeObject: rtableID
		# start with original table
		selectObject: tableID
		# if !=all, extract selected gender from original table
		if select_gender > 1
			auxg = nowarn Extract rows where column (text): "gender", "is equal to", select_gender$
		endif
		# if !=all, extract selected age range from auxg (if it was generated above) or original table
		if select_age = 2
			auxa = nowarn Extract rows where: "self[""age""]>0 and self[""age""]<20"
		elsif select_age = 3
			auxa = nowarn Extract rows where: "self[""age""]>=20 and self[""age""]<=30"
		elsif select_age = 4
			auxa = nowarn Extract rows where: "self[""age""]>30 and self[""age""]<=40"
		elsif select_age = 5
			auxa = nowarn Extract rows where: "self[""age""]>40"
		elsif select_age = 6
			auxa = nowarn Extract rows where: "self[""age""]<0"
		endif
		# if !=all, extract selected location from auxa (if it was generated above) or auxg (if...) or original table
		if select_location > 1
			auxl = nowarn Extract rows where column (text): "location", "is equal to", select_location$
		endif
		# preserve resulting table as rtable
		rtableID = Copy: searchName$ + "_refined"
		# remove auxiliary tables when necessary
		nocheck removeObject: auxg
		nocheck removeObject: auxa
		nocheck removeObject: auxl
		# jump to table analysis above
		goto SecondDialog
	endif
	# toggle table view
	if clicked = 3 and not table_on
		# open table
		selectObject: rtableID
		do ("View & Edit")
		table_on = 1
	elsif clicked = 3 and table_on
		# close table
		editor: rtableID
		do ("Close")
		table_on = 0
	endif
	# handle ANALYZE
	if clicked = 4
		# remove old stuff if box is checked
		if remove_previous
			nocheck removeObject: soundID, gridID
		endif
		# reject indices out of range
		if recording_index > nResults
			writeInfoLine: "*** ERROR ***"
			appendInfoLine: "There's no recording with index " + string$ (recording_index)
			appendInfoLine: "Please adjust your selection."
		else
			aMsg$ = "To analyze a recording select its index and click ANALYZE below."
			# get stuff from the table
			selectObject: rtableID
			sound$ = Get value: recording_index, "audio"
			sound$ = corpusdir$ + "/" + sound$
			orth$ = Get value: recording_index, "orth"
			if fileReadable (sound$)
				# load sound and attach textgrid with orthographic transcription
				soundID = Read from file: sound$
				gridID = To TextGrid: "orth", ""
				Set interval text: 1, 1, orth$
				plusObject: soundID
				do ("View & Edit")
				editor: gridID
					asynchronous Play window
				endeditor
			else
				# aMsg$ = "*** ERROR: " + sound$ + " is not readable."
				writeInfoLine: "*** ERROR ***"
				appendInfoLine: "can't open " + sound$
				appendInfoLine: "possible explanations:"
				appendInfoLine: "- the audio file which is referenced in the transcription is missing"
				appendInfoLine: "- the audio file is in place but you don't have read permissions"
				appendInfoLine: "- ...?"
			endif
			# increase index
			if recording_index < nResults
				recording_index += 1
			endif
		endif
	endif
until clicked = 1

label END
if remove_previous
	nocheck removeObject: soundID, gridID
endif
nocheck removeObject: tableID, rtableID

