#using MMbiPlanner: MMePlanner 
#using MMbiPlanner: MMbSpec 

# Create MMbiPlanner planner and test the type correctness
#planner = MMePlanner()
#@test typeof(planner) == MMePlanner

# spec is fixed as MinStepsGoal, so for search! we will have to create the problem-like immutable struct:

#spec = MMbSpec(problem)
#@test typeof(spec) == MMbSpec



# Get solution
#solution = search!(planner, spec)

# And then we plug in the sol to check that our works at all...
#@test length(solution.plan) > 0
#@test solution.status == :success

# MMe is not utilized right now
"""@testset "MMbiPlanner basic functionality" begin
    # The module is accessible for tests
    @test isdefined(@__MODULE__, :MMbiPlanner)

    # Planner is actually created
    mm_planner = MMePlanner()
    @test typeof(mm_planner) == MMePlanner

    # Asset check (just as extrea check)
    asset_file = joinpath(dirname(pathof(SymbolicPlanners)), "..", "assets", "runtime-comparison.png")
    @test isfile(asset_file)
end"""
