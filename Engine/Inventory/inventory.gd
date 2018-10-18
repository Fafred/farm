#### inventory.gd ####
#### 10/16/18
####
#### Script which handles Diablo-style "Tetris" inventories.  Inventories can be
####	custom shapes, and and have "slots" which items fill.  When items are
####	added to the inventory they must go in an empty slot, or if they're
####	coming from	another inventory the item in the slot they're attempting to
####	store must be able to be "swapped" with the incoming item.

extends Node

### SIGNALS ###
signal inventory_changed	# Emitted whenever there's any change in this inventory, eg, its shape changes, or an item is moved.  	passes: inventory obj
signal item_inserted		# Emitted when an item is inserted into this inventory.													passes: inventory obj, item
signal item_moved			# Emitted when an item moves, either within this inventory or from this one into another one.			passes:	inventory obj, item
signal item_removed			# Emitted when an item is removed from the inventory.													passes: inventory obj, item

### EXPORTS ###
export(Vector2) var size = Vector2(2, 2) setget set_size, get_size		# Defines the rectangle size of this inventory.
export(Array) var shape = [] setget set_shape, get_shape				# Defines which slots allow items to be placed in them.  If empty or null, then the entire rectangle is used.

var uuid = 0

### PRIVATE ###
var _slot_contents = []		# When an item is placed into the inventory, references to it are stored in the slots it takes up.
var _items = { }			# Key: item uuids of items in the inventory.  Value: The Vector2 position of the items.
var _version = 0

func _ready():
	#TESTING_run_tests()
	pass
#endfunc

func has(item):
	# has
	#		Checks if the given item is contained within this inventory.
	#
	# _arguments_
	#	item:		an item uuid
	#
	# _returns_
	#	true:		item is contained in this inventory.
	#	false:		item is not contained in this inventory.

	return _items.keys().has(item)
#endfunc

func get_item_at(slot):
	# get_item_at
	#		Returns the item, if any, which is taking up a particular inventory
	#			slot.
	#
	# _arguments_
	#	slot:		 Vector2 of the slot's pos.
	#
	# _returns_
	#	item:		uuid of item at slot.
	#	null:		no item at slot, or slot out of the inventory's bounds.

	if typeof(slot) != TYPE_VECTOR2:
		return null
	#endif

	if slot.x < 0 or slot.x >= size.x or slot.y < 0 or slot.y >= size.y:
		return null
	#endif

	return _slot_contents[_vec2toindex(slot)]

func get_item_pos(item):
	# get_item_pos
	#		Returns the Vector2 position of the slot the item is in.
	#
	# _arguments_
	#	item:		the uuid of the item to retrieve the pos of.
	#
	# _returns_
	#	Vector2:	the position of the item, if it's in the inventory.
	#	null:		if the item is not in the inventory

	if not self.has(item):
		return null
	#endif

	return _items[item]
#endfunc

func get_items():
	# get_items
	#		Returns a list of items in this inventory.
	#
	# _returns_
	#	Array:		array of item ids of items contained in this inventory

	return _items.keys()

func attempt_insert(item, slot = null):
	# attempt_insert
	#		attempts to insert an item into the inventory at the given slot.
	#		If the slot is null, then it will attempt to insert it at the
	#		first available slot.  Returns true if successful, otherwise
	#		false.
	#
	# _arguments_
	# 	item:		an item uuid
	# 	slot:		Vector2 pos where to place the item in the inventory,
	#				if null then it will attempt to fit the item into the first
	#				available location.
	#
	# _returns_
	#	true:		item was successfully inserted into the inventory.
	#	false:		item could not be inserted into inventory.
	#
	# _signals_
	#	inventory_changed	:	if successful
	#	item_inserted		:	if successful

	var commit_insert = false

	if slot == null:
		for y in range(0, size.y):
			for x in range(0, size.x):
				if can_insert(item, Vector2(x, y)):
					commit_insert = true
					break
				#endif
			#endfor
			if commit_insert == true:
				break
			#endif
		#endfor
	else:
		if can_insert(item, slot):
			commit_insert = true
		else:
			return false

	if commit_insert == false:
		return false

	# Make sure this item is first removed from this inventory if it's here.
	remove_item(item)
	_place_item(item, slot)

	_version += 1

	emit_signal("inventory_changed", self)
	emit_signal("item_inserted", self, item)
	return true
#endfunc

