using SparseArrayKit
using TensorOperations
using LinearAlgebra

using AutomaticDocstrings # not necessary for the running of the module
AutomaticDocstrings.options[:min_args] = 1
AutomaticDocstrings.options[:kwargs_header] = "# Keyword arguments:"

################################################################################
## PTNet

"""
    PTSparseNet

DOCSTRING

# Fields:
- `input::SparseArray{Float64, 3}`: DESCRIPTION
- `output::SparseArray{Float64, 3}`: DESCRIPTION
- `marking::SparseArray{Float64, 2}`: DESCRIPTION
- `tmp_marking::SparseArray{Float64, 2}`: DESCRIPTION
- `enabled::SparseArray{Bool, 1}`: DESCRIPTION
- `input_interface_places::SparseArray{Bool, 1}`: DESCRIPTION
- `input_interface_transitions::SparseArray{Bool, 1}`: DESCRIPTION
- `output_interface_places::SparseArray{Bool, 1}`: DESCRIPTION
- `output_interface_transitions::SparseArray{Bool, 1}`: DESCRIPTION
- `noninhibitor_arcs::SparseArray{Bool, 2}`: DESCRIPTION
"""
mutable struct PTSparseNet <: AbstractDiscreteSparseNet
    input::SparseArray{Float64,3}
    output::SparseArray{Float64,3}
    marking::SparseArray{Float64,2}
    tmp_marking::SparseArray{Float64,2}
    enabled::SparseArray{Bool,1}
    input_interface_places::SparseArray{Bool,1}
    input_interface_transitions::SparseArray{Bool,1}
    output_interface_places::SparseArray{Bool,1}
    output_interface_transitions::SparseArray{Bool,1}
    noninhibitor_arcs::SparseArray{Bool,2}
end


"""
    PTSparseNet(in::SparseArray{Float64, 3}, out::SparseArray{Float64, 3}, mark::SparseArray{Float64, 2})

DOCSTRING

# Arguments:
- `in`: DESCRIPTION
- `out`: DESCRIPTION
- `mark`: DESCRIPTION
"""
function PTSparseNet(in::SparseArray{Float64,3}, out::SparseArray{Float64,3}, mark::SparseArray{Float64,2})

    ps = size(in)[1]
    ts = size(in)[2]
    rs = size(in)[3]

    net = PTNet(
        in,
        out,
        mark,
        SparseArrayKit.SparseArray(zeros(Float64, ps, rs)),
        SparseArrayKit.SparseArray(zeros(Bool, ts)),
        SparseArrayKit.SparseArray(zeros(Bool, ps)),
        SparseArrayKit.SparseArray(zeros(Bool, ts)),
        SparseArrayKit.SparseArray(zeros(Bool, ps)),
        SparseArrayKit.SparseArray(zeros(Bool, ts)),
        SparseArrayKit.SparseArray(zeros(Bool, ps, ts)),
    )

    compute_input_interface_places!(net)

    compute_output_interface_transitions!(net)

    compute_output_interface_places!(net)

    compute_output_interface_transitions!(net)

    compute_non_inhibitor_arcs!(net)

    return net

end


"""
    build_from_code!(code::Vector{S}, in::SparseArray{Float64, 3}, out::SparseArray{Float64, 3}, mark::SparseArray{Float64, 2})

DOCSTRING

# Arguments:
- `code`: DESCRIPTION
- `in`: DESCRIPTION
- `out`: DESCRIPTION
- `mark`: DESCRIPTION
"""
function build_from_code!(code::Vector{S}, in::SparseArrayKit.SparseArray{Float64,3}, out::SparseArrayKit.SparseArray{Float64,3}, mark::SparseArrayKit.SparseArray{Float64,2}) where {S<:AbstractToken}

    # build their values from code
    @inline @inbounds for symbol in code
        if symbol.k == P

            in[symbol.p, symbol.t, :] += symbol.w

        elseif symbol.k == T

            out[symbol.p, symbol.t, :] += symbol.w

        elseif symbol.k == I

            in[symbol.p, symbol.t, :] = fill(-1, size(in)[3])

        else
            throw(ErrorException("Error, unknown kind of symbol"))
        end

        mark[symbol.p, :] += symbol.m

    end
end


