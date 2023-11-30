

########################################################################################################################
## PTDenseNet

"""
    PTDenseNet

DOCSTRING

# Fields:
- `input::Array{Float64, 3}`: DESCRIPTION
- `output::Array{Float64, 3}`: DESCRIPTION
- `marking::Array{Float64, 2}`: DESCRIPTION
- `enabled::Array{Bool, 1}`: DESCRIPTION
- `input_interface_places::Array{Bool, 2}`: DESCRIPTION
- `input_interface_transitions::Array{Bool, 2}`: DESCRIPTION
- `output_interface_places::Array{Bool, 2}`: DESCRIPTION
- `output_interface_transitions::Array{Bool, 2}`: DESCRIPTION
- `functions::Array{Function, 1}`: DESCRIPTION
- `enabled_function::Function`: DESCRIPTION
"""
mutable struct PTDenseNet <: AbstractDiscreteDenseBasicNet
    input::Array{Float64,3}
    output::Array{Float64,3}
    marking::Array{Float64,2}
    tmp_marking::Array{Float64,2}
    enabled::Array{Bool,1}
    input_interface_places::Array{Bool,1}
    input_interface_transitions::Array{Bool,1}
    output_interface_places::Array{Bool,1}
    output_interface_transitions::Array{Bool,1}
    noninhibitor_arcs::Array{Bool,2}
end


# constructors for PTDenseNet and homogeneous and basic version of it
"""
    PTDenseNet(in::Array{Float64, 3}, out::Array{Float64, 3}, mark::Array{Float64, 2}, functions::Array{Function, 1})

DOCSTRING

# Arguments:
- `in`: DESCRIPTION
- `out`: DESCRIPTION
- `mark`: DESCRIPTION
- `functions`: DESCRIPTION
- `enabled`: DESCRIPTION
"""
function PTDenseNet(in::Array{Float64,3}, out::Array{Float64,3}, mark::Array{Float64,2})

    ps = size(in)[1]
    ts = size(in)[2]
    rs = size(in)[3]

    net = PTDenseNet(
        in,
        out,
        mark,
        zeros(Float64, ps, rs),
        zeros(Bool, ts),
        zeros(Bool, ps),
        zeros(Bool, ts),
        zeros(Bool, ps),
        zeros(Bool, ts),
        zeros(Bool, ps, ts),
    )

    compute_input_interface_places!(net)

    compute_output_interface_places!(net)

    compute_output_interface_places!(net)

    compute_output_interface_transitions!(net)

    compute_non_inhibitor_arcs!(net)

    return net
end


"""
    build_from_code!(code::Vector{S}, in::Array{Float64, 3}, out::Array{Float64, 3}, mark::Array{Float64, 2})

DOCSTRING

# Arguments:
- `code`: DESCRIPTION
- `in`: DESCRIPTION
- `out`: DESCRIPTION
- `mark`: DESCRIPTION
"""
function build_from_code!(code::Vector{S}, in::Array{Float64,3}, out::Array{Float64,3}, mark::Array{Float64,2}) where {S<:AbstractToken}

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
    PTDenseNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{AbstractToken})

DOCSTRING

# Arguments:
- `place_size`: DESCRIPTION
- `transition_size`: DESCRIPTION
- `resource_size`: DESCRIPTION
- `code`: DESCRIPTION
"""
function PTDenseNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{S}) where {S<:AbstractToken}

    # make arrays/tensors
    in::Array{Float64,3} = zeros(Float64, place_size, transition_size, resource_size)

    out::Array{Float64,3} = zeros(Float64, place_size, transition_size, resource_size)

    mark::Array{Float64,2} = zeros(Float64, place_size, resource_size)

    enabled::Array{Bool,1} = zeros(Bool, transition_size)

    build_from_code!(code, in, out, mark)

    # build the net
    net = PTDenseNet(
        in,
        out,
        mark,
        zeros(Float64, place_size, resource_size),
        enabled,
        zeros(Bool, place_size),
        zeros(Bool, transition_size),
        zeros(Bool, place_size),
        zeros(Bool, transition_size),
        zeros(Bool, place_size, transition_size),
    )

    # build the aux. data
    compute_input_interface_places!(net)

    compute_output_interface_places!(net)

    compute_output_interface_places!(net)

    compute_output_interface_transitions!(net)

    compute_non_inhibitor_arcs!(net)

    return net
end



################################################################################
## EnergyBasedNet

"""
    PTDenseNetEnergy

DOCSTRING

# Fields:
- `basenet::PTDenseNet`: DESCRIPTION
- `energy::EnergyLookup`: DESCRIPTION
"""
mutable struct PTDenseNetEnergy <: AbstractDiscreteDenseEnergyNet
    basenet::PTDenseNet
    energy::EnergyLookup
end


"""
    Base.getproperty(net::PTDenseNetEnergy, s::Symbol)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
- `s`: DESCRIPTION
"""
function Base.getproperty(net::PTDenseNetEnergy, s::Symbol)
    if s in [:basenet, :energy]
        return getfield(net, s)
    else
        return getproperty(net.basenet, s)
    end
end


"""
    PTDenseNetEnergy(in::Array{Float64, 3}, out::Array{Float64, 3}, mark::Array{Float64, 2}, energies::EnergyLookup)

DOCSTRING

# Arguments:
- `in`: DESCRIPTION
- `out`: DESCRIPTION
- `mark`: DESCRIPTION
- `energies`: DESCRIPTION
"""
function PTDenseNetEnergy(in::Array{Float64,3}, out::Array{Float64,3}, mark::Array{Float64,2}, energies::EnergyLookup)

    ps = size(in)[1]
    ts = size(in)[2]
    rs = size(in)[3]

    net = PTDenseNetEnergy(PTDenseNet(
            in,
            out,
            mark), energies)

    return net
end


"""
    PTDenseNetEnergy(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{S}, resources::Vector{Vector{E}})

DOCSTRING

# Arguments:
- `place_size`: DESCRIPTION
- `transition_size`: DESCRIPTION
- `resource_size`: DESCRIPTION
- `code`: DESCRIPTION
- `resources`: DESCRIPTION
"""
function PTDenseNetEnergy(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{S}, resources::Vector{Vector{E}}) where {S<:AbstractToken,E<:AbstractEnergyToken}

    # build the net
    net = PTDenseNetEnergy(PTDenseNet(
            place_size, transition_size, resource_size, code
        ),
        EnergyLookup(resources)
    )
    return net
end


########################################################################################################################
## PTSparseNet
