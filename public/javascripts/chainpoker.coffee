#Points and Paths - alpha

#ok, starting point? MnSp?
#	pull over: lots of misc PM stuff, board locking(from MnSp)
#	new(?): clicks, thin-accelerate, img load

#I guess the 1st todo is getting sprites to sit (vs die at end of path)
#	maybe we make groups static?

#gotta lock to board after thin
#--

#$ ->
#  myGame = new Game
#  myGame.run()
#PE = require("poker-evaluator")

class Game
	constructor: ->
		host = "http://localhost:3000"
#		host = "http://frozen-gorge-8975.herokuapp.com"  #is this the problem?? imgs not serving??
		@dev = true

		#load images
		@cardsImg = new Image
		@cardsImg.src = host + "/../images/cards4.png"

		@canvas = document.getElementById('canvas')
		@ctx = canvas.getContext("2d")

		HTMLCanvasElement.prototype.relMouseCoords = @relMouseCoords  #??

		@x = 0
		@y = 0
		@hand = []
		@handPts = [] #?

		@timer = 7200  #consider using only the first 90 frames
		@score = 0

		@scoreBank = []
		@timerBank = []

		@cardBG = new Image
		@cardBG.src = host + "/../images/cardBG.png"

		for i in [0..3]
			@loadImg = new Image
			@loadImg.src = host + "/../images/scoreImageBank#{i}a.png"
			@scoreBank.push(@loadImg)
			@loadImg = new Image
			@loadImg.src = host + "/../images/clockImageBank#{i}a.png"
			@timerBank.push(@loadImg)


		@tFrameNum = 0 #0-119; (timer/120).toInt?
		@scFrameNum = 0 #0-119; using 0-89 at present

		#["bridge_charged","bridge_charged_hover","joker_charged","joker_charged_hover","rotate_charged","rotate_charged_hover","shuffle_charged","shuffle_charged_hover","suits_charged","suits_charged_hover"] #,"bomb_charged","bomb_charged_hover"]
		@boardTiles = ["break","shuffle","joker","rotate","reroll","bridge"]	#,"PokerMGraphics/CardBack1"]
		@powerImgs = (new Image for i in [0..@boardTiles.length-1])
		@powerImgs[i].src = "http://localhost:3000/../images/#{e}.png" for e,i in @boardTiles  #ImgScroll/
#		@powerImgs[i].src = "http://frozen-gorge-8975.herokuapp.com/../images/#{e}.png" for e,i in @boardTiles  #ImgScroll/

		@powerNotes = ["Break","Shuffle","Joker","Rotate","ReRoll","Bridge"]
		@powerLoc = ([625,y] for y in [250..500] by 50) #[[600,150],[600,200],[600,250],[600,300],[600,350],[600,400]]



		@bank = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]
		@bankFrameX = [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5]
		@bankFrameY = [0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4]

		@boards = [[[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]], [[0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1]], [[0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1]], [[0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0], [0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0], [0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0], [0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0], [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0], [0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0], [0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0], [0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0], [0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 0, 0], [0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0], [0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0], [0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0], [0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0]], [[0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0], [0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0], [0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]], [[0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0], [0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0], [1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1], [1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1], [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1], [1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1], [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0], [0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]], [[1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1], [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1], [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], [1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], [1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]], [[0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0], [1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0], [0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0], [0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1], [0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0], [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0], [1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1], [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0], [0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1], [0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0], [1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0], [0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0]], [[1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1], [0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0], [0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0], [0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0], [1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0], [1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0, 0], [1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0], [1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0], [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0], [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0], [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0], [1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]], [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0], [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0], [0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]], [[1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0], [1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0], [1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1], [0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1], [0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1], [1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0], [1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1], [0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0]], [[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1], [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1], [1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1], [1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1], [1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1], [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1], [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1], [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]], [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1], [1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1], [1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1], [1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1], [1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1], [1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1], [1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1], [1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1], [1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1], [1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1], [1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1], [1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]], [[1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1], [1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1], [1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1], [1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1], [1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1], [1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0]], [[1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]], [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0], [1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1], [0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0], [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0]], [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0], [1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1], [0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]], [[0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0]], [[1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0], [1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0], [1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0], [1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0], [1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0], [1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0], [1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1], [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0], [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0], [1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]], [[0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], [0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0], [0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0], [0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0], [0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]], [[0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0], [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0], [0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0], [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0], [0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0], [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0], [0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1]], [[0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0], [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0], [0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1], [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0], [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0], [0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1], [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0], [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0], [0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1], [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0], [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0], [0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1], [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0], [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0]], [[1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1], [1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1], [1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1], [0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1], [0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1], [1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0], [1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1], [0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0], [1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1], [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1], [1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0], [1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1]], [[1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0], [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0], [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0], [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1], [1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1]], [[1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1], [1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1], [1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1], [1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1], [1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1]], [[1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1], [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1], [1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]], [[0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0], [0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0], [1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1], [0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0], [0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0], [0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0], [0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0]], [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1], [1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1], [1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1], [1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1], [1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1]], [[0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0], [1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1], [1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1], [0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0], [0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0], [0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0], [0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0], [0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0], [0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0], [1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1], [1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1], [0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0]], [[1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1], [1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0], [0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0], [0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0], [0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0], [0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0], [0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0], [0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0], [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0], [1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1], [1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]], [[1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]]

