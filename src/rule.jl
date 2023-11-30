using AutomaticDocstrings # not necessary for the running of the module
AutomaticDocstrings.options[:min_args] = 1
AutomaticDocstrings.options[:kwargs_header] = "# Keyword arguments:"

using SparseArrayKit


########################################################################################################################
## Rule structures and constructors
"""
    Rule

DOCSTRING

# Fields:
- `label::Int64`: DESCRIPTION
- `replaced_places::Vector{Int64}`: DESCRIPTION
- `enabled::bool`: DESCRIPTION
- `target_in::Array{Float64, 3}`: DESCRIPTION
- `target_out::Array{Float64, 3}`: DESCRIPTION
- `control_marking::Array{Float64, 2}`: DESCRIPTION
- `effect_in::Array{Float64, 3}`: DESCRIPTION
- `effect_out::Array{Float64, 3}`: DESCRIPTION
- `marking_redistribution::Function`: DESCRIPTION
- `p_size::Int64`: DESCRIPTION
- `t_size::Int64`: DESCRIPTION
- `r_size::Int64`: DESCRIPTION
"""
mutable struct Rule <: AbstractRule
    label::Int64
    enabled::bool
    replaced_places::Set{Int64}
    # target to fullfill
    target_in::Array{Float64,3}
    target_out::Array{Float64,3}

    # additional condition
    control_marking::Array{Float64,2}

    # effect
    effect_in::Array{Float64,3}
    effect_out::Array{Float64,3}

    # auxilliary stuff
    marking_redistribution::Function
    transfer_relation_places::Dict{Int64,Set{Int64}}
    transfer_relation_transitions::Dict{Int64,Set{Int64}}
    old_marking::Array{Float64,2}

    p_size::Int64
    t_size::Int64
    r_size::Int64
end


"""
    build_rule_from_code!(target_in::Array{Float64, 3}, target_out::Array{Float64, 3}, control_marking::Array{Float64, 2}, effect_in::Array{Float64, 3}, effect_out::Array{Float64, 3}, code::Vector{S})

DOCSTRING

# Arguments:
- `target_in`: DESCRIPTION
- `target_out`: DESCRIPTION
- `control_marking`: DESCRIPTION
- `effect_in`: DESCRIPTION
- `effect_out`: DESCRIPTION
- `code`: DESCRIPTION
"""
function build_rule_from_code!(
    label::Int64,
    target_in::Union{Array{Float64,3},SparseArray{Float64,3}},
    target_out::Union{Array{Float64,3},SparseArray{Float64,3}},
    control_marking::Union{Array{Float64,2},SparseArray{Float64,2}},
    effect_in::Union{Array{Float64,3},SparseArray{Float64,3}},
    effect_out::Union{Array{Float64,3},SparseArray{Float64,3}},
    transfer_relation_places::Dict{Int64,Set{Int64}},
    transfer_relation_transitions::Dict{Int64,Set{Int64}},
    code::Vector{S}) where {S<:AbstractRuleToken}

    for token in code
        if token.rulelabel == label && isempty(token.replace) == false

            # target 
            if token.k == P
                target_in[token.p, token.t, :] += token.w
            elseif token.k == T
                target_out[token.p, token.t, :] += token.w
            elseif token.k == I
                target_in = fill(-1.0, size(target.in)[3])
            end

            # control marking 
            control_marking[token.p, :] += token.c

            # effect
            for ruletoken in token.replace
                push!(transfer_relation_places[token.p], ruletoken.p)
                push!(transfer_relation_transitions[token.t], ruletoken.t)

                if ruletoken.k == P
                    effect_in[ruletoken.p, ruletoken.t, :] += ruletoken.w
                elseif ruletoken.k == T
                    effect_out[ruletoken.p, ruletoken.t, :] += ruletoken.w
                elseif ruletoken.k == I
                    effect_in = fill(-1.0, size(target.in)[3])
                end
            end
        end
    end
end


