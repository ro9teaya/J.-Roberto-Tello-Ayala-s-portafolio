using StatsBase, Agents, DataFrames
using Distributions
using LightGraphs: SimpleGraphs
using Random: MersenneTwister
using DrWatson: @dict


mutable struct Person <: AbstractAgent
    id::Int
    pos::Int
    vul::Bool # 1 if vulnerable, 0 if not
    beta::Float64 # p of getting infected (not spreading infection)
    # gamma::Float64 # p of recovery (think about time interpretation)
    # delta::Float64 # p of hospitalisation -- ignore death for now
    status::Symbol # Susceptible, Exposed, Infected, Recovered, Quarantined
    q_not_inf::Bool # 1 if they are not I and sent to Q
    days_in_quar::Int # days it has been in quarantine
    days_until_infected::Int # days since becoming exposed
    days_exposed::Int # days before someone trasitions to I from E
    days_infected::Int # numbers of days someone will remain infected
    days_recovered::Int # no of days someone has been recovered
    infected::Bool # If at some points become truly infected
    category::Int # Group they are part of
    score::Int
end

mutable struct Persons <: AbstractAgent
    id::Int
    pos::Int
    vul::Bool # 1 if vulnerable, 0 if not
    beta::Float64 # p of getting infected (not spreading infection)
    # gamma::Float64 # p of recovery (think about time interpretation)
    # delta::Float64 # p of hospitalisation -- ignore death for now
    status::Symbol # Susceptible, Exposed, Infected, Recovered, Quarantined
    q_not_inf::Bool # 1 if they are not I and sent to Q
    days_in_quar::Int # days it has been in quarantine
    days_until_infected::Int # days since becoming exposed
    days_exposed::Int # days before someone trasitions to I from E
    days_infected::Int # numbers of days someone will remain infected
    days_recovered::Int # no of days someone has been recovered
    infected::Bool # If at some points become truly infected
    category::Int # Group they are part of
    score::Int
    segment::Int
end

"""
Initialises the model by grouping people randomly.
Takes different parameters for vulnerable and non-vulnerable agents
"""
function initialise(
    n, p, inf_frac,
    vulnerable_frac,
    beta_vul,
    beta_nv,
    seed=27)

    # model properties, time_quarantine = time in quarantine
    # time_recovered = days someone is R before returning to S
    # no_groups = the number of groups
    # init_inf = ids of people initially infected
    properties = @dict(time_quarantine = 14,
                        time_recovered = 60,
                        no_groups = Int(round(n/10)),
                        init_inf = [],
                        prob_self_isolation = 0.6)

    # creation of the model
    model = ABM(
              Person,
              GraphSpace(SimpleGraphs.erdos_renyi(n,p,is_directed=false,seed=seed)); properties = properties)
              #GraphSpace(SimpleGraphs.barabasi_albert(n,n0,k,seed=seed)))

    # Vector that aids in verifying no group is bigger than 10
    allocate = zeros(model.no_groups)

    # Adds vulnerable people
    for i in 1:Int(vulnerable_frac*n)
        # select a group at random, if it has more than ten people, select another
        group = rand(1:model.no_groups)
        while allocate[group] >= 10
            group = rand(1:model.no_groups)
        end
        add_agent!(i, model, 1, beta_vul, :S, 0, 0, 0, 0, 0, 0, false, group)
        allocate[group] = 1 + allocate[group]
    end

    # Adds non-vulnerable people
    for i in Int(vulnerable_frac*n)+1:n
        # select a group at random, if it has more than ten people, select another
        group = rand(1:model.no_groups)
        while allocate[group] >= 10
            group = rand(1:model.no_groups)
        end
        add_agent!(i, model, 0, beta_nv, :S, 0, 0, 0, 0, 0, 0, false, group)
        allocate[group] = 1 + allocate[group]
    end

    # Infect some people randomly
    for i in sample(collect(allids(model)), Int(round(inf_frac*n)), replace=false)
        model[i].status = :I
        model[i].infected = true
        # set the id of the person infected onto the vector of initially infected
        push!(model.init_inf, i)
    end

    return model