func can_insert(item, slot):
	# can_insert
	#		Checks if it's possible to insert an item into the inventory
	#		at the given slot.  If slot is null, then it checks if it
	#		will fit anywhere in the inventory.  Returns true if it's
	#		possible to fit, otherwise no.
	#
	# _arguments_
	#	item:		the item uuid of the item to test insertion
	#	slot:		Vector2 pos indicating where to test if the item can
	#				be inserted.  If null it will test if there is any location
	#				in the inventory where it can be inserted.
	#
	# _returns_
	#	true:		item can be inserted at the given slot, if any
	#	false:		item cannot be inserted at given slot, or at all if slot was null

	# TODO: Need to check if item is a uuid

	var index = _vec2toindex(slot)

	if index == null:
		# This will only happen if slot isn't a Vector2 or is a position out of bounds
		#	of the inventory.
		return false

	# Check if there's an item currently in that slot.
	if _slot_contents[index] != null:
		return false

	# Check if slot is placable.
	if shape[index] != true:
		return false

	# TODO: Adjust for different item sizes/shapes.

	return true
#endfunc

func attempt_move(item, slot, from_inventory = self, target_inventory = self):
	# attempt_move
	#		Attempts to move an item in this inventory to the specified
	#		slot in a target inventory.  Returns true if successful, false otherwise.
	#
	# _arguments_
	#	item:		the item uuid of the item to attempt to move
	#	slot:		Vector2 of the position to attempt to move the item to
	#
	# _returns_
	#	true:		move was successful
	#	false:		move was not successful
	#
	# _signals_
	#	inventory_changed	:	if successful
	#	item_moved			:	if successful

	if not from_inventory.has(item):
		print("I don't have the item to give...")
		return false

	if target_inventory.can_insert(item, slot):
		if from_inventory.remove_item(item):
			if not target_inventory.attempt_insert(item, slot):
				return false
	#endif
	else:
		var current_pos = from_inventory.get_item_pos(item)
		var blocking_item = target_inventory.get_item_at(slot)
		var blocking_item_pos = target_inventory.get_item_pos(blocking_item)

		if not target_inventory.remove_item(blocking_item):
			return false
		#endif

		if not from_inventory.remove_item(item):
			target_inventory.insert_item(blocking_item, blocking_item_pos)
			return false
		#endif

		var result = false

		if target_inventory.can_insert(item, slot) and from_inventory.can_insert(blocking_item, current_pos):
			result = from_inventory.attempt_insert(blocking_item, current_pos) and target_inventory.attempt_insert(item, slot)
		#endif

		if result == false:
			# Something went horribly wrong... but what?  Return everything to its original state... hopefully.
			if target_inventory.has(item) or self.has(item):
				target_inventory.remove_item(item)
				from_inventory.remove_item(item)
			if target_inventory.has(blocking_item) or self.has(blocking_item):
				target_inventory.remove_item(blocking_item)
				from_inventory.remove_item(blocking_item)

			target_inventory.attempt_insert(blocking_item, blocking_item_pos)
			from_inventory.attempt_insert(item, current_pos)
			return false
		#endif

	_version += 1

	emit_signal("inventory_changed", self)
	emit_signal("item_moved", self, item)

	return true
#endfunc

#func can_move(item, slot):
#	# can_move
#	#		Tests if an item can move to that a particular spot in the inventory.
#	#
#	# _arguments_
#	#	item:		the item uuid of the item to test validity of move
#	#	slot:		the slot to test
#	#
#	# _returns_
#	#	true:		the item can move to the selected spot.
#	#	false:		the item cannot move to the selected spot.
#	pass

func remove_item(item):
	# remove_item
	#		Removes an item from the inventory.  Returns true if successful, false otherwise
	#
	# _arguments_
	#	item:		item to remove
	#
	# _returns_
	#	true:		item was removed
	#	false:		item was not removed
	#
	# _signals_
	#	inventory_changed	:	if successful
	#	item_removed		:	if successful

	var item_found = false

	if _items.has(item):
		_items.erase(item)
		item_found = true

	for i in range(0, _slot_contents.size()):
		if _slot_contents[i] == item:
			_slot_contents[i] = null
			item_found = true
		#endif
	#endfor

	if not item_found:
		return false
	#endif

	_version += 1

	emit_signal("inventory_changed", self)
	emit_signal("item_removed", self, item)

	return true
#endfunc