"""
    Rule(label::Int64, p_size::Int64, t_size::Int64, r_size::Int64, marking_redistribution::Function, code::Vector{S})

DOCSTRING

# Arguments:
- `label`: DESCRIPTION
- `p_size`: DESCRIPTION
- `t_size`: DESCRIPTION
- `r_size`: DESCRIPTION
- `marking_redistribution`: DESCRIPTION
- `code`: DESCRIPTION
"""
function Rule(label::Int64, p_size::Int64, t_size::Int64, r_size::Int64, marking_redistribution::Function, code::Vector{S}) where {S<:AbstractRuleToken}

    #target 
    target_in::Array{Float64,3} = zeros(Float64, p_size, t_size, r_size)
    target_out::Array{Float64,3} = zeros(Float64, p_size, t_size, r_size)

    #additional condition
    control_marking::Array{Float64,2} = zeros(Float64, p_size, r_size)

    # effect 
    effect_in::Array{Float64,3} = zeros(Float64, p_size, t_size, r_size)
    effect_out::Array{Float64,3} = zeros(Float64, p_size, t_size, r_size)

    #transfer relation 
    transfer_relation_places = Dict{Int64,Set{Int64}}()
    transfer_relation_transitions = Dict{Int64,Set{Int64}}()

    #building the constituents
    build_rule_from_code!(label, target_in, target_out, control_marking, effect_in, effect_out, transfer_relation_places, transfer_relation_transitions, code)

    return Rule(
        label,
        false,
        Set(),
        target_in,
        target_out,
        control_marking,
        effect_in,
        effect_out, marking_redistribution,
        transfer_relation_places,
        transfer_relation_transitions,
        Array{Float64,2}(), p_size,
        t_size,
        r_size
    )
end



"""
    SparseRule

DOCSTRING

# Fields:
- `label::Int64`: DESCRIPTION
- `replaced_places::Dict{Int64, Vector{Int64}}`: DESCRIPTION
- `enabled::bool`: DESCRIPTION
- `target_in::SparseArray{Float64, 3}`: DESCRIPTION
- `target_out::SparseArray{Float64, 3}`: DESCRIPTION
- `control_marking::SparseArray{Float64, 2}`: DESCRIPTION
- `effect_in::SparseArray{Float64, 3}`: DESCRIPTION
- `effect_out::SparseArray{Float64, 3}`: DESCRIPTION
- `marking_redistribution::Function`: DESCRIPTION
- `p_size::Int64`: DESCRIPTION
- `t_size::Int64`: DESCRIPTION
- `r_size::Int64`: DESCRIPTION
"""
mutable struct SparseRule <: AbstractSparseRule
    label::Int64
    enabled::bool
    replaced_places::Set{Int64}

    # target to fullfill
    target_in::SparseArray{Float64,3}
    target_out::SparseArray{Float64,3}

    # additional condition
    control_marking::SparseArray{Float64,2}

    # effect
    effect_in::SparseArray{Float64,3}
    effect_out::SparseArray{Float64,3}

    # auxilliary stuff
    marking_redistribution::Function
    transfer_relation_places::Dict{Int64,Set{Int64}}
    transfer_relation_transitions::Dict{Int64,Set{Int64}}
    old_marking::SparseArray{Float64,2}(), p_size::Int64
    t_size::Int64
    r_size::Int64
end