end


"""
Initialises the model by grouping with some of its neighbors.
Takes different parameters for vulnerable and non-vulnerable agents
"""
function initialise_neighbor(
    n, p, inf_frac,
    vulnerable_frac,
    beta_vul,
    beta_nv,
    seed=27)

    # model properties, time_quarantine = time in quarantine
    # time_recovered = days someone is R before returning to S
    # no_groups = the number of groups
    # init_inf = ids of people initially infected
    properties = @dict(time_quarantine = 14,
                        time_recovered = 60,
                        no_groups = Int(round(n/10)),
                        init_inf = [],
                        prob_self_isolation = 0.6)

    # creation of the model
    model = ABM(
              Person,
              GraphSpace(SimpleGraphs.erdos_renyi(n,p,is_directed=false,seed=seed)); properties = properties)
              #GraphSpace(SimpleGraphs.barabasi_albert(n,n0,k,seed=seed)))

    # Vector that aids in veryfing no group is bigger than 10
    allocate = zeros(model.no_groups)

    maxint =  typemax(Int)
    # Adds vulnerable people
    for i in 1:Int(vulnerable_frac*n)
        add_agent!(i, model, 1, beta_vul, :S, 0, 0, 0, 0, 0, 0, false, maxint)
    end

    # Adds non-vulnerable people
    for i in Int(vulnerable_frac*n)+1:n
        add_agent!(i, model, 1, beta_nv, :S, 0, 0, 0, 0, 0, 0, false, maxint)
    end

    # ids will contain people who don't have a group assigned yet
    ids = Set(collect(1:n))

    # Starts iterating through the number of groups
    for group in 1:model.no_groups
        # counter works to assess that no group contains more than ten people
        counter  =  0
        # Iterates over all agents
        for agent in 1:n
            # Verifies that the agent doesen't have a group
            if agent in ids
                # Assigns a group and increase the counter
                model[agent].category = group
                allocate[group] = allocate[group] + 1
                delete!(ids, agent)
                counter = counter  + 1
                # Checks for neighbors that don't have a group already
                for neighbor in nearby_positions(model[agent], model)
                    if neighbor in ids
                        counter = counter + 1
                        model[neighbor].category = group
                        allocate[group] = allocate[group] + 1
                        delete!(ids, neighbor)
                    end
                    if counter == 10
                        break
                    end
                end
                if counter == 10
                    break
                end
            end
        end
    end

    # Infect some people randomly
    for i in sample(collect(allids(model)), Int(round(inf_frac*n)), replace=false)
        model[i].status = :I
        model[i].infected = true
        # Set the id of the person infected onto the vector of initially infected
        push!(model.init_inf, i)
    end

    return model
end

function initialise_vulnerable(
    n, p, inf_frac,
    vulnerable_frac,
    beta_vul, gamma_vul, delta_vul,
    beta_nv, gamma_nv, delta_nv,
    seed=27)

    # model properties, time_quarantine = time in quarantine
    # time_recovered = days someone is R before returning to S
    # no_groups = the number of groups
    # init_inf = ids of people initially infected
    properties = @dict(time_quarantine = 14,
                        time_recovered = 60,
                        no_groups = Int(round(n/10)),
                        init_inf = [],
                        prob_self_isolation = 0.6)

    # creation of the model
    model = ABM(
              Person,
              GraphSpace(SimpleGraphs.erdos_renyi(n,p,is_directed=false,seed=seed)); properties = properties)
              #GraphSpace(SimpleGraphs.barabasi_albert(n,n0,k,seed=seed)))

    # Vector that aids in verifying no group is bigger than 10
    allocate = zeros(model.no_groups)

    group =  1
    # Adds vulnerable people and groups them together
    for i in 1:Int(vulnerable_frac*n)
        while allocate[group] >= 10
            group = group + 1
        end
        add_agent!(i, model, 1, beta_vul, gamma_vul, delta_vul, :S, 0, 0, 0, 0, 0, false, group)
        allocate[group] = 1 + allocate[group]
    end

    # Adds non-vulnerable people and groups them together
    for i in Int(vulnerable_frac*n)+1:n
        while allocate[group] >= 10
            group = group + 1
        end
        add_agent!(i, model, 0, beta_nv, gamma_nv, delta_nv, :S, 0, 0, 0, 0, 0, false, group)
        allocate[group] = 1 + allocate[group]
    end

    # Infect some people randomly
    for i in sample(collect(allids(model)), Int(round(inf_frac*n)), replace=false)
        model[i].status = :I
        model[i].infected = true
        # Set the id of the person infected onto the vector of initially infected
        push!(model.init_inf, i)
    end

    return model
