extends Control

onready var inv_square_scene = preload("res://Interface/inventory_square.tscn")

var rows = 0
var columns = 0

func _ready():
	initialize(Vector2(8, 1))


func initialize(size):
	var columns = size.x
	var rows = size.y

	$GridContainer.columns = columns

	for y in range(0, rows):
		for x in range(0, columns):
			var inv_square = inv_square_scene.instance()

			$GridContainer.add_child(inv_square)

			print("(%s,%s" % [x, y])

	self.rect_size = $GridContainer.rect_size