"""
    PTSparseNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{S})

DOCSTRING

# Arguments:
- `place_size`: DESCRIPTION
- `transition_size`: DESCRIPTION
- `resource_size`: DESCRIPTION
- `code`: DESCRIPTION
"""
function PTSparseNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{S}) where {S<:AbstractToken}

    # make arrays/tensors
    in = SparseArrayKit.SparseArray(zeros(Float64, place_size, transition_size, resource_size))

    out = SparseArrayKit.SparseArray(zeros(Float64, place_size, transition_size, resource_size))

    mark = SparseArrayKit.SparseArray(zeros(Float64, place_size, resource_size))

    enabled = SparseArrayKit.SparseArray(zeros(Bool, transition_size))

    build_from_code!(code, in, out, mark)

    # build the net
    net = PTSparseNet(
        in,
        out,
        mark,
        SparseArray{Float64, 2}(zeros(Float64, place_size, resource_size)),
        enabled,
        SparseArray{Bool, 1}(zeros(Bool, place_size)),
        SparseArray{Bool, 1}(zeros(Bool, transition_size)),
        SparseArray{Bool, 1}(zeros(Bool, place_size)),
        SparseArray{Bool, 1}(zeros(Bool, transition_size)),
        SparseArray{Bool, 2}(zeros(Bool, place_size, transition_size)),
    )

    # build the aux. data
    compute_input_interface_places!(net)

    @assert net.input_interface_places isa SparseArrayKit.SparseArray

    compute_output_interface_transitions!(net)

    compute_output_interface_places!(net)

    compute_output_interface_transitions!(net)

    compute_non_inhibitor_arcs!(net)

    return net
end
################################################################################
## EnergyBasedNet

"""
    PTSparseEnergyNet

DOCSTRING

# Fields:
- `basenet::PTSparseNet`: DESCRIPTION
- `energy::EnergyLookup`: DESCRIPTION
"""
mutable struct PTSparseEnergyNet <: AbstractDiscreteEnergySparseNet
    basenet::PTSparseNet
    energy::EnergyLookup
end


"""
    Base.getproperty(net::PTSparseEnergyNet, s::Symbol)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
- `s`: DESCRIPTION
"""
function Base.getproperty(net::PTSparseEnergyNet, s::Symbol)
    if s in [:basenet, :energy]
        return getfield(net, s)
    else
        return getproperty(net.basenet, s)
    end
end


"""
PTSparseEnergyNet(in::Array{Float64, 3}, out::Array{Float64, 3}, mark::Array{Float64, 2}, energies::EnergyLookup)

DOCSTRING

# Arguments:
- `in`: DESCRIPTION
- `out`: DESCRIPTION
- `mark`: DESCRIPTION
- `energies`: DESCRIPTION
"""
function PTSparseEnergyNet(in::Array{Float64,3}, out::Array{Float64,3}, mark::Array{Float64,2}, energies::EnergyLookup)
    return PTSparseEnergyNet(
        PTNet(in, out, mark),
        energies
    )
end


"""
    PTSparseEnergyNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{S}, resources::Vector{Vector{E}})

DOCSTRING

# Arguments:
- `place_size`: DESCRIPTION
- `transition_size`: DESCRIPTION
- `resource_size`: DESCRIPTION
- `code`: DESCRIPTION
- `resources`: DESCRIPTION
"""
function PTSparseEnergyNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{S}, resources::Vector{Vector{E}}) where {S<:AbstractToken,E<:AbstractEnergyToken}
    return PTSparseEnergyNet(
        PTNetSparse(
            place_size,
            transition_size,
            resource_size,
            code
        ),
        EnergyLookup(resources)
    )
end


################################################################################
# functions for net functionality

"""
    compute_input_interface_places!(net::N)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_input_interface_places!(net::N) where {N<:AbstractSparseNet}

    SparseArrayKit.zerovector!(net.input_interface_places)

    @inline @inbounds for p in 1:size(net.marking)[1]

        # input interface place: nothing comes into it -> output elements zero, 
        # stuff goes out from it: input elements nonzero

        if any(.!isapprox.(sum(net.input[p, :, :], dims=1), 0)) &&
           all(isapprox.(sum(net.output[p, :, :], dims=1), 0))
            net.input_interface_places[p] = true
        else
            #nothing to be done here
        end
    end
end


"""
    compute_input_interface_transitions!(net::N)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_input_interface_transitions!(net::N) where {N<:AbstractSparseNet}

    SparseArrayKit.zerovector!(net.input_interface_transitions)

    @inline @inbounds for t in 1:size(net.input)[2]
        # input interface transitions -> have no input => input==0, but have output ==> output nonzero
        if any(.!isapprox.(sum(net.output[:, t, :], dims=1), 0)) &&
           all(isapprox.(sum(net.input[:, t, :], dims=1), 0))
            net.input_interface_transitions[t] = true
        else
            #nothing to be done here
        end
    end
