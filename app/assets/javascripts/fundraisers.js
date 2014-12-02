// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

//= require pickdate/picker
//= require pickdate/picker.date
//= require pickdate/picker.time
//= require pickdate/legacy


setPledgeWindow = function() {
    var $startTime = $('#fundraiser-show .pledge-window .start-time');
    var $endTime = $('#fundraiser-show .pledge-window .end-time');
    var fromString = $startTime.text();
    var toString = $endTime.text();

    var fromDateTimeStrings = isoToLocalStrings(fromString);
    var toDateTimeStrings = isoToLocalStrings(toString);

    if (fromDateTimeStrings) {
        $startTime.text(fromDateTimeStrings[0] + " " + fromDateTimeStrings[1]); 
    } else {
        $startTime.text('TBD');
    }
    if (toDateTimeStrings) {
        $endTime.text(toDateTimeStrings[0] + " " + toDateTimeStrings[1]); 
    } else {
        $endTime.text('TBD');
    }

    $startTime.show();
    $endTime.show();
};