"""
SparseRule(label::Int64, p_size::Int64, t_size::Int64, r_size::Int64, marking_redistribution::Function, code::Vector{S})

DOCSTRING

# Arguments:
- `label`: DESCRIPTION
- `p_size`: DESCRIPTION
- `t_size`: DESCRIPTION
- `r_size`: DESCRIPTION
- `marking_redistribution`: DESCRIPTION
- `code`: DESCRIPTION
"""
function SparseRule(label::Int64, p_size::Int64, t_size::Int64, r_size::Int64, marking_redistribution::Function, code::Vector{S}) where {S<:AbstractRuleToken}

    #target 
    target_in::SparseArray{Float64,3} = SparseArray(zeros(Float64, p_size, t_size, r_size))
    target_out::SparseArray{Float64,3} = SparseArray(zeros(Float64, p_size, t_size, r_size))

    #additional condition
    control_marking::SparseArray{Float64,2} = SparseArray{zeros(Float64, p_size, r_size)}

    # effect 
    effect_in::SparseArray{Float64,3} = SparseArray{zeros(Float64, p_size, t_size, r_size)}
    effect_out::SparseArray{Float64,3} = SparseArray{zeros(Float64, p_size, t_size, r_size)}

    #transfer relation 
    transfer_relation_places = Dict{Int64,Set{Int64}}()
    transfer_relation_transitions = Dict{Int64,Set{Int64}}()

    #building the constituents
    build_rule_from_code!(label, target_in, target_out, control_marking, effect_in, effect_out, transfer_relation_places, transfer_relation_transitions, code)

    return SparseRule(
        label,
        false,
        Set(),
        target_in,
        target_out,
        control_marking,
        effect_in,
        effect_out, marking_redistribution,
        transfer_relation_places,
        transfer_relation_transitions,
        SparseArray{Float64,2}(), p_size,
        t_size,
        r_size
    )
end



########################################################################################################################
## Functionality

"""
    rebuild_net!(net::N, rule::Rule)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
- `rule`: DESCRIPTION
"""
function rebuild_net!(rule::R, net::N) where {N<:AbstractNet,R<:AbstractRule}

    # This assumes that the net does only get bigger beyond the largest indices, 
    # and excludes any kind of in-between insertion or reshuffling of nodes 

    TensorType = typeof(net.input)
    MarkingType = typeof(net.marking)
    BVecType = typeof(net.enabled)
    BMatrixType = typeof(net.noninhibitor_arcs)

    if rule.p_size > size(net.input)[1] || rule.t_size > size(net.input)[2] || rule.r_size > size(net.input)[3]

        s = size(net.input)

        input::TensorType = zeros(rule.p_size, rule.t_size, rule.r_size)
        in[1:s[1], 1:s[2], 1:s[3]] = net.input
        net.input = input

        out::TensorType = zeros(rule.p_size, rule.t_size, rule.r_size)
        in[1:s[1], 1:s[2], 1:s[3]] = net.output
        net.output = out

        mark::MarkingType = zeros(rule.p_size, rule.r_size)
        mark[1:s[1], 1:s[3]] = net.marking
        net.marking = mark

        enabled::BVecType = zeros(Bool, rule.t_size)
        enabled[1:s[2]] = net.enabled
        net.enabled = enabled

        net.noninhibitor_arcs::BMatrixType = zeros(Bool, rule.p_size, rule.t_size)
        net.input_interface_places::BVecType = zeros(Bool, rule.p_size,)
        net.ouput_interface_places::BVecType = zeros(Bool, rule.p_size,)
        net.input_interface_transitions::BVecType = zeros(Bool, rule.t_size,)
        net.output_interface_transitions::BVecType = zeros(Bool, rule.t_size,)

        compute_input_interface_places!(net)
        compute_input_interface_transitions!(net)
        compute_output_interface_places!(net)
        compute_output_interface_transitions!(net)
        compute_non_inhibitor_arcs!(net)
    end
end


"""
    count_nonzero_target_elements(rule::Rule)

DOCSTRING

# Arguments:
- `rule`: DESCRIPTION
"""
function count_nonzero_target_elements(rule::R)::Dict{String,Int64} where {R<:AbstractDenseRule}
    res::Dict{String,Int64} = Dict()
    res["in"] = 0
    res["out"] = 0

    for p in 1:size(rule.target_in)[1]
        for t in 1:size(rule.target_in)[2]
            if all(rule.target_in[p, t, :] .≈ 0.0)
                continue
            else
                res["in"] += 1
            end
        end
    end

    for p in 1:size(rule.target_out)[1]
        for t in 1:size(rule.targe_out)[2]
            if all(rule.target_out[p, t, :] .≈ 0.0)
                continue
            else
                res["out"] += 1
            end
        end
    end

    return res
end

