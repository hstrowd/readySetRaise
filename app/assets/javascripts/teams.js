// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


var convertTimeValuesToLocal = function(targetSelector) {
    $(targetSelector).each(function(i) {
        var localDateTime = isoToLocalStrings($(this).text())
        if (localDateTime && localDateTime.length == 2) {
            $(this).text(localDateTime[0] + ' at ' + localDateTime[1]);
        }
    });
};
