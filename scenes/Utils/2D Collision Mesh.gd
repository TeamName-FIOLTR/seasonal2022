tool
extends CollisionPolygon2D


export(NodePath) var target_mesh_object setget set_target_mesh_obj

func set_target_mesh_obj(n_obj):
	target_mesh_object = n_obj
	if not is_inside_tree(): yield(self, "ready")
	generate_collision_polygon()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func generate_collision_polygon():
	print("getting mesh node")
	var mesh_object = get_node_or_null(target_mesh_object)
	if mesh_object:
		print("yup node exists alright")
		var mesh_node = mesh_object.get_child(0)
		if mesh_node is MeshInstance:
			print("aaand it's even a MeshInstance, why won't you look at that")
			var mesh = mesh_node.mesh
			var mesh_array = mesh.surface_get_arrays(0)
#			var new_shape = ConvexPolygonShape2D.new()
			var new_vert_array : PoolVector2Array
			var mesh3d_vert_array = mesh_array[0]
			var vert_count = len(mesh3d_vert_array)
			print("thing has %s verticies, wow"%vert_count)
			new_vert_array.resize(vert_count)
			for vert_idx in range(vert_count):
				new_vert_array[vert_idx].x = mesh3d_vert_array[vert_idx].x
				new_vert_array[vert_idx].y = -mesh3d_vert_array[vert_idx].y
#			new_shape.points = new_vert_array
#			shape = new_shape
			polygon = new_vert_array
			$"Test Polygon".polygon = new_vert_array
			print("aaaand it should be done")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
