return function(Benchmark)
	Benchmark({
		["rename folder to Test"] = function(folder: Folder)
			folder.Name = "Test"
		end,

		["add 1000 + 2000"] = function(num1, num2)
			num1 += num2
		end,

		["wait 1"] = function()
			task.wait(1)
		end,
	})
		:Function(function()
			print("Started benchmarking")
		end)
		:BeforeEach({
			["rename folder to Test"] = function(self)
				return self:Flag(Instance.new("Folder", workspace))
			end,

			["add 1000 + 2000"] = function()
				return 1000, 2000
			end,
		})
		:TimeOut(1)
		:Run(10)
end
