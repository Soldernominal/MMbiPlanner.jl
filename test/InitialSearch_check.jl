@testset "search! basic functionality" begin
    domain = load_domain(:blocksworld)
    problem = load_problem(:blocksworld, "problem-2")
    spec = Specification(problem)
    state = initstate(domain, problem)

    @test typeof(problem) == GenericProblem
    @test typeof(Specification) == DataType
    @test typeof(spec) == MinStepsGoal
    @test typeof(state) == GenericState

    planner = BidirectionalPlanner()

    sol = MMbiPlanner.search!(planner, MMbiPlanner.MMbSpec(problem))

    @test sol.status in (:success, :failure)
    @test sol.status != :max_nodes
    @test sol.status != :max_times
    @test sol.expanded >= 0
end
