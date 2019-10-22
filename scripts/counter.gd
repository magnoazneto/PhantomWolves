extends RichTextLabel

onready var wolf_max = get_parent().get_parent().get_parent().total_wolves
var wolf_die = 0
var dialog = ["Wolves: "]
var page = 0
	
func _ready():
	set_process(true)
	set_bbcode(dialog[page] + str(wolf_die) + " / " + str(wolf_max))
	set_visible_characters(14)
	
func refresh():
	wolf_die += 1
	set_bbcode(dialog[page] + str(wolf_die) + " / " + str(wolf_max))
	set_visible_characters(14)
	#print("Refreshed: ", wolf_die)
