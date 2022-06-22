return function(Benchmark)
	Benchmark({
		["Print Hello world! to console"] = function()
			print("Hello world!")
		end,

		["Warn Hello world! to console"] = function()
			warn("Hello world!")
		end,
	})
		:Function(function()
			print("Started benchmarking!")
		end)
		:Run(25)
		:Function(function()
			print("Finished benchmarking!")
		end)
end
