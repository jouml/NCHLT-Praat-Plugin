# Praat NCHLT plug-in


## The Praat NCHLT plugin moved to [Codeberg](https://codeberg.org/joemayer/NCHLT-Praat-Plugin)

Version 1.1 of the plugin (July 2025) supports the latest SADiLaR folder naming pattern and is available on [Codeberg](https://codeberg.org/joemayer/NCHLT-Praat-Plugin).


**This repository is obsolete.**


## Description

This plugin enables Praat to search in the orthographic transcriptions of the
[NCHLT Speech Corpus](https://www.isca-archive.org/sltu_2014/barnard14_sltu.pdf) and open the audio files of corresponding search results.
The NCHLT Speech Corpus contains orthographically transcribed broadband speech
corpora for all of South Africa’s eleven official languages. Each language
corpus consists of a large training suite (trn) and a smaller test suite (tst).
The NCHLT Speech Corpus must be installed on your machine (at least one
language) before using this plugin. The corpus may be obtained from [SADiLaR](https://repo.sadilar.org/browse/project?value=NCHLT%20Speech&bbm.return=2).

After launching from the Praat *Open* menu, you first select one of your installed languages, pick one of the suites, and specify a search pattern. The XML transcription is loaded into Praat and searched for the pattern. You can further refine the search using speaker attributes (gender, age, location). When you are done with searching you can view the results in a table (including orthographic transcription, speaker ID, age, gender, and location) and open corresponding audio files for acoustic analysis.


## Manual

A detailed manual is included.


## Recquirements

- [Praat](http://www.praat.org) 5.4.x or newer
- [NCHLT Speech Corpus](https://repo.sadilar.org/browse/project?value=NCHLT%20Speech&bbm.return=2) (at least one language)


## Installation

Instructions available on [Codeberg](https://codeberg.org/joemayer/NCHLT-Praat-Plugin).


## Usage

When launched the first time, the plugin asks for the base directory of the NCHLT
Speech Corpus. This is the directory/folder that contains the language-specific
sub-directories called `nchlt_<ISO 639-3>` (old format) or `nchlt.speech.corpus.<ISO 639-3>`
(current format) (`<ISO 639-3>` is a placeholder for the 3-letter language code):

```x
base directory
│
├──nchlt_<ISO 639-3>
│	├── audio
│	│   ├── <spk_id>
│	│   │   ├── nchlt_<ISO 639-3>_<spk_id><gender>_<file_number>.wav
│	│   ...
│	└── transcriptions
│	   ├── nchlt_<ISO 639-3>.trn.xml
│	   └── nchlt_<ISO 639-3>.tst.xml
│
├──nchlt.speech.corpus.<ISO 639-3>
│  ├──...
│  ...
...

```

After selection, the base directory path is stored in the file `CorpusDir` in the plugin
directory. That means you have to do this only once and the plugin is aware of
your corpus directory in the future. If you move your corpus to an other
location or if there are problems with base dir detection, just delete 
`CorpusDir` in the plugin directory. You'll be asked for the base dir the next
time you launch the plugin.

The plugin scans the corpus base directory for installed languages and presents
a menu to choose a language from (if you add a new language to your corpus, it
will be recognized automatically the next time you launch the plugin). Then you
have to select a suite (training or test or both) and specify a search pattern.
Search patterns have two modes: simple and regex. If you choose simple search
pattern all lower-case characters in a pattern are regarded as literal characters. Additionally, you may
use the upper-case character "V" which isn't interpreted literally but
represents a set of characters, namely vowels: [aeiou].

### Some examples:

| pattern | match examples |
|---------| -------------- |
|VpV	  |	api, kupo, jepas ... |
|khV	  |	khi, akho, teskhu ... |
|tVpV	  |	tapi, stupo, tepas ...|


Prohibited are upper-case characters (except for "V"), special symbols (like
\&%$), punctuation marks (like ?!,.), and spaces.

If you choose regex search pattern you can assemble a regular expression as
complex as you wish. Regex syntax is described in the [Praat regular expressions
tutorial](http://www.fon.hum.uva.nl/praat/manual/Regular_expressions.html).

After you start the search, please be patient. Some XML files are pretty large
and it may take some seconds (depends on your machine) to perform the search.
The search results (if any) are available as a Praat table object. A dialog
window will open (and stay open) to let you refine your search and/or view the
table. You can browse through all results and perform acoustic analysis either
one by one or you pick specific items identified in the table.


## Changelog

### v1.0
- support for new SADiLaR folder naming pattern
- available on Github

### v0.4
- detailed manual added

### v0.3
- Python no longer required (slower but more robust)
- regular expression search
- filtering of search results

### v0.2
- usability improvements and bug fixes

### v0.1
- initial release
- XML parsing with Python ElementTree


## License

This is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this software.  If not, see <http://www.gnu.org/licenses/>.
