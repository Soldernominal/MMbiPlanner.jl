using Test
using MMbiPlanner
using MMbiPlanner: search!
using SymbolicPlanners
using SymbolicPlanners: FFHeuristic
using PDDL
using PlanningDomains
using BenchmarkTools

# Load the domain and the task

# Couldn't get these to work, it can't find them :/
#domain  = load_domain("blocks-domain.pddl")
#problem = load_problem("blocks-problem.pddl", domain)
# I ended up using the env-s from SymbolicPlanners akin to its tests, but I had to use PlanningDomains library.

#include("InitialSearch_check.jl")      #  Testing the initial mme search! functionality
#include("search_check.jl")      #  Testing the correct mme search! functionality (Doesn't hold rn, needs improvement of mme)
#include("Env1_comparison.jl")   #  blocksworld_axioms
#include("Env2_comparison.jl")   #  blocksworld
#include("Env3_comparison.jl")   #  zeno travel
#include("Env4_comparison.jl")   #  wolf-goat-cabbage (wfc)