end

"""
"""
function initialise_score(
    n, p, inf_frac,
    vulnerable_frac,
    beta_vul,
    beta_nv,
    seed=27)

    # model properties, time_quarantine = time in quarantine
    # time_recovered = days someone is R before returning to S
    # no_groups = the number of groups
    # init_inf = ids of people initially infected
    properties = @dict(time_quarantine = 14,
                        time_recovered = 60,
                        no_groups = Int(round(n/10)),
                        init_inf = [],
                        prob_self_isolation = 0.6)

    # creation of the model
    model = ABM(
              Persons,
              GraphSpace(SimpleGraphs.erdos_renyi(n,p,is_directed=false,seed=seed)); properties = properties)
              #GraphSpace(SimpleGraphs.barabasi_albert(n,n0,k,seed=seed)))

    # Vector that aids in verifying no group is bigger than 10
    allocate = zeros(model.no_groups)

    group = 1
    vulnerable_high = Int(0.1*n)

    for i in 1:Int(vulnerable_frac*n)
        while allocate[group] >= 10
            group = group + 1
        end
        if i <= vulnerable_high
            add_agent!(i, model, 1, beta_vul, :S, 0, 0, 0, 0, 0, 0, false, group, 5,1)
            allocate[group] = 1 + allocate[group]
        else
            add_agent!(i, model, 1, beta_vul, :S, 0, 0, 0, 0, 0, 0, false, group, 3,2)
            allocate[group] = 1 + allocate[group]
        end

    end

    non_high = Int(n*(0.2+vulnerable_frac))
    # Adds non-vulnerable people and groups them together
    for i in Int(vulnerable_frac*n)+1:n
        while allocate[group] >= 10
            group = group + 1
        end
        if i <= non_high
            add_agent!(i, model, 0, beta_nv, :S, 0, 0, 0, 0, 0, 0, false, group, 5,3)
            allocate[group] = 1 + allocate[group]
        else
            add_agent!(i, model, 0, beta_nv, :S, 0, 0, 0, 0, 0, 0, false, group, 3,4)
            allocate[group] = 1 + allocate[group]
        end
    end

    # Infect some people randomly
    for i in sample(collect(allids(model)), Int(round(inf_frac*n)), replace=false)
        model[i].status = :I
        model[i].infected = true
        # set the id of the person infected onto the vector of initially infected
        push!(model.init_inf, i)
    end

    return model
end


"""
Function that spreads the virus
"""
function transmit!(agent, model)
    # If someone is infected it can pass it on to its neighbors
    if agent.status == :I
        for neighbor in nearby_positions(agent, model)
            # Only can pass the virus if susceptible
            if model[neighbor].status == :S
                if rand() < model[neighbor].beta
                    model[neighbor].status = :E
                    model[neighbor].infected = true
                    # Set the days some will be in E before transitioning to I
                    model[neighbor].days_exposed = rand(3:5)
                end
            end
        end
    end
end

