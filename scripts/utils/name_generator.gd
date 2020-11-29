extends Node

var names = ['Adara', 'Adena', 'Adrianne', 'Alarice', 'Alvita', 'Amara', 'Ambika', 'Antonia', 'Araceli', 'Balandria', 'Basha',
'Beryl', 'Bryn', 'Callia', 'Caryssa', 'Cassandra', 'Casondrah', 'Chatha', 'Ciara', 'Cynara', 'Cytheria', 'Dabria', 'Darcei',
'Deandra', 'Deirdre', 'Delores', 'Desdomna', 'Devi', 'Dominique', 'Drucilla', 'Duvessa', 'Ebony', 'Ezzuh', 'Eohda', 'Fantine', 
'Fuscienne', 'Farsha', 'Gabi', 'Gallia', 'Grokk', 'Hanna', 'Hedda', 'Jerica', 'Jetta', 'Joby', 'Kacila', 'Kagami', 'Kala', 'Kallie', 
'Keelia', 'Kerry', 'Kimberly', 'Killian', 'Kory', 'Lilith', 'Lucretia', 'Lysha', 'Mercedes', 'Mia', 'Maura', 'Perdita', 'Quella',
'Riona', 'Safiya', 'Salina', 'Severin', 'Sidonia', 'Sirena', 'Solita', 'Tempest', 'Thea', 'Treva', 'Trista', 'Vala', 'Winta', 'Xarka',
'Xena', 'Yuzz', 'Yara', 'Zakarr', 'Osebri', 'Guocha']

var alphabet = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']

var markov = {}

func _ready():
	_load_names()

func _load_names():
	for name in names:
		var currName = name
		for i in range(currName.length()):
			var currLetter = currName[i].to_lower()
			var letterToAdd;
			if i == (currName.length() - 1):
				letterToAdd = "."
			else:
				letterToAdd = currName[i+1]
			var tempList = []
			if markov.has(currLetter):
				tempList = markov[currLetter]
			tempList.append(letterToAdd)
			markov[currLetter] = tempList

func _get_name(firstChar = null, minLength = 3, maxLength = 8):
	var count = 1
	var name = ""
	if firstChar:
		name += firstChar
	else:
		var random_letter = alphabet[_roll(0, alphabet.size()-1)]
		name += random_letter
	while count < maxLength:
		var new_last = name.length()-1
		var nextLetter = _get_next_letter(name[new_last].to_lower())
		if str(nextLetter) == ".":
			if count > minLength:
				return name
		else:
			name += str(nextLetter)
			count+=1
	return name

func _get_next_letter(letter):
	var thisList = markov[letter]
	return thisList[_roll(0, thisList.size()-1)]

# Random number generator
func _roll(l,h):
	return int(round(rand_range(l,h)))
	
func get_name_planet() -> String:
	
	var new_name = ""
	
	# Number in front
	if randf() < 0.3:
		new_name += "%d " % (randi() % 8000 + 1000)
		
	
	# Planet name
	new_name += _get_name().capitalize()
	
	# Roman number after
	if randf() < 0.3:
		var roman = ""
		var max_char = 3
		
		for _i in range(randi() % 5 + 1):
			var roman_char = randi() % (max_char + 1)
			match roman_char:
				1:
					roman += "I"
				2:
					roman += "V"
				3:
					roman += "X"

			max_char = min(roman_char, max_char)

		new_name += " %s" % roman
	return new_name

func get_name_galaxy() -> String:
	return get_name_planet()
	
func get_name_ship() -> String:
	return get_name_planet()
	
func get_name_asteroid() -> String:
	return get_name_planet()
