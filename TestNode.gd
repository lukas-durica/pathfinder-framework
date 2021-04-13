extends Node2D

func _ready():
	var vec2_pool = PoolVector2Array()
	var prev_point : Vector2
	for point in $Path2D.curve.tessellate():
		print("point: ", point)
		if prev_point:
			vec2_pool.push_back(prev_point)
			vec2_pool.push_back(point)
		prev_point = point
	
		#$Area2D/CollisionShape2D.shape.segments.push_back(point)
	$Area2D/CollisionShape2D.shape.segments = vec2_pool
	#$Area2D/CollisionShape2D.shape.segments = $Path2D.curve.tessellate()
	print("$Area2D/CollisionShape2D.shape.segments: ", $Area2D/CollisionShape2D.shape.segments.size())


func _on_Area2D_area_entered(area):
	print("area entered")
