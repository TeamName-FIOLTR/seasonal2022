extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func localize_the_physss(cube : RigidBody):
	print("\napplying phys to ", cube.name)
	var local_apply_pos = Vector3.RIGHT
	var local_force_vec = Vector3.UP
	print("local pos: ", local_apply_pos)
	print("local vec: ", local_force_vec)
	print("global transform: ", cube.global_transform)
	
	var stupid_phys_apply = cube.global_transform.basis*local_apply_pos
	var stupid_phys_force = cube.global_transform.basis*local_force_vec
	cube.apply_impulse(stupid_phys_apply,stupid_phys_force)

func do_dum_phys():
	localize_the_physss($cube1)
	localize_the_physss($cube2)
	localize_the_physss($cube3)
	localize_the_physss($cube4)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		do_dum_phys()
