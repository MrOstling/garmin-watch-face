import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class WatchFaceView extends WatchUi.WatchFace {
    var fontLg;
    var font;
    var TWO_PI = Math.PI * 2;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        fontLg = WatchUi.loadResource( Rez.Fonts.BalineLg );
        font = WatchUi.loadResource( Rez.Fonts.Baline );
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        if(dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        //digitalClock(dc);
        View.onUpdate(dc);
        drawTicks(dc);
        analogClock(dc);
    }

    function analogClock(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour;
        var minute = clockTime.min;
        var hourFraction = minute / 60.0;
        var minutesAngle = hourFraction * TWO_PI;
        var hoursAngle = (((hour % 12) / 12.0) + (hourFraction / 12.0)) * TWO_PI;
        dc.setColor(getApp().getProperty("ForegroundColor") as Number, Graphics.COLOR_TRANSPARENT);
        drawHand(dc, hoursAngle, 80, 5);
        drawHand(dc, minutesAngle, 118, 3);
    }

    function drawHand(dc, angle, length, width) {
        // Map out the coordinates of the watch hand
        var coords = [ [-(width/2), -10], [-(width/2), -length], [width/2, -length], [width/2, -10] ];
        drawRotatedPolygon(dc, angle, coords);
    }

    function drawTick(dc, angle, length, width){
        var coords = [ [-(width/2),-119+length], [-(width/2), -119], [width/2, -119], [width/2, -119+length] ];
        drawRotatedPolygon(dc, angle, coords);
    }

    function drawTicks(dc){
        for (var i = 0; i < 12; i += 1){
            drawTick(dc, i*TWO_PI/12, 20, 3);
        }
    }

    function drawRotatedPolygon(dc, angle, poly) {
        var result = new [poly.size()];
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);
        for (var i = 0; i < poly.size(); i += 1){
            var x = (poly[i][0] * cos) - (poly[i][1] * sin);
            var y = (poly[i][0] * sin) + (poly[i][1] * cos);
            result[i] = [centerX+x, centerY+y];
        }
        dc.fillPolygon(result);
    }

    function digitalClock(dc as Dc) as Void {
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (getApp().getProperty("UseMilitaryFormat")) {
                timeFormat = "$1$$2$";
                hours = hours.format("%02d");
            }
        }
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);
        var time = View.findDrawableById("TimeLabel") as Text;
        time.setColor(getApp().getProperty("ForegroundColor") as Number);
        time.setFont(fontLg);
        time.setText(timeString);
    }

    function date(dc as Dc) as Void {
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_LONG);
        var dateString = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.month, info.day]);
        var date = View.findDrawableById("DateLabel") as Text;
        date.setColor(getApp().getProperty("ForegroundColor") as Number);
        date.setFont(font);
        date.setText(dateString);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