#		@boardNames = []
		@boardOrder = [0, 27, 13, 15, 29, 12, 11, 28, 10, 20, 2, 1, 8, 4, 30, 25, 24, 22, 18, 19, 17, 16, 5, 23, 7, 3, 6, 21, 26, 14, 9]

#		@curOrder = 0
#		@plus = true #use mouseHit() instead of mouseDown()??
		#@level = 0 #@curOrder??
#		@curBoard = (e.slice(0) for e in @boards[0])
#		@backBoard = (e.slice(0) for e in @boards[0]) #for animations
#		@markBoard = (e.slice(0) for e in @boards[0])
		@rotPos = (e.slice(0) for e in @boards[0])
		@rotBackBoard = (e.slice(0) for e in @boards[0])
		@shufflePos = (e.slice(0) for e in @boards[0])
		@shuffleBackBoard = (e.slice(0) for e in @boards[0])

		@stack = []
		@shuffleList = []

		@boardLock = false

		@lastPos = []
		@firstPos = []

		@canvas = document.getElementById('canvas')
		@ctx = canvas.getContext("2d")
		@ctx.font = "24px Arial"

		HTMLCanvasElement.prototype.relMouseCoords = @relMouseCoords  #??

		#relative mouse coords support #are we using this now??
		@stylePaddingLeft = parseInt(document.defaultView.getComputedStyle(canvas, null)['paddingLeft'], 10)      || 0
		@stylePaddingTop  = parseInt(document.defaultView.getComputedStyle(canvas, null)['paddingTop'], 10)       || 0
		@styleBorderLeft  = parseInt(document.defaultView.getComputedStyle(canvas, null)['borderLeftWidth'], 10)  || 0
		@styleBorderTop   = parseInt(document.defaultView.getComputedStyle(canvas, null)['borderTopWidth'], 10)   || 0
		# Some pages have fixed-position bars (like the stumbleupon bar) at the top or left of the page
		# They will mess up mouse coordinates and this fixes that

		@canvasMinX = $("#canvas").offset().left
		@canvasMinY = $("#canvas").offset().top

		#call these once?
		$(document).mousedown(@onMouseDown)
		$(document).mouseup(@onMouseUp)
		$(document).mousemove(@onMouseMove)
		$(document).keydown(@onKeyDown)

		@sprList = []

		@power = 0

		@breaks = 100
		@shuffles = 100
		@jokers = 100
		@rotates = 100
		@rerolls = 100
		@bridges = 100

		#used?
		@breaksX = 600
		@shufflesX = 600
		@jokersX = 600
		@rotatesX = 600
		@rerollsX = 600
		@bridgesX = 600

		@breaksY = 150
		@shufflesY = 200
		@jokersY = 250
		@rotatesY = 300
		@rerollsY = 350
		@bridgesY = 400

		@activeup = -1

		#----------
		#i1/j1 calcs? 220, 260; [220-(6-i)*40,220-(6-j)*40]; [220-(6-i)*40,260+(j-7)*40]; [260+(i-7)*40,220-(6-j)*40];[260+(i-7)*40,260+(j-7)*40]
		for i in [0..13]
			for j in [0..13]
				i1 = -20-(6-i)*40 if i<7  #these are all offset by 20 (to center the cards)
				j1 = -20-(6-j)*40 if j<7
				i1 = 20+(i-7)*40 if i>6
				j1 = 20+(j-7)*40 if j>6

				frac = Math.PI/60.0
				r = Math.sqrt((i1*i1+j1*j1))
				startTh = Math.atan2(i1,j1)
				#[i][j][index][x], [index][y]
				@rotPos[i][j] = ([Math.round(r * Math.sin(startTh-th*frac))+20, Math.round(r * Math.cos(startTh-th*frac))+20] for th in [0..29])

		@rotBoardIndex = 0 #serves entire board
		@rotBoard = false

		@shuffleIndex = 0
		@shuffleBoard = false

		@select = []

		setInterval(@main, 60) #was 200?