func get_shape():
	# get_shape
	#	Returns the "shape" of the inventory - an array of boolean values with a size
	#	equal to size.x * size.y of the inventory.  Indices with a value of true indicate
	#	cells where items may be placed, where indices with a value of false indicate
	#	that items cannot be placed there.
	#
	#	_returns_
	#	Array[bool]	: an array of boolean values, true = item can be placed in that slot,
	#					false = item cannot be placed in that slot
	var ret_arr = []

	if typeof(shape) == TYPE_ARRAY and shape.size() > 0:
		for i in range(0, shape.size()):
			ret_arr.append(shape[i])
		#endfor
	else:
		for i in range(0, size.x * size.y):
			ret_arr.append(true)
		#endfor
	#endif/else

	return ret_arr
#endfunc

func set_shape(new_shape):
	# set_shape
	#	Sets the "shape" of the inventory.  The array represents the
	#	inventory slots, where values of true indicate items can be placed
	#	there, while values of false indicate that items cannot be placed
	#	in that slot.  This will allow customizing the shape of the inventory.
	#
	#   Setting the shape of an inventory with items already in it will not
	#		affect the location of those items, even if they're now in slots
	#		which are not marked for allowable placement.
	#
	# _arguments_
	#	new_shape : array of boolean values.  The size of the array must equal
	#				the size of the inventory (size.x * size.y), or null,
	#				or 0.  In the case of null or 0, the inventory is
	#				considered to allow placement of items in every possible slot.
	#
	# _returns_
	#	true:	shape was successfully set.
	#	false:	shape not successfully set.
	#
	# _signals_
	#	inventory_changed	:	if successfully set.
	if typeof(new_shape) != TYPE_ARRAY and new_shape != null:
		return false
	#endif

	if new_shape == null or new_shape.size() == 0:
		shape = []
		for i in range(0, size.x * size.y):
			shape.append(true)
		#endfor
	elif new_shape.size() != (self.size.x * self.size.y) and new_shape.size() != 0:
		return false
	else:
		shape = []
		for i in range(0, new_shape.size()):
			if typeof(new_shape[i]) == TYPE_BOOL:
				shape.append(new_shape[i])
			elif new_shape[i] == 0:
				shape.append(false)
			else:
				shape.append(true)
			#endifelse
		#endfor
	#endif/else

	_version += 1

	emit_signal("inventory_changed", self)

	return true
#endfunc


func get_size():
	# get_size
	#		Getter for local variable size
	#
	# _returns_
	# Vector2:	the size of the inventory
	return Vector2(size.x, size.y)
#endfunc

func set_size(vec2):
	# set_size
	#		Setter for local variable size.
	#
	#		Setting the size will erase item contents and the shape.
	#
	# _arguments_
	#	vec2:	Vector2 representing the size of the inventory's rectangle
	#
	# _returns_
	#	true:	size was successfully set.
	#	false:	size was not set
	#
	# _signals_
	#	inventory_changed	:	if size is successfully set.
	if vec2.x < 0 or vec2.y < 0:
		return false
	#endif

	size.x = vec2.x
	size.y = vec2.y

	self.shape = []

	for i in range(0, size.x * size.y):
		_slot_contents.append(null)

	_version += 1

	emit_signal("inventory_changed", self)

	return true
#endfunc

### HELPERS ###
func _place_item(item, slot):
	# _place_item
	#	This is the helper function to actually add an item to the inventory.
	#		Should only be used within this class, never called from outside
	#		the class.
	#
	# _arguments_
	#	item:	item uuid of item to place.
	#	slot:	Vector2 of where the item is in the inventory.
	#
	# _returns_:
	#	true:	item successfully added
	#	false:	unable to add item

	if not can_insert(item, slot):
		return false

	_items[item] = slot

	# TODO: code for different sizes of items.
	var index = _vec2toindex(slot)
	_slot_contents[index] = item
	return true
#endfunc

func _vec2toindex(vec2):
	# vec2toindex
	#	Takes a Vector2 and returns the appropriate index for inventory.
	#
	# _arguments_
	#	vec2:	Vector2 position in the inventory.
	#
	# _returns_
	#	null:	if the position was out of bounds of the inventory's size, or
	#				if vec2 isn't of type Vector2
	#	int:	otherwise, returns the index.

	# vec2 needs to be a Vector2.
	if typeof(vec2) != TYPE_VECTOR2:
		return null
	#endif

	# slot must be within bounds of inventory size.
	if vec2.x < 0 or vec2.x >= size.x or vec2.y < 0 or vec2.y >= size.y:
		return null
	#endif

	var index = vec2.x + (vec2.y * size.x)

	# TODO : more sanity checking.

	return int(index)
