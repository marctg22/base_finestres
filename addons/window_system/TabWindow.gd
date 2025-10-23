extends Control
class_name TabWindow

@export var title: String = "New Tab"

# Ara la senyal passa la finestra que la demana
signal request_close(window)

func _ready() -> void:
	# Si hi ha un Label anomenat "Title", actualitza el títol
	if has_node("Title"):
		$Title.text = title
	# Si hi ha un botó "Close", connecta'l a la funció local que emet la senyal
	if has_node("Close"):
		$Close.pressed.connect(Callable(self, "_on_close_pressed"))
	# Assigna el focus mode correcte per Godot 4.x
	# Opcions: Control.FOCUS_NONE / Control.FOCUS_CLICK / Control.FOCUS_ALL
	focus_mode = Control.FOCUS_ALL

func _on_close_pressed() -> void:
	# Emetem la pròpia instància com a argument per facilitar la connexió
	emit_signal("request_close", self)