"""
Function that counts how much time people is infected or quarantined
After enough days have passed, it sets their status to Recovered
"""
function release!(agent, model)
    if agent.status == :E
        if agent.days_until_infected > agent.days_exposed
            agent.status = :I
        end
        agent.days_until_infected = 1 + agent.days_until_infected
    end

    if agent.status == :R
        if agent.days_recovered >= model.time_recovered
            agent.status = :S
        else
            agent.days_recovered += 1
        end
    end

    if agent.status == :Q
        if agent.days_in_quar >= model.time_quarantine
            if agent.infected == false
                agent.status = :S
            else
                agent.status = :R
                agent.days_recovered = 1
            end
            agent.days_in_quar = 0
            agent.q_not_inf = 0
        else
            agent.days_in_quar = agent.days_in_quar + 1
        end
    end

    if agent.status==:I
        if agent.days_infected > model.time_quarantine
            agent.status = :R
            agent.days_recovered = 1
        else
            agent.days_infected = 1 + agent.days_infected
        end
        if 3 <= agent.days_infected
            if rand() < model.prob_self_isolation
                agent.status = :Q
            end
        end
    end

end

function agent_step!(agent, model)
    release!(agent, model)
    transmit!(agent, model)
end

"""
Works as if no tests are applied
"""
function collect_data(model::ABM, agent_step!, T=100)
    susceptible(x) = count(i == :S for i in x)
    exposed(x) = count(i == :E for i in x)
    infected(x) = count(i == :I for i in x)
    recovered(x) = count(i == :R for i in x)
    quarantined(x) = count(i == :Q for i in x)

    vul(a) = a.vul == 1
    nv(a) = a.vul == 0

    adata_vul = [(:status, f, vul) for f in
        (susceptible, exposed, infected, recovered, quarantined)]
    adata_nv = [(:status, f, nv) for f in
    (susceptible, exposed, infected, recovered, quarantined)]
    qni = [(:q_not_inf, sum, f) for f in (vul, nv)]

    adata = vcat(adata_vul, adata_nv, qni)
    data, _ = run!(model, agent_step!, T; adata=adata)

    return data
end


"""
Function that allocates a vector of tests (1 or 0) across all groups.
If there is someone positive, everyone in group j goes to quarantine
"""
function contain!(model::ABM, tests::Vector{Int64}) # FIX SYNTAX
    groups_to_test = findall(!iszero, tests)
    groups_in_q = Int64[]
    groups_tested = Int64[]

    for j in groups_to_test
        group = filter(p -> p.category == j, collect(allagents(model)))
        while all(p -> p.status == :Q, group) || (j ∈ groups_tested)
            if model.no_groups < j + 1
                j = 0
            end
            j += 1
            group = filter(p -> p.category == j, collect(allagents(model)))
        end

        if any(p -> p.status == :I, group)
            for p in filter(p -> p.status != :I, group)
                p.q_not_inf = 1
            end
            (p -> p.status = :Q).(group)
            push!(groups_in_q, j)
        end
        push!(groups_tested,j)
    end
    if groups_to_test == groups_tested
        action_equal = true
    else
        action_equal = false
    end

    return groups_in_q, groups_tested, action_equal
end


"""
Sets the states to what originally was
"""
function reset_model!(model)
    for i in collect(allids(model))
        model[i].days_in_quar = 0
        model[i].q_not_inf = 0
        model[i].days_in_quar = 0
        model[i].days_until_infected = 0
        model[i].days_exposed = 0
        model[i].days_infected = 0
        model[i].days_recovered = 0
        if i in model.init_inf
            model[i].status = :I
            model[i].infected = true
        else
            model[i].status = :S
            model[i].infected = false
        end
    end
end

# # toy example
# model = initialise(
#            1500, 0.05, 0.05,
#            0.1,
#            0.3, 0.1, 0.3,
#            0.1, 0.2, 0.3)
#
# data = collect_data(model, agent_step!, 100)
#
# println("Number of people initially infected: ", length(filter(p->p.status == :I, collect(allagents(model)))))
# tests = vcat(ones(Int(0.5*model.no_groups)), zeros(Int(0.5*model.no_groups)))
# contain!(model,tests)
# println("Number of people set to quarantine: ",length(filter(p->p.status == :Q, collect(allagents(model)))))
# step!(model, agent_step!, 1)
# println("Number of people now infected: ", length(filter(p->p.status == :I, collect(allagents(model)))))
#
# test = collect_data(model, agent_step!, 1)
