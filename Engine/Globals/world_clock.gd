#### world_clock.gd
#### 10/18/18
####
#### Handles the in-game time and seasons.


extends Node

### EXTERNALS ###
export(float) var minute_length_in_seconds = 0.7 setget set_minute_length, get_minute_length
export(bool) var autostart = true setget set_autostart, get_autostart

### SIGNALS ###
signal minute_tick
signal hour_tick
signal day_tick
signal week_tick
signal month_tick
signal season_tick
signal year_tick

func _ready():
	$"Timer - Minute".wait_time = self.minute_length_in_seconds
	$"Timer - Minute".connect("timeout", self, "_on_timeout")
	pass

### SET GETS ###
func get_autostart():
	return autostart
#endfunc

func set_autostart(do_autostart):
	self.autostart = do_autostart
#endfunc

func get_minute_length():
	return self.minute_length_in_seconds
#endfunc

func set_minute_length(min_length_in_sec):
	if min_length_in_sec < 0:
		LOG.error(self, "set_minute_length", "Cannot set minute length to be less than 0.016 seconds.", {"min_length_in_sec" : min_length_in_sec })
		return false
	#endif

	self.minute_length_in_seconds = min_length_in_sec
	return true
#endfunc

func _on_timeout():
	pass
#endfunc
