// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

//= require pickdate/picker
//= require pickdate/picker.date
//= require pickdate/picker.time
//= require pickdate/legacy


// TODO: Move this to a more generic location.
convertToLocalTime = function(cssSelector) {
    var $timeEl = $(cssSelector);
    var isoString = $timeEl.text();

    var dateTimeStrings = isoToLocalStrings(isoString);

    if (dateTimeStrings) {
        $timeEl.html('<div class="date">' + dateTimeStrings[0] + '</div> ' +
                     '<div class="time"> at ' + dateTimeStrings[1] + '</div>');
    } else {
        $timeEl.text('TBD');
    }
};
