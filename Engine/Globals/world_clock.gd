#### world_clock.gd
#### 10/18/18
####
#### Handles the in-game time and seasons.  Clock starts as soon as the in-game
####	time is set.


extends Node

### EXTERNALS ###
export(float) var minute_length_s = 0.7 setget set_minute_length_s, get_minute_length_s

### SIGNALS ###
signal minute_tick			# (minute value)	- Emitted when the minute changes
signal hour_tick			# (hour value)		- Emitted when the hour changes
signal day_tick				# (day value)		- Emitted when the day changes
signal month_tick			# (month value)		- Emitted when the month changes
signal year_tick			# (year value)		- Emitted when the year changes
signal time_changed			#					- Emitted when the time changes.

var _minute = null
var _hour = null
var _day = null
var _month = null
var _year = null

const MAX_DAYS_IN_MONTH = 30
const MAX_MONTHS_IN_YEAR = 4

func _ready():
	# TODO: FOR TESTING.
	self.set_time(0, 0, 1, 1, 0)
#endfunc

func get_minute():
	# get_minute
	#	Retrieves the current value of minute
	#
	# _returns_
	#	int:	current value of minute
	return _minute
#endfunc

func get_hour():
	# get_hour
	#	Retrieves the current value of hour
	#
	# _returns_
	#	int:	current value of hour
	return _hour
#endfunc

func get_day():
	# get_day
	#	Retrieves the current value of day
	#
	# _returns_
	#	int:	current value of day
	return _day
#endfunc

func get_month():
	# get_month
	#	Retrieves the current value of month
	#
	# _returns_
	#	int:	current value of month
	return _month
#endfunc

func get_year():
	# get_year
	#	Retrieves the current value of year
	#
	# _returns_
	#	int:	current value of year
	return _year
#endfunc

func get_minute_length_s():
	# get_minute_length
	#	Retrieves the real world amount of seconds per in-game minute.
	#
	# _returns_
	# float:	number of real world seconds per in-game minute.
	return minute_length_s
#endfunc

func pause():
	# pause
	#	Pauses the in-game clock.
	$"Timer - Minute".stop()
#endfunc

func set_minute_length_s(min_length_in_sec):
	# set_minute_length
	#		Sets the length of a minute in real world seconds.
	#
	# _arguments_
	#	min_length_in_sec:	float, number of seconds each in-game minute takes.
	#
	# _returns_
	#	true:	minute length successfully sent
	#	false:	minute length not set
	if min_length_in_sec < 0:
		LOG.error(self, "set_minute_length", "Cannot set minute length to be less than 0.016 seconds.", {"min_length_in_sec" : min_length_in_sec })
		return false
	#endif

	minute_length_s = min_length_in_sec
	return true
#endfunc

func set_time(mi, h, d, mo, y):
	# set_time
	#	Sets the current time and starts the timer.
	#
	# _arguments_ (must all be of type int)
	#	mi:		minute
	#	h:		hour
	#	d:		day
	#	mo:		month
	#	y:		year
	#
	# _returns_
	#	true:	time successfully set.
	#	false:	setting time unsuccessful.

	if typeof(mi) != TYPE_INT or typeof(h) != TYPE_INT or typeof(d) != TYPE_INT or typeof(mo) != TYPE_INT or typeof(y) != TYPE_INT:
		LOG.error(self, "set_time", "Incorrect type used as args.  All args must be of type int.",
					{	"type of mi" : typeof(mi), "value of mi": mi,
						"type of h" : typeof(h), "value of h": h,
						"type of d" : typeof(d), "value of d": d,
						"type of mo" : typeof(mo), "value of mo": mo,
						"type of y" : typeof(y), "value of y": y })
		return false
	#endif


	# Do some sanity checking.  If any of these values are outside the proper
	#	ranges, the clock is not set.

	var was_successful = true

	if mi < 0 or mi > 59:
		was_successful = false
		LOG.error(self, "set_time", "Value outside of range for argument mi. Must be: -1 > mi < 60.", {"value of mi" : mi})
	#endif

	if h < 0 or h > 23:
		was_successful = false
		LOG.error(self, "set_time", "Value outside of range for argument h.  Must be -1 > h < 24.", {"value of h" : h})
	#endif

	if d < 1 or d > MAX_DAYS_IN_MONTH:
		was_successful = false
		LOG.error(self, "set_time", "Value outside of range for argument d.  Must be 0 > d <= %s." % MAX_DAYS_IN_MONTH, {"value of d" : d})
	#endif

	if mo < 1 or mo > MAX_MONTHS_IN_YEAR:
		was_successful = false
		LOG.error(self, "set_time", "Value outside of range for argument mo.  Must be 0 > mo <= %s." % MAX_MONTHS_IN_YEAR, {"value of mo" : mo})
	#endif

	if y < 0:
		was_successful = false
		LOG.error(self, "set_time", "Value outside of range for argument y.  Must be y > -1.", {"value of y" : y})
	#endif

	if was_successful:
		_minute = mi
		_hour = h
		_day = d
		_month = mo
		_year = y

		# Start the timer.
		$"Timer - Minute".wait_time = get_minute_length_s()
		$"Timer - Minute".one_shot = false
		$"Timer - Minute".connect("timeout", self, "_on_timeout")

		$"Timer - Minute".start()
	#endif



	return was_successful
#endfunc

func start():
	# start
	#	If the clock has been paused, this will start it.
	$"Timer - Minute".start()
#endfunc

### SIGNAL HANDLING ###

func _on_timeout():
	# _on_timeout
	#	Called whenever the Timer ticks.  Sets the time and if any of the
	#		values has changed will emit the proper signal in descending order
	#		of value, year first and minute last.
	#
	# _signals_
	#	minute_tick(minute value):	minute value has changed.
	#	hour_tick(hour value):		hour value has changed
	#	day_tick(day value):		day value has changed
	#	month_tick(month value):	month value has changed
	#	year_tick(year value):		year value has changed
	#	time_changed:				time has changed.

	var do_hour_tick = false
	var do_day_tick = false
	var do_month_tick = false
	var do_year_tick = false

	_minute += 1

	if _minute > 59:
		_hour += 1
		_minute = 0
		do_hour_tick = true
	#endif

	if _hour > 23:
		_day += 1
		_hour = 0
		do_day_tick = true
	#endif

	if _day > MAX_DAYS_IN_MONTH:
		_month += 1
		_day = 1
		do_month_tick = true
	#endif

	if _month > MAX_MONTHS_IN_YEAR:
		_year += 1
		_month = 1
		do_year_tick = true
	#endif

	if do_year_tick:
		emit_signal("year_tick", _year)
	if do_month_tick:
		emit_signal("month_tick", _month)
	if do_day_tick:
		emit_signal("day_tick", _day)
	if do_hour_tick:
		emit_signal("hour_tick", _hour)
	emit_signal("minute_tick", _minute)
	emit_signal("time_changed")
#endfunc
