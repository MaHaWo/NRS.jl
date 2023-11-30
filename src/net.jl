using TensorOperations
using LinearAlgebra

using AutomaticDocstrings # not necessary for the running of the module
AutomaticDocstrings.options[:min_args] = 1
AutomaticDocstrings.options[:kwargs_header] = "# Keyword arguments:"

########################################################################################################################
## PTNet

"""
    PTNet

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
mutable struct PTNet <: AbstractDiscreteDenseNet
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


# constructors for PTNet and homogeneous and basic version of it
"""
    PTNet(in::Array{Float64, 3}, out::Array{Float64, 3}, mark::Array{Float64, 2}, functions::Array{Function, 1})

DOCSTRING

# Arguments:
- `in`: DESCRIPTION
- `out`: DESCRIPTION
- `mark`: DESCRIPTION
- `functions`: DESCRIPTION
- `enabled`: DESCRIPTION
"""
function PTNet(in::Array{Float64,3}, out::Array{Float64,3}, mark::Array{Float64,2})

    ps = size(in)[1]
    ts = size(in)[2]
    rs = size(in)[3]

    net = PTNet(
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
    PTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{AbstractToken})

DOCSTRING

# Arguments:
- `place_size`: DESCRIPTION
- `transition_size`: DESCRIPTION
- `resource_size`: DESCRIPTION
- `code`: DESCRIPTION
"""
function PTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{S}) where {S<:AbstractToken}

    # make arrays/tensors
    in::Array{Float64,3} = zeros(Float64, place_size, transition_size, resource_size)

    out::Array{Float64,3} = zeros(Float64, place_size, transition_size, resource_size)

    mark::Array{Float64,2} = zeros(Float64, place_size, resource_size)

    enabled::Array{Bool,1} = zeros(Bool, transition_size)

    build_from_code!(code, in, out, mark)

    # build the net
    net = PTNet(
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
    PTNetEnergy

DOCSTRING

# Fields:
- `basenet::PTNet`: DESCRIPTION
- `energy::EnergyLookup`: DESCRIPTION
"""
mutable struct PTNetEnergy <: AbstractDiscreteEnergyDenseNet
    basenet::PTNet
    energy::EnergyLookup
end


"""
    Base.getproperty(net::PTNetEnergy, s::Symbol)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
- `s`: DESCRIPTION
"""
function Base.getproperty(net::PTNetEnergy, s::Symbol)
    if s in [:basenet, :energy]
        return getfield(net, s)
    else
        return getproperty(net.basenet, s)
    end
end


"""
    PTNetEnergy(in::Array{Float64, 3}, out::Array{Float64, 3}, mark::Array{Float64, 2}, energies::EnergyLookup)

DOCSTRING

# Arguments:
- `in`: DESCRIPTION
- `out`: DESCRIPTION
- `mark`: DESCRIPTION
- `energies`: DESCRIPTION
"""
function PTNetEnergy(in::Array{Float64,3}, out::Array{Float64,3}, mark::Array{Float64,2}, energies::EnergyLookup)

    ps = size(in)[1]
    ts = size(in)[2]
    rs = size(in)[3]

    net = PTNetEnergy(PTNet(
            in,
            out,
            mark), energies)

    return net
end


"""
    PTNetEnergy(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{S}, resources::Vector{Vector{E}})

DOCSTRING

# Arguments:
- `place_size`: DESCRIPTION
- `transition_size`: DESCRIPTION
- `resource_size`: DESCRIPTION
- `code`: DESCRIPTION
- `resources`: DESCRIPTION
"""
function PTNetEnergy(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{S}, resources::Vector{Vector{E}}) where {S<:AbstractToken,E<:AbstractEnergyToken}

    # build the net
    net = PTNetEnergy(PTNet(
        place_size, transition_size, resource_size, code
        ),
        EnergyLookup(resources)
    )
    return net
end


# ################################################################################
# ## ContinuousPTNet
# """
#     ContinuousPTNet

# DOCSTRING

# # Fields:
# - `enabled_degree::Array{Float64, 1}`: DESCRIPTION
# - `enabled_weight::Array{Float64, 2}`: DESCRIPTION
# """
# mutable struct ContinuousPTNet <: AbstractContinuousNet
#     basenet::PTNet
#     enabled_degree::Array{Float64,1}
#     enabled_weight::Array{Float64,2}
# end

# """
#     Base.getproperty(net::ContinuousPTNet, s::Symbol)

# DOCSTRING

# # Arguments:
# - `net`: DESCRIPTION
# - `s`: DESCRIPTION
# """
# function Base.getproperty(net::ContinuousPTNet, s::Symbol)
#     if s in [:basenet, :enabled_degree, :enabled_weight]
#         return getproperty(net, s)
#     else
#         return getproperty(net.basenet, s)
#     end
# end

# """
#     ContinuousPTNet(in::Array{Float64, 3}, out::Array{Float64, 3}, mark::Array{Float64, 2}, functions::Array{Function, 1})

# DOCSTRING

# # Arguments:
# - `in`: DESCRIPTION
# - `out`: DESCRIPTION
# - `mark`: DESCRIPTION
# - `functions`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function ContinuousPTNet(in::Array{Float64,3}, out::Array{Float64,3}, mark::Array{Float64,2}, functions::Array{Function,1})

#     return ContinuousPTNet(
#         PTNet(in, out, mark, functions, enabled),
#         zeros(Float64, size(input)[2]),
#         zeros(Float64, size(input)[2], size(input)[3])
#     )
# end

# """
#     ContinuousPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, functions::Vector{Function}, code::Vector{AbstractToken}, enabledfunc::Function)

# DOCSTRING

# # Arguments:
# - `place_size`: DESCRIPTION
# - `transition_size`: DESCRIPTION
# - `resource_size`: DESCRIPTION
# - `functions`: DESCRIPTION
# - `code`: DESCRIPTION
# - `enabledfunc`: DESCRIPTION
# """
# function ContinuousPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, functions::Vector{Function}, code::Vector{AbstractToken}, enabledfunc::Function)

#     return ContinuousPTNet(
#         PTNet(place_size, transition_size, resource_size, functions, code, enabledfunc),
#         zeros(Float64, size(input)[2]),
#         zeros(Float64, size(input)[2], size(input)[3])
#     )
# end

# """
#     HomogeneousContinuousPTNet(in::Vector{Vector{Float64}}, out::Vector{Vector{Float64}}, mark::Vector{Vector{Float64}}, func::Function)

# DOCSTRING

# # Arguments:
# - `in`: DESCRIPTION
# - `out`: DESCRIPTION
# - `mark`: DESCRIPTION
# - `func`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function HomogeneousContinuousPTNet(in::Vector{Vector{Float64}}, out::Vector{Vector{Float64}}, mark::Vector{Vector{Float64}}, func::Function)
#     return ContinuousPTNet(
#         PTNet(in, out, mark, func, enabled),
#         zeros(Float64, size(input)[2]),
#         zeros(Float64, size(input)[2], size(input)[3])
#     )
# end

# """
#     HomogeneousContinuousPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, func::Function, code::Vector{AbstractToken})

# DOCSTRING

# # Arguments:
# - `place_size`: DESCRIPTION
# - `transition_size`: DESCRIPTION
# - `resource_size`: DESCRIPTION
# - `func`: DESCRIPTION
# - `code`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function HomogeneousContinuousPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, func::Function, code::Vector{AbstractToken})
#     return ContinuousPTNet(
#         PTNet(place_size, transition_size, resource_size, func, code, enabled),
#         zeros(Float64, size(input)[2]),
#         zeros(Float64, size(input)[2], size(input)[3])
#     )
# end

# """
#     BasicContinuousPTNet(in::Matrix{Vector{Float64}}, out::Matrix{Vector{Float64}}, mark::Vector{Vector{Float64}}, )

# DOCSTRING

# # Arguments:
# - `in`: DESCRIPTION
# - `out`: DESCRIPTION
# - `mark`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function BasicContinuousPTNet(in::Matrix{Vector{Float64}}, out::Matrix{Vector{Float64}}, mark::Vector{Vector{Float64}}, )
#     return ContinuousPTNet(
#         PTNet(in, out, mark, func, enabled),
#         zeros(Float64, size(input)[2]),
#         zeros(Float64, size(input)[2], size(input)[3])
#     )
# end

# """
#     BasicContinuousPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{AbstractToken}, )

# DOCSTRING

# # Arguments:
# - `place_size`: DESCRIPTION
# - `transition_size`: DESCRIPTION
# - `resource_size`: DESCRIPTION
# - `code`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function BasicContinuousPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{AbstractToken}, )
#     return ContinuousPTNet(
#         PTNet(place_size, transition_size, resource_size, code, enabled),
#         zeros(Float64, size(input)[2]),
#         zeros(Float64, size(input)[2], size(input)[3])
#     )
# end

# ################################################################################
# ## ContinuousMassActionPTNet

# """
#     ContinuousMassActionPTNet

# DOCSTRING

# # Fields:
# - `basenet::ContinuousPTNet`: DESCRIPTION
# """
# mutable struct ContinuousMassActionPTNet <: AbstractContinuousNetMassAction
#     basenet::ContinuousPTNet
# end


# """
#     Base.getproperty(net::ContinuousPTNet, s::Symbol)

# DOCSTRING

# # Arguments:
# - `net`: DESCRIPTION
# - `s`: DESCRIPTION
# """
# function Base.getproperty(net::ContinuousPTNet, s::Symbol)
#     if s == :basenet
#         return getproperty(net, s)
#     else
#         return getproperty(net.basenet, s)
#     end
# end


# """
#     ContinuousPTNet(in::Array{Float64, 3}, out::Array{Float64, 3}, mark::Array{Float64, 2}, functions::Array{Function, 1}, )

# DOCSTRING

# # Arguments:
# - `in`: DESCRIPTION
# - `out`: DESCRIPTION
# - `mark`: DESCRIPTION
# - `functions`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function ContinuousMassActionPTNet(in::Array{Float64,3}, out::Array{Float64,3}, mark::Array{Float64,2}, functions::Array{Function,1}, )
#     return ContinuousMassActionPTNet(
#         ContinuousPTNet(in, out, mark, functions, enabled,
#             zeros(Float64, size(input)[2]),
#             zeros(Float64, size(input)[2], size(input)[3])
#         ))

# end

# """
#     ContinuousPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, functions::Vector{Function}, code::Vector{AbstractToken}, enabledfunc::Function)

# DOCSTRING

# # Arguments:
# - `place_size`: DESCRIPTION
# - `transition_size`: DESCRIPTION
# - `resource_size`: DESCRIPTION
# - `functions`: DESCRIPTION
# - `code`: DESCRIPTION
# - `enabledfunc`: DESCRIPTION
# """
# function ContinuousMassActionPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, functions::Vector{Function}, code::Vector{AbstractToken}, enabledfunc::Function)

#     return ContinuousMassActionPTNet(
#         ContinuousPTNet(place_size, transition_size, resource_size, functions, code, enabledfunc, zeros(Float64, size(input)[2]),
#             zeros(Float64, size(input)[2], size(input)[3])
#         ))
# end

# """
# HomogeneousContinuousMassActionPTNet(in::Vector{Vector{Float64}}, out::Vector{Vector{Float64}}, mark::Vector{Vector{Float64}}, func::Function, )

# DOCSTRING

# # Arguments:
# - `in`: DESCRIPTION
# - `out`: DESCRIPTION
# - `mark`: DESCRIPTION
# - `func`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function HomogeneousContinuousMassActionPTNet(in::Vector{Vector{Float64}}, out::Vector{Vector{Float64}}, mark::Vector{Vector{Float64}}, func::Function, )
#     return ContinuousMassActionPTNet(
#         ContinuousPTNet(in, out, mark, func, enabled, zeros(Float64, size(input)[2]), zeros(Float64, size(input)[2], size(input)[3])
#         ))
# end

# """
# HomogeneousContinuousMassActionPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, func::Function, code::Vector{AbstractToken}, )

# DOCSTRING

# # Arguments:
# - `place_size`: DESCRIPTION
# - `transition_size`: DESCRIPTION
# - `resource_size`: DESCRIPTION
# - `func`: DESCRIPTION
# - `code`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function HomogeneousContinuousMassActionPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, func::Function, code::Vector{AbstractToken}, )
#     return ContinuousMassActionPTNet(
#         ContinuousPTNet(place_size, transition_size, resource_size, func, code, enabled, zeros(Float64, size(input)[2]), zeros(Float64, size(input)[2], size(input)[3])
#         ))
# end

# """
# BasicContinuousMassActionPTNet(in::Matrix{Vector{Float64}}, out::Matrix{Vector{Float64}}, mark::Vector{Vector{Float64}}, )

# DOCSTRING

# # Arguments:
# - `in`: DESCRIPTION
# - `out`: DESCRIPTION
# - `mark`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function BasicContinuousMassActionPTNet(in::Matrix{Vector{Float64}}, out::Matrix{Vector{Float64}}, mark::Vector{Vector{Float64}}, )
#     return ContinuousMassActionPTNet(
#         ContinuousPTNet(in, out, mark, func, enabled, zeros(Float64, size(input)[2]), zeros(Float64, size(input)[2], size(input)[3])
#         ))
# end

# """
# BasicContinuousMassActionPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{AbstractToken}, )

# DOCSTRING

# # Arguments:
# - `place_size`: DESCRIPTION
# - `transition_size`: DESCRIPTION
# - `resource_size`: DESCRIPTION
# - `code`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function BasicContinuousMassActionPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{AbstractToken}, )
#     return ContinuousMassActionPTNet(
#         ContinuousPTNet(place_size, transition_size, resource_size, code, enabled, zeros(Float64, size(input)[2]), zeros(Float64, size(input)[2], size(input)[3])))
# end

# ################################################################################
# ## ContinuousStochasticPTNet
# """
# ContinuousStochasticPTNet

# DOCSTRING

# # Fields:
# - `basenet::ContinuousPTNet`: DESCRIPTION
# """
# mutable struct ContinuousStochasticPTNet <: AbstractContinuousNetStochastic
#     basenet::ContinuousPTNet
# end


# """
#     Base.getproperty(net::ContinuousPTNet, s::Symbol)

# DOCSTRING

# # Arguments:
# - `net`: DESCRIPTION
# - `s`: DESCRIPTION
# """
# function Base.getproperty(net::ContinuousStochasticPTNet, s::Symbol)
#     if s == :basenet
#         return getproperty(net, s)
#     else
#         return getproperty(net.basenet, s)
#     end
# end


# """
# ContinuousStochasticPTNet(in::Array{Float64, 3}, out::Array{Float64, 3}, mark::Array{Float64, 2}, functions::Array{Function, 1}, )

# DOCSTRING

# # Arguments:
# - `in`: DESCRIPTION
# - `out`: DESCRIPTION
# - `mark`: DESCRIPTION
# - `functions`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function ContinuousStochasticPTNet(in::Array{Float64,3}, out::Array{Float64,3}, mark::Array{Float64,2}, functions::Array{Function,1}, )
#     return ContinuousStochasticPTNet(
#         ContinuousPTNet(in, out, mark, functions, enabled,
#             zeros(Float64, size(input)[2]),
#             zeros(Float64, size(input)[2], size(input)[3])
#         ))

# end

# """
#     ContinuousPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, functions::Vector{Function}, code::Vector{AbstractToken}, enabledfunc::Function)

# DOCSTRING

# # Arguments:
# - `place_size`: DESCRIPTION
# - `transition_size`: DESCRIPTION
# - `resource_size`: DESCRIPTION
# - `functions`: DESCRIPTION
# - `code`: DESCRIPTION
# - `enabledfunc`: DESCRIPTION
# """
# function ContinuousStochasticPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, functions::Vector{Function}, code::Vector{AbstractToken}, enabledfunc::Function)
#     return ContinuousStochasticPTNet(
#         ContinuousPTNet(place_size, transition_size, resource_size, functions, code, enabledfunc, zeros(Float64, size(input)[2]),
#             zeros(Float64, size(input)[2], size(input)[3])
#         ))
# end

# """
# HomogeneousContinuousStochasticPTNet(in::Vector{Vector{Float64}}, out::Vector{Vector{Float64}}, mark::Vector{Vector{Float64}}, func::Function, )

# DOCSTRING

# # Arguments:
# - `in`: DESCRIPTION
# - `out`: DESCRIPTION
# - `mark`: DESCRIPTION
# - `func`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function HomogeneousContinuousStochasticPTNet(in::Vector{Vector{Float64}}, out::Vector{Vector{Float64}}, mark::Vector{Vector{Float64}}, func::Function, )
#     return ContinuousStochasticPTNet(
#         ContinuousPTNet(in, out, mark, func, enabled, zeros(Float64, size(input)[2]), zeros(Float64, size(input)[2], size(input)[3])
#         ))
# end

# """
# HomogeneousContinuousStochasticPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, func::Function, code::Vector{AbstractToken}, )

# DOCSTRING

# # Arguments:
# - `place_size`: DESCRIPTION
# - `transition_size`: DESCRIPTION
# - `resource_size`: DESCRIPTION
# - `func`: DESCRIPTION
# - `code`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function HomogeneousContinuousStochasticPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, func::Function, code::Vector{AbstractToken}, )
#     return ContinuousStochasticPTNet(
#         ContinuousPTNet(place_size, transition_size, resource_size, func, code, enabled, zeros(Float64, size(input)[2]), zeros(Float64, size(input)[2], size(input)[3])
#         ))
# end

# """
# BasicContinuousStochasticPTNet(in::Matrix{Vector{Float64}}, out::Matrix{Vector{Float64}}, mark::Vector{Vector{Float64}}, )

# DOCSTRING

# # Arguments:
# - `in`: DESCRIPTION
# - `out`: DESCRIPTION
# - `mark`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function BasicContinuousStochasticPTNet(in::Matrix{Vector{Float64}}, out::Matrix{Vector{Float64}}, mark::Vector{Vector{Float64}}, )
#     return ContinuousStochasticPTNet(
#         ContinuousPTNet(in, out, mark, func, enabled, zeros(Float64, size(input)[2]), zeros(Float64, size(input)[2], size(input)[3])
#         ))
# end

# """
# BasicContinuousMassActionPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{AbstractToken}, )

# DOCSTRING

# # Arguments:
# - `place_size`: DESCRIPTION
# - `transition_size`: DESCRIPTION
# - `resource_size`: DESCRIPTION
# - `code`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function BasicContinuousStochasticPTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{AbstractToken}, )
#     return ContinuousStochasticPTNet(
#         ContinuousPTNet(place_size, transition_size, resource_size, code, enabled, zeros(Float64, size(input)[2]), zeros(Float64, size(input)[2], size(input)[3])))
# end
# ################################################################################
# ## ContinuousSimplePTNet
# """
#     ContinuousSimplePTNet

# DOCSTRING

# # Fields:
# - `basenet::ContinuousPTNet`: DESCRIPTION
# """
# mutable struct ContinuousSimplePTNet <: AbstractContinuousNetSimple
#     basenet::ContinuousPTNet
# end

# function Base.getproperty(net::ContinuousSimplePTNet, s::Symbol)
#     if s == :basenet
#         return getproperty(net, s)
#     else
#         return getproperty(net.basenet, s)
#     end
# end

# """
# ContinuousSimplePTNet(in::Array{Float64, 3}, out::Array{Float64, 3}, mark::Array{Float64, 2}, functions::Array{Function, 1}, )

# DOCSTRING

# # Arguments:
# - `in`: DESCRIPTION
# - `out`: DESCRIPTION
# - `mark`: DESCRIPTION
# - `functions`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function ContinuousSimplePTNet(in::Array{Float64,3}, out::Array{Float64,3}, mark::Array{Float64,2}, functions::Array{Function,1}, )
#     return ContinuousSimplePTNet(
#         ContinuousPTNet(in, out, mark, functions, enabled,
#             zeros(Float64, size(input)[2]),
#             zeros(Float64, size(input)[2], size(input)[3])
#         ))

# end

# """
# ContinuousSimplePTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, functions::Vector{Function}, code::Vector{AbstractToken}, enabledfunc::Function)

# DOCSTRING

# # Arguments:
# - `place_size`: DESCRIPTION
# - `transition_size`: DESCRIPTION
# - `resource_size`: DESCRIPTION
# - `functions`: DESCRIPTION
# - `code`: DESCRIPTION
# - `enabledfunc`: DESCRIPTION
# """
# function ContinuousSimplePTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, functions::Vector{Function}, code::Vector{AbstractToken}, enabledfunc::Function)
#     return ContinuousSimplePTNet(
#         ContinuousPTNet(place_size, transition_size, resource_size, functions, code, enabledfunc, zeros(Float64, size(input)[2]),
#             zeros(Float64, size(input)[2], size(input)[3])
#         ))
# end

# """
# HomogeneousContinuousSimplePTNet(in::Vector{Vector{Float64}}, out::Vector{Vector{Float64}}, mark::Vector{Vector{Float64}}, func::Function, )

# DOCSTRING

# # Arguments:
# - `in`: DESCRIPTION
# - `out`: DESCRIPTION
# - `mark`: DESCRIPTION
# - `func`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function HomogeneousContinuousSimplePTNet(in::Vector{Vector{Float64}}, out::Vector{Vector{Float64}}, mark::Vector{Vector{Float64}}, func::Function, )
#     return ContinuousSimplePTNet(
#         ContinuousPTNet(in, out, mark, func, enabled, zeros(Float64, size(input)[2]), zeros(Float64, size(input)[2], size(input)[3])
#         ))
# end

# """
# HomogeneousContinuousSimplePTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, func::Function, code::Vector{AbstractToken}, )

# DOCSTRING

# # Arguments:
# - `place_size`: DESCRIPTION
# - `transition_size`: DESCRIPTION
# - `resource_size`: DESCRIPTION
# - `func`: DESCRIPTION
# - `code`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function HomogeneousContinuousSimplePTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, func::Function, code::Vector{AbstractToken}, )
#     return ContinuousSimplePTNet(
#         ContinuousPTNet(place_size, transition_size, resource_size, func, code, enabled, zeros(Float64, size(input)[2]), zeros(Float64, size(input)[2], size(input)[3])
#         ))
# end

# """
# BasicContinuousSimplePTNet(in::Matrix{Vector{Float64}}, out::Matrix{Vector{Float64}}, mark::Vector{Vector{Float64}}, )

# DOCSTRING

# # Arguments:
# - `in`: DESCRIPTION
# - `out`: DESCRIPTION
# - `mark`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function BasicContinuousSimplePTNet(in::Matrix{Vector{Float64}}, out::Matrix{Vector{Float64}}, mark::Vector{Vector{Float64}}, )
#     return ContinuousSimplePTNet(
#         ContinuousPTNet(in, out, mark, func, enabled, zeros(Float64, size(input)[2]), zeros(Float64, size(input)[2], size(input)[3])
#         ))
# end

# """
# BasicContinuousSimplePTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{AbstractToken}, )

# DOCSTRING

# # Arguments:
# - `place_size`: DESCRIPTION
# - `transition_size`: DESCRIPTION
# - `resource_size`: DESCRIPTION
# - `code`: DESCRIPTION
# - `enabled`: DESCRIPTION
# """
# function BasicContinuousSimplePTNet(place_size::Int64, transition_size::Int64, resource_size::Int64, code::Vector{AbstractToken}, )
#     return ContinuousSimplePTNet(
#         ContinuousPTNet(place_size, transition_size, resource_size, code, enabled, zeros(Float64, size(input)[2]), zeros(Float64, size(input)[2], size(input)[3])))
# end

################################################################################
# functions for net functionality
"""
    compute_input_interface_places!(net::N) where N <: AbstractDiscreteDenseNet

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_input_interface_places!(net::N) where {N<:AbstractDiscreteDenseNet}

    # check all places 
    @inline @inbounds for p in 1:size(net.marking)[1]

        # input interface place: nothing comes into it -> output elements zero, 
        # stuff goes out from it: input elements nonzero

        if any(.!isapprox.(sum(net.input[p, :, :], dims=1), 0)) &&
           all(isapprox.(sum(net.output[p, :, :], dims=1), 0))
            net.input_interface_places[p] = true
        else
            net.input_interface_places[p] = false
        end
    end
end

"""
    compute_input_interface_transitions!(net::N) where N <: AbstractDiscreteDenseNet

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_input_interface_transitions!(net::N) where {N<:AbstractDiscreteDenseNet}
    @inline @inbounds for t in 1:size(net.input)[2]
        # input interface transitions -> have no input => input==0, but have output ==> output nonzero
        if any(.!isapprox.(sum(net.output[:, t, :], dims=1), 0)) &&
           all(isapprox.(sum(net.input[:, t, :], dims=1), 0))
            net.input_interface_transitions[t] = true
        else
            net.input_interface_transitions[t] = false
        end
    end
end

"""
    compute_output_interface_places!(net::N) where N <: AbstractDiscreteDenseNet

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_output_interface_places!(net::N) where {N<:AbstractDiscreteDenseNet}

    @inline @inbounds for p in 1:size(net.marking)[1]

        # input interface place: nothing comes into it -> output elements zero, 
        # stuff goes out from it: input elements nonzero
        # println("p: ", p, ", ", sum(net.output[p, :, :], dims=1))
        if any(.!isapprox.(sum(net.output[p, :, :], dims=1), 0)) &&
           all(isapprox.(sum(net.input[p, :, :], dims=1), 0))

            net.output_interface_places[p] = true
        else
            net.output_interface_places[p] = false
        end
    end
end

"""
    compute_output_interface_transitions!(net::N) where N <: AbstractDiscreteDenseNet

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_output_interface_transitions!(net::N) where {N<:AbstractDiscreteDenseNet}

    @inline @inbounds for t in 1:size(net.input)[2]
        # input interface transitions -> have no input => input==0, but have output ==> output nonzero
        if any(.!isapprox.(sum(net.input[:, t, :], dims=1), 0)) &&
           all(isapprox.(sum(net.output[:, t, :], dims=1), 0))
            net.output_interface_transitions[t] = true
        else
            net.output_interface_transitions[t] = false
        end
    end
end


"""
    compute_non_inhibitor_arcs!!(net::N) where N <: AbstractDiscreteDenseNet

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_non_inhibitor_arcs!(net::N) where {N<:AbstractDiscreteDenseNet}

    # inhibitor arc w(p,t) are those that have input[p, t, :] .== -1 over the resoure index r 
    @inline @inbounds net.noninhibitor_arcs = Matrix{Bool}(sum(net.input, dims=3)[:, :, 1] .!= size(net.input)[3] * -1.0)
end

########################################################################################################################
## conflict handling 

"""
detect_conflict_vector(net::N)::BitVector where N <: AbstractDiscreteNet

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function detect_conflict_vector(net::N)::BitVector where {N<:AbstractDiscreteNet}

    conflict::BitVector = fill(false, size(net.marking)[1])

    @inline @inbounds for p in 1:size(net.marking)[1]
        # conflict found when the sum of the weights going out from a place to enabled transitions is greater than its marking, such that they cannot all be served at once 
        if any((@tensor x[r] := view(net.input, p, :, :)[t, r] * net.enabled[t]) .> net.marking[p, :])
            conflict[p] = true
        end
    end

    return conflict
end


"""
    detect_conflict(net::N)::Bool where N <: AbstractDiscreteDenseNet

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function detect_conflict(net::N)::Bool where {N<:AbstractDiscreteDenseNet}

    conflict::Bool = false

    @inline @inbounds for p in 1:size(net.marking)[1]

        # conflict found when the sum of the weights going out from a place to enabled transitions is greater than its marking, such that they cannot all be served at once 
        if any((@tensor x[r] := view(net.input, p, :, :)[t, r] * net.enabled[t]) .> net.marking[p, :])
            conflict = true
        end
    end

    return conflict
end




"""
    handle_conflict!(net::AbstractDiscreteDenseNet)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function handle_conflict!(net::N) where {N <: AbstractDiscreteDenseNet}

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

########################################################################################################################
## computation of enabled transitions for different types of nets 
"""
    compute_enabled!(net::AbstractDiscreteDenseNet)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_enabled!(net::N) where {N <: AbstractDiscreteDenseNet}

    #FIXME: there a faster way to compute this?
    @inline @inbounds for t in 1:size(net.input)[2]
        # println("t: ", t)
        #declare temps and reset enabled value
        e::Bool = true

        net.enabled[t] = false

        # whether we have inhibitor arcs 
        @inline @inbounds for p in 1:size(net.input)[1]

            if all(net.input[p, t, :] .≈ 0.0)
                continue
            end
            # println(" p: ")
            # println("   m: ", net.marking[p, :], ", I: ", net.input[p, t, :])
            # check that there is enough marking
            ew = all(net.marking[p, :] .> net.input[p, t, :] .|| net.marking[p, :] .≈ net.input[p, t, :])

            # check whether we have an inhibitor arc
            en = all(isapprox.(net.input[p, t, :], -1.0))

            # check whether marking is zero
            em = all(isapprox.(net.marking[p, :], 0))

            # first term before || is the normal marking when there is no inhibitors involved, second one is when there is an inhibitor involved
            e = e && ((!en && ew) || (en && em))
            # println("   es: ", ew, ", ", !en, ", ", em)
        end

        net.enabled[t] = e
    end
end


"""
    compute_enabled!(net::AbstractDiscreteDenseEnergyNet)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_enabled!(net::N) where {N <: AbstractDiscreteDenseEnergyNet}

    @inline @inbounds for t in 1:size(net.input)[2]

        e::Bool = true

        net.enabled[t] = false

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


# """
#     compute_enabled_degree!(net::AbstractContinuousNet, t::Int64)

# DOCSTRING

# # Arguments:
# - `net`: DESCRIPTION
# - `t`: DESCRIPTION
# """
# function compute_enabled_degree!(net::AbstractContinuousNet, t::Int64)
#     min::Float64 = 1e12

#     @inline @inbounds for p in size(net.input)[1]
#         # skip inhibitors
#         if all(isapprox.(net.input[p, t, :], -1))
#             continue
#         else
#             # find the minimum
#             if all(isapprox(net.marking[p, :], 0.0))
#                 min = 0
#             else
#                 @inline @inbounds for r in 1:size(net.input)[3]
#                     value = net.marking[p, r] / net.input[p, t, r]
#                     if value < min
#                         min = value
#                     end
#                 end
#             end
#         end
#     end

#     net.enabled_degree[t] = min
# end



# """
#     compute_enabled!(net::AbstractContinuousNetStochastic)

# DOCSTRING

# # Arguments:
# - `net`: DESCRIPTION
# """
# function compute_enabled!(net::AbstractContinuousNetStochastic)
#     throw(ErrorException("Stochastic nets not yet implemented"))
# end


# """
#     compute_enabled!(net::AbstractNet)

# DOCSTRING

# # Arguments:
# - `net`: DESCRIPTION
# """
# function compute_enabled!(net::AbstractContinuousNetMassAction)
#     @inline @inbounds for t in 1:size(net.input)[2]

#         net.enabled[t] = true
#         net.enabled_weight[t] = ones(Float64, size(net.input)[3])

#         @inline @inbounds for p in 1:size(net.input)[1]

#             # inhibitor arc and enabled_weight not zero
#             if all(isapprox.(net.input[p, t, :], -1)) && all(isapprox.(net.enabled_weight[t, :], 0)) == false

#                 if all(isapprox.(net.marking[p, :], 0))
#                     # marking is zero and we have inhibitor arc
#                     # --> multiplied by one, so do nothing 
#                 else
#                     net.enabled_weight[t] .= 0  # put to zero otherwise
#                 end
#                 # no inhibitor arc
#             else
#                 net.enabled_weight[t, :] .*= net.marking[p, :]
#             end
#         end
#     end
# end


# """
#     compute_enabled!(net::AbstractNet)

# DOCSTRING

# # Arguments:
# - `net`: DESCRIPTION
# """
# function compute_enabled!(net::AbstractContinuousNetSimple)

#     @inline @inbounds for t in 1:size(net.input)[2]
#         e::Bool = true

#         net.enabled_degree[t] = 0.0

#         # check enabled degree 
#         compute_enabled_degree!(net, t)

#         net.enabled[t] = any(net.enabled_degree[t] .> 0)

#         # check inhibitor arcs 
#         @inline @inbounds for t in 1:size(net.input)[2]
#             @inline @inbounds for p in 1:size(net.input)[1]
#                 if all(isapprox.(net.input[p, t, :], -1.0)) == true &&
#                    all(isapprox.(net.marking[p, :], 0.0)) == false
#                     net.enabled[t] = false
#                 end
#             end
#         end
#     end
# end


########################################################################################################################
## steps and runs of nets 

"""
    compute_step!(net::N)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_step!(net::N) where {N<:AbstractDiscreteDenseNet}

    compute_enabled!(net)

    handle_conflict!(net)

    if hasfield(typeof(net), :tmp_marking)
        @tensor begin
            net.tmp_marking[p, r] = (net.output[p, t, r] - (net.input.*net.noninhibitor_arcs)[p, t, r]) * net.enabled[t] + net.marking[p, r]
        end

        net.marking = deepcopy(net.tmp_marking)

        fill!(net.tmp_marking, 0.0)

    elseif hasfield(typeof(net), :basenet)
        @tensor begin
            net.basenet.tmp_marking[p, r] = (net.basenet.output[p, t, r] - (net.basenet.input.*net.basenet.noninhibitor_arcs)[p, t, r]) * net.basenet.enabled[t] + net.basenet.marking[p, r]
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
function run!(net::N, maxiter::Int64, tol::Float64) where {N<:AbstractDiscreteDenseNet}

    # println("running net")
    iter = 1

    old_marking = zeros(Float64, size(net.marking)...)

    # println("iter: ", iter, "/", maxiter)
    # println("tol: ", dot(net.marking - old_marking, net.marking - old_marking), tol)
    if hasfield(typeof(net), :tmp_marking)

        while iter < maxiter && (dot(net.marking - old_marking, net.marking - old_marking) > tol)
            old_marking = net.marking
            # println(" iter: ", iter)
            compute_step!(net)
            # println(iter, "/", maxiter)
            # println("   m=", net.marking)
            # println("  om=", old_marking)
            # println("   e=", net.enabled),
            # println(" tol=", dot(net.marking - old_marking, net.marking - old_marking), " <? ", tol)

            iter += 1
        end

    elseif hasfield(typeof(net), :basenet)

        while iter < maxiter && (dot(net.basenet.marking - old_marking, net.basenet.marking - old_marking) > tol)
            old_marking = net.basenet.marking
            # println(" iter: ", iter)
            compute_step!(net)
            # println(iter, "/", maxiter)
            # println("   m=", net.basenet.marking)
            # println("  om=", old_marking)
            # println("   e=", net.basenet.enabled),
            # println(" tol=", dot(net.basenet.marking - old_marking, net.basenet.marking - old_marking), " <? ", tol)

            iter += 1
        end

    else 
        throw(ErrorException("Error, unknown field in running net"))
    end
end
