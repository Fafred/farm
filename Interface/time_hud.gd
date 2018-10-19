extends Control

enum DAY_SEGMENT { DAWN, DAY, SUNSET, NIGHT }
enum WEATHER { FINE, CLOUDS, OVERCAST, RAIN }

onready var fine_dawn = "res://Assets/timeandweather_00.png"
onready var fine_day = "res://Assets/timeandweather_01.png"
onready var fine_sunset = "res://Assets/timeandweather_02.png"
onready var fine_night = "res://Assets/timeandweather_03.png"

onready var cloudy_dawn = "res://Assets/timeandweather_04.png"
onready var cloudy_day = "res://Assets/timeandweather_05.png"
onready var cloudy_sunset = "res://Assets/timeandweather_06.png"
onready var cloudy_night = "res://Assets/timeandweather_07.png"

onready var overcast_dawn = "res://Assets/timeandweather_08.png"
onready var overcast_day = "res://Assets/timeandweather_09.png"
onready var overcast_sunset = "res://Assets/timeandweather_10.png"
onready var overcast_night = "res://Assets/timeandweather_11.png"

onready var rain_dawn = "res://Assets/timeandweather_12.png"
onready var rain_day = "res://Assets/timeandweather_13.png"
onready var rain_sunset = "res://Assets/timeandweather_14.png"
onready var rain_night = "res://Assets/timeandweather_15.png"

onready var paths = [ [ fine_dawn, fine_day, fine_sunset, fine_night ], [ cloudy_dawn, cloudy_day, cloudy_sunset, cloudy_night ], [ overcast_dawn, overcast_day, overcast_sunset, overcast_night ], [ rain_dawn, rain_day, rain_sunset, rain_night ] ]

func _ready():
	CLOCK.connect("time_changed", self, "_on_time_changed")
#endfunc

func on_environment_change(environment):
	var hour = environment["h"]
	var minute = environment["m"]
	var day_segment = environment["day_segment"]
	var weather = environment["weather"]

	var path = paths[weather][day_segment]
	var texture = load(path)

	$weather_icon.texture = texture

	$background/label_time.set_text("%02d:%02d" % [hour, minute])
#endfunc


var temp_time = 0
var temp_weather = 0
var hour = 0
var minute = 0

func _on_time_changed():
	# _on_time_changed
	#	Called when the CLOCK emits the time_changed signal.  Updates the HUD
	#		clock to display the current time.

	var hour = CLOCK.get_hour()
	var minute = CLOCK.get_minute()
	var temp_time = DAY_SEGMENT.DAY
	var weather = 0

	if hour < 5 or hour > 22:
		temp_time = DAY_SEGMENT.NIGHT
		weather = randi() % 4
	elif hour > 4 and hour < 8:
		temp_time = DAY_SEGMENT.DAWN
		weather = randi() % 4
	elif hour > 19 and hour < 23:
		temp_time = DAY_SEGMENT.SUNSET
		weather = randi() % 4

	if minute % 10 == 0:
		on_environment_change({"h": hour, "m": minute, "day_segment": temp_time, "weather": temp_weather})
