local timesRun = 0

return {
	atStart = function()
		timesRun = 0
		print("Benchmarking started...")
	end,

	atEnd = function()
		warn(timesRun)
		print("Benchmarking finished!")
	end,

	["Printing out Hello world to console"] = {
		before = function()
			timesRun += 1
			return "Hello world"
		end,

		calls = 10,

		run = function(context)
			print(context[1])
		end,
	},
}