end


"""
    compute_output_interface_places!(net::N)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_output_interface_places!(net::N) where {N<:AbstractSparseNet}

    SparseArrayKit.zerovector!(net.output_interface_places)

    @inline @inbounds for p in 1:size(net.marking)[1]

        # input interface place: nothing comes into it -> output elements zero, 
        # stuff goes out from it: input elements nonzero

        if any(.!isapprox.(sum(net.output[p, :, :], dims=1), 0)) &&
           all(isapprox.(sum(net.input[p, :, :], dims=1), 0))

            net.output_interface_places[p] = true
        else
            # nothing to be done here
        end
    end
end


"""
    compute_output_interface_transitions!(net::N)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_output_interface_transitions!(net::N) where {N<:AbstractSparseNet}

    SparseArrayKit.zerovector!(net.output_interface_transitions)

    @inline @inbounds for t in 1:size(net.input)[2]
        # input interface transitions -> have no input => input==0, but have output ==> output nonzero
        if any(.!isapprox.(sum(net.input[:, t, :], dims=1), 0)) &&
           all(isapprox.(sum(net.output[:, t, :], dims=1), 0))
            net.output_interface_transitions[t] = true
        else
            # nothing to be done here
        end
    end
end


"""
    compute_non_inhibitor_arcs!(net::N)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_non_inhibitor_arcs!(net::N) where {N<:AbstractSparseNet}

    SparseArrayKit.zerovector!(net.noninhibitor_arcs)

    # inhibitor arc w(p,t) are those that have input[p, t, :] .== -1 over the resoure index r 
    @inline @inbounds net.noninhibitor_arcs = Matrix{Bool}(sum(net.input, dims=3)[:, :, 1] .!= size(net.input)[3] * -1.0)
end


################################################################################
## conflict handling

"""
    detect_conflict_vector(net::N)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function detect_conflict_vector(net::N)::BitVector where {N<:AbstractDiscreteSparseNet}
    
    println("detect_conflict_vector sparse")
    conflict::BitVector = fill(false, size(net.marking)[1])

    @inline @inbounds for p in 1:size(net.marking)[1]
        # conflict found when the sum of the weights going out from a place to enabled transitions is greater than its marking, such that they cannot all be served at once 
        
        if any((@tensor x[r] := net.input[p, :, :][t, r] * net.enabled[t]) .> net.marking[p, :])
            conflict[p] = true
        end
    end

    return conflict
end


"""
    detect_conflict(net::N)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function detect_conflict(net::N)::Bool where {N<:AbstractDiscreteSparseNet}
    
    conflict::Bool = false

    @inline @inbounds for p in 1:size(net.marking)[1]

        # conflict found when the sum of the weights going out from a place to enabled transitions is greater than its marking, such that they cannot all be served at once 
        if any((@tensor x[r] := net.input[p, :, :][t, r] * net.enabled[t]) .> net.marking[p, :])
            conflict = true

        end
    end

    return conflict
end


"""
    handle_conflict!(net::N)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function handle_conflict!(net::N) where {N<:AbstractDiscreteSparseNet}
    # randomly disable transitions until no more conflicts are detected
    @inline @inbounds while detect_conflict(net) && sum(net.enabled) > 0

        disabled::Bool = false

        @inline @inbounds while disabled == false

            # easier julia way
            idx::Int64 = rand(1:length(net.enabled))

            if net.enabled[idx]
                net.enabled[idx] = false
                disabled = true
            end

            # the way it's implemented in cpp:
            # for e in net.enabled 
            #     if e && rand(Float64) < 0.5
            #         e = false 
            #         disabled = true 
            #     end
            # end
        end

    end
end

################################################################################
## computation of enabled transitions for different types of nets 


