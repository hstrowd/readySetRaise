// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var setupCountdown = function(outputSelector, time) {
    var $outputField = $(outputSelector);
    if (!$outputField.length) { return; }

    var date = new Date(time);
    if (isNaN(date.getTime())) { return; }
    $outputField.text(countdown(date).toString());
    setInterval(function() {
        $outputField.text(countdown(date).toString());        
    }, 1000);
};