"""
    count_nonzero_target_elements(rule::R)

DOCSTRING

# Arguments:
- `rule`: DESCRIPTION
"""
function count_nonzero_target_elements(rule::R)::Dict{String,Int64} where {R<:AbstractSparseRule}

    res::Dict{String,Int64} = Dict()

    res["in"] = length(nonzero_values(rule.trage.target_in))
    res["out"] = length(nonzero_values(rule.trage.target_out))

    return res
end


"""
    count_nonzero_effect_elements(rule::Rule)

DOCSTRING

# Arguments:
- `rule`: DESCRIPTION
"""
function count_nonzero_effect_elements(rule::R)::Dict{String,Int64} where {R<:AbstractDenseRule}
    res::Dict{String,Int64} = Dict()
    res["in"] = 0
    res["out"] = 0

    for p in 1:size(rule.effect_in)[1]
        for t in 1:size(rule.effect_in)[2]
            if all(rule.effect_in[p, t, :] .≈ 0.0)
                continue
            else
                res["in"] += 1
            end
        end
    end

    for p in 1:size(rule.effect_out)[1]
        for t in 1:size(rule.effect_out)[2]
            if all(rule.effect_out[p, t, :] .≈ 0.0)
                continue
            else

                res["out"] += 1
            end
        end
    end

    return res
end


"""
    count_nonzero_effect_elements(rule::R)

DOCSTRING

# Arguments:
- `rule`: DESCRIPTION
"""
function count_nonzero_effect_elements(rule::R)::Dict{String,Int64} where {R<:AbstractSparseRule}
    res::Dict{String,Int64} = Dict()

    res["in"] = length(nonzero_values(rule.trage.effect_in))
    res["out"] = length(nonzero_values(rule.trage.effect_out))

    return res
end


"""
    compute_enabled!(rule::R, nets::Vector{N}, with_control_marking::Bool, with_weight_check::Bool)

DOCSTRING

# Arguments:
- `rule`: DESCRIPTION
- `nets`: DESCRIPTION
- `with_control_marking`: DESCRIPTION
- `with_weight_check`: DESCRIPTION
"""
function compute_enabled!(rule::R; nets::Vector{N}=[], with_control_marking::Bool=false, with_weight_check::Bool=false)::Bool where {N<:AbstractSparseNet,R<:AbstractSparseRule}

    control_marking_fulfilled::Bool = true

    pattern_found::Bool = true

    # check pattern in network
    @inline @inbounds for key in nonzero_keys(rule.target_in)

        pattern_found_single::Bool = true

        @inline @inbounds for net in nets
            if with_weight_check

                pattern_found_single = pattern_found_single && (haskey(net.input.data, key) && net.input[key] ≈ rule.target_in[key])
            else

                pattern_found_single = pattern_found_single && haskey(net.input.data, key)
            end
        end

        pattern_found = pattern_found && pattern_found_single
    end

    @inline @inbounds for key in nonzero_keys(rule.target_out)

        pattern_found_single::Bool = true

        @inline @inbounds for net in nets

            if with_weight_check

                pattern_found_single = pattern_found_single && (haskey(net.output.data, key) && net.output[key] ≈ rule.target_out[key])

            else

                pattern_found_single = pattern_found_single && haskey(net.output.data, key)
            end
        end

        pattern_found = pattern_found && pattern_found_single

    end

    # check control marking
    if with_control_marking

        @inline @inbounds for key in nonzero_keys(rule.control_marking)

            found_marking_single::Bool = true

            @inline @inbounds for net in nets

                found_marking_single = found_marking_single && (haskey(net.marking.data, key) && net.marking[key] ≈ rule.control_marking[key])

            end

            control_marking_fulfilled = control_marking_fulfilled && found_marking_single
        end

    end

    return pattern_found && control_marking_fulfilled
end


