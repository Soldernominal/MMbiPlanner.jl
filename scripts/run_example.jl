#=
cd scripts
julia --project run_example.jl
=#

using MMbiPlanner
using SymbolicPlanners
using PDDL
using BenchmarkTools

# Загрузка домена и проблемы
domain  = load_domain("blocks-domain.pddl")
problem = load_problem("blocks-problem.pddl", domain)
spec    = Specification(problem)

# Создание планнеров
symb_planner = BidirectionalPlanner()
mm_planner   = MMBiPlanner()

println("=== SymbolicPlanners bidirectional ===")
@btime SymbolicPlanners.search!($symb_planner, $spec)

println("\n=== MMbiPlanner ===")
@btime MMbiPlanner.search!($mm_planner, $spec)

# Запуск и вывод решения MMbiPlanner
solution = MMbiPlanner.search!($mm_planner, $spec)
println("\nMMbiPlanner solution:")
println("Plan: ", solution.plan)
println("Expanded nodes: ", solution.expanded)
