// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

//= require datetime-fields
//= require mustache.min
//= require countdown.min

var setupCountdown = function(outputSelector, time) {
    var $outputField = $(outputSelector);
    if (!$outputField.length) { return; }

    var date = new Date(time);
    var countdownUnits = (countdown.DAYS|countdown.HOURS|countdown.MINUTES|countdown.SECONDS);
    if (isNaN(date.getTime())) { return; }
    $outputField.text(countdown(date, null, countdownUnits).toString());
    setInterval(function() {
        $outputField.text(countdown(date, null, countdownUnits).toString());
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

    var chartContainer = $('#chart-pledge-breakdown');
    if (hasNewPledges || !chartContainer.children().length) {
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

        // Ensure two decimal places are always shown.
        pledge.full_amount = pledge.amount.toFixed(2);
        pledge.dollar_amount = Math.round(pledge.amount);
        pledge.amount_class = (pledge.monthly && 'monthly') || '';

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
    var progressBarWidth = Math.min(100, pctComplete);
    $progressBar.animate({width: progressBarWidth + '%'});
    var $progressLabel = $progressBar.find('.label');
    if ($progressLabel.length) { $progressLabel.text(pctComplete + '%'); }
};


var rotateTab = function() {
    var $tabs = this.children('.tabs');
    var $selectedTab = $tabs.children('.tab.selected');

    var $nextTab = null;
    if ($selectedTab.length) {
        var currentIndex = $selectedTab.data('index');
        var $nextTabByIndex = $tabs.children('.tab-' + (currentIndex + 1));
        if ($nextTabByIndex.length) {
            $nextTab = $($nextTabByIndex[0]);
        }
    }

    if (!$nextTab || !$nextTab.length) {
        $nextTab = $tabs.children('.tab-0');
    }

    if ($nextTab.length) {
        activateTab($nextTab, this);
    }
};

var autoRotateTimer = null;
var autoRotateTabSelector = '#event-dashboard .event-details .tabs .tab.button';
var ROTATION_INTERVAL_SECONDS = 30;

var deactivateRotationButton = function() {
    var $rotationTab = $(autoRotateTabSelector);
    $rotationTab.removeClass('pressed');
};
var activateRotationButton = function() {
    var $rotationTab = $(autoRotateTabSelector);
    var isPressed = $rotationTab.hasClass('pressed');
    if (!isPressed) {
        $rotationTab.addClass('pressed');
    }
};
var toggleAutoRotate = function($parentPanel) {
    if (autoRotateTimer) {
        disableAutoRotate($parentPanel);
    } else {
        enableAutoRotate($parentPanel);
    }
};
var enableAutoRotate = function($parentPanel) {
    autoRotateTimer = setInterval($.proxy(rotateTab, $parentPanel),
                                  ROTATION_INTERVAL_SECONDS * 1000);
    activateRotationButton();

    var $pledgeLogBody = $parentPanel.find('.pledge-log .tab-body .list');
    startAutoScroll($pledgeLogBody);
};
var disableAutoRotate = function($parentPanel) {
    if (autoRotateTimer) { clearTimeout(autoRotateTimer); }
    autoRotateTimer = null;
    deactivateRotationButton();

    var $pledgeLogBody = $parentPanel.find('.pledge-log .tab-body .list');
    stopAutoScroll($pledgeLogBody);
};

var setupTabs = function($parentPanel) {
    var $tabs = $parentPanel.children('.tabs');
    $tabs.children('.tab.panel').each(function (index, tab) {
        $(tab).click(function(e) {
            disableAutoRotate($parentPanel);
            activateTab($(this), $parentPanel);
        });
    });
};

var activateTab = function($tab, $parentPanel) {
    $tab.parent().children('.tab').removeClass('selected');
    $tab.addClass('selected');

    var selectedTab = $tab.data('tab');
    $parentPanel.children('.tab-container').removeClass('selected');
    $parentPanel.children('.tab-container.' + selectedTab).addClass('selected');

    $parentPanel.trigger('tabChange', selectedTab);
};




/**
 *  ==== Auto-Scrolling ====
 **/

var AUTO_SCROLL_PAUSE_MILLISECONDS = 1000;
var autoScrollTimer = null;
var autoScrollOn = false;
var autoScrollTimer = null;

var startAutoScroll = function($container) {
    if (autoScrollOn) { return; }
    autoScrollOn = true;
    $.proxy(autoScroll, $container)();
};
var stopAutoScroll = function($container) {
    autoScrollOn = false;
    clearTimeout(autoScrollTimer);
    $container.stop(true);
};
var resetAutoScroll = function($container) {
    if (!autoScrollOn) { return; }
    stopAutoScroll($container);
    $container.scrollTop(0);
    startAutoScroll($container);
};

var continueAutoScroll = function() {
    if (!autoScrollOn) { return };
    // Wait when the bottom or top is reached and then scroll back.
    autoScrollTimer = setTimeout($.proxy(autoScroll, this),
                                 AUTO_SCROLL_PAUSE_MILLISECONDS);
};
var autoScroll = function() {
    if (!autoScrollOn) { return };

    var endScrollPosition = (this[0].scrollHeight - this.height());
    // If it's already near the bottom, scroll back to the top.
    if (endScrollPosition - this.scrollTop() < 10) {
        endScrollPosition = 0;
    }
    var scrollDistance = Math.abs(this.scrollTop() - endScrollPosition);

    var animationOptions = {
        scrollTop: endScrollPosition
    };
    // Use a function of the scroll distance to ensure a consistent for short and long lists.
    var animationDurationMilliseconds = scrollDistance * 50;
    this.animate(animationOptions,
                 animationDurationMilliseconds,
                 'linear', // Don't ease the scroll in or out.
                 $.proxy(continueAutoScroll, this));
};
