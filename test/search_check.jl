@testset "search! solves blocksworld problem" begin
    using SymbolicPlanners
    using PDDL
    using PlanningDomains
    using MMbiPlanner

    domain  = load_domain(:blocksworld)
    problem = load_problem(:blocksworld, "problem-2")
    spec = Specification(problem)

    state = initstate(domain, problem)

    planner = BidirectionalPlanner()

    sol = MMbiPlanner.search!(planner, MMbiPlanner.MMbSpec(problem))

    @test sol.status == :success
    @test length(sol.plan) > 0

    # Check: that the path leads to goal
    final_state = simulate(StateRecorder(), domain, state, sol.plan)
    @test satisfy(domain, final_state[end], spec)
end