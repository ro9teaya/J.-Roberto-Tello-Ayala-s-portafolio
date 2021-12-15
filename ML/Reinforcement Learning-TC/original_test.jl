include("Simulations/model.jl")
using LinearAlgebra
using ProgressMeter, Plots


"""
        Return vector of segments where NOT everyone is on quarantine.
"""
function filter_quarantined(model::ABM)
    groups_notin_q = Int32[]
    for i in 1:model.no_groups
        group = filter(p -> p.segment == i, collect(allagents(model)))
        if any(p -> p.status != :Q, group) # Add only if one is at least not in q
            push!(groups_notin_q, i)
        end
    end
    return groups_notin_q
end

"""
       Returns a vector containing *effective* average exposure for each
       segment. Average is computed only over non-quarantined people.
       Returns
       -------
       vector, int OR float
           i-th entry contains average exposure for i-th segment
"""

function average_exposure(model::ABM, groups_notin_q::Vector{Int64})
    avg_exp = Float64[]
    for i in groups_notin_q
        exposure = 0.0
        count = 0
        group = filter(p -> p.segment == i, collect(allagents(model)))
        for p in group
            if p.status != :Q
                exposure += size(nearby_ids(p,model))[1]
                count += 1
            end
        end
        push!(avg_exp, exposure/count)
    end
    return avg_exp
end

"""
       Returns a vector containing *effective* number of people in each
       segment, without counting quarantined people.
"""
function segment_sizes(model::ABM, groups_notin_q::Vector{Int64})
    segment_sizes =  Int32[]
    for i in groups_notin_q
        sizes = 0
        group = filter(p -> p.segment == i, collect(allagents(model)))
        for p in group
            if p.status != :Q
                sizes += 1
            end
        end
        push!(segment_sizes, sizes)
    end
    return segment_sizes
end

"""
        Return a vectro of infection rates for the segments.
        Only non-quarantined individuals are counted.
"""
function segment_probabilities(model::ABM, groups_notin_q::Vector{Int64}, segment_sizes::Vector{Int32})
    avg_prob = Float64[]
    for (i, group_id) in enumerate(groups_notin_q)
        group = filter(p -> p.segment == group_id, collect(allagents(model)))
        push!(avg_prob, count(p.status  == :I for p in group)/segment_sizes[i])
    end
    return avg_prob
end

"""
  Obtains the cost of each segment
"""
function obtain_cost(model::ABM, groups_notin_q::Vector{Int64})
    cost = Int32[]
    for i in groups_notin_q
        group = filter(p -> p.segment == i, collect(allagents(model)))
        push!(cost, group[1].score)
    end
    return cost
end


 """Allocate tests greedily to segments."""
function greedy(model::ABM, sorted_indices, group_sizes, seg_sizes, no_tests::Int)
    remaining_tests = no_tests
    test_alloc = zeros(Int, size(seg_sizes)[1])
    for i in sorted_indices
        if remaining_tests == 0
            break
        end
        seg_tests = min(seg_sizes[i] ÷ group_sizes[i], remaining_tests)
        test_alloc[i] = seg_tests
        remaining_tests -= seg_tests
    end
    return test_alloc
end

"""
        Compute how many tests to allocate to each segment and determine the
        correct group sizes.
        Returns two vectors, one with test allocations and one with group
        sizes.
"""
function solve_opt_problem(model::ABM, groups_notin_q::Vector{Int64}, segment_sizes,
    avg_exp::Vector{Float64}, avg_prob::Vector{Float64}, cost::Vector{Int32},  no_tests::Int)
    s =  size(avg_prob)[1]
    opt_test_alloc, opt_group_sizes = [0,0,0,0], [0,0,0,0]
    optimum = Inf
    thetas = zeros(Float64, s)
    @showprogress for group_sizes in Base.product(ntuple(x->1:10, s)...) # the max group size is fixed to ten for now
        group_sizes = collect(group_sizes)
        @.thetas = ((cost * (1 - avg_prob)) - (avg_exp * avg_prob) - (cost * group_sizes * (1 - avg_prob)^group_sizes))
        sorted_indices = sortperm(-thetas)
        test_alloc = greedy(model, sorted_indices, group_sizes, segment_sizes, no_tests)
        obj_val = dot(thetas, test_alloc)
        if obj_val <= optimum
            optimum = obj_val
            opt_test_alloc = test_alloc
            opt_group_sizes = collect(group_sizes)
        end
    end
    return opt_test_alloc, opt_group_sizes
end

"""
        Tests test_alloc[s] groups of size g[s] for each segment s. Whenever
        a group tests positive, quarantine everyone in the group.
"""
function unif_group_tests!(model::ABM, groups_notin_q::Vector{Int64}, test_alloc, group_sizes)
    for (i, group_id) in enumerate(groups_notin_q)
        t = test_alloc[i]
        if t == 0
            continue
        end
        g = group_sizes[i]
        group = filter(p -> p.segment == group_id, collect(allagents(model)))
        active_indices = filter(p -> p.status != :Q, group)
        @assert  t*g <= size(active_indices)[1]
        to_test = sample(active_indices, (t,g);replace  = false)
        for test in 1:t
            if any(x -> x.status == :I, to_test[test,:])
                for p in filter(p -> p.status != :I, to_test[test,:])
                    p.q_not_inf = 1
                end
                (x -> x.status = :Q).(to_test[test,:])
            end
        end
    end
end
