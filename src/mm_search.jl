using SymbolicPlanners
using SymbolicPlanners: Heuristic
using SymbolicPlanners: FFHeuristic
using UnPack

# Tried to use custom struct, but julia was arguing about data types :(
"""struct MMePlanner <: Planner
    base::BidirectionalPlanner
end

MMePlanner(; heuristic = FFHeuristic()) =
    MMePlanner(BidirectionalPlanner(heuristic, heuristic))

#MMePlanner() = MMePlanner(FFHeuristic())
"""

function search!(sol::BiPathSearchSolution, planner::BidirectionalPlanner,
                 f_heuristic::Heuristic, b_heuristic::Heuristic,
                 domain::Domain, state::State, 
                 f_spec::Specification, b_spec::Specification)
    @unpack max_nodes, max_time = planner
    @unpack f_search_tree, b_search_tree = sol
    f_search_noise = planner.forward.search_noise
    b_search_noise = planner.backward.search_noise
    f_queue, b_queue = sol.f_frontier, sol.b_frontier
    sol.expanded, sol.f_expanded, sol.b_expanded = 0, 0, 0
    f_node_id, b_node_id = nothing, nothing
    f_reached, b_reached, crossed = false, false, false

    # Adeded
    best_meet = Inf

    # Functions for detecting frontier crossing (Removed, due to it not being mm).
    """function find_f_in_b_queue(node)
        for b_id in keys(b_queue)
            issubset(b_search_tree[b_id].state, node.state) && return b_id
        end
        return nothing
    end        
    function find_b_in_f_queue(node)
        for f_id in keys(f_queue)
            issubset(node.state, f_search_tree[f_id].state) && return f_id
        end
        return nothing
    end        """
    start_time = time()

    while !isempty(f_queue) || !isempty(b_queue)
        # --------------------+ Advance the forward search +--------------------
        if !isempty(f_queue)
            f_node_id, _ = isnothing(f_search_noise) ?
                SymbolicPlanners.findbest(f_queue) :
                SymbolicPlanners.prob_findbest(f_queue, f_search_noise)
            f_node = f_search_tree[f_node_id]
            # Check if goal is reached
            if is_goal(f_spec, domain, f_node.state)
                f_reached = true; sol.status = :success; break
            end
            # Check if frontiers cross (Also removed)
            """b_node_id = find_f_in_b_queue(f_node)
            if !isnothing(b_node_id)
                crossed = true; sol.status = :success; break
            end"""
            # Dequeue node          
            isnothing(f_search_noise) ?
                SymbolicPlanners.dequeue!(f_queue) :
                SymbolicPlanners.dequeue!(f_queue, f_node_id)
            # Expand node
            SymbolicPlanners.expand!(planner.forward, f_heuristic, f_node,
                    f_search_tree, f_queue, domain, f_spec)

            # Added
            # MM meet update from forward side
            bnode = get(b_search_tree, f_node_id, nothing)
            if bnode !== nothing
                gF = f_node.path_cost
                gB = bnode.path_cost
                best_meet = min(best_meet, gF + gB)
            end

            sol.f_expanded += 1
            sol.expanded += 1
        end

         # --------------------+ Advance the backward search +--------------------
        if !isempty(b_queue)
            b_node_id, _ = isnothing(b_search_noise) ?
                SymbolicPlanners.findbest(b_queue) :
                SymbolicPlanners.prob_findbest(b_queue, b_search_noise)
            b_node = b_search_tree[b_node_id]
            # Check if goal is reached
            if is_goal(b_spec, domain, b_node.state)
                b_reached = true; sol.status = :success; break
            end
            # Check if frontiers cross (Removed)
            """f_node_id = find_b_in_f_queue(b_node)
            if !isnothing(f_node_id)
                crossed = true; sol.status = :success; break
            end"""
            # Dequeue node          
            isnothing(b_search_noise) ?
                SymbolicPlanners.dequeue!(b_queue) :
                SymbolicPlanners.dequeue!(b_queue, b_node_id)
            # Expand node
            SymbolicPlanners.expand!(planner.backward, b_heuristic, b_node,
                    b_search_tree, b_queue, domain, b_spec)

            # Added
            # MM meet update from backward side
            if haskey(f_search_tree, b_node_id)
                gF = f_search_tree[b_node_id].path_cost
                gB = b_search_tree[b_node_id].path_cost
                best_meet = min(best_meet, gF + gB)
            end


            sol.b_expanded += 1
            sol.expanded += 1
        end

        # --------------------+ MM termination rule +--------------------
        if !isempty(f_queue) && !isempty(b_queue)
            # Allocation reduced by diminishing flooding memory with peek
            _, f_key = SymbolicPlanners.peek(f_queue)
            _, b_key = SymbolicPlanners.peek(b_queue)

            f_priority = f_key[1]
            b_priority = b_key[1]
            if min(f_priority, b_priority) >= best_meet
                crossed = true
                sol.status = :success
                break
            end
        end
        # ----------------------------------------------------------------

        # Check if resource limits are exceeded
        if sol.expanded >= max_nodes
            sol.status = :max_nodes # Node budget reached
            break
        elseif time() - start_time >= max_time
            sol.status = :max_times # Time budget reached
            break
        end
    end
    # Reconstruct plan if one is found
    if sol.status == :in_progress # No solution found
        sol.status = :failure
    elseif f_reached
        sol.plan, sol.f_trajectory = SymbolicPlanners.reconstruct(f_node_id, f_search_tree)
        sol.trajectory = sol.f_trajectory
    elseif b_reached
        sol.plan, sol.b_trajectory = SymbolicPlanners.reconstruct(b_node_id, b_search_tree)
        sol.trajectory = SymbolicPlanners.simulate(SymbolicPlanners.StateRecorder(), domain, state, sol.plan)
    """
    elseif crossed
        f_plan, sol.f_trajectory = SymbolicPlanners.reconstruct(f_node_id, f_search_tree)
        b_plan, sol.b_trajectory = SymbolicPlanners.reconstruct(b_node_id, b_search_tree)
        sol.plan = vcat(f_plan, reverse(b_plan))
        sol.trajectory = SymbolicPlanners.simulate(SymbolicPlanners.StateRecorder(), domain, state, sol.plan)
    end
    """
    # This has a risk of not finding solution, cause it has no midpoint of meeting (happens for cube world)
    elseif crossed
        sol.status = :failure   # Temporarily turned off incorrect crossing
    end
    return sol
end
