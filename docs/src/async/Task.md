# Task

`zyklib.async.Task` is for computations that are too long to run at once without
lagging the game or even surpassing the 1000ms limit on function execution time.

A `zyklib.async.Task` is built on top of a Lua `coroutine` to allow for collaborative 
multitasking in the single-threaded Lua runtime.
Tasks run cooperatively: call `zyklib.async.Task.maybeYield()` from task work
to yield until a later logic tick. Code that does not yield continues running
on the current tick. 
Tasks are progressed through the game's logic ticks and need to manually yield 
after a set amount of work.

```lua
local task = zyklib.async.Task.new(function()
  for i = 1, 100 do
    do_work(i)
    zyklib.async.Task.maybeYield()
  end

  return "done"
end)

task.finished_event:subscribe(function(result)
  print(result)
end)

task:start()
```

## API reference

```{lua:autoobject} zyklib.async.Task
:members:
```
