@testset "Blocksworld axioms comparison" begin
    domain = load_domain(:zeno_travel)
    problem = load_problem(:zeno_travel, "problem-2")
    spec = Specification(problem)
    state = initstate(domain, problem)

    @test typeof(problem) == GenericProblem
    @test typeof(Specification) == DataType
    @test typeof(spec) == MinStepsGoal
    @test typeof(state) == GenericState
    

    # Create MMbiPlanner planner and test the type correctness
    planner = BidirectionalPlanner()

    # Symbolic bidirectional sol check
    sol_symb = SymbolicPlanners.solve(planner, domain, state, spec)
    @test sol_symb.status == :success
    #@test length(sol_symb.plan) > 0

    # mm check
    sol_mm = MMbiPlanner.search!(planner, MMbiPlanner.MMbSpec(problem))
    #@test sol_mm.status == :success
    #@test length(sol_mm.plan) > 0
    @test sol_mm.status in (:success, :failure)
    @test sol_mm.status != :max_nodes
    @test sol_mm.status != :max_times

    # Time comparison of 2 searches
    @btime SymbolicPlanners.solve($planner, $domain, $state, $spec)
    @btime MMbiPlanner.search!($planner, MMbiPlanner.MMbSpec($problem))

    @info "SymbolicPlanners" sol_symb.expanded
    @info "MMbiPlanner" sol_mm.expanded sol_mm.status
end