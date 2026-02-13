# MMbiPlanner

[![Build Status](https://github.com/Soldernominal/MMbiPlanner.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Soldernominal/MMbiPlanner.jl/actions/workflows/CI.yml?query=branch%3Amain)



# Installation

Make sure [SumbolicPlanners.jl] (https://github.com/JuliaPlanners/SymbolicPlanners.jl/tree/master) and
          [PDDL.jl] (https://github.com/JuliaPlanners/PDDL.jl/tree/master) directories are installed and are
located in the same directory, as the MMbiPlanner.

1) julia --project=MMbiPlanner
    or
    cd to directory and then use julia --project
                                 or
                                 julia --project=.
2) ]instantiate
    this should download all necessary dependencies
3) using MMbiPlanner

For the stable version, press ] to enter the Julia package manager REPL, then run:

add MMbiPlanner

# Features

This is a mm-ϵ (Meet-in-the-Middle) bidirectional planner, based on the bidirectional search framework from `SymbolicPlanners.jl`.
Every other feature is used from the mentioned library.

The key difference from the original bidirectional planner is the **MM termination rule**,
which guarantees optimal stopping based on the current best meeting cost instead of
stopping immediately when the two frontiers touch

### What is new compared to 'SymbolicPlanners.jl/src/planners/bidirectional.jl'?

The original bidirectional planner stops as soon as the forward and backward
search frontiers intersect.

This implementation instead:

- Tracks the best meeting cost 'best_meet = gF + gB', where F and B are Forward and Backward, respectfully, 
  and g is distance from start to current node.
- Allows multiple frontier intersections during search
- Stops **only when** min(f_forward, f_backward) ≥ best_meet, where f = g + h (heuristic)

# Usage Example

```julia
using MMbiPlanner
using SymbolicPlanners
using PDDL

domain  = load_domain("blocks-domain.pddl")
problem = load_problem("blocks-problem.pddl", domain)

spec = Specification(problem)

planner = MMBiPlanner()
solution = search!(planner, spec)

println(solution.plan)
```

or

``` julia
using MMbiPlanner
using SymbolicPlanners
using PDDL

domain  = load_domain(joinpath(dirname(pathof(PDDL)),
                               "..","docs","src","assets","blocks-domain.pddl"))

problem = load_problem(joinpath(dirname(pathof(PDDL)),
                                "..","docs","src","assets","blocks-problem.pddl"),
                       domain)

spec = Specification(problem)

planner = MMBiPlanner()
solution = search!(planner, spec)

println("Plan:")
println(solution.plan)
println("Expanded nodes: ", solution.expanded)
```

# Performance Comparison

![Runtime comparison of search! bidirectional and mm-e algorithms](assets/func-comparison.png)

+==================================+========================+========================+
| Feature	                         |   SymbolicPlanners	    |      MMbiPlanner       |
+==================================+========================+========================+
| Immediate frontier stopping	     |         Yes            |          No            |
+----------------------------------+------------------------+------------------------+
| Multiple meeting updates	       |         No             |          Yes           |
+----------------------------------+------------------------+------------------------+
| MM optimal termination rule	     |         No             |          Yes           |
+----------------------------------+------------------------+------------------------+
| Reduced expansions in theory	   |         No             |          Yes           |
+----------------------------------+------------------------+------------------------+

![Actual results so far](assets/runtime-comparison.png)

+==================================+========================+========================+
| Execution Time	                 |   SymbolicPlanners	    |      MMbiPlanner       |
+==================================+========================+========================+
| Blocksworld axioms env.   	     |       10.711ms         |        15.850ms        |
+----------------------------------+------------------------+------------------------+
| Blocksworld env.        	       |       1.019ms          |        8.008 ms        |
+----------------------------------+------------------------+------------------------+