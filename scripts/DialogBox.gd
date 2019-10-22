extends RichTextLabel

var page = 0

func _ready():
	#set_bbcode(dialog[page])
	#set_visible_characters(page)
	pass
	
func start(message):
	set_visible_characters(-1)
	get_parent().visible = true
	get_parent().get_node("Timer2").start()
	set_bbcode(message)
	

func _on_Timer_timeout():
	visible_characters += 1
