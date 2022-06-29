extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(bool) var freedom_degrees

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func recieve_player_temperature(temp):
	$VBoxContainer/Temp.text = "Temperature: %3.1f °C"%temp
	if freedom_degrees:
		$VBoxContainer/Temp.text = "Temperature: %3.1f °F"%((temp*9.0/5.0)+32)

func recieve_player_battery(batt):
	$VBoxContainer/Batt.text = "Battery: %3.1f"%batt+"%"
