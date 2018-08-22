import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import MuseScore 1.0

MuseScore {
      menuPath: "Plugins.Retune"
      description: "Retune plugin"
      version: "1.0"
      onRun: {
            console.log("=============");
            console.log("Start tunning");
            console.log("=============");
            var parms = {};
            parms.accidentals = {};
            retuneAll(parms);
            Qt.quit();
      }

	 // Eliminados los valores de la matriz para
	 // protección del trabajo a entregar
     property variant matrix: [] 
      
      function retuneAll(parms) {
        var cursor = curScore.newCursor();
        cursor.rewind(1);
        var startStaff;
        var endStaff;
        var endTick;
        var fullScore = true;
        startStaff = 0; 
        endStaff = curScore.nstaves - 1; 
        for (var staff = startStaff; staff <= endStaff; staff++) {
          for (var voice = 0; voice < 4; voice++) {
            cursor.rewind(1); // sets voice to 0
            cursor.voice = voice; //voice has to be set after goTo
            cursor.staffIdx = staff;
            cursor.rewind(0) // if no selection, beginning of score
            var measureCount = 0;
            // Loop elements of a voice
            while (cursor.segment) {
              if (cursor.element) {
                if (cursor.element.type == Element.CHORD) {
                  var graceChords = cursor.element.graceNotes;
                  for (var i = 0; i < graceChords.length; i++) {
                    // iterate through all grace chords
                    var notes = graceChords[i].notes;
                    for (var j = 0; j < notes.length; j++)
                      tuneNote(notes[j], parms);
                  }
                  var notes = cursor.element.notes;
                  for (var i = 0; i < notes.length; i++) {
                    var note = notes[i];
                    tuneNote(note, parms);
                  }
                }
              }
              cursor.next();
            }
          }
        }
      }
      

      
     function accToLetter(acc) {
          if (acc != null){
            switch(acc.accType){
              case Accidental.FLAT_SLASH2:                   return 1; 
              case Accidental.FLAT_SLASH:                     return 2; 
              case Accidental.FLAT_ARROW_DOWN:        return 3; 
              case Accidental.NATURAL:                         return 4;
              case Accidental.SHARP_SLASH:                   return 5; 
              case Accidental.SHARP_ARROW_DOWN:     return 6; 
              case Accidental.SHARP_ARROW_UP:           return 7; 
              case Accidental.SHARP_SLASH2:                 return 8; 
              case Accidental.SHARP_SLASH3:                 return 9; 
              case Accidental.SHARP_SLASH4:                 return 10; 
              default: return -1;
            }
          }
      }
      
      function tpcToLetter(tpc){
            if (tpc==null){
                  return null;
            }
            switch(tpc){
              case 14: return 0; //c
              case 13: return 3; //f
              case 18: return 2; //e
              case 16: return 1; //d
              case 19: return 6; //b
              case 17: return 5; //a
              case 15: return 4; //g
              default: 
                 return null;     
            }
      }

      function retuneNote(note) {
            var result = null;
            var ai = accToLetter(note.accidental);
            var ti = tpcToLetter(note.tpc);
            if (ai >=0 ){
                  result = matrix[ai][ti];
            } else if (ai == -1){
                  note.accidental.color = "#FF0000"
            }
            return result;
      }      
      
      function tuneNote(note, parms) {
        var tpc = note.tpc;
        var acc = note.accidental!==null ? note.accidental.accType: null;
        console.log(">>> tpc: " + tpc + ", acc: " + acc);
        var retuning = retuneNote(note);
        if (retuning !==null && !isNaN(retuning)){
            console.log("Retuning TPC:"+tpc+" with "+retuning+" tpc1:"+note.tpc1+" tpc2:"+note.tpc2);
            note.color="#009900";
            note.tuning = retuning;
        }else{
            console.log(">>>>>>>>>>>  Error at "+tpc+" acc:"+acc);
            note.color="#FF9900";
            note.tuning= 0.0;
        }
        
        return;
      }


}