#		setInterval(@cleanSprites,2)

		@spriteQ = [[]]
		@spriteB = [[]]
		@effectQ = [[]]
		@upQ = [[]]


		@upsB = new Board(610,290,1,6,40,40)
		@ups = (new Sprite(@powerImgs,[@sprPos(@upsB,e[0],e[1])]) for e in @upsB.luta)
		@ups[@bPos1(@upsB,s.pos[0],s.pos[1])] = s for s in @ups
		e.id = i for e,i of @ups
		@upQ.unshift(@ups)
		$('#out').text(JSON.stringify([@ups.length,@upQ[0].length,@upsB.luta]))


		@B = new Board(50,50,14,14,40,40)  #**are we not using these at present??
		@B.setmask(@boards[0])

		@cardsSrcIndex = ([i%4*40,i%13*40] for i in [0..51]) #only works if sheet is drawn "right"

		@sprites = (new Sprite(@cardsImg,[@sprPos(@B,e[0],e[1])]) for e in @B.maska)
		@sprites[@bPos1(@B,s.pos[0],s.pos[1])] = s for s in @sprites #is this working??

		@spriteQ.unshift(@sprites)
		e.id = @xRand(52) for e in @spriteQ[0] #??

#		$('#out').text(JSON.stringify([(e? for e in @columns(@B,@spriteQ[0])[5] when e?)]))   #WTF, why is this different than the same thing below?? !! ??

#		@ups = new board(50,50,16,16,40,40)

		@mmLock = false
		@mdLock = false

#		window.onload = =>

#		$('#out').text(JSON.stringify([@spriteQ[0].length]))
		@cnt = 0

	@time = new Date()

#	fillBoard: (B,sprB) -> sprB.push(new Sprite(@cardsImgs, [p[0],p[1]], {id: @xRand(52)})) for p in B.mask  #flexible construct using map??

	#----------
	#Knuth shuffle
	knuth: (l) ->
		i = l.length
		return false if i is 0
		while --i
			j = Math.floor(Math.random() * (i+1))
			[l[i], l[j]] = [l[j], l[i]]

	mkShufflePaths: () ->
		@shuffleList = []
		for row,x in @curBoard
			for c,y in row
				@shuffleList.push([x,y]) if c isnt 0

		knuth(@shufflelist)

		#knuth
#		i = @shuffleList.length
#		#return false if i is 0
#		while --i
#		    j = Math.floor(Math.random() * (i+1))
#		    [@shuffleList[i], @shuffleList[j]] = [@shuffleList[j], @shuffleList[i]]

		while @shuffleList.length > 1
			a = @shuffleList.pop()
			b = @shuffleList.pop()

			[@curBoard[a[0]][a[1]],@curBoard[b[0]][b[1]]] = [@curBoard[b[0]][b[1]],@curBoard[a[0]][a[1]]]
			#**Gotta change from board coords to screen coords (before rounding)
			c = [(a[0]+b[0])/2,Math.abs(a[1]-b[1])+2]
			@shufflePos[b[0]][b[1]] = @benzier(a,b,c,30)
			@shufflePos[a[0]][a[1]] = @shufflePos[b[0]][b[1]].slice(0).reverse() #benzier() #shufflePos[a[0],a[1]].reverse
