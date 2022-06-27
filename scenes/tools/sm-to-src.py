import simfile
from simfile.notes import Note, NoteType, NoteData
from simfile.timing import TimingData, Beat, BeatValues, BeatValue
from simfile.timing.engine import TimingEngine
from simfile.notes.group import OrphanedNotes, group_notes

from math import floor

file_path = input("Path to Simfile to convert: ")

with open(file_path, 'r') as infile:
    file = simfile.load(infile)

    for chart in file.charts:
        src = ""

        timings = TimingData(file)
        engine = TimingEngine(timings)

        src += "bpm:" + str(timings.bpms[0].value) + "\n"

        note_data = NoteData(chart)

        for note in note_data:
            if note.note_type == NoteType.TAP:
                src += "direction:" + str(note.column) + "\n"
                src += "position:" + str(engine.time_at(note.beat) * 1000.0) + "\n"
                src += "sustaintime:0\n"
        
        group_iterator = group_notes(
            note_data,
            include_note_types={NoteType.HOLD_HEAD, NoteType.TAIL},
            join_heads_to_tails=True,
            orphaned_tail=OrphanedNotes.DROP_ORPHAN,
        )

        last_beat = -100

        for grouped_notes in group_iterator:
            note = grouped_notes[0]

            cur_section = floor(note.beat / 16)

            src += "direction:" + str(note.column) + "\n"
            src += "position:" + str(engine.time_at(note.beat) * 1000.0) + "\n"
            src += "sustaintime:" + str((engine.time_at(note.tail_beat) - engine.time_at(note.beat)) * 1000.0) + "\n"

            if note.beat < last_beat:
                break
            else:
                last_beat = note.beat
                        
        with open(str(chart.difficulty).lower() + ".src", "w") as srcfile:
            srcfile.write(src)