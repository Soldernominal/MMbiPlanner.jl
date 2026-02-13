module MMbiPlanner

#=
import Pkg
Pkg.activate(".")
Pkg.develop(path=".")   # Tells Julia that this package is for development.

Actually, above is not needed. We only need to run:
Pkg.activate(".")
using SymbolicPlanners
=#

#=
How to activate the Project:
1) julia --project=MMbiPlanner
    or
    cd to directory and then use julia --project
                                 or
                                 julia --project=.
2) ]instantiate
3) using MMbiPlanner
4) using SymbolicPlanners
=#

#=
Add symbolic planners to dependencies:
1) using Pkg
2) Pkg.develop(path="../SymbolicPlanners.jl")  # путь относительно MMbiPlanner
3) Pkg.develop(path="../PDDL.jl")
4) ]status
=#

#=
Run tests:
1) ]test
=#

# try/catch block to make sure you can start julia if Revise should not be installed
try
    using Revise
catch e
    @warn(e.msg)
end

using SymbolicPlanners
using PDDL
using UnPack

include("mm_search.jl")     # The copy of search!, but with MM

struct MMbSpec
    problem::GenericProblem
end

# Wrapping for easier local calls
function search!(planner::BidirectionalPlanner, spec::MMbSpec)
    problem = spec.problem
    domain  = load_domain(problem.domain)
    state   = initstate(domain, problem)

    f_spec = SymbolicPlanners.simplified(Specification(problem), domain, state)
    b_spec = BackwardSearchGoal(f_spec, state)

    f_h = planner.forward.heuristic
    b_h = planner.backward.heuristic

    precompute!(f_h, domain, state, f_spec)
    precompute!(b_h, domain, state, b_spec)

    f_search_tree, f_queue =
        SymbolicPlanners.init_forward(planner.forward, f_h, domain, state, f_spec)

    b_search_tree, b_queue =
        SymbolicPlanners.init_backward(planner.backward, b_h, domain, state, b_spec)

    sol = BiPathSearchSolution(:in_progress, Term[], nothing, 0,
                               f_search_tree, f_queue, 0, nothing,
                               b_search_tree, b_queue, 0, nothing)

    sol = search!(sol, planner, f_h, b_h, domain, state, f_spec, b_spec)
    return sol
end

export search!, MMbSpec

end