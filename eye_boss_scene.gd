extends Node2D

const CONST_TO_SIDE_X : int = 35

@onready var rng : RandomNumberGenerator  = RandomNumberGenerator.new()
@onready var eyeboss_path : Path2D = $Eyeboss
@onready var eyeboss_anim : AnimationPlayer = $Eyeboss/AnimationPlayer
@onready var eyeboss_char : CharacterBody2D = $Eyeboss/EyebossBody
@onready var eyeboss_sprite : AnimatedSprite2D = \
	$Eyeboss/EyebossBody/AnimatedSprite2D
@onready var eyeboss_pathfollow : PathFollow2D = \
	$Eyeboss/PathFollow2D
@onready var eyeboss_area : Area2D = $Eyeboss/Area2D
@onready var CirclePath : Path2D = $Path2D
@onready var CircleAnim : AnimationPlayer = $Path2D/AnimationPlayer
@onready var Player : CharacterBody2D = $Player
@onready var killbox : Area2D = $FloorKillbox
@onready var result : Label = $result
@onready var audio_shoot : AudioStreamPlayer2D = $audio_shoot
@onready var audio_dmg : AudioStreamPlayer2D = $audio_dmg
@onready var audio_jmp : AudioStreamPlayer2D = $audio_jump
@onready var audio_hitboss : AudioStreamPlayer2D = $audio_hitboss
@onready var audio_phase2 : AudioStreamPlayer2D = $audio_phase2
@onready var audio_clownbg : AudioStreamPlayer2D = $audio_clownbg
@onready var backdrop : Sprite2D = $backdrop
@onready var SidewallLeft : StaticBody2D = $Sidewall_left
@onready var back2 : Sprite2D = $backtomenu
@onready var cont : Sprite2D = $continue
@onready var warn : Sprite2D = $warn
@onready var particles : CPUParticles2D = $CPUParticles2D
@onready var audio_dash : AudioStreamPlayer2D = $audio_dash
@onready var audio_warn : AudioStreamPlayer2D = $audio_warn

var backwards_anim : bool = false
var dead : bool = false
var audiopitch : float = 1.000
var dash_speed : float = 40.0
var framecount : int = 0
var pos_x : int 
var pos_y : int
var valxx : int = 0
var removeboss : bool = false
var endboss : bool = false
var dash_atk : bool = false
var forward : bool = false
var pos_eyebosschar : Vector2
var pos_player : Vector2
var pos_temp : Vector2
var phase2 : bool = false
var recheck1 : bool = false
var towarn : bool = false
var setonce : float
var countupper : int = 0
var pitch_scaler : float

