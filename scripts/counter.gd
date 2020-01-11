extends RichTextLabel

onready var wolf_max = Network.total_wolves
onready var wolf_die = Network.dead_wolves
var dialog = ["Wolves: "]
var page = 0
	
func _ready():
	set_process(true)
	set_bbcode(dialog[page] + str(wolf_die) + " / " + str(wolf_max))
	set_visible_characters(14)

func _process(delta):
	set_bbcode(dialog[page] + str(Network.dead_wolves) + " / " + str(wolf_max))
	set_visible_characters(14)

