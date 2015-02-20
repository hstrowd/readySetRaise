//= require pickdate/picker
//= require pickdate/picker.date
//= require pickdate/picker.time
//= require pickdate/legacy

var convertToLocalTime = function(cssSelector) {
    var $timeEls = $(cssSelector);
    $timeEls.each(function(index, timeHtml) {
        var $timeEl = $(timeHtml);
        if (!$timeEl || ($timeEl.children('.date').length > 0)) { return; }
        var isoString = $timeEl.text();

        var dateTimeStrings = isoToLocalStrings(isoString);

        if (dateTimeStrings) {
            $timeEl.html('<div class="date">' + dateTimeStrings[0] + '</div> ' +
                         '<div class="time"> at ' + dateTimeStrings[1] + '</div>');
        } else {
            $timeEl.text('TBD');
        }
    });
    return $timeEls;
};

var initDateTimeField = function (model, field, options) {
    var curDate = new Date();
    var options = $.extend(options, {
        defaultDate: (curDate.getMonth() + 1) + "/" + curDate.getDate() + "/" + curDate.getFullYear(),
        defaultTime: '12:00 PM',
        datePicker: {
            format: 'mm/dd/yyyy'
        },
        timePicker: {
          editable: false,
          format: 'h:i A',
          min: [00,00]
        }
    });

    // Updates the display fields to reflect the underlying raw date/time value.
    var updateDisplayTime = function(model, field, opts) {
        var curDate = new Date();
        var options = $.extend(opts, {
            defaultDate: (curDate.getMonth() + 1) + "/" 
                + curDate.getDate() + "/" 
                + curDate.getFullYear(),
            defaultTime: '12:00 PM'
        });

        var rawField = $('#' + model + '_' + field + '_time');
        var dateField = $('#date_' + field);
        var timeField = $('#time_' + field);

        var rawDate = new Date();
        var dateTimeStrings = isoToLocalStrings(rawField.val());
        if (dateTimeStrings) {
            dateField.val(dateTimeStrings[0]);
            timeField.val(dateTimeStrings[1]);
        } else {
            dateField.val(options.defaultDate);
            timeField.val(options.defaultTime);
        }
    };
    updateDisplayTime(model, field);

    $( '#date_' + field ).pickadate(options.datePicker);
    $( '#time_' + field ).pickatime(options.timePicker);


    // Update the underlying date/time value every time the composite values change.
    var updateRawTime = function(model, field) {
        return function(event) {
            var dateField = $('#date_' + field);
            var timeField = $('#time_' + field);
            var rawField = $('#' + model + '_' + field + '_time');
            var dateValue;
            
            var dateString = dateField.val();
            var dateCheck = /^\d{1,2}\/\d{1,2}\/\d{2,4}$/
            if (!dateCheck.test(dateString)) {
                dateString = null;
                dateField.val(options.defaultDate);
            } else {
                dateValue = new Date(Date.parse(dateString));
            }
          
            var timeString = timeField.val();
            var timeCheck = /^[0-1]?[0-9]:[0-5][0-9] (am|pm|AM|PM)$/;
            if (!timeCheck.test(timeString)) {
                timeField.val(options.defaultTime);
            } else if (dateString) {
                dateValue = new Date(Date.parse(dateString + " " + timeString));
            }
          
            if (dateValue) {
                rawField.val(dateValue.toISOString());
                rawField.trigger('change')
            }
        };
    };
    $( '#date_' + field ).change(updateRawTime(model, field));
    $( '#time_' + field ).change(updateRawTime(model, field));

    $( '#' + model + '_' + field + '_time' ).change(function(e) { 
        updateDisplayTime(model, field);
    });

    // Ensure the underlying raw datetime values are up to date with the displayed composite values.
    updateRawTime(model, field)();
};


var maintainChronologicalOrder = function(model, earlierField, laterField) {
    var $early = $('#' + model + '_' + earlierField + '_time');
    var $later = $('#' + model + '_' + laterField + '_time');

    var syncDates = function(fieldToKeep) {
        return function (event) {
            var earlyDate = new Date(Date.parse($early.val()));
            var laterDate = new Date(Date.parse($later.val()));

            if (earlyDate > laterDate) {
                if (fieldToKeep == 'early') {
                    $later.val($early.val());
                    $later.trigger('change');
                } else {
                    $early.val($later.val());
                    $early.trigger('change');
                }
            }
        };
    };

    $early.change(syncDates('early'));
    $later.change(syncDates('later'));
};
