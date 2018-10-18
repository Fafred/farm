extends TextureButton

var item_name = ""
var textover = ""
var imagetexture = null
var item_uuid = null
var inv_uuid = null

signal attempt_swap(a, b)

func load_item(item_number, cell_size, inventory_uuid):
	var item_data = DB.get_item(item_number)

	if item_data == null:
		print("emptyslot: unable to load item #" + str(item_number))
		return
	#endif

	inv_uuid = inventory_uuid

	var file_name = item_data["filename"]
	item_uuid = item_number
	textover = item_data["textover"]
	item_name = item_data["name"]

	imagetexture = ImageTexture.new()
	imagetexture.load("res://inv testing/" + file_name)
	imagetexture.set_size_override(Vector2(cell_size, cell_size))

	self.texture_normal = imagetexture
#endfunc

func get_drag_data(pos):
	if item_uuid == null:
		return
	#endif

	var drag_preview = TextureRect.new()
	drag_preview.texture = imagetexture
	drag_preview.set_anchors_preset(PRESET_CENTER_TOP)
	set_drag_preview(drag_preview)
	return self
#endfunc

func can_drop_data(pos, data):
	if typeof(data) == typeof(self):
		return true
	return false
#endfunc

func drop_data(pos, data):
	if data == self:
		return
	#endif

	emit_signal("attempt_swap", data, self)
#endfunc