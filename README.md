# ReBenchmark
An easy to use super lite benchmarking module for ROBLOX!

Took some ideas from Fusion's benchmarks.

# API:

## ReBenchmark.BenchModules(table)

Benchmarks all of the modules provided in a table

Example of how a benchmarking module looks like:

```lua
return {
    atStart = function()
        print("Benchmarking started...")
    end,

    atEnd = function()
        print("Finished benchmarking!")
    end,

    ["Print `Hello world` to console 50 times"] = {
        before = function()
            -- do something to prepare for run
            return "Hello world"
        end,

        calls = 50,

        run = function(context)
            print(context[1])
        end,

        after = function()
            -- do something to clean the run function up
        end
    }
}
```

How to benchmark it:

```lua
local ReBenchmark = require(game:GetService("ReplicatedStorage").ReBenchmark)
ReBenchmark.BenchModules({path.to.my.module})
```

## ReBenchmark.BenchFunction(run, calls, before, after)

Benchmarks a single function.

```lua
local ReBenchmark = require(game:GetService("ReplicatedStorage").ReBenchmark)

ReBenchmark.BenchFunction(function(context)
    print(context[1])
end, 15, function()
    print("Before")
    return "Hello world"
end, function()
    print("After")
end)
```

## ReBenchmark.BenchAuto()

Gets all the modules ending with `.rebench` and `.bench` and then benchmarks them.

Example:

```lua
local ReBenchmark = require(game:GetService("ReplicatedStorage").ReBenchmark)
ReBenchmark.BenchAuto()
```