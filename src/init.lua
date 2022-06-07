--[[
	ReBenchmark
	An easy to use and super light benchmarking module.

	Version: 0.1.1
	Created by: james_mc98
	Last update: 2022-06-07

	Notice: Using ReBench.BenchAuto requires that all the benchmarking modules end with .rebench or .bench
]]

local Reporter = {}
Reporter.StartModule = "\nBenchmark module results:\n"
Reporter.StartFunction = "\nBenchmark function result:\n"
Reporter.Tree = "\t[%s]:\n"
Reporter.Result = "\t\t- %s: %s\n"
Reporter.ResultFunction = "\t- %s: %s\n"

function Reporter.ModuleReport(benchResults: { [string]: { [string]: any } })
	local report = Reporter.StartModule

	for treeName, treeResults in pairs(benchResults) do
		report = report .. string.format(Reporter.Tree, treeName)
		for resultName, resultValue in pairs(treeResults) do
			report = report .. string.format(Reporter.Result, resultName, tostring(resultValue))
		end
	end

	print(report)
end

function Reporter.FunctionReport(benchResult: { [string]: string })
	local report = Reporter.StartFunction

	for resultName, resultValue in pairs(benchResult) do
		report = report .. string.format(Reporter.ResultFunction, resultName, tostring(resultValue))
	end

	print(report)
end

local Benchmarker = {}
Benchmarker.DefaultCalls = 5
Benchmarker.Decimals = 5

function Benchmarker.SimplifyNumber(number: number): string
	local dotSplit = string.split(tostring(number), ".")
	return dotSplit[1] .. "." .. string.sub(dotSplit[2], 0, Benchmarker.Decimals)
end

function Benchmarker.CalculateData(times: { [number]: number }, calls: number): { [string]: string }
	local avarageTime = 0
	local shortestTime = math.huge
	local longestTime = 0

	-- avarage time
	table.foreachi(times, function(_, b)
		avarageTime += b
	end)
	avarageTime = avarageTime / calls

	-- shortest time
	for _, v in ipairs(times) do
		if v < shortestTime then
			shortestTime = v
		end
	end

	-- longest time
	for _, v in ipairs(times) do
		if v > longestTime then
			longestTime = v
		end
	end

	return {
		["Avarage time"] = Benchmarker.SimplifyNumber(avarageTime),
		["Longest time"] = Benchmarker.SimplifyNumber(longestTime),
		["Shortest time"] = Benchmarker.SimplifyNumber(shortestTime),
	}
end

function Benchmarker.Module(benchmarkConfig: { any }): { [string]: { [string]: string } }
	local benchResults = {}

	if typeof(benchmarkConfig.atStart) == "function" then
		benchmarkConfig.atStart()
	end

	for treeName, argument in pairs(benchmarkConfig) do
		if typeof(argument) == "table" then
			local beforeContext = {}

			-- table for holding the results
			local times = {}

			for _ = 1, argument.calls or Benchmarker.DefaultCalls do
				if typeof(argument.before) == "function" then
					beforeContext = table.pack(argument.before())
					beforeContext.n = nil
				end

				local startTime = tick()

				argument.run(beforeContext)

				local endTime = tick()

				if typeof(argument.after) == "function" then
					argument.after()
				end

				table.insert(times, endTime - startTime)
			end

			benchResults[treeName] = Benchmarker.CalculateData(times, argument.Calls or Benchmarker.DefaultCalls)
		end
	end

	if typeof(benchmarkConfig.atEnd) == "function" then
		benchmarkConfig.atEnd()
	end

	return benchResults
end

function Benchmarker.Function(
	runCallback: ({ [number]: any }) -> (),
	calls: number,
	beforeCallback: () -> (any),
	afterCallback: () -> ()
): { [string]: { [string]: string } }
	-- table for saving the returned values from the before function, to later pass it to run
	local beforeContext = {}

	-- table for holding the results
	local times = {}

	for _ = 1, calls or Benchmarker.DefaultCalls do
		if typeof(beforeCallback) == "function" then
			beforeContext = table.pack(beforeCallback())
			beforeContext.n = nil
		end

		local startTime = tick()

		runCallback(beforeContext)

		local endTime = tick()

		if typeof(afterCallback) == "function" then
			afterCallback()
		end

		table.insert(times, endTime - startTime)
	end

	return Benchmarker.CalculateData(times, calls or Benchmarker.DefaultCalls)
end

local ReBenchmark = {}

--[[
	Runs a benchmark on a list of modules

	Returns the results

	**Example**:

	```lua
	local ReBenchmark = require(game:GetService("ReplicatedStorage").ReBench)

	local benchmarkModules = {}

	for _, v in ipairs(game:GetDescendants()) do
		if v:IsA("ModuleScript") and v.Name:match(".spec$") then
			table.insert(benchmarkModules, v)
		end
	end

	ReBenchmark.BenchModules(benchmarkModules)
	```
]]
function ReBenchmark.BenchModules(benchmarkModules: { [number]: ModuleScript })
	local benchmarkResults = {}

	for _, v in ipairs(benchmarkModules) do
		local results = Benchmarker.Module(require(v))

		for o, b in pairs(results) do
			benchmarkResults[o] = b
		end
	end

	Reporter.ModuleReport(benchmarkResults)

	return benchmarkResults
end

--[[
	Benchmarks a single function. 

	Returns the results.

	**Example**:

	```lua
	local ReBenchmark = require(game:GetService("ReplicatedStorage").ReBench)

	ReBenchmark.BenchFunction(function(context)
		print(context[1])
	end, 15, function()
		print("Before")
		return "Hello world"
	end, function()
		print("After")
	end)
	```
]]
function ReBenchmark.BenchFunction(
	runFunction: ({ [number]: any }) -> (),
	calls: number,
	beforeFunction: () -> (any),
	afterFunction: () -> ()
): { [string]: string }
	local result = Benchmarker.Function(runFunction, calls, beforeFunction, afterFunction)

	Reporter.FunctionReport(result)

	return result
end

--[[
	Scans trough the entire game, looking for benchmarking modules.

	All benchmarking modules **must end with**: `.rebench` or .`bench`.

	Returns the results.

	**Example**:

	```lua
	local ReBenchmark = require(game:GetService("ReplicatedStorage").ReBench)
	ReBenchmark.BenchAuto()
	```
]]
function ReBenchmark.BenchAuto()
	local benchModules = {}

	for _, v in ipairs(game:GetDescendants()) do
		if v:IsA("ModuleScript") and v.Name:match(".rebench$") or v.Name:match(".bench$") then
			table.insert(benchModules, v)
		end
	end

	ReBenchmark.BenchModules(benchModules)
end

return ReBenchmark
