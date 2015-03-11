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
};


function setupSizeToggling($toggleableFields) {
    $.each($toggleableFields, function(index, field) {
        var $field = $(field);
        var $view = $field.find('.view');
        var lessHeight = $field.data('less-height');
        var $moreToggle = $field.find('.toggle.more');
        var $lessToggle = $field.find('.toggle.less');
        if (!lessHeight || $moreToggle.length <= 0 || $view.length <= 0 || $lessToggle.length <= 0) {
            // Field missing necessary components for size toggling.
            return;
        }

        $moreToggle.click(function() {
            $field.removeClass('less').addClass('more');
            $view.css('max-height', '');
        });
        $lessToggle.click(function() {
            $field.removeClass('more').addClass('less');
            $view.css('max-height', lessHeight + 'px');
        });
    });
};

function checkForSizeToggling($toggleableFields) {
    $.each($toggleableFields, function(index, field) {
        var $field = $(field);
        var lessHeight = $field.data('less-height');
        var $content = $field.find('.content');
        var $toggles = $field.find('.size-toggles');
        if (!lessHeight || $content.length <= 0 || $toggles.length <= 0) {
            // Field missing necessary components for size toggling.
            return;
        }

        if ($content.height() <= lessHeight) {
            $toggles.hide();
        } else {
            $toggles.show();
        }
    });
};