"""
    compute_enabled!(net::N)  where {N <: AbstractDiscreteSparseNet}

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_enabled!(net::N) where {N <: AbstractDiscreteSparseNet}

    SparseArrayKit.zerovector!(net.enabled)

    @inline @inbounds for t in 1:size(net.input)[2]

        #declare temps and reset enabled value
        e::Bool = true

        # whether we have inhibitor arcs 
        @inline @inbounds for p in 1:size(net.input)[1]

            if all(net.input[p, t, :] .≈ 0.0)
                continue
            end

            # check that there is enough marking
            ew = all(net.marking[p, :] .> net.input[p, t, :] .|| net.marking[p, :] .≈ net.input[p, t, :])

            # check whether we have an inhibitor arc
            en = all(isapprox.(net.input[p, t, :], -1.0))

            # check whether marking is zero
            em = all(isapprox.(net.marking[p, :], 0))

            # first term before || is the normal marking when there is no inhibitors involved, second one is when there is an inhibitor involved
            e = e && ((!en && ew) || (en && em))
        end

        net.enabled[t] = e
    end
end


"""
    compute_enabled!(net::N) where{N <: AbstractDiscreteEnergySparseNet}

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_enabled!(net::N) where {N <: AbstractDiscreteEnergySparseNet}

    SparseArrayKit.zerovector!(net.enabled)

    @inline @inbounds for t in 1:size(net.input)[2]

        e::Bool = true

        @inline @inbounds for p in 1:size(net.input)[1]

            energy_m = 0.0

            energy_w = 0.0

            # build energy values
            @inline @inbounds for r in 1:size(net.input)[3]
                energy_m += net.marking[p, r] * net.energy.lookup_table[r]

                energy_w += net.input[p, t, r] * net.energy.lookup_table[r]
            end


            ew = energy_m > energy_w || isapprox(energy_m, energy_w)

            # check whether we have an inhibitor arc
            en = all(isapprox.(net.input[p, t, :], -1.0))

            # check whether marking energy is zero
            em = all(isapprox.(energy_m, 0.0))

            e = e && ((!en && ew) || (en && em))
        end

        net.enabled[t] = e
    end
end

################################################################################
## steps and runs of nets 

"""
    compute_step!(net::N)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_step!(net::N) where {N<:AbstractDiscreteSparseNet}

    compute_enabled!(net)

    handle_conflict!(net)

    if hasfield(typeof(net), :tmp_marking)

        @tensor begin
            net.tmp_marking[p, r] = (net.output[p, t, r] - (SparseArray{Float64, 3}(net.input .* net.noninhibitor_arcs) )[p, t, r]) * net.enabled[t] + net.marking[p, r]
        end

        net.marking = deepcopy(net.tmp_marking)

        SparseArrayKit.zerovector!(net.tmp_marking)

    elseif hasfield(typeof(net), :basenet)
        @tensor begin
            net.basenet.tmp_marking[p, r] = (net.basenet.output[p, t, r] - (SparseArray{Float64, 3}(net.basenet.input .* net.basenet.noninhibitor_arcs) )[p, t, r]) * net.basenet.enabled[t] + net.basenet.marking[p, r]
        end

        net.basenet.marking = deepcopy(net.basenet.tmp_marking)

        fill!(net.basenet.tmp_marking, 0.0)
    else
        throw(ErrorException("Error, unknown net makeup - neither :basenet nor basic net constituents are elements of the net"))
    end
end



"""
    run!(net::N, maxiter::Int64, tol::Float64)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
- `maxiter`: DESCRIPTION
- `tol`: DESCRIPTION
"""
function run!(net::N, maxiter::Int64, tol::Float64) where {N<:AbstractSparseNet}

    iter = 1

    old_marking = SparseArray{zeros(Float64, size(net.marking)...)}

    if hasfield(typeof(net), :tmp_marking)

        while iter < maxiter && (dot(net.marking - old_marking, net.marking - old_marking) > tol)
            
            old_marking = net.marking

            compute_step!(net)

            iter += 1
        end

    elseif hasfield(typeof(net), :basenet)

        while iter < maxiter && (dot(net.basenet.marking - old_marking, net.basenet.marking - old_marking) > tol)

            old_marking = net.basenet.marking

            compute_step!(net)

            iter += 1
        end

    else 
        throw(ErrorException("Error, unknown field in running net"))
    end
end