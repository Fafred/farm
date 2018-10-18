extends TextureRect

#export(Vector2) var cells = Vector2(2, 2) setget set_size, get_size
export(int) var cell_size = 64
export(Texture) var empty_slot_texture = null

onready var empty_slot_button = preload("res://Interface/inventory/emptyslot_TextureButton.tscn")

var slots = { }
var _inv = null
var _inv_version = null

func _ready():
	pass

func connect_to_inventory(inv):
	if inv == null:
		return false
	#endif

	_inv = inv

	_inv.connect("inventory_changed", self, "_on_inventory_changed")
	load_inventory()
	return true

func load_inventory():
	# connect_to_inventory
	#   Clears all its information and then connects this ui to a game inventory.
	#     Sets the size, creates the slots, and reads in the items.
	#
	# _arguments_
	# inv:    a node with an inventory.gd script attached.
	#
	# _returns_
	# true:   if successfully connected
	# false:  if it couldn't connect to the node.

	# Clear out all the current information, if any.

	if _inv == null:
		return false
	#endif

	if _inv_version == _inv._version:
		print("Skipped load - versions match.")
		return

	slots = { }

	for child in self.get_children():
		child.queue_free()
	#endfor

	# Create the base ui of the inventory.
	var size = _inv.get_size()
	var shape = _inv.get_shape()

	self.rect_min_size = Vector2(size.x * cell_size, size.y * cell_size)

	for y in range(0, size.y):
		for x in range(0, size.x):
			if shape[int(x) + int(size.x * y)] == false:
				continue
			#endif
			var slot_pos = Vector2(x, y)
			var local_pos = Vector2(x * cell_size, y * cell_size)

			var new_slot = empty_slot_button.instance()

			# Set the background texture for this slot.
			if empty_slot_texture != null:
				var text_rect = TextureRect.new()
				text_rect.texture = empty_slot_texture
				self.add_child(text_rect)
				text_rect.set_position(local_pos)

			# Add the button, then tell it to load the graphic for the item
			#	if there is one in that slot.
			slots[new_slot] = slot_pos
			self.add_child(new_slot)
			new_slot.set_position(local_pos)
			new_slot.connect("attempt_swap", self, "_on_attempt_swap")

			var item_uuid = _inv.get_item_at(slot_pos)

			if item_uuid != null:
				new_slot.load_item(item_uuid, cell_size, _inv)
			#endif
		#endfor
	#endfor
	_inv_version = _inv._version
#endfunc

func _on_attempt_swap(item_a, item_b):
	var item_b_pos = item_b.get_position()
	var slot = Vector2(item_b_pos.x / cell_size, item_b_pos.y / cell_size)

	_inv.attempt_move(item_a.item_uuid, slot, item_a.get_parent()._inv, item_b.get_parent()._inv)
#endfunc

func _on_inventory_changed(inv):
	load_inventory()
#endfunc