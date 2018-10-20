#### item_db.gd
#### 10/18/18
####	Database for the items.

extends Node

### KEYS ###
const KEY_ITEM_TEMPLATE = "item_template"

### SIGNALS ###
signal item_changed 			# (item_uuid, data_key) : item in the db has changed.
signal item_removed				# (item_uuid)	: item has been removed from the db.
signal item_created				# (item_uuid)	: item has been created.

### PRIVATE ###
var _item_templates = { }
var _items = { }

var _name = "item_db.gd"

func create_item(template_uuid, data_dict = { }):
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
		LOG.error(self, "create_item", "Argument data_dict must be of type dictionary.", { "template_uuid" : template_uuid, "type of data_dict":typeof(data_dict)})
		return null
	#endif

	var item_uuid = UUID.v4()

	_items[item_uuid] = data_dict

	if template_uuid != null:
		_items[item_uuid][KEY_ITEM_TEMPLATE] = template_uuid

		if not _item_templates.has(template_uuid):
			LOG.warning(self, "create_item", "Item's given template_uuid not found in _item_templates.", { "item_uuid" : item_uuid, "template_uuid" : template_uuid })
	#endif

	emit_signal("item_created", item_uuid)
	return item_uuid
#endfunc

func create_template(template_uuid, data_dict = { }):
	# create_template
	#	Creates a new template with the given uuid.
	#
	# _arguments_
	#	template_uuid:	the uuid of the template to create.  Cannot be null.
	#	data_dict:		dictionary of data to associate with the template.
	#
	# _returns_
	#	true:	template successfully added.
	#	false:	unable to add template

	# Does the template uuid already exist?  If so, return false.
	if _item_templates.has(template_uuid):
		LOG.warning(self, "create_template", "Attempting to add template uuid, but that uuid is already in use.", {"template_uuid":template_uuid})
		return false
	#endif

	# Is the template_uuid null?  If so, return false.
	if template_uuid == null:
		LOG.error(self, "create_template", "Cannot use a null for a template uuid.", {})
		return false
	#endif

	if typeof(data_dict) != TYPE_DICTIONARY:
		LOG.error(self, "create_template", "Argument data_dict must be of type dictionary.", { "template_uuid" : template_uuid, "type of arg data_dict" : typeof(data_dict) } )
		return false
	#endif

	_item_templates[template_uuid] = data_dict
	return true
#endfunc

func get_data(item_uuid, data_key = null, do_get_template_data = true):
	# get_data
	#	Returns the requested data of the item of it exists.  If the item itself
	#		doesn't have the data_key, it attempts to return the value in the
	#		_item_templates at the data_key (if it exists).  Returns null if
	#		neither exists.
	#
	# _arguments_
	#	item_uuid:	the uuid of the item to retrieve the data for
	#	data_key:	the key to retrieve the value for.  If null it returns all
	#				the item's data merged with template data.
	#	do_get_template_data:	whether or not to retrieve the data key from the
	#							template if not present in the item's data.
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

	if not data_key == null:
		# Does the item have the data_key
		if _items[item_uuid].has(data_key):
			#Then return the data stored at the key.
			ret_data = _items[item_uuid][data_key]
		# Does the item have a template
		elif do_get_template_data == true and _items[item_uuid].has(KEY_ITEM_TEMPLATE):
			# Yes, so attempt to retrieve the data from the template db.
			var template_key = _items[item_uuid][KEY_ITEM_TEMPLATE]

			# Does the key actually exist, though?
			if _item_templates.has(template_key):
				# It does.  Does the template actually have the requested key?
				if _item_templates[template_key].has(data_key):
					# It does.  Return the data from the template db, then.
					ret_data = _item_templates[template_key][data_key]
				#endif
			else:
				LOG.warning(self, "get_data", "Item has a template uuid which does not exist in the template db.", { "item_uuid" : item_uuid, "template_uuid" : template_key })
			#endifelse
		#endifel
	else:
		# They passed a null for the data key, so we send them everything.
		#	Starting with all the data from the template - if the item is tied
		#	to one.
		ret_data = { }

		# Check if this item has a template uuid.
		if do_get_template_data == true and _items[item_uuid].has(KEY_ITEM_TEMPLATE):
			var template_key = _items[item_uuid][KEY_ITEM_TEMPLATE]

			# It does, so now see if the template db actually has this template uuid
			if _item_templates.has(template_key):
				# It does, so add all the values from the template to the return data.
				for key in _item_templates[template_key].keys():
					ret_data[key] = _item_templates[template_key][key]
				#endfor
			else:
				LOG.warning(self, "get_data", "Item has a template uuid which does not exist in the template db.", { "item_uuid" : item_uuid, "template_uuid" : template_key })
			#endifelse
		#endif

		# Add all the data from this specific item.  This will overwright template
		#	data, if they share the same keys.
		for key in _items[item_uuid]:
			ret_data[key] = _items[item_uuid]
		#endfor

	return ret_data
