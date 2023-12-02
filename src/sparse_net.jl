################################################################################
## PTNet

"""
    BasicSparseNet

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
mutable struct BasicSparseNet <: AbstractBasicSparseDiscreteNet
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
    BasicSparseNet(in::SparseArray{Float64, 3}, out::SparseArray{Float64, 3}, mark::SparseArray{Float64, 2})

DOCSTRING

# Arguments:
- `in`: DESCRIPTION
- `out`: DESCRIPTION
- `mark`: DESCRIPTION
"""
function BasicSparseNet(in::SparseArray{Float64,3}, out::SparseArray{Float64,3}, mark::SparseArray{Float64,2})

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
    BasicSparseNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{S})

DOCSTRING

# Arguments:
- `place_size`: DESCRIPTION
- `transition_size`: DESCRIPTION
- `resource_size`: DESCRIPTION
- `code`: DESCRIPTION
"""
function BasicSparseNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{S}) where {S<:AbstractToken}

    # make arrays/tensors
    in = SparseArrayKit.SparseArray(zeros(Float64, place_size, transition_size, resource_size))

    out = SparseArrayKit.SparseArray(zeros(Float64, place_size, transition_size, resource_size))

    mark = SparseArrayKit.SparseArray(zeros(Float64, place_size, resource_size))

    enabled = SparseArrayKit.SparseArray(zeros(Bool, transition_size))

    build_from_code!(code, in, out, mark)

    # build the net
    net = BasicSparseNet(
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
    EnergySparseNet

DOCSTRING

# Fields:
- `basenet::BasicSparseNet`: DESCRIPTION
- `energy::EnergyLookup`: DESCRIPTION
"""
mutable struct EnergySparseNet <: AbstractEnergySparseDiscreteNet
    basenet::BasicSparseNet
    energy::EnergyLookup
end


"""
    Base.getproperty(net::EnergySparseNet, s::Symbol)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
- `s`: DESCRIPTION
"""
function Base.getproperty(net::EnergySparseNet, s::Symbol)
    if s in [:basenet, :energy]
        return getfield(net, s)
    else
        return getproperty(net.basenet, s)
    end
end


"""
EnergySparseNet(in::Array{Float64, 3}, out::Array{Float64, 3}, mark::Array{Float64, 2}, energies::EnergyLookup)

DOCSTRING

# Arguments:
- `in`: DESCRIPTION
- `out`: DESCRIPTION
- `mark`: DESCRIPTION
- `energies`: DESCRIPTION
"""
function EnergySparseNet(in::Array{Float64,3}, out::Array{Float64,3}, mark::Array{Float64,2}, energies::EnergyLookup)
    return EnergySparseNet(
        PTNet(in, out, mark),
        energies
    )
end


"""
    EnergySparseNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{S}, resources::Vector{Vector{E}})

DOCSTRING

# Arguments:
- `place_size`: DESCRIPTION
- `transition_size`: DESCRIPTION
- `resource_size`: DESCRIPTION
- `code`: DESCRIPTION
- `resources`: DESCRIPTION
"""
function EnergySparseNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{S}, resources::Vector{Vector{E}}) where {S<:AbstractToken,E<:AbstractEnergyToken}
    return EnergySparseNet(
        PTNetSparse(
            place_size,
            transition_size,
            resource_size,
            code
        ),
        EnergyLookup(resources)
    )
end

