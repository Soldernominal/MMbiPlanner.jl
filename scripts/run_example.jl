#=
cd scripts
julia --project run_example.jl
doesn't find package here.
=#

using MMbiPlanner
using SymbolicPlanners
using PDDL
using BenchmarkTools

# Load the problem env
domain  = load_domain("blocks-domain.pddl")
problem = load_problem("blocks-problem.pddl", domain)
spec = Specification(problem)

# Create planners, from SymbolicPlanners and MMbiPlanners(mm-e)
symb_planner = BidirectionalPlanner()
mm_planner = MMBiPlanner()

println("=== SymbolicPlanners bidirectional ===")
@btime SymbolicPlanners.search!($symb_planner, $spec)

println("\n=== MMbiPlanner ===")
@btime MMbiPlanner.search!($mm_planner, $spec)

# Init and output MMbiPlanners sol
solution = MMbiPlanner.search!($mm_planner, $spec)
println("\nMMbiPlanner solution:")
println("Plan: ", solution.plan)
println("Expanded nodes: ", solution.expanded)
