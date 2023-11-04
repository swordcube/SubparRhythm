extends Node

func value_from_dict(dict:Dictionary, value:String, default:Variant = null):
	return get_default(dict[value] if dict.has(value) else null, default)

func get_default(value:Variant, default_value:Variant):
	return value if value != null else default_value