#		$('#out').text(JSON.stringify([@shufflePos[a[0]][b[1]]]))

	#----- usefull fns -----
	mapentries: (m) -> (e for k,e of m)
	add: (a,b) -> a+b
	concatFn: (a,b) -> a.concat(b)
	xRand: (e) -> Math.floor(Math.random()*e)
	vRand: (e) ->
		i = @xRand(e.length)
		e[i]
	flipIJ: (a) -> [a[1],a[0]] #realign flipped coords
	flattenOne: (arr) -> arr.reduce(@concatFn,[])
#	knuth: (a) ->
#		n = a.length
#		while n > 1
#			r = @xRand(n)
#			n -= 1
#			[a[n], a[r]] = [a[r], a[n]]
#		a

	lockinput: () ->
		$(document).off('mousedown',@onMouseDown)
		$(document).off('mouseup',@onMouseUp)
		$(document).off('mousemove',@onMouseMove)
		$(document).off('keydown',@onKeyDown)

	unlockinput: () ->
		$(document).on('mousedown',@onMouseDown)
		$(document).on('mouseup',@onMouseUp)
		$(document).on('mousemove',@onMouseMove)
		$(document).on('keydown',@onKeyDown)


#	addB: (B, Q, s) ->
	#rmB: () ->

	#-----||-----||-----
	main: =>
		@ctx.clearRect(0,0,800,600)
		@processSpriteQ(@spriteQ)
		@processSpriteQ(@effectQ)
		@processSpriteQ(@upQ)

		#@rendTime()  #how are we handling timer??
		@renderCards(@spriteQ)
		@renderQ(@upQ)

		@timer -= 1 if @timer > 0
		#gameOver() if @timer < 1 and @curBoard is 25
		@tFrameNum = parseInt((7200-@timer)/60)

		@cnt++
#		$('#out').text(JSON.stringify([[@x,@y], @activeup, @spriteQ[0].length]))

#		$('#out').text(JSON.stringify([PE.evalHand("As","Ks","Qs","Js","Ts","3c","5h")]))


#	cleanSprites(sprList): => sprList = (spr for spr in sprList when spr.kill)

	#so, we're assuming spriteQ...
	processSpriteQ: (q) ->
		q.shift() if q[0].length is 0 and q[1]?
#		q[0] = (s for s in q[0] when s.kill isnt true)  #this is fucking things up, maybe that's why we were cleaning less often??

		for s in q[0]
			s.pos = s.path.shift() ? s.pos
#			s.kill = true if s.path.length is 0  #defaults to sitting now? otherwise sets kill for cleanup? when/where?
			s.v = [s.v[0]+s.a[0], s.v[1]+s.a[1]]
			s.pos = [s.pos[0]+s.v[0], s.pos[1]+s.v[1]]

#			@ctx.drawImage(s.img,s.pos[0],s.pos[1]) if s.img?  #time cost vs utility of behavior sprites??
			s.update()
			#(collisions and clicks)

	renderQ: (Q) ->
