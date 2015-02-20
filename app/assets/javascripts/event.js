// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

//= require datetime-fields
//= require mustache.min
//= require countdown.min

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


var setupAutoRefresh = function(eventID) {
    var runRefresh = function() {
        $.ajax({ url: '/events/' + eventID + '.json',
                 dataType: 'json',
                 success: function(data, textStatus, jqXHR) {
                     refreshEventDashboard(data);
                 },
                 error: function(jqXHR, textStatus, error) {
                     console.log("Error: " + textStatus);
                 } });
    };

    runRefresh();
    setInterval(runRefresh, 10000);
};

var refreshEventDashboard = function(eventData) {
    var $dashboard = $('#event-dashboard');
    if (!$dashboard.length) { return; }

    // Add new pledges to the pledge log.
    var hasNewPledges = updatePledgeLog($dashboard, eventData.pledges);

    if (hasNewPledges) {
        var libraryOpts = {
            xAxis: {
                labels: {
                    style: {
                        fontSize: "1.3em"
                    }
                }
            }
        };
        new Chartkick.ColumnChart("chart-pledge-breakdown", '/events/' + eventData.eventID + '/pledge-breakdown.json', { library: libraryOpts });
    }

    // Update the progress bar.
    updateProgressBar($dashboard, eventData.pledgeTotal, eventData.pledgeTarget);
};

var updatePledgeLog = function($dashboard, pledges) {
    var $pledgeLog = $dashboard.find(".event-details .pledge-log .list");
    if (!$pledgeLog.length) { return; }

    var hasNewPledges = false;
    for (var i = (pledges.length - 1); i >= 0; i--) {
        var pledge = pledges[i];
        var $existingRecord = $pledgeLog.find('div[data-pledge-id=' + pledge.pledgeID + ']');
        if ($existingRecord.length) { continue; }

        hasNewPledges = true;

        var template = $('#pledge-item').html();
        var $rendered = $(Mustache.render(template, pledge));
        $rendered.hide();
        $pledgeLog.prepend($rendered);
        $rendered.show(500);
    }

    return hasNewPledges;
};

var updateProgressBar = function($dashboard, pledgeTotal, pledgeTarget) {
    var $progressBar = $dashboard.find(".overall .progress-bar .pct-complete");
    if (!$progressBar.length) { return; }

    var pctComplete = 0;
    if (pledgeTarget > 0) {
        pctComplete = Math.round(pledgeTotal / pledgeTarget * 100);
    }
    $progressBar.animate({width: pctComplete + '%'});
    var $progressLabel = $progressBar.find('.label');
    if ($progressLabel.length) { $progressLabel.text(pctComplete + '%'); }
};