signal hit_killbox
signal hit_player_with_boss

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	result.visible = false
	back2.visible = false
	cont.visible = false
	eyeboss_char.add_collision_exception_with(Player)
	eyeboss_anim.play("float")
	eyeboss_sprite.play()
	CircleAnim.speed_scale = 0.6
	CircleAnim.play("anim")
	particles.amount = 7
	rng.seed = Time.get_ticks_msec()
	
	pos_x = int(backdrop.global_position.x)
	pos_y = int(backdrop.global_position.y)
	
	pos_player.x = CONST_TO_SIDE_X
	pos_player.y = Player.global_position.y
	
	pos_eyebosschar = eyeboss_char.global_position
	
	audio_clownbg.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (dead == false):
		pos_temp = eyeboss_char.global_position
		eyeboss_area.global_position = pos_temp
		particles.global_position = pos_temp
	if (result.visible and eyeboss_anim.is_playing):
		eyeboss_anim.pause()
	if (framecount == 41 and dead == false):
		backdrop.global_position.x = rng.randi_range(\
			pos_x - 1,\
			pos_x + 1)
		backdrop.global_position.y = rng.randi_range(\
			pos_y - 1,\
			pos_y + 1)
		framecount = 0
		audiopitch = rng.randf_range(0.80, 1.21)
		audio_shoot.pitch_scale = (float(audiopitch - 0.03))
		audio_dmg.pitch_scale = (float(audiopitch + 0.03))
		audio_jmp.pitch_scale = float(audiopitch - 0.02)
		audio_hitboss.pitch_scale = float(audiopitch + 0.02)
	elif(dead == false):
		framecount += 1
	elif (dead and endboss == false):
		var process_frames : bool = (Engine.get_process_frames() % 30 == 0)
		if(eyeboss_sprite.frame != 5 and process_frames):
			eyeboss_sprite.frame += 1
		if (valxx < 50 and process_frames):
			audio_clownbg.volume_db -= 1
			valxx += 1
		if (eyeboss_sprite.frame == 5 and removeboss \
			and process_frames):
			if (recheck1):
				endboss = true
				eyeboss_sprite.queue_free()
				particles.queue_free()
				result.visible = true
				cont.visible = true
			elif (!(recheck1)):
				warn.queue_free()
				recheck1 = true
			
	if (dash_atk == true):
		if (eyeboss_char.global_position.distance_to(pos_eyebosschar) < 900.0 \
			and forward):
			eyeboss_char.global_position = eyeboss_char.global_position.\
				move_toward(pos_player, dash_speed)
		elif (eyeboss_char.global_position.distance_to(pos_eyebosschar) > 850.0 \
				and forward):
				if (forward):
					forward = false
		elif (eyeboss_char.global_position.distance_to(pos_eyebosschar) > 8.0 \
				and forward == false):
				eyeboss_char.global_position = eyeboss_char.global_position.\
					move_toward(pos_eyebosschar, dash_speed)
		elif (eyeboss_char.global_position.distance_to(pos_eyebosschar) < 8.0 \
				and forward == false):
				eyeboss_char.global_position = pos_eyebosschar
				eyeboss_sprite.frame = 1
				eyeboss_sprite.play()
				eyeboss_anim.play("float")
				towarn = false
				dash_atk = false
				
	if (towarn == false):
		warn.global_position = eyeboss_char.global_position
		warn.self_modulate.a8 = 255
		countupper = 0
	if (towarn == true):
		warn.global_position.y = min(warn.global_position.y + 10.0, setonce)
		if (warn.global_position.y == setonce and countupper < 255):
			warn.self_modulate.a8 -= 5
			countupper += 5

func _on_animated_sprite_2d_animation_finished() -> void:
	if (backwards_anim == false): #Animation play backwards
		if (phase2 == false): 
			await get_tree().create_timer(1).timeout
		if (dead == false):
			eyeboss_sprite.speed_scale = -1.0
			eyeboss_sprite.play()
			backwards_anim = true
	
	elif (backwards_anim): #Animation play forwards
		dashatk()
		await get_tree().create_timer(1).timeout
		if (dead == false):
			eyeboss_sprite.speed_scale = 1.0
			eyeboss_sprite.play()
			backwards_anim = false
			

func dashatk() -> void:
	if (dash_atk == false and dead == false):
		pitch_scaler = rng.randf_range(0.90, 1.10)
		audio_warn.pitch_scale = pitch_scaler + 0.01
		audio_dash.pitch_scale = min(pitch_scaler + 0.05, 1.05)
		eyeboss_anim.pause()
		eyeboss_sprite.pause()
		audio_warn.play()
		setonce = warn.global_position.y + 120
		towarn = true
		pos_player.x = CONST_TO_SIDE_X
		pos_player.y = Player.global_position.y
		pos_eyebosschar = eyeboss_char.global_position
		await get_tree().create_timer(1).timeout
		audio_dash.play()
		forward = true
		dash_atk = true

func _on_floor_killbox_body_entered(body: Node2D) -> void:
	if (killbox.overlaps_body(Player)):
		hit_killbox.emit()

func OnBothDeath() -> void:
	backdrop.global_position.x = pos_x
	backdrop.global_position.y = pos_y
	CircleAnim.pause()
	dead = true

func _on_hearts_killplayer() -> void:
	eyeboss_sprite.stop()
	eyeboss_anim.pause()
	OnBothDeath()
	result.visible = true
	back2.visible = true
	particles.queue_free()

func _on_audio_clownbg_finished() -> void:
	if (dead == false):
		audio_clownbg.play()


func _on_boss_hp_bar_bossdead() -> void:
	eyeboss_sprite.stop()
	eyeboss_anim.pause()
	result.text = "YOU WIN!"
	OnBothDeath()
	removeboss = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body == Player):
		hit_player_with_boss.emit()


func _on_boss_hp_bar_phase_two() -> void:
	if (phase2 == false):
		audio_phase2.play()
		eyeboss_anim.speed_scale = 1.5
		phase2 = true
