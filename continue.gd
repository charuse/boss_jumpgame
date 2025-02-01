extends Sprite2D

const cont_path : String = "res://eye_boss_scene.tscn"
const score_path : String = "res://score.tscn"

var current_scene : String
var onEyeboss : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_scene = get_tree().current_scene.name
	if (current_scene == "EyeBossScene"):
		onEyeboss = true
	else:
		onEyeboss = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and visible:
		if(get_rect().has_point(to_local(event.position))):
			if(Global.bosses[1] and onEyeboss == false): #Check for enabled 2nd boss
				get_tree().change_scene_to_file(cont_path)
			else:
				get_tree().change_scene_to_file(score_path)