#		$('#out').text(JSON.stringify(["renderQ",Q[0].length,Q[0][0].img[0]?,([i,s.img[i]?] for i,s of Q[0] when s.img[i]?)]))  #what jank
		@ctx.drawImage(s.img[i],s.pos[0],s.pos[1]) for i,s of Q[0] when s.img[i]? #what jank

	renderCards: (Q) ->  #accept board?
		@ctx.globalAlpha = 1

		for s in Q[0]
			xy = @cardsSrcIndex[[s.id]]
			@ctx.drawImage(s.img,xy[0],xy[1],40,40,s.pos[0],s.pos[1],40,40) if not @select[@bPos(@B,s.pos[0],s.pos[1])]

		@ctx.globalAlpha = 0.5
		@ctx.fillStyle = "#000000"
		for e in @select
			[x,y] = @sprPos(@B,e[0],e[1])
			@ctx.fillRect(x,y,40,40)
		@ctx.globalAlpha = 1

		@ctx.drawImage(@scoreBank[@bank[@scFrameNum]],@bankFrameX[@scFrameNum]*108,@bankFrameY[@scFrameNum]*108,108,108,600,100,108,108)
		@ctx.drawImage(@timerBank[@bank[@tFrameNum]],@bankFrameX[@tFrameNum]*108,@bankFrameY[@tFrameNum]*108,108,108,600,100,108,108)


	#---------------
	eval: (h) ->
#		$('#out').text(JSON.stringify([@hand,h]))

		type = [null,"no pair",null,null,null,"pair",null,null,"two pair","set","straight","flush","full house","quads","straight flush",null,null,"quints"]
		score = [null,0,null,null,null,1,null,null,2,3,4,5,6,7,8,null,null,9] #mkFlush=Straight?
		jokers = 0
		jokers += 1 for i in h when i is 53
		h = (e for e in h when e isnt 53)

		suits = (c%4 for c in h)
		ranks = (c%13 for c in h)
		cardsInHand = (0 for i in [0..13])

		cardsInHand[e%13] += 1 for e in h
		suitsInHand = (0 for i in [0..3])
		suitsInHand[e%4] += 1 for e in h

		flush = false
		suitsInHand[i] += jokers for i in [0..3]
		flush = true for i in suitsInHand when i is 5

		cardsInHand[13] = cardsInHand[0]

		pairs = 0
		set = false
		quads = false
		quints = false
		for i in [0..12] #13?
			cih = cardsInHand[i]
			pairs = pairs + 1 if cih >= 2
			set = true if cih >= 3
			quads = true if cih >= 4
			quints = true if cih is 5
			js = jokers
			straightCount = 1 #+ js
			if cih is 1 and i < 10
				j = 1
				while (cardsInHand[i+j] is 1 or js isnt 0)
					straightCount += 1 if cardsInHand[i+j] is 1 or js > 0
					js -= 1 if cardsInHand[i+j] is 0
					j += 1
				permStraightCount = true if straightCount is 5

		handScore = 1
		handScore = 5 if pairs is 1
		handScore = 8 if pairs is 2
		handScore = 9 if set
		handScore = 10 if permStraightCount
		handScore = 11 if flush
		handScore = 12 if set and pairs is 2
		handScore = 13 if quads
		handScore = 14 if flush and permStraightCount  #is 5
		handScore = 17 if quints

		while((jokers>0) and ((handScore is 1) or (handScore is 9) or (handScore is 13) or (handScore is 8)))
			handScore += 4
			jokers -= 1

#		$('#out').text(JSON.stringify([type[handScore]]))

		score[handScore]


	#-----**Mouse Events**-----
	compPts: (p, p1) -> p[0] == p1[0] and p[1] == p1[1]

	onMouseDown: (e) =>
		#[@x,@y] = canvas.relMouseCoords(e)
		[xr,yr] = @getPosition(e)
		[@x,@y] = @bPos(@B,xr,yr)

#		$('#out').text(JSON.stringify([[@x,@y], @activeup]))

		[x1,y1] = @bPos(@upsB,xr,yr)
#		$('#out').text(JSON.stringify([[x1,y1]]))

		if -1 < @x < 14 and -1 < @y < 14  #@B.bWidth		#(@x isnt -1) and (@y isnt -1)
			switch @activeup
				when 0
					#if not @spriteQ[0][@x,@y]   #**right, huh, we have to add it to the B.maska too ??
					if @spriteQ[0][[@x,@y]] isnt 1 #and @x @y

						s = new Sprite(@cardsImg,[@sprPos(@B,@x,@y)])  #**gotta change forth and back to lock ??**
						s.id = @xRand(52)
						@spriteQ[0].push(s)
						@spriteQ[0][[@x,@y]] = s #true

						@B.maska.push([@x,@y]) #**hmm... bridged tiles still not dropping quite right**
						@B.maska[[@x,@y]] = true

