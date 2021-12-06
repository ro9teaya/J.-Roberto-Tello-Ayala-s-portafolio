include("Simulations/model.jl")
include("original_test.jl")

using ProgressMeter
using Plots
using SparseArrays

# Initialise the SEIRQ model
model = initialise_score(
                   1500, 0.05, 0.02,
                   0.2,
                   0.05,
                   0.01)

"""
Reward function, evaluated at each time step after taking an action.
    ...
    Arguments: current_model: the model at the current time step
               past_infected: the number of infected before applying new tests

    Output: the reward of the action
    ...

"""
function reward(current_model::ABM)
  #quarantine = count(i.status  == :Q for i in allagents(current_model)) # number of people currently in quarantine
  q_not_inf = count(i.q_not_inf == 1 for i in allagents(current_model)) # number of people currently in quarantine and not infected
  infected = count(i.status  == :I for i in allagents(current_model)) # number of people currently infected
  exposed = count(i.status == :E for i in allagents(current_model)) # people that actually get infected over the course of the simulation
  # if past_infected == 0
  #     rate = 0
  # else
  #     rate = (infected/past_infected - 1)*100 # infection rate
  # end
  return -(0.5*infected + 0.5*exposed+0.2*q_not_inf) # the reward needs to be maximized, whilst minimizing the objective (that's why it has a minus sign)
end

"""
State function, computes the state in which the model is currently at.
    ...
    Arguments: model = the model at the current time step

    Output: cout = number of total groups currently in quarantine
    ...

"""
function state(model::ABM)
    count =  1
    for i in 1:model.no_groups
        group = filter(p -> p.category == i, collect(allagents(model)))
        if any(p -> p.status == :I, group) # Add to the count only if all the individuals in the group are in quarantine
            count += 1
        end
    end
    # count = 1
    # for i in 1:model.no_groups
    #     group = filter(p -> p.category == i, collect(allagents(model)))
    #     if all(p -> p.status == :Q, group) # Add to the count only if all the individuals in the group are in quarantine
    #         count += 1
    #     end
    # end
    # return  count

    return Int(count)
end

function state_complete(model::ABM, n0::Int)
    state = zeros(Int, n0)
    for i in 1:n0
        group = filter(p -> p.category == i, collect(allagents(model)))
        if all(p -> p.status == :Q, group)
            state[i] = 1
        end
    end
    return state
end

"""
Action function, computes all possible  actions (permuations).
    ...
    Arguments: x = vector filled with ones and zeros

    Output: t = all possible permutations
    ...

"""
function unique_permutations(x::T, prefix=T()) where T
    if length(x) == 1
        return [[prefix; x]]
    else
        t = T[]
        for i in eachindex(x)
            if i > firstindex(x) && x[i] == x[i-1]
                continue
            end
            append!(t, unique_permutations([x[begin:i-1];x[i+1:end]], [prefix; x[i]]))
        end
        return t
    end
end

"""
Learning function, implementation  of tabular q-learning with temporal difference
    ...
    Arguments: model = Initialized SEIRQ ABM model
               tests_per_day = tests applied each testing day
               no_training_epochs = epochs for the model to train
               α = learning rate
               γ = discount reward factor

    Output: Q_table = Q-table with state to action pairs
    ...

"""
function learning(model::ABM, tests_per_day::Int, no_training_epochs::Int, γ = 0.4)
    no_groups = model.no_groups # number of groups
    action_space = unique_permutations([ones(Int, tests_per_day);zeros(Int, no_groups - tests_per_day)])
    no_actions = size(action_space)[1] # total number of possible actions
    Q_table  = spzeros(no_groups+1, no_actions) # initialize Q table
    rewa = Float64[]  # rewards for each epoch
    no_infected = Int32[]  # people actually infected after each epoch
    Solutions = Vector{Vector{Int32}}
    quarantine = Solutions()
    # training begins
    @showprogress for i in 1:no_training_epochs
        α = 0.5*(1-i/no_training_epochs) + (i/no_training_epochs)*0.05
        quad = Int32[]
        reset_model!(model) # the model is reset to its orgiginal values after each iteration
        current_state = state(model) # retrival of the state
        rew = 0.0 # restart reward after each training epoch
        for j in 0:99 # simulation starts for a 100 days
            # testing ocurrs on Monday's, Wednesday's, and Friday's
            if (j % 5 == 0) || (j % 5 == 2) || (j % 5 == 4)
                r_t = 0.0
                # epsilon greedy. for managing exploration and eplotation
                # 1 - ϵ decreases after each epoch
                if rand() < 1*(1-i/no_training_epochs) +  (i/no_training_epochs)*0.1
                    action_index = sample(1:no_actions)
                    @inbounds action = action_space[action_index] # random action
                else
                    @inbounds action_index = argmax(Q_table[current_state,:])
                    @inbounds action = action_space[action_index] # action that it's the most optimal
                end

                # We try to use the strategy choosen above, and if any of the groups is in quarantine
                # we select other groups to be tested that are not in quarantine
                new_groups_in_q, new_groups_tested, action_equal = contain!(model, action)
                for t in new_groups_in_q push!(quad, t); r_t += 100.0;  if  size(new_groups_in_q) == size(new_groups_tested); r_t += 50.0; end; end
                if action_equal == false
                    action = zeros(Int,model.no_groups)
                    action[new_groups_tested] .= 1
                    action_index = findall(x -> x == action, action_space)[1]
                end

                r_t += reward(model) #  compute the reward for the action taken
                rew += γ^(j)*r_t # add reward to plot afterwards

                step!(model, agent_step!, 1) # advance the model another step/day
                next_state = state(model) # compute the next step
                # updated q value computation, using temporal diffence
                @inbounds old_value = Q_table[current_state, action_index]
                @inbounds next_max = maximum(Q_table[next_state,:])
                @inbounds q_new  = (1 - α)*old_value[1] + α*(r_t + γ*next_max)
                @inbounds Q_table[current_state, action_index] = q_new
                current_state = next_state
            else
                step!(model, agent_step!, 1)
                current_state = state(model)
            end
        end
        push!(rewa, rew)
        push!(no_infected, count(i.infected == true for i in allagents(model)))
        push!(quarantine, quad)
    end
    return Q_table, rewa, no_infected, quarantine
