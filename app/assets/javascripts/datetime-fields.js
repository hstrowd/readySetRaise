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
          editable: true,
          format: 'h:i A',
          min: [8,00]
        }
    });

    // Set the initial composite datetime values based on the raw value.
    var initCompositeDateTimeFields = function(model, field, opts) {
        var curDate = new Date();
        var options = $.extend(opts, {
            defaultDate: (curDate.getMonth() + 1) + "/" + curDate.getDate() + "/" + curDate.getFullYear(),
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
    initCompositeDateTimeFields(model, field);

    $( '#date_' + field ).pickadate(options.datePicker);
    $( '#time_' + field ).pickatime(options.timePicker);


    // Update the raw datetime value every time the composite values change.
    var updatePledgeTime = function(model, field) {
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
            }
        };
    };
    // TODO: Update the end date/time if needed when the start time is modifed to be after the current end time..
    $( '#date_' + field ).change(updatePledgeTime(model, field));
    $( '#time_' + field ).change(updatePledgeTime(model, field));

    // Ensure the underlying raw datetime values are up to date with the displayed composite values.
    updatePledgeTime(model, field)();
};
