extends Node2D

const gamepath : String = "res://game_scene.tscn"
const controlspath : String = "res://settings.tscn"
const eyebosspath : String = "res://eye_boss_scene.tscn"

@onready var play_button : Button = $PlayButton
@onready var controls_button : Button = $ControlsButton
@onready var load : Label = $Load
@onready var cbox_spriteArr : Array[AnimatedSprite2D] = \
	[$checkbox1/box_sprite, $checkbox2/box_sprite, $checkbox3/box_sprite, \
	 $checkbox4/box_sprite, $checkbox5/box_sprite]
@onready var cbox_group : Array[CharacterBody2D] = \
	[$checkbox1, $checkbox2, $checkbox3, $checkbox4, $checkbox5]
@onready var mod_lbls : Array[Label] = [$DoubleHP, $OneHeart, \
	$NoDoubleJump, $LessAmmo, $Kneecapped]
@onready var exit_button : CharacterBody2D = $exit_button
@onready var begin_button : StaticBody2D = $begin_button
@onready var ModLabel : Label = $Label
@onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()
@onready var checkclick : AudioStreamPlayer2D = $audio_Check_Click
@onready var aud_openmenu : AudioStreamPlayer2D = $audio_openmenu
@onready var aud_closemenu : AudioStreamPlayer2D = $audio_closemenu
@onready var cbox_boss : Array[AnimatedSprite2D] = \
	[$boss1_box/box_sprite, $boss2_box/box_sprite]
@onready var req : Label = $Require
@onready var badselec : AudioStreamPlayer2D = $bad_select
@onready var pic_clown : Sprite2D = $Clown_pic
@onready var pic_eye : Sprite2D = $Eye_pic

var checked : Array[bool] = [false, false, false, false, false]
var bosses : Array[bool] = [true, true]
var framecount : int = 0
var sec_count : int = 60
var xy_load : int = 0
var checkbox_loader : int = 0
var checkbox_unloader : int = 0
var checkclickpitch : float = 1.000
var pitch2 : float = 1.000
var sendpath : String
var legitpath : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load.visible = false
	ModLabel.visible = false
	$Boss2TestButton.visible = false
	req.visible = false
	exit_button.visible = false
	begin_button.visible = false
	cbox_boss[0].stop()
	cbox_boss[1].stop()
	cbox_boss[0].visible = false
	cbox_boss[1].visible = false
	pic_eye.visible = false
	pic_clown.visible = false
	
	while xy_load < 5:
		cbox_spriteArr[xy_load].stop()
		cbox_spriteArr[xy_load].frame = 0
		cbox_group[xy_load].visible = false
		mod_lbls[xy_load].visible = false
		xy_load += 1
		
	play_button.visible = true
	controls_button.visible = true
	cbox_boss[0].frame = 1
	cbox_boss[1].frame = 1
	
	
	rng.seed = Time.get_ticks_msec()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (sec_count < 60):
		sec_count += 1
	else:
		checkclickpitch = rng.randf_range(0.820, 1.080)
		pitch2 = rng.randf_range(0.940, 1.060)
		checkclick.pitch_scale = checkclickpitch
		aud_closemenu.pitch_scale = pitch2 - 0.10
		aud_openmenu.pitch_scale = pitch2 + 0.10
		sec_count = 0

func _on_controls_button_pressed() -> void:
	get_tree().change_scene_to_file(controlspath)

func _on_play_button_pressed() -> void:
	if (play_button.visible and checkbox_loader == 0):
		aud_openmenu.play()
		setupCheckbox()
	
func setupCheckbox() -> void:
	play_button.visible = false
	controls_button.visible = false
	ModLabel.visible = true
	
	while checkbox_loader < 5:
		cbox_group[checkbox_loader].visible = true
		mod_lbls[checkbox_loader].visible = true
		checkbox_loader += 1
		
	bosses = [true, true]
	pic_eye.visible = true
	pic_clown.visible = true
	cbox_boss[0].visible = true
	cbox_boss[1].visible = true
	checkbox_unloader = 0
	exit_button.visible = true
	begin_button.visible = true
		
func resetCheckbox() -> void:
	ModLabel.visible = false
	
	while checkbox_unloader < 5:
		cbox_group[checkbox_unloader].visible = false
		mod_lbls[checkbox_unloader].visible = false
		checked[checkbox_unloader] = false
		checkbox_unloader += 1
		
	bosses = [true, true]
	pic_eye.visible = false
	pic_clown.visible = false
	cbox_boss[0].visible = false
	cbox_boss[1].visible = false
	req.visible = false
	play_button.visible = true
	controls_button.visible = true
	checkbox_loader = 0
	exit_button.visible = false
	begin_button.visible = false

func _on_checkbox_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and cbox_group[0].visible:
		checkclick.play()
		if (checked[0] == false):
			cbox_spriteArr[0].frame = 1
			checked[0] = true
		else:
			cbox_spriteArr[0].frame = 0
			checked[0] = false

func _on_checkbox_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and cbox_group[1].visible:
		checkclick.play()
		if (checked[1] == false):
			cbox_spriteArr[1].frame = 1
			checked[1] = true
		else:
			cbox_spriteArr[1].frame = 0
			checked[1] = false

func _on_checkbox_3_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and cbox_group[2].visible:
		checkclick.play()
		if (checked[2] == false):
			cbox_spriteArr[2].frame = 1
			checked[2] = true
		else:
			cbox_spriteArr[2].frame = 0
			checked[2] = false

func _on_checkbox_4_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and cbox_group[3].visible:
		checkclick.play()
		if (checked[3] == false):
			cbox_spriteArr[3].frame = 1
			checked[3] = true
		else:
			cbox_spriteArr[3].frame = 0
			checked[3] = false

func _on_checkbox_5_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and cbox_group[4].visible:
		checkclick.play()
		if (checked[4] == false):
			cbox_spriteArr[4].frame = 1
			checked[4] = true
		else:
			cbox_spriteArr[4].frame = 0
			checked[4] = false
			
func _on_boss_1_box_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and cbox_boss[0].visible:
		checkclick.play()
		if bosses[0] == false:
			cbox_boss[0].frame = 1
			bosses[0] = true
		else:
			cbox_boss[0].frame = 0
			bosses[0] = false

func _on_boss_2_box_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and cbox_boss[1].visible:
		checkclick.play()
		if bosses[1] == false:
			cbox_boss[1].frame = 1
			bosses[1] = true
		else:
			cbox_boss[1].frame = 0
			bosses[1] = false

func _on_exit_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed \
		and exit_button.visible and checkbox_unloader == 0:
		aud_closemenu.play()
		resetCheckbox()

func _on_begin_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed \
		and begin_button.visible and checkbox_unloader == 0:
		load.visible = true
		Global.modifiers = checked
		Global.bosses = bosses
		if (Global.bosses[0] == true and Global.bosses[1] == false):
			sendpath = gamepath
			legitpath = true
		elif(Global.bosses[0] == false and Global.bosses[1] == true):
			sendpath = eyebosspath
			legitpath = true
		elif(Global.bosses[0] == true and Global.bosses[1] == true):
			sendpath = gamepath
			legitpath = true
		elif(Global.bosses[0] == false and Global.bosses[1] == false):
			legitpath = false
			load.visible = false
			req.visible = true
			badselec.play()
		if (legitpath):
			await get_tree().create_timer(0.01).timeout
			get_tree().change_scene_to_file(sendpath)
		
func _on_boss_2_test_button_pressed() -> void:
	if ($Boss2TestButton.visible):
		get_tree().change_scene_to_file(eyebosspath)
