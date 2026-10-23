# Generates openmpt_ext's SFZ instrument reader from upstream's openmpt/soundlib/SampleFormatSFZ.cpp.
#
# libopenmpt compiles the reader out (it needs MPT_EXTERNAL_SAMPLES, which only the tracker build
# defines) and keeps a CSoundFile::ReadSFZInstrument stub that always fails. This extracts the reader
# so it can be built as a CTrackerSoundFile member, the way SampleFormatFLACExt.cpp does for FLAC,
# and it follows upstream on every update instead of being a copy that can drift.
#
# Usage: cmake -DINPUT=<SampleFormatSFZ.cpp> -DOUTPUT=<generated .cpp> -P GenerateSFZImport.cmake

file(READ "${INPUT}" upstream)

# The reader starts after the first "#ifdef MPT_EXTERNAL_SAMPLES" and ends where the export code
# ("#ifndef MODPLUG_NO_FILESAVE") begins. That guard also appears in the include block at the top,
# so look for the end only after the start.
set(begin_marker "\n#ifdef MPT_EXTERNAL_SAMPLES\n")
set(end_marker "\n#ifndef MODPLUG_NO_FILESAVE\n")

string(FIND "${upstream}" "${begin_marker}" begin)
if(begin EQUAL -1)
	message(FATAL_ERROR "GenerateSFZImport: no '#ifdef MPT_EXTERNAL_SAMPLES' in ${INPUT}; upstream changed, update cmake/GenerateSFZImport.cmake")
endif()
string(LENGTH "${begin_marker}" begin_length)
math(EXPR body_start "${begin} + ${begin_length}")
string(SUBSTRING "${upstream}" ${body_start} -1 rest)

string(FIND "${rest}" "${end_marker}" end)
if(end EQUAL -1)
	message(FATAL_ERROR "GenerateSFZImport: no '#ifndef MODPLUG_NO_FILESAVE' after the reader in ${INPUT}; upstream changed, update cmake/GenerateSFZImport.cmake")
endif()
string(SUBSTRING "${rest}" 0 ${end} body)

# Make the reader a CTrackerSoundFile member.
set(original "bool CSoundFile::ReadSFZInstrument(INSTRUMENTINDEX nInstr, FileReader &file)")
set(renamed "bool CTrackerSoundFile::ReadSFZInstrument(INSTRUMENTINDEX nInstr, FileReader &file)")
string(FIND "${body}" "${original}" found)
if(found EQUAL -1)
	message(FATAL_ERROR "GenerateSFZImport: ReadSFZInstrument's signature changed in ${INPUT}; update cmake/GenerateSFZImport.cmake")
endif()
string(REPLACE "${original}" "${renamed}" body "${body}")

file(WRITE "${OUTPUT}" "// Generated from openmpt/soundlib/SampleFormatSFZ.cpp by cmake/GenerateSFZImport.cmake. Do not edit.

#include \"stdafx.h\"
#include \"TrackerSoundFile.h\"
#include \"mpt/io_file/inputfile.hpp\"
#include \"mpt/io_file_read/inputfile_filecursor.hpp\"
#include \"../common/mptFileIO.h\"
#include \"../soundlib/modsmp_ctrl.h\"
#include \"mpt/base/numbers.hpp\"
#include \"mpt/parse/parse.hpp\"

#include <functional>

OPENMPT_NAMESPACE_BEGIN

${body}
OPENMPT_NAMESPACE_END
")
