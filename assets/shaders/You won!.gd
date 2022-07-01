extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(int) var amount_of_won = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	amount_of_won = Globalnobel.amount_of_win
	$Label.text = $Label.text%amount_of_won
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