#						@sprites = (new Sprite(@cardsImg,[@sprPos(@B,e[0],e[1])]) for e in @B.maska)
#						@sprites[@bPos1(@B,s.pos[0],s.pos[1])] = s for s in @sprites #is this working??
#						@spriteQ.unshift(@sprites)
#						e.id = @xRand(52) for e in @spriteQ[0] #??

				when 1
					@activeup = -1 #filler

				else
					@mdLock = true

					@select = [[@x,@y]]
					@select[[@x,@y]] = true
#					$('#out').text(JSON.stringify(["true",@select]))

#["bridge_charged","bridge_charged_hover","joker_charged","joker_charged_hover","rotate_charged","rotate_charged_hover","shuffle_charged","shuffle_charged_hover","suits_charged","suits_charged_hover"] #,"bomb_charged","bomb_charged_hover"]
		#activate here, and check... above?
		if x1 is 0
			switch y1
				when 0 #bridge
					if @activeup isnt 0
						@activeup = 0
					else
						@activeup = -1

				when 1 #joker
					@activeup = 1
					#do we have a set() for the board yet??  **must be able to interact seemlessly

	onMouseMove: (e) =>
#		$('#out').text(JSON.stringify([@select]))
		hand = (@spriteQ[0][s].id for s in @select)
#		$('#out').text(JSON.stringify([@select,hand,@eval(hand),@activeup]))  #,@printQ(@spriteQ[0])

		if @mdLock
			[xr,yr] = @getPosition(e)
			[@x,@y] = @bPos(@B,xr,yr)

			if (@x isnt -1) and (@y isnt -1) and @spriteQ[0][[@x,@y]]?
				if not @select[[@x,@y]]? and @select.length<5 and Math.abs(@x-@select[@select.length-1][0]) < 2 and Math.abs(@y-@select[@select.length-1][1]) < 2
					@select.push([@x,@y])
					@select[[@x,@y]] = true

				if @select.length>1 and @compPts(@select[@select.length-2], [@x,@y])
					e = @select.pop()
					delete @select[e]


	onMouseUp: (e) =>
#		$('#out').text(JSON.stringify([@select]))

		hand = (@spriteQ[0][s].id for s in @select)