#endfunc

func get_data_batch(item_uuids, data_keys, do_get_template_data = true):
	# get_data_batch
	#	Functions as get data, but allows for multiple items and/or multiple
	#		keys.
	#
	# _arguments_
	# item_uuids:	array of item uuids to look up
	# data_keys:	array of data keys.
	#
	# _returns_
	# dictionary:	dictionary where the keys are item uuids and the values are
	#					themselves dictionaries with key: data_key and the values
	#					associated with them.
	# null:			one or both of the arguments were not arrays, or else there
	#					was some other problem.

	# Make sure both arguments are arrays.
	if not typeof(item_uuids) == TYPE_ARRAY or not typeof(data_keys) == TYPE_ARRAY:
		LOG.error(self, "get_data_batch", "Both arguments must be of type array.", { "type of item_uuids" : typeof(item_uuids), "type of data_keys" : typeof(data_keys) })
		return null
	#endif

	var ret_dict = { }
	var uuids_not_found = [ ]

	for item_uuid in item_uuids:
		if not _items.has(item_uuid):
			uuids_not_found.append(item_uuid)
			continue
		#endif

		var data_dict = { }

		for key in data_keys:
			if _items[item_uuid].has(key):
				data_dict[key] = _items[item_uuid][key]
			elif do_get_template_data == true and _items[item_uuid].has(KEY_ITEM_TEMPLATE):
				var template_key = _items[item_uuid][KEY_ITEM_TEMPLATE]

				if _item_templates[template_key].has(key):
					data_dict[key] = _item_templates[template_key][key]
				#endif
			#endifel
		#endfor

		ret_dict[item_uuid] = data_dict
	#endfor

	if uuids_not_found.size() > 0:
		LOG.warning(self, "get_data_batch", "Item UUIDs not found.", { "item uuids" : uuids_not_found })
	#endif

	return ret_dict
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

func load_items(items):
	# load_items
	#	Adds the items to the items db.  These will overwrite any existing items
	#		with the data present in the items dict arg.
	#
	# _arguments_
	#	items:	dictionary of items.  key: item uuid, value: data
	#
	# _returns_
	#	true:	items successfully added
	#	false:	unable to add items.

	if typeof(items) != TYPE_DICTIONARY:
		LOG.error(self, "load_items", "Argument items must be of type dictionary.", { "type of arg items" : typeof(items) })
		return false
	#endif

	var num_of_overwrites = 0
	var overwritten_items = [ ]

	for key in items.keys():
		# Track number of items we overwrite.
		if _items.has(key):
			num_of_overwrites += 1
			overwritten_items.append(key)
			_items.erase(key)
		#endif

		_items[key] = items[key]
	#endfor

	if num_of_overwrites > 0:
		LOG.warning(self, "load_items", "Overwrote %s items which already existed in the db." % str(num_of_overwrites), { "Overwritten item uuids" : overwritten_items})
	#endif

	return true
#endfunc

func load_templates(templates):
	# load_templates
	#	Adds the templates to the template db.  This will overwrite existing any
	#		templates with the same uuids present in the templates dict arg.
	#
	# _arguments_
	#	templates:	dictionary of templates.  key: template uuid, value: data
	#
	# _returns_
	#	true:	templates successfully added
	#	false:	templates not added.

	if typeof(templates) != TYPE_DICTIONARY:
		LOG.error(self, "load_templates", "Argument templates must be of type dictionary.", { "type of arg templates" : typeof(templates) })
		return false
	#endif

	var num_of_overwrites = 0
	var overwritten_templates = [ ]

	for key in templates.keys():
		# Keep track of how many times we overwrite existing templates.
		if _item_templates.has(key):
			num_of_overwrites += 1
			overwritten_templates.append(key)
			_item_templates.erase(key)
		#endif

		# Copy them into our db.
		_item_templates[key] = templates[key]
	#endfor

	if num_of_overwrites > 0:
		LOG.warning(self, "load_templates", "Overwrote %s templates which already existed in the db." % str(num_of_overwrites), { "Overwritten template uuids" : overwritten_templates})
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

	_items.erase(item_uuid)
	emit_signal("item_removed", item_uuid)
	return true
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