"""
    compute_enabled!(rule::R; nets::Vector{N}, with_control_marking::Bool = false, with_weight_check::Bool = false)

DOCSTRING

# Arguments:
- `rule`: DESCRIPTION
# Keyword arguments:
- `nets`: DESCRIPTION
- `with_control_marking`: DESCRIPTION
- `with_weight_check`: DESCRIPTION
"""
function compute_enabled!(rule::R; nets::Vector{N}=[], with_control_marking::Bool=false, with_weight_check::Bool=false)::Bool where {N<:AbstractDenseNet,R<:AbstractDenseRule}


    control_marking_fulfilled::Bool = true

    pattern_found::Bool = true

    # check pattern in network
    @inline @inbounds for key in eachindex(rule.target_in)

        pattern_found_single::Bool = true

        @inline @inbounds for net in nets
            if with_weight_check

                pattern_found_single = pattern_found_single && ( net.input[key] ≈ 0. == false) && (net.input[key] ≈ rule.target_in[key])
            else

                pattern_found_single = pattern_found_single && (net.input[key] ≈ 0. == false)
            end
        end

        pattern_found = pattern_found && pattern_found_single
    end

    @inline @inbounds for key in eachindex(rule.target_out)

        pattern_found_single::Bool = true

        @inline @inbounds for net in nets

            if with_weight_check

                pattern_found_single = pattern_found_single && (net.output[key] ≈ 0. == false) && (net.output[key] ≈ rule.target_out[key])

            else

                pattern_found_single = pattern_found_single && (net.output[key] ≈ 0. == false)
            end
        end

        pattern_found = pattern_found && pattern_found_single

    end
    # check control marking
    if with_control_marking

        @inline @inbounds for key in eachindex(rule.control_marking)

            found_marking_single::Bool = true

            @inline @inbounds for net in nets

                found_marking_single = found_marking_single && (net.marking[key] ≈ 0. == false) && (net.marking[key] ≈ rule.control_marking[key])

            end

            control_marking_fulfilled = control_marking_fulfilled && found_marking_single
        end

    end

    return pattern_found && control_marking_fulfilled

end


"""
    rewrite!(net::N, rule::Rule)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
- `rule`: DESCRIPTION
"""
function rewrite!(rule::R, net::N; nets::Vector{N}=[], with_control_marking::Bool=false, with_weight_check::Bool=false)::Tuple{Int64,Int64} where {N<:AbstractSparseNet,R<:AbstractSparseRule}

    if rule.p_size < net.p_size || rule.t_size < net.t_size || rule.r_size < net.r_size 
        # rebuild net
        rebuild_net!(rule, net)
    end

    compute_enabled!(rule; nets=nets, with_control_marking=with_control_marking, with_weight_check=with_weight_check)

    rule.replaced_places = Set()
    rule.old_marking = SparseArray{Float64,2}()

    if rule.enabled

        rule.old_marking = net.marking

        # replace the nodes in the system 

        ## delete the old elements of the network 
        has_effect::Bool = false

        @inline @inbounds for key in nonzero_keys(rule.target_in)

            if haskey(net.input.data, key)

                if net.input[key] - rule.target_in[key] > 0.0 || net.input[key] - rule.target_in[key] ≈ 0.0 || net.input[key] ≈ -1.0
                    net.input[key] = 0.0 # this erases the element
                else
                    net.input[key] -= rule.target_in[key]
                end

                push!(rule.replaced_places, key[1])

                has_effect = true
            end

        end

        @inline @inbounds for key in nonzero_keys(rule.target_out)

            if haskey(net.output.data, key)

                if net.output[key] - rule.target_out[key] > 0.0 || net.output[key] - rule.target_out[key] ≈ 0.0
                    net.output[key] = 0.0 # this erases the element
                else
                    net.output[key] -= rule.target_out[key]
                end

                push!(rule.replaced_places, key[1])

                has_effect = true

            end

        end

        ## if something has changed, then add the new stuff
        if has_effect

            @inline @inbounds for key in nonzero_keys(rule.effect_in)

                if rule.effect_in[key] ≈ -1.0
                    net.input[key] = rule.effect_in[key]
                else
                    net.input[key] += rule.effect_in[key]
                end

                push!(rule.replaced_places, key[1])

            end

            @inline @inbounds for key in nonzero_keys(rule.effect_out)

                net.output[key] += rule.effect_out[key]

                push!(rule.replaced_places, key[1])

            end

        end

        # redistribute marking
        rule.marking_redistribution(net)
    end

