extends CharacterBody2D
#dog peeks and laughs
func dog_laugh():
	_move(Vector2(0,-40))
 
func _move(pos):
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position",position + pos,1)
