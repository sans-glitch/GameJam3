extends Control
var curr_slide_num

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curr_slide_num = 1
	show_slide(1)	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if curr_slide_num > 2:
		$Level1.hide()
		$GolfBall.hide()
	else:
		$Level1.show()
		$GolfBall.show()

func show_slide(num : int):
	var children = get_children()
	for child in children:
		if child is CanvasLayer or child is Control:
			child.hide()
	
	var path_string = str(num)
	var selected_slide = get_node(path_string)
	if selected_slide:
		selected_slide.show()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("ui_right") and curr_slide_num < 6:
		curr_slide_num += 1
		show_slide(curr_slide_num)
	if Input.is_action_just_pressed("ui_left") and curr_slide_num > 1:
		curr_slide_num -= 1
		show_slide(curr_slide_num)
	if event is InputEventMouseButton and (curr_slide_num == 3 or curr_slide_num == 5):
		curr_slide_num += 1
		show_slide(curr_slide_num)
	if Input.is_action_just_pressed("inventory") and curr_slide_num == 4:
		curr_slide_num += 1
		show_slide(curr_slide_num)