#		$('#out').text(JSON.stringify([@select,hand,@eval(hand)]))  #,@printQ(@spriteQ[0])

		if @select.length>1
			@lockinput()
			delete @spriteQ[0][s] for s in @select
			@spriteQ[0].pop() while @spriteQ[0][0]? #??
			@spriteQ[0].push(e) for k,e of @spriteQ[0]  #so, ugly...

			@scFrameNum += @eval(hand)

			longpath = 0
			for c in @columns(@B,@spriteQ[0])
				go = false
				cnt = 0
				while c.length>0
					spr = c.pop()
					cnt++ if go and not spr?
					if spr?
						go = true if not go
						spr.path = (@thin(@bline(spr.pos,[spr.pos[0],spr.pos[1]+cnt*@B.tHeight]),8)) if go and cnt > 0
						longpath = cnt if cnt > longpath

			s = @mkBehavior =>
				@locktoB(@B, @spriteQ[0])
				@unlockinput()
				for e in @B.maska
					if not @spriteQ[0][e]?
						s = new Sprite(@cardsImg,[@sprPos(@B,e[0],e[1])])
						s.id = @xRand(52)
						@spriteQ[0][e] = s
						@spriteQ[0].push(s)
						#add some sort of fade in

			s.update = ->
				@delay++
				@pkux() if @delay > longpath*5   #why don't we need a closure here

			@effectQ.unshift([s])

		@mdLock = false
		@select = []

	onKeyDown: (e) =>

	#the miki725 solution
	getPosition: (e) ->
		if !e
			e = window.event
		if e.target
			targ = e.target
		else if e.srcElement
			targ = srcElement
		if targ.nodeType == 3  #for safari bug; still needed?
			targ = targ.parentNode

		x = e.pageX - $(targ).offset().left
		y = e.pageY - $(targ).offset().top

		[x,y]


	#-----Path Creation Tools-----
	zeroPath: (start, rep) -> (start for i in [0..rep])
	line: (p0,p1,nSeg) -> false

	bline: (pnt1,pnt2) ->  #bresenham's
		p1 = pnt1[..]
		p2 = pnt2[..]
		dx = Math.abs(p2[0] - p1[0])
		dy = Math.abs(p2[1] - p1[1])
		sx = if p1[0] < p2[0] then 1 else -1
		sx = 0 if p1[0] is p2[0]
		sy = if p1[1] < p2[1] then 1 else -1
		sy = 0 if p1[1] is p2[1]
		err = (if dx>dy then dx else dy)/2

		path = []
		while true
			path.push([p1[0],p1[1]])
			break if (p1[0] is p2[0]) and (p1[1] is p2[1])
			e2 = err
			if e2 > -dx
				err -= dy
				p1[0] += sx
			if e2 < dy
				err += dx
				p1[1] += sy
		path

	benzier: (p1,p2,p3,nSeg) ->
		path = []
		for i in [0..nSeg]
			t = i/nSeg
			t1 = 1.0-t
			a = Math.pow(t1,2)
			b = 2.0*t*t1
			c = Math.pow(t,2)

			path.push([Math.round((a*p1[0]+b*p2[0]+c*p3[0])*40),Math.round((a*p1[1]+b*p2[1]+c*p3[1])*40)])
		path

	circle: (p1, r, nSeg) -> ([Math.floor(r*Math.cos(angle)+p1[0]), Math.floor(r*Math.sin(angle)+p1[1])] for angle in [0..2*Math.PI] by 2*Math.PI/(nSeg-1))

	#bcircle: (p1,r) -> false

	thin: (path,rate) -> (i for i in path by rate) #first pass on thin

	drawPath: (path) ->
		@ctx.moveTo(path[0][0],path[0][1])
		for [i,j] in path
			@ctx.lineTo(i,j)
			@ctx.stroke()

	rotatePathR: (path,count) -> path.shift(path.pop()) for i in [0..count]
	rotatePathL: (path,count) -> path.push(path.unshift()) for i in [0..count]

	#pntsInCircle/square/rect... rndPntsIn... drawConnectedPath, guassianThin/rndGuassianThin, sinPath
	#smoothPath - keeps distance from one pnt to next within some error
	#accelerate

	#----Board Manipulation Routines-----
	#adjustments for hex boards??
	row: (B,spriteB,j) -> (spriteB[[i,j]] for i in [0..B.bWidth] when B.maska[[i,j]]?)  #sparserow() ??   **spriteB as map??  **gives lots of undefined's
	row1: (B,spriteB,j) -> (spriteB[[i,j]] for i in [0..B.bWidth])
	rows: (B, spriteB) -> (row1(B,spriteB,j) for j in [0..B.bHeight])
	column: (B,spriteB,i) -> (spriteB[[i,j]] for j in [0..B.bHeight] when B.maska[[i,j]])
	column1: (B,spriteB,i) -> (spriteB[[i,j]] for j in [0..B.bHeight-1])
	columns: (B, spriteB) -> (@column1(B,spriteB,i) for i in [0..B.bWidth-1])

	bPosP: (B,pt) -> [Math.floor((pt[0]-B.boardX)/B.tWidth),Math.floor((pt[1]-B.boardY)/B.tHeight)]
	sprPosP: (B,pt) -> [pt[0]*B.tWidth+B.boardX, pt[1]*B.tHeight+B.boardY]

	bPos1: (B,x,y) -> [Math.floor((x-B.boardX)/B.tWidth),Math.floor((y-B.boardY)/B.tHeight)]
	sprPos: (B,x,y) -> [x*B.tWidth+B.boardX, y*B.tHeight+B.boardY]

	bPos: (B,x,y,buf) ->
		bX = Math.floor((x-B.boardX)/40)
		bX = -1 if not (bX*40+B.boardX+3 < x < bX*40+B.boardX+34) #-B.boardX
