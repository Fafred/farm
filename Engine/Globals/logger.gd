extends Node

### CONSTANTS ###
const TYPE_WARNING = "WARNING"
const TYPE_ERROR 	= "ERROR"
const TYPE_LOG		= "LOG"

const KEY_SCRIPT_NAME = "key_script_name"
const KEY_FUNCTION_NAME = "key_function_name"
const KEY_ERROR_TEXT = "key_error_text"
const KEY_DATA = "key_data"
const KEY_TIME = "key_time"

### SIGNALS ###
signal error #	error(error type, data)

var _print_settings = {	TYPE_WARNING	:	true,
						TYPE_ERROR		:	true,
						TYPE_LOG		:	true }

var _write_settings = {	TYPE_WARNING	:	true,
						TYPE_ERROR		:	true,
						TYPE_LOG		:	true }

var errors = { }

func _ready():
	self.connect("error", self, "_on_error")
#endfunc

func warning(node, function_name, error_text, data):
	self._log(TYPE_WARNING, node, function_name, error_text, data)
#endfunc

func error(node, function_name, error_text, data):
	self._log(TYPE_ERROR, node, function_name, error_text, data)
#endfunc

func logg(node, function_name, error_text, data):
	self._log(TYPE_LOG, node, function_name, error_text, data)
#endfunc

func _log(ERROR_TYPE, node, function_name, error_text, data):
	if not errors.has(ERROR_TYPE):
		errors[ERROR_TYPE] = [ ]
	#endif

	var script_name = node.get_script().get_path()

	var error_data =	{	KEY_SCRIPT_NAME		: script_name,
							KEY_FUNCTION_NAME	: function_name,
							KEY_ERROR_TEXT		: error_text,
							KEY_DATA			: data,
							KEY_TIME 			: OS.get_datetime()
						}

	errors[ERROR_TYPE].append(error_data)

	emit_signal("error", ERROR_TYPE, error_data)
#endfunc

func _write(error_string):
	#TODO: implement.
	pass
#endfunc

func _on_error(error_type, error_data):
	var datetime = error_data[KEY_TIME]
	var time_string = "%s:%s:%s" % [datetime["hour"], datetime["minute"], datetime["second"]]
	var error_string = "_%s_ %s\n[%s]\t:\t(%s)\n\t%s\n\t----------------------" % [	error_type,
						time_string,
						error_data[KEY_SCRIPT_NAME],
						error_data[KEY_FUNCTION_NAME],
						error_data[KEY_ERROR_TEXT]
					]

	for key in error_data[KEY_DATA].keys():
		error_string += "\n\t\t> %s : %s" % [	key,
											error_data[KEY_DATA][key]]
	#endfor

	if _print_settings.has(error_type) and _print_settings[error_type] == true:
		print(error_string)
	#endif

	if _write_settings.has(error_type) and _write_settings[error_type] == true:
		_write(error_string)
#endfunc