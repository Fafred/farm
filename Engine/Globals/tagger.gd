#### tagger.gd
#### 10/19.18
####
####	System that handles adding tags and tag data to uuids.  It's completely
####		agnostic as to what the uuids represent, and the tags are stored
####		seperately from any other data which might be associated with the
####		uuid.

extends Node

var _uuids = { }

func _ready():
	ITEM_DB.connect("item_removed", self, "_on_item_removed_from_db")
#endfunc

func get_tag_data(uuid, tag):
	# get_tag_data
	#	Returns the tag data for the specificied tag of the specified uuid.
	#
	# _arguments_
	#	uuid:	uuid to get the tag data for
	#	tag:	tag to get the tag data for.
	#
	# _returns_
	#	value:	whatever data is associated with that tag for the uuid
	#	null:	either uuid wasn't found, or the uuid didn't have the tag.
	if has_tag(uuid, tag):
		return _uuids[uuid][tag]
	#endif
	return null
#endfunc

func has_tag(uuid, tag):
	# has_tag
	#	Checks whether or not a given tag exists for a particular uuid.
	#
	# _arguments_
	#	uuid:	uuid to check
	#	tag:	tag to check
	#
	# _returns_
	#	true:	uuid does have that tag
	#	false:	uuid does not have that tag
	if _uuids.has(uuid):
		return _uuids[uuid].has(tag)
	#endif
	return false
#endfunc

func set_tag_data(uuid, tag, value):
	# set_tag_data
	#	Creates a tag for the uuid if it doesn't exist, then sets the data for
	#		that tag.
	#
	# _arguments_
	#	uuid:	uuid for the tag to be associated with
	#	tag:	tag to associate with the uuid
	#	value:	tag data to store
	if not _uuids.has(uuid):
		_uuids[uuid] = { }
	#endif

	_uuids[uuid][tag] = value
#endfunc

func remove_uuid(uuid):
	# remove_uuid
	#	Removes all tags associated with the uuid.
	#
	# _arguments_
	#	uuid:	uuid to remove the tags from.
	if _uuids.has(uuid):
		_uuids.erase(uuid)
	#endif
#endfunc

func remove_tag(uuid, tag):
	# remove_tag
	#	Removes the tag from the uuid if it exists.
	#
	# _arguments_
	#	uuid:	uuid to remove the tag from
	#	tag:	tag to remove
	if _uuids.has(uuid):
		if _uuids[uuid].has(tag):
			_uuids[uuid].erase(tag)
		#endif

		if _uuids[uuid].keys().size() < 1:
			_uuids.erase(uuid)
		#endif
	#endif
#endfunc

func _on_item_removed_from_db(item_uuid):
	if _uuids.has(item_uuid):
		_uuids.erase(item_uuid)
	#endif
#endfunc