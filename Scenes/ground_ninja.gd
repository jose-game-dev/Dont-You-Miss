extends CharacterBody2D

@onready var character_body_2d: CharacterBody2D = $"."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Variables: 
@onready var timer: Timer = $Timer
# Traits: 
@export var gravity: float = 1200
@export var jump_height: float = 500

var speed: float = 350
var direction: int = 1 # If 1 = right, if -1 = left 

signal next_round

func _ready() -> void:
	input_pickable = true

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Horizontal movement 
		velocity.x = speed * direction 
	move_and_slide()
	
	# Sprite rotates
	animated_sprite_2d.flip_h = direction < 0 
	
func _on_input_event(_viewport: Node, event: InputEvent, _shape_ind: int):
#	Checks if the ninja is dead 
	if event.is_action_pressed("shoot"):
		death()
		
func death(): 
	
	input_pickable = false
	
	if is_instance_valid(collision_shape_2d):
		collision_shape_2d.disabled = true  # que no choque más
		
	velocity = Vector2.ZERO
	
	animated_sprite_2d.play("Death")
	await get_tree().create_timer(1).timeout
	velocity = Vector2.DOWN * 100

func _on_screen_notifier_2d_screen_exited(): 
	next_round.emit()
	queue_free()

func _on_move_timer_timeout() -> void:
	# Changes direction if the conditions are true
		direction *= -1

func _on_jump_timer_timeout() -> void:
	# if its on the gorund and the timer is up
	if is_on_floor():
		velocity.y = -jump_height
