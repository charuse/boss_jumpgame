extends Node2D

@onready var ScoreLabel : Label = $ScoreLabel
@onready var back2 : Sprite2D = $backtomenu
@onready var audio_ct : AudioStreamPlayer2D = $audio_count
@onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var score : int = 0
var countval : int = 0
var jmp_val : int = 2
var dbl_boss_hp : bool = false
var one_heart : bool = false
var no_dbl_jmp : bool = false
var less_ammo : bool = false
var kneecapped : bool = false
var count_start : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back2.visible = false
	audio_ct.play()
	if (Global.modifiers[0]):
		dbl_boss_hp = true
	if (Global.modifiers[1]):
		one_heart = true
	if (Global.modifiers[2]):
		no_dbl_jmp = true
	if (Global.modifiers[3]):
		less_ammo = true
	if (Global.modifiers[4]):
		kneecapped = true
	if (Global.bosses[0]):
		score += 150
		if (dbl_boss_hp):
			score += 100
		if (one_heart):
			score += 100
		if (no_dbl_jmp):
			score += 80
		if (less_ammo):
			score += 60
		if (kneecapped):
			score += 40
	if (Global.bosses[1]):
		score += 200
		if (dbl_boss_hp):
			score += 120
		if (one_heart):
			score += 120
		if (no_dbl_jmp):
			score += 80
		if (less_ammo):
			score += 80
		if (kneecapped):
			score += 40
			
	rng.seed = Time.get_ticks_msec()
	count_start = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (count_start):
		if (countval != score):
			jmp_val = rng.randi_range(2, 6)
			countval = min(countval + jmp_val, score)
			ScoreLabel.text = str(countval)
		if (countval == score):
			if (audio_ct.is_playing()):
				audio_ct.stop()
			back2.visible = true
			count_start = false
