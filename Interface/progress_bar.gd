extends Control

var max_value = 100

func initialize(max_val):
	max_value = max_val
	$TextureProgress.max_value = max_value
#endfunc

func on_change_amount(current):
	animate_value($TextureProgress.value, current)
	$TextureRect/Label.set_text("%s" % current)
#endfunc

func animate_value(start, end):
	$Tween.interpolate_property($TextureProgress, "value", start, end, 1.0, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()
#endfunc

var is_going_up = false

func _on_Timer_timeout():
	var val = $TextureProgress.value

	var delta = int(rand_range(1.0, 10.0))

	if is_going_up:
		val += delta
		if val > 99:
			is_going_up = false
	else:
		val -= delta
		if val < 1:
			is_going_up = true

	on_change_amount(val)