#endfunc

### TESTING ###
func TESTING_run_tests():
	self.set_size(Vector2(3,3))
	print(str(self.get_size()))

#	TESTING_set_shape()
#	TESTING_add_items()
#	TESTING_move_items()


#endfunc

func TESTING_move_items():
	print("Testing move_item\n-----------------------------------")
	var items = [ ]
	TESTING_print_contents()
	randomize()

	for i in range(0, int(size.x)):
		var item = randi()
		var pos = Vector2(i, randi() % int(size.y))
		items.append([item, pos])
		self.attempt_insert(items[i][0], items[i][1])

	TESTING_print_contents()

	for i in range(0, items.size()):
		self.attempt_move(items[i][0], items[randi()%items.size()][1])

	TESTING_print_contents()

	for i in range(0, items.size()):
		for ii in range(0, 5):
			var slot = Vector2(randi() % int(size.x), randi() % int(size.y))
			self.attempt_move(items[i][0], slot)

	TESTING_print_contents()

func TESTING_add_items():
	TESTING_print_contents()
	TESTING_insert_item()
	TESTING_print_contents()
	print("Attempting to add multiple items...")
	for i in range(0, 4):
		TESTING_insert_item()
	TESTING_print_contents()

	var item_uuids = _items.keys()
	var num_of_items = item_uuids.size()

	for i in range(0, num_of_items):
		print("\tRemoving item 1 of " + str(num_of_items) + ".  Item #" + str(item_uuids[i]) + " (true): " + str(TESTING_remove_item(item_uuids[i])))
		TESTING_print_contents()
#endfunc

func TESTING_set_shape(vec2 = null):
	if vec2 == null:
		vec2 = Vector2(size.x, size.y)
	#endif

	print("Setting bad shape (false): " + str(self.set_shape([false, false, true, true])))
	print("Setting bad shape (false): " + str(self.set_shape("test")))
	print("Changing size to " + str(vec2.x) + "x" + str(vec2.y) + " (true): " + str(self.set_size(vec2)))
	print("Setting good shape (true): " + str(self.set_shape([false, true, true, true, true, true])))
	TESTING_print_shape()

	print("Setting shape to empty (true): " + str(self.set_shape([])))
	TESTING_print_shape()

	print("Zeroing out shape (true): " + str(self.set_shape([false, false, false, false, false, false])))
	TESTING_print_shape()

	print("Setting shape to null (true): " + str(self.set_shape(null)))
	TESTING_print_shape()
#endfunc

func TESTING_print_shape():
	print("Printing shape: " + str(shape))
	for y in range(0, size.y):
		var row = []
		for x in range(0, size.x):
			row.append(shape[x + (size.x * y)])
		#endfor
		print("\t" + str(row))
		row.clear()
#endfunc

func TESTING_print_contents():
	print("Contents:")
	for y in range(0, size.y):
		var row = []
		for x in range(0, size.x):
			row.append(_slot_contents[_vec2toindex(Vector2(x, y))])
		printt(row)
	#endfor
#endfunc

func TESTING_insert_item(vec2 = null):
# TESTING_insert_item
#	Attempts to place a dummy item in the inventory at the given, if any, location.
#
# _arguments_
#	vec2:	Vector2 position of where to attempt it.  If no argument is passed then
#				it will attempt to insert the dummy item at a random location.
#
# _returns_
#	Array:	[ boolean result, item#, Vector2 position]
	var item = randi()

	if vec2 == null:
		vec2 = Vector2(randi() % int(size.x), randi() % int(size.y))
	#endif

	var result = attempt_insert(item, vec2)

	print("Attempting to place " + str(item) + " at " + str(vec2) + ": " + str(result))
	return [ result, item, vec2 ]
#endfunc

func TESTING_remove_item(item = null):
# TESTING_remove_item
#	Tests if an item is removed from the inventory.  If argument is left null, it will remove
#		a random item.
#
# _arguments_
#	item:	item uuid of the item to remove.  If null it will pick a random item.
#
# _returns_
#	true:	item was successfully removed
#	false:	item was not removed
	if item == null:
		var keys = _items.keys()

		item = keys[randi() % keys.size()]
	#endif

	var result = remove_item(item)

	if _items.keys().has(item):
		result = false

	for i in range(0, _slot_contents.size()):
		if _slot_contents[i] == item:
			result = false
		#endif
	#endfor

	return result
#endfunc