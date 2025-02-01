extends AnimatedSprite2D

signal killplayer

# NEEDS TO STAY ABOVE PLAYER OBJ IN SCENE TREE
# SO 1HP MODIFIER WORKS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	frame = 3

func _on_player_hpdec(newhp: int) -> void:
	frame = newhp
	if (newhp == 0):
		killplayer.emit()
