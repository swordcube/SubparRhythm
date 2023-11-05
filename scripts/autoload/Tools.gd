extends Node

var _next_scene:String
var _next_scene_node:Node

func _ready():
	Transition.post_trans_in.connect(func():
		if is_instance_valid(_next_scene_node):
			var tree:SceneTree = get_tree()
			tree.unload_current_scene()
			
			var root:Window = tree.root
			if not root.get_children().has(_next_scene_node):
				root.add_child(_next_scene_node)
				
			tree.current_scene = _next_scene_node
			
			_next_scene_node = null
		else:
			get_tree().change_scene_to_file(_next_scene)
		
		Transition.trans_out()
	)

func value_from_dict(dict:Dictionary, value:String, default:Variant = null):
	return get_default(dict[value] if dict.has(value) else null, default)

func get_default(value:Variant, default_value:Variant):
	return value if value != null else default_value

func switch_scene(file_path:String):
	_next_scene = file_path
	Transition.trans_in()
	
func switch_scene_to_node(node:Node):
	_next_scene_node = node
	Transition.trans_in()
	
func reload_current_scene():
	_next_scene = get_tree().current_scene.scene_file_path
	Transition.trans_in()
