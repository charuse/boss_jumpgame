extends CharacterBody2D

@onready var timer : Timer = $Timer
@onready var sprite : Sprite2D = $Sprite2D
@onready var audio_shoot : AudioStreamPlayer2D = \
	get_parent().get_node("audio_shoot")
@onready var audio_dmg : AudioStreamPlayer2D = \
	get_parent().get_node("audio_dmg")
@onready var audio_jmp : AudioStreamPlayer2D = \
	get_parent().get_node("audio_jump")
@onready var result : Label = get_parent().get_node("result")

const bulletpath = preload("res://bullet.tscn")

var SPEED : float = 180.0
var JUMP_VELOCITY : float = -400.0
var iframe : bool = false
var doublejump : bool = true
var collide_y : int = 560
var jumpct : int = 1
var bulletct : int = 0
var hp : int = 3
var dir : int = 1
var bullet_max : int = 5

var bulletpos : Vector2
var direction : int

signal bossHitt
signal hpdec(newhp : int)
signal new_bullet(bullet_node : CharacterBody2D)

func _ready() -> void:
	timer.start()
	sprite.visible = true
	
	#MODIFIERS
	#1 Heart
	if (Global.modifiers[1]):
		hp = 1
		hpdec.emit(1)
	#Single jump
	if (Global.modifiers[2]):
		doublejump = false
	#Ammo restrict
	if (Global.modifiers[3]):
		bullet_max = 2
	#Kneecapped
	if (Global.modifiers[4]):
		SPEED = 120.0
		

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if (jumpct == 2):
			jumpct = 1
		if (velocity.y > 0): #Apply extra velocity when falling
			velocity.y += 10
	else:
		if (doublejump):
			jumpct = 2
		else:
			jumpct = 1
		
		if (result.visible):
			velocity.x = 0
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_jump") and (jumpct > 0) \
		and !(result.visible):
		velocity.y = JUMP_VELOCITY
		jumpct -= 1
		audio_jmp.play()
		
	if Input.is_action_just_pressed("ui_shoot") and !(result.visible):
		bulletct = get_tree().get_nodes_in_group("BULLET").size()
		#print("bulletct: ", bulletct)
		if (bulletct < bullet_max):
			shoot()

	# Get the input direction and handle the movement/deceleration.
	if !(result.visible):
		direction = Input.get_axis("ui_left", "ui_right")
	if direction and !(result.visible):
		velocity.x = direction * SPEED
	elif !(result.visible):
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	#Set shooting direction upon change
	if (direction == -1 and dir != -1):
		dir = -1
		sprite.flip_h = true
	if (direction == 1 and dir != 1):
		dir = 1
		sprite.flip_h = false
	
	if (Engine.get_process_frames() % 4 == 0):
		if (iframe == true):
			sprite.visible = !(sprite.visible)
		elif (!(sprite.visible) && (iframe == false)):
			sprite.visible = true
	# CHECK FOR COLLISION WITH BOSS WALLS
	# CHECKS IF GROUND HAS SPRITE2D FOR COLLISION
	for i in get_slide_collision_count():
		var collision_info := get_slide_collision(i)
		if collision_info:
			var collider : Object = collision_info.get_collider()
			if not collider or not (collider.has_node("Sprite2D") or collider.has_node("AnimatedSprite2D")):
				add_collision_exception_with(collider)
				
	move_and_slide()
	

func shoot() -> void:
	var bullet = bulletpath.instantiate()
	if (dir == 1):
		bulletpos = Vector2(30, 0)
		bullet.vel = Vector2(1.5, 0)
	else:
		bulletpos = Vector2(-30, 0)
		bullet.vel = Vector2(-1.5, 0)
	
	get_parent().add_child(bullet)
	bullet.boss_hit.connect(bossHit)
	bullet.position = ($Sprite2D.global_position + bulletpos)
	
	audio_shoot.play()

func bossHit() -> void:
	bossHitt.emit()

func _on_boss_hit_player() -> void:
	if (iframe == false):
		iframe = true
		hp -= 1
		hpdec.emit(hp)
		timer.start()
		audio_dmg.play()

func _on_timer_timeout() -> void:
	if (iframe == true):
		iframe = false

func _on_hearts_killplayer() -> void:
	queue_free()


func _on_eye_boss_scene_hit_killbox() -> void:
	hpdec.emit(0)
