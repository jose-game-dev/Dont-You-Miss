extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var speed: float = 250

signal next_round

func _ready():
	input_pickable = true
	velocity = _random_up_direction() * speed
	
func _random_up_direction():
	var x = deg_to_rad(randf_range(0,180))
	return Vector2(cos(x), sin(x)).normalized()
	
func _physics_process(delta):
	var col = move_and_collide(velocity * delta)
	
	if col:
		velocity = velocity.bounce(col.get_normal())
		
	_check_direction()
	
func _check_direction():
	if velocity.x <0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
		


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("shoot"):
		#when we click the demon it gets destroyed
		death()
		

func death():
	input_pickable = false 
	
	if is_instance_valid(collision_shape_2d):
		collision_shape_2d.disabled = true  # que no choque más

	velocity = Vector2.ZERO
	
	sprite.play("Death")
	await get_tree().create_timer(1).timeout
	velocity = Vector2.DOWN * 600


func _on_screen_notifier_2d_screen_exited():
	next_round.emit()
	queue_free()
