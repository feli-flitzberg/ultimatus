extends Node

# player/enemy signals
signal pos(playerpos: Vector2)
signal wipe(wattack, wslow)
signal heal(value)
signal addscore(value)
signal dead

# ui signals
signal startrun
signal started
signal endrun(score, time)
signal pause
signal pausecalled
signal unpause

# reusing the autoload for stats/settings functions
var config = ConfigFile.new()
var conf = configure()
func configure():
	var new = config
	var err = new.load("user://settings.ini")
	if err != OK:
		new.set_value("Scores", "hiscore", 0)
		new.set_value("Scores", "hiscoretime", 0)
		new.set_value("Scores", "hitime", 0)
		new.set_value("Scores", "hitimescore", 0)
		new.set_value("Scores", "curscore", 0)
		new.set_value("Scores", "curtime", 0)
		new.set_value("Settings", "senable", true)
		new.set_value("Settings", "menable", true)
		new.set_value("Settings", "svol", 1)
		new.set_value("Settings", "mvol", 1)
		new.set_value("Settings", "tmode", false)
		new.save("user://settings.ini")
	return new

func scoresave(score, time):
	var tsenable = conf.get_value("Settings", "senable", true)
	var tmenable = conf.get_value("Settings", "menable", true)
	var tsvol = conf.get_value("Settings", "svol", 1)
	var tmvol = conf.get_value("Settings", "mvol", 1)
	var ttmode = conf.get_value("Settings", "tmode", false)
	var scorecheck = conf.get_value("Scores", "hiscore", 0)
	if score > scorecheck:
		conf.set_value("Scores", "hiscore", score)
		conf.set_value("Scores", "hiscoretime", time)
	var timecheck = conf.get_value("Scores", "hitime", 0)
	if time > timecheck:
		conf.set_value("Scores", "hitime", time)
		conf.set_value("Scores", "hitimescore", score)
	conf.set_value("Scores", "curscore", score)
	conf.set_value("Scores", "curtime", time)
	conf.set_value("Settings", "senable", tsenable)
	conf.set_value("Settings", "menable", tmenable)
	conf.set_value("Settings", "svol", tsvol)
	conf.set_value("Settings", "mvol", tmvol)
	conf.set_value("Settings", "tmode", ttmode)
	conf.save("user://settings.ini")

func configsave(senable, menable, svol, mvol, tmode):
	var thiscore = conf.get_value("Scores", "hiscore", 0)
	var thiscoretime = conf.get_value("Scores", "hiscoretime", 0)
	var thitime = conf.get_value("Scores", "hitime", 0)
	var thitimescore = conf.get_value("Scores", "hitimescore", 0)
	var tcurscore = conf.get_value("Scores", "curscore", 0)
	var tcurtime = conf.get_value("Scores", "curtime", 0)
	conf.set_value("Scores", "hiscore", thiscore)
	conf.set_value("Scores", "hiscoretime", thiscoretime)
	conf.set_value("Scores", "hitime", thitime)
	conf.set_value("Scores", "hitimescore", thitimescore)
	conf.set_value("Scores", "curscore", tcurscore)
	conf.set_value("Scores", "curtime", tcurtime)
	conf.set_value("Settings", "senable", senable)
	conf.set_value("Settings", "menable", menable)
	conf.set_value("Settings", "svol", svol)
	conf.set_value("Settings", "mvol", mvol)
	conf.set_value("Settings", "tmode", tmode)
	conf.save("user://settings.ini")