end

function learning_complete(tests_per_day::Int, no_training_epochs::Int, α = 0.1, γ = 0.9)
    model = initialise(
                       100, 0.05, 0.02,
                       0.2,
                       0.05,
                       0.01)
    no_groups = model.no_groups # number of groups
    action_space = unique_permutations([ones(Int, tests_per_day);zeros(Int, no_groups - tests_per_day)])
    no_actions = size(action_space)[1] # total number of possible actions
    Q_table  = spzeros(2^no_groups, no_actions) # initialize Q table
    rewa = Float64[]  # rewards for each epoch
    no_infected = Int32[]  # people actually infected after each epoch
    state_space = [[α,β,γ,a,b,c,d,e,f,g] for α in 0:1 for β in 0:1 for γ in 0:1 for a in 0:1 for b in 0:1 for c in 0:1 for d in 0:1 for e in 0:1 for f in 0:1 for g in 0:1]

    # training begins
    @showprogress for i in 1:no_training_epochs
        current_state = state_complete(model, no_groups) # retrival of the state
        current_index = 1
        rew = 0.0 # restart reward after each training epoch
        for j in 0:99 # simulation starts for a 100 days
            # testing ocurrs on Monday's, Wednesday's, and Friday's
            if (j % 5 == 0) || (j % 5 == 2) || (j % 5 == 4)
                #past_infected = count(i.status  == :I for i in allagents(model))
                # epsilon greedy. for managing exploration and eplotation
                # 1 - ϵ decreases after each epoch
                if rand() < 1*(1-i/no_training_epochs) +  (i/no_training_epochs)*0.1
                    action_index = sample(1:no_actions)
                    @inbounds action = action_space[action_index] # random action
                else
                    @inbounds action_index = argmax(Q_table[current_index,:])
                    @inbounds action = action_space[action_index] # action that it's the most optimal
                end

                # We try to use the strategy choosen above, and if any of the groups is in quarantine
                # we select other three gorups to be tested that are no in quarantine
                new_groups_in_q, new_groups_tested, action_equal = contain!(model, action)
                for t in new_groups_in_q push!(quad, t); r_t += 100.0;  if  size(new_groups_in_q) == size(new_groups_tested); r_t += 50.0; end; end
                if action_equal == false
                    action = zeros(Int,model.no_groups)
                    action[new_groups_tested] .= 1
                    action_index = findall(x -> x == action, action_space)[1]
                end

                r_t = reward(model) # compute the reward for the action taken
                rew = rew + (γ^j)*r_t # add reward to plot afterwards

                step!(model, agent_step!, 1) # advance the model another step
                next_state = state_complete(model, no_groups) # compute the next step
                next_index = findall(x -> x == next_state, state_space)[1]

                # updated q value computation, using temporal diffence
                @inbounds old_value = Q_table[current_index, action_index]
                @inbounds next_max = maximum(Q_table[next_index,:])
                @inbounds q_new  = (1 - α)*old_value[1] + α*(r_t + γ*next_max)
                @inbounds Q_table[current_index, action_index] = q_new
                current_state = next_state
                current_index = next_index
            else
                step!(model, agent_step!, 1)
                current_state = state(model)
            end
        end
        push!(rewa, rew)
        push!(no_infected, count(i.infected == true for i in allagents(model)))
            model = initialise(
                               100, 0.05, 0.02,
                               0.2,
                               0.05,
                               0.01)
    end
    return Q_table, rewa, no_infected
end

