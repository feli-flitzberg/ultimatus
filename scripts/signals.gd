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
		new.save("user://settings.ini")
	return new
func scoresave(score, time):
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
	conf.save("user://settings.ini")
