# ReBenchmark
An easy-to-use and light-weight benchmarking module with lots of features!

# API:

## Utility functions to run benchmark modules:

### ReBenchmark.Run( {[number]: ModuleScript} )

Benchmarks all of the modules provided in a table

Example of how a benchmarking module looks like:

```lua
return function(Benchmark)
	Benchmark({
		["rename folder to Test"] = function(folder: Folder)
			folder.Name = "Test"
		end,
	})
		:Function(function()
			print("Started benchmarking")
		end)
		:BeforeEach({
			["rename folder to Test"] = function(self)
				return self:Flag(Instance.new("Folder", workspace))
			end,
		})
		:TimeOut(5)
		:Run(10)
end
```

How to benchmark it:

```lua
local ReBenchmark = require(game:GetService("ReplicatedStorage").ReBenchmark)
ReBenchmark.BenchModules({path.to.my.module})
```

### ReBenchmark.AutoBench()

Scans trough the entire game looking for `.bench` or `.rebench` modules to run them.

After the benchmark finished it will automatically report the results into the console.

```lua
local ReBenchmark = require(game:GetService("ReplicatedStorage").ReBenchmark)
ReBenchmark.AutoBench()
```

# In benchmark modules:

### ReBenchmark:TimeOut(seconds)

Sets a timeout for the given benchmark module.

### ReBenchmark:Flag(object)

Adds the object to Janitor for later to get cleaned up.

This can be automated by doing :Run(MY_NUMBER, true)

### ReBenchmark:Run(cycles, autoFlag)

Runs the provided functions certain amount of times.
If not provided it will default to 500 cycles

Second parameter is optional.
AutoFlag cleans up every instance that was returned by the :BeforeEach() functions.

### ReBenchmark:Function(callback)

Runs the provided function.
Useful for preparing the benchmark, or to clean it up.

### ReBenchmark:BeforeEach(table)

Hook a function to be run before the specified benchmark.
Variables that are returned by the pre ran function get passed to the benchmark function!

If in the :Run method after the cycles AutoFlag is not enabled, ReBench will pass it self into the function, 
so :Flag can be used!
    
```lua
return function(Benchmark)
    Benchmark({
        ["rename folder to Test"] = function(folder: Folder)
            folder.Name = "Test"
        end,
    })
        :BeforeEach({
            ["rename folder to Test"] = function(self)
                return self:Flag(Instance.new("Folder", workspace))
            end,
        })
        :Run(10)
end
```

### ReBenchmark:ToConsole(method)

Prints out the results into the output.

If needed a function can be passed into the method to later be used to log the results.
If not present it will default to `print`.

```lua
return function(Benchmark)
    Benchmark({
        ["rename folder to Test"] = function(folder: Folder)
            folder.Name = "Test"
        end,
    })
        :BeforeEach({
            ["rename folder to Test"] = function(self)
                return self:Flag(Instance.new("Folder", workspace))
            end,
        })
        :Run(10):ToConsole(warn)
end
```

### ReBenchmark:ReturnResults()

Returns the results of the benchmarks.