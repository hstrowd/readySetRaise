// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

//= require pickdate/picker
//= require pickdate/picker.date
//= require pickdate/picker.time
//= require pickdate/legacy


setPledgeWindow = function() {
    var $startTime = $('#fundraiser-show .pledge-window .start.time');
    var $endTime = $('#fundraiser-show .pledge-window .end.time');
    var fromString = $startTime.text();
    var toString = $endTime.text();

    var fromDateTimeStrings = isoToLocalStrings(fromString);
    var toDateTimeStrings = isoToLocalStrings(toString);

    if (fromDateTimeStrings) {
        $startTime.html('<div class="date">' + fromDateTimeStrings[0] + '</div>' +
                        '<div class="time"> at ' + fromDateTimeStrings[1] + '</div>');
    } else {
        $startTime.text('TBD');
    }
    if (toDateTimeStrings) {
        $endTime.html('<div class="date">' + toDateTimeStrings[0] + '</div>' +
                      '<div class="time"> at ' + toDateTimeStrings[1] + '</div>');
    } else {
        $endTime.text('TBD');
    }

    $startTime.show();
    $endTime.show();
};
