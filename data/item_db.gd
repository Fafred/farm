#### item_db.gd
#### 10/18/18
####	Database for the items.

extends Node

### KEYS ###
const KEY_ITEM_TEMPLATE = "item_template"

### SIGNALS ###
signal item_changed 			# (item_uuid, data_key) : item in the db has changed.


### PRIVATE ###
var _item_templates = { }
var _items = { }

var _name = "item_db.gd"

func create_item(template_uuid, data_dict):
	# create_item
	#	Creates an item, sets the item's template, and then stores the data
	#	given.
	#
	# _arguments_
	# template_uuid:	the uuid of the template the item uses.  If it's null,
	#					then when data is retrieved from the item it won't look
	#					up data from the template.
	# data_dict:		the dictionary representing all the data specific to
	#					this item.
	#
	# _returns_
	#	uuid:			the uuid of the item created.
	#	null:			data_dict wasn't a dictionary, or some other problem.
	#					The item wasn't created.

	if not typeof(data_dict) == TYPE_DICTIONARY:
		return null
	#endif

	var item_uuid = UUID.v4()

	_items[item_uuid] = data_dict

	if template_uuid != null:
		_items[item_uuid][KEY_ITEM_TEMPLATE] = template_uuid

		if not _item_templates.has(template_uuid):
			LOG.warning(self, "create_item", "Item's given template_uuid not found in _item_templates.", { "item_uuid" : item_uuid, "template_uuid" : template_uuid })
	#endif

	return true
#endfunc

func remove_item(item_uuid):
	# destroy_item
	#	Removes the given item's data from the db.
	#
	# _arguments_
	#	item_uuid:	uuid of the item to remove.
	#
	# _returns_
	#	true:	item successfully removed.
	#	false:	item didn't exist, or else wasn't removed.

	if not has_item(item_uuid):
		LOG.warning(self, "remove_item", "Attempting to remove item which doesn't exist.", { "item_uuid" : item_uuid })
		return false
	#endif




func get_data(item_uuid, data_key):
	# get_data
	#	Returns the requested data of the item of it exists.  If the item itself
	#		doesn't have the data_key, it attempts to return the value in the
	#		_item_templates at the data_key (if it exists).  Returns null if
	#		neither exists.
	#
	# _arguments_
	#	item_uuid:	the uuid of the item to retrieve the data for
	#
	# _returns_
	#	data:	whatever value is stored at the data_key, either in the
	#			_items or _item_template dict for the given item
	#	null:	either the item_uuid wasn't found, or else there was no data
	#			found for the given key.

	# Does the item exist
	if not has_item(item_uuid):
		# Nope.  Return null.
		return null
	#endif
	var ret_data = null

	# Does the item have the data_key
	if _items[item_uuid].has(data_key):
		#Then return the data stored at the key.
		ret_data = _items[item_uuid][data_key]
	# Does the item have a template
	elif _items[item_uuid].has(KEY_ITEM_TEMPLATE):
		# Yes, so attempt to retrieve the data from the template db.
		template_key = _items[item_uuid][KEY_ITEM_TEMPLATE]

		# Does the key actually exist, though?
		if _item_templates.has(template_key):
			# It does.  Does the template actually have the requested key?
			if _item_templates[template_key].has(data_key):
				# It does.  Return the data from the template db, then.
				ret_data = _item_templates[template_key][data_key]
			#endif
		#endif
	#endifel

	# Either the item_uuid wasn't found, or else neither the item db nor the
	#	template db had the requested key.
	return ret_data
#endfunc

func has_item(item_uuid):
	# has_item
	#	Checks if there's an item with the given uuid in the database.
	#
	# _arguments_
	#	item_uuid:	uuid of the item to check.
	#
	# _returns_
	#	true:	item exists
	#	false:	item doesn't exist

	return _items.has(item_uuid)
#endfunc

func has_template(template_uuid):
	# has_template
	#	Checks if there's an item template with the given uuid in the database.
	#
	# _arguments_
	#	template_uuid:	uuid of the template to check
	#
	# _returns_
	#	true:	template exists
	#	false:	template doesn't exist.
	return _item_templates.has(template_uuid)
#endfunc

func set_data(item_uuid, data_key, data):
	# set_data
	#	Sets the data stored at the given data_key, if the item exists.
	#
	# _arguments_
	#	item_uuid:	uuid of the item to set the data of.
	#	data_key:	key that will store the value.
	#	data:		value to store at the given key.
	#
	# _returns_
	#	true:		data successfully stored.
	#	false:		item didn't exist, or some other problem.
	#
	# _signals_
	#	item_changed:	if data was successfully changed.

	# Does the item exist.
	if has_item(item_uuid):
		# It does.  Set the value to the given key and emit the signal.
		_items[item_uuid][data_key] = data
		emit_signal("item_changed", item_uuid, data_key)
		return true
	#endif

	return false
#endfunc