# plots
Q, rewa, no_infected, quarantine = learning(model, 3, 10000)
T = Float64[]
S = Float64[]
for i in 1:500
    push!(T,sum(rewa[i*20-19:i*20])/20)
    push!(S,sum(no_infected[i*20-19:i*20])/20)
end
# for i in 1:2500
#     push!(S,sum(no_infected[i*40-39:i*40])/40)
# end
plot1 = plot(T, title =  "Average sum of discounted rewards",titlelocation = :center, label  = "Discounted reward", xlabel= "Twenty epoch average",legend=:bottomleft,smooth=true)
plot2 = plot(S, title = "Average number of total infections",titlelocation = :center, label = "Number of people infected", xlabel= "Twenty epoch average",legend=:bottomleft, smooth = true)
savefig(plot2, "no_infected_pres.pdf")
savefig(plot1, "reward_pres.pdf")

action_space = unique_permutations([ones(Int, 3);zeros(Int, 147)])
graf1 = Int32[]
quade = Int32[]
Solutions = Vector{Vector{Int32}}
groups_in_qq = Solutions()
groups_in_qr = Solutions()
reset_model!(model)
for i in 0:99
    if (i % 5 == 0) || (i % 5 == 2) || (i % 5 == 4)
        state_now = state(model)
        action_idx = argmax(Q[state_now,:])
        action = action_space[action_idx]
        new_groups_in_q, new_groups_tested, action_equal = contain!(model,action)
        push!(groups_in_qq, new_groups_in_q)
        push!(quade,count(i.status  == :Q for i in allagents(model)))
        push!(graf1,count(i.status  == :I for i in allagents(model)))
        step!(model,agent_step!)
    else
        push!(quade,count(i.status  == :Q for i in allagents(model)))
        push!(graf1,count(i.status  == :I for i in allagents(model)))
        step!(model,agent_step!)
    end
end

# reset_model!(model)
# for i in 0:99
#     push!(quade,count(i.status  == :I for i in allagents(model)))
#     step!(model,agent_step!)
# end

# grafs = [graf1,quade]
# plot3 = plot(1:100,grafs, label = ["Q action policy" "No policy"], xlabel= "Number of days", ylabel  = "Active cases", title  =  "Epidemic curve for two policies")
# savefig(plot3, "Quad-cases3.pdf")

graf2 = Int32[]
quadee = Int32[]
reset_model!(model)
for i in 0:99
    if (i % 5 == 0) || (i % 5 == 2) || (i % 5 == 4)
        action_idx = sample(1:size(action_space)[1])
        action = action_space[action_idx]
        new_groups_in_q, new_groups_tested, action_equal = contain!(model,action)
        push!(groups_in_qr, new_groups_in_q)
        push!(graf2,count(i.status  == :I for i in allagents(model)))
        push!(quadee,count(i.status  == :Q for i in allagents(model)))
        step!(model,agent_step!)
    else
        push!(graf2,count(i.status  == :I for i in allagents(model)))
        push!(quadee,count(i.status  == :Q for i in allagents(model)))
        step!(model,agent_step!)
    end
end

quadeee = Int32[]
graf3 = Int32[]
reset_model!(model)
for i in 0:99
    if (i % 5 == 0) || (i % 5 == 2) || (i % 5 == 4)
        groups_notin_q = [1,2,3,4]
        exp = average_exposure(model,groups_notin_q)
        seg = segment_sizes(model, groups_notin_q)
        prob = segment_probabilities(model, groups_notin_q, seg)
        cost = obtain_cost(model, groups_notin_q)
        test_alloc, group_sizes = solve_opt_problem(model, groups_notin_q, seg, exp, prob, cost, 3)
        unif_group_tests!(model, groups_notin_q, test_alloc, group_sizes)
        push!(graf3,count(i.status  == :I for i in allagents(model)))
        push!(quadeee,count(i.status  == :Q for i in allagents(model)))
        step!(model,agent_step!)
    else
        push!(graf3,count(i.status  == :I for i in allagents(model)))
        push!(quadeee,count(i.status  == :Q for i in allagents(model)))
        step!(model,agent_step!)
    end
end

grafff =  [graf1, graf3]
plot4 = plot(1:100,grafff, label = ["Q action policy" "Original protocol"], xlabel= "Number of days", ylabel  = "Active cases", title  =  "Epidemic curve for two policies")
savefig(plot4, "epidemic_pres_new24567.pdf")

grafs = [graf1,graf2]
plot3 = plot(1:100,grafs, label = ["Q action policy" "Random policy" ], xlabel= "Number of days", ylabel  = "Active cases", title  =  "Epidemic curve for two policies")
savefig(plot3, "epidemic_pres_2new24567.pdf")

qud = [quade, quadee,quadeee]
plot7 = plot(1:100,qud, label = ["Q action policy" "Random policy" "Original protocol"], xlabel= "Number of days", ylabel  = "Individuals in quarantine", title  =  "Number of people in quarantine for three policies")
savefig(plot7, "quarantineee234567.pdf")
