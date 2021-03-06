class_name DiscordRPCUtil

const Commands: Dictionary = {
	DISPATCH = "DISPATCH",
	AUTHORIZE = "AUTHORIZE",
	AUTHENTICATE = "AUTHENTICATE",
	GET_GUILD = "GET_GUILD",
	GET_GUILDS = "GET_GUILDS",
	GET_CHANNEL = "GET_CHANNEL",
	GET_CHANNELS = "GET_CHANNELS",
	SUBSCRIBE = "SUBSCRIBE",
	UNSUBSCRIBE = "UNSUBSCRIBE",
	SET_USER_VOICE_SETTINGS  = "SET_USER_VOICE_SETTINGS",
	SELECT_VOICE_CHANNEL = "SELECT_VOICE_CHANNEL",
	GET_SELECTED_VOICE_CHANNEL = "GET_SELECTED_VOICE_CHANNEL",
	SELECT_TEXT_CHANNEL = "SELECT_TEXT_CHANNEL",
	GET_VOICE_SETTINGS = "GET_VOICE_SETTINGS",
	SET_VOICE_SETTINGS = "SET_VOICE_SETTINGS",
	CAPTURE_SHORTCUT = "CAPTURE_SHORTCUT",
	SET_CERTIFIED_DEVICES = "SET_CERTIFIED_DEVICES",
	SET_ACTIVITY = "SET_ACTIVITY",
	SEND_ACTIVITY_JOIN_INVITE = "SEND_ACTIVITY_JOIN_INVITE",
	CLOSE_ACTIVITY_REQUEST = "CLOSE_ACTIVITY_REQUEST"
}

const Events: Dictionary = {
	READY = "READY",
	ERROR = "ERROR",
	GUILD_STATUS = "GUILD_STATUS",
	GUILD_CREATE = "GUILD_CREATE",
	CHANNEL_CREATE = "CHANNEL_CREATE",
	VOICE_CHANNEL_SELECT = "VOICE_CHANNEL_SELECT",
	VOICE_STATE_CREATE = "VOICE_STATE_CREATE",
	VOICE_STATE_UPDATE = "VOICE_STATE_UPDATE",
	VOICE_STATE_DELETE = "VOICE_STATE_DELETE",
	VOICE_SETTINGS_UPDATE = "VOICE_SETTINGS_UPDATE",
	VOICE_CONNECTION_STATUS = "VOICE_CONNECTION_STATUS",
	SPEAKING_START = "SPEAKING_START",
	SPEAKING_STOP = "SPEAKING_STOP",
	MESSAGE_CREATE = "MESSAGE_CREATE",
	MESSAGE_DELETE = "MESSAGE_DELETE",
	NOTIFICATION_CREATE = "NOTIFICATION_CREATE",
	ACTIVITY_JOIN = "ACTIVITY_JOIN",
	ACTIVITY_SPECTATE = "ACTIVITY_SPECTATE",
	ACTIVITY_JOIN_REQUEST = "ACTIVITY_JOIN_REQUEST"
}
