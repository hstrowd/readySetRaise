// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery-combobox
//= require turbolinks

//= require login
//= require google-analytics

//= require_tree .



function isoToLocalStrings(dateInput) {
    var rawDate = new Date(dateInput);
    if (!rawDate || isNaN( rawDate.getTime() )) { return null; }

    var year = rawDate.getFullYear();
    var month = (rawDate.getMonth() + 1);
    var day = rawDate.getDate();
    var hours = rawDate.getHours();
    var minutes = rawDate.getMinutes();
    var period = 'AM';

    if (hours >= 12) {
        hours = hours % 12;
        period = 'PM';
    }
    if (hours == 0) { hours = 12 }
    if (minutes < 10) {
        minutes = "0" + minutes;
    }

    var dateString = month + "/" + day + "/" + year;
    var timeString = hours + ':' + minutes + ' ' + period;

    return [dateString, timeString];
}