#		bX = -1 if not -1 < bX < B.bWidth
		bY = Math.floor((y-B.boardY)/40)
		bY = -1 if not (bY*40+B.boardY+3 < y < bY*40+B.boardY+34) #-B.boardY
#		bY = -1 if not -1 < bY < B.bHeight
		[bX,bY]

	locktoB: (B, spriteB) ->
		#$('#out').text(JSON.stringify([(@sprPosP(B, @bPosP(B,e.pos)) for e in spriteB)]))
		e.pos = @sprPosP(B, @bPosP(B,e.pos)) for e in spriteB  #adjust sparse indexes to current sprite locations
		@sparseLock(B, spriteB)

	spritestoB: (B, spriteB) -> (B.LUT[[e.pos[0],e.pos[1]]] for e in spriteB)

	sparseLock: (B, spriteB) ->
		board = (spriteB.pop() while spriteB.length>0)
		board[@bPosP(B,e.pos)] = e for e in board
		@spriteQ[0] = board

	difference: (B, spriteB) -> (e for e in B.mask when spriteB[i]?)

	#fillB: (B, spriteB) ->
	#pruneB: ()

	#--
	printQ: (Q) -> ([k,e.pos] for k,e of Q)

	#----Sprite Creation Routines-----
	#external behavior to insert into sprite queu
	mkBehavior: (fn) =>
		s = new Sprite(null, [[0,0],[0,0]])
		s.upEx = fn #does this get the game global binding right?
		s

#--
#	drawSprite: (spr,B) ->
#		ctx.draw(spr.img,spr.x,spr.y,,,,) if spr.srcB?
#		ctx.draw(spr.img,spr.x,spr.y) if not spr.srcB?

#-----

#velocity helps (constant?) thrust and collisions; accel may help falling
#paths vs dx/dy
#sheet vs frame array  (need fn to break up sheet)
class Sprite
	constructor: (@img, @path) ->  #@update) ->
		@pos = @path[0]
		@v = [0,0] #accel as vel path? no. #v/a as integers?
		@a = [0,0] #??
		@marks = {}

		@id = 0
		@delay = 0

		@frame = 0
		@frames = [] #frames in strip (not sheet)

		@srcB = undefined
		@srcXY = [0,0]

		@update = -> @pkux()  #path based kill default; leave this way for this slots project
		@upEx = => false

		@pkux = -> @upEx()

#			if @path.length < 2 #is 1  #either default this, or offer as a built in option!! with easy pass in... aniUp, aniExUp
#				@kill = true
#				@upEx()

		@intensity = 100
		@dIntensity = 0

		@kill = false
		#physics for later, (mass, point force, momentum, friction, )

		@collidable = false
		@clickable = false

		#click: () ->
		#iter:() ->


#need: board offsets, board Width/height, tile height/width, mask
#	spacing??
class Board
	constructor: (@boardX,@boardY,@bWidth,@bHeight,@tWidth,@tHeight) ->
		@lut = []
		@lut[[i,j]] = [i,j] for i in [0..@bWidth-1] for j in [0..@bHeight-1]  #reverse map back to board pnts
		@luta = (e for k,e of @lut) #because maps are apparently hard to work with??
		@maska = [] #(e for k,e of @LUT when @maskarr[e[0]][e[1]] isnt 0)  #all [x,y]'s in mask
		@allX = @tWidth*@bWidth+@boardX
		@allY = @tHeight*@bHeight+@boardY
		@data = {}
		@setmask = (arr) ->
			for e in @luta when arr[e[0]][e[1]] is 1
				@maska.push(e)
				@maska[e] = e

#			@maska = []
#			for e in @luta
#				@maska.push(e) if arr[e[0]][e[1]] is 1

#			@maska = (e for e in @luta when arr[e[0]][e[1]] is 1)

#			$('#out').text(JSON.stringify((e for k,e of @lut)))
#			@mask = (e for k,e of @lut when arr[e[0]][e[1]] isnt 0)



$ ->
	$("#out").text = "testing"
	myGame = new Game