end


"""
    rewrite!(rule::R, net::N; nets::Vector{N}, with_control_marking::Bool = false, with_weight_check::Bool = false)

DOCSTRING

# Arguments:
- `rule`: DESCRIPTION
- `net`: DESCRIPTION
# Keyword arguments:
- `nets`: DESCRIPTION
- `with_control_marking`: DESCRIPTION
- `with_weight_check`: DESCRIPTION
"""
function rewrite!(rule::R, net::N; nets::Vector{N}=[], with_control_marking::Bool=false, with_weight_check::Bool=false)::Tuple{Int64,Int64} where {N<:AbstractDenseNet,R<:AbstractDenseRule}

    compute_enabled!(rule; nets=nets, with_control_marking=with_control_marking, with_weight_check=with_weight_check)

    rule.replaced_places = Set()
    rule.old_marking = Array{Float64,2}()

    if rule.enabled

        rule.old_marking = net.marking

        # replace the nodes in the system 

        ## delete the old elements of the network 
        has_effect::Bool = false

        @inbounds @inline for key in eachindex(rule.target_in)

            if net.input[key] ≈ 0. == false

                if net.input[key] - rule.target_in[key] > 0.0 || net.input[key] - rule.target_in[key] ≈ 0.0 || net.input[key] ≈ -1.0
                    net.input[key] = 0.0 
                else
                    net.input[key] -= rule.target_in[key]
                end

                push!(rule.replaced_places, key[1])

                has_effect = true
            end

        end

        @inbounds @inline for key in eachindex(rule.target_out)

            if net.output[key] ≈ 0. == false

                if net.output[key] - rule.target_out[key] > 0.0 || net.output[key] - rule.target_out[key] ≈ 0.0
                    net.output[key] = 0.0 
                else
                    net.output[key] -= rule.target_out[key]
                end

                push!(rule.replaced_places, key[1])

                has_effect = true

            end

        end

        ## if something has changed, then add the new stuff
        if has_effect

            # rebuild net
            rebuild_net!(rule, net)

            @inbounds @inline for key in eachindex(rule.effect_in)

                if rule.effect_in[key] ≈ -1.0
                    net.input[key] = rule.effect_in[key]
                else
                    net.input[key] += rule.effect_in[key]
                end

                push!(rule.replaced_places, key[1])

            end

            @inbounds @inline for key in eachindex(rule.effect_out)

                net.output[key] += rule.effect_out[key]

                push!(rule.replaced_places, key[1])

            end

        end

        # redistribute marking
        rule.marking_redistribution(net)
    end

end


"""
    redistribute_marking_conserved(net::N, rule::Rule)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
- `rule`: DESCRIPTION
"""
function redistribute_marking_conserved(net::N, rule::R) where {N<:AbstractNet,R<:AbstractRule}

    @inline @inbounds for (old_key, new_keys) in rule.replaced_places

        n = rule.old_marking[old_key]

        @inline @inbounds for new_key in new_keys

            if n > 1.0
                net.marking[new_key] += 1.0
                n -= 1.0
            elseif n < 1.0
                net.marking[new_key] += n
                n = 0.0
            elseif n ≈ 0.0
                break
            else
                throw(ErrorException("Error, something wrong with conserved marking redistribution for old_index $old_key -> $new_keys at $new_key: n = $n, net.marking[$new_key] = $(net.marking[new_key])"))
            end
        end
    end
end


"""
    redistribute_marking_copy(net::N, rule::Rule)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
- `rule`: DESCRIPTION
"""
function redistribute_marking_copy(net::N, rule::R) where {N<:AbstractNet,R<:AbstractRule}

    for (old_key, new_keys) in rule.replaced_places

        for new_key in new_keys
            net.marking[new_key] = rule.old_marking[old_key]
        end

    end
end