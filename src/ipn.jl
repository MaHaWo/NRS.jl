module IPN

using LinearAlgebra 
using TensorOperations
using SparseArrayKit

include("../src/types.jl")
include("../src/symmetries.jl")
include("../src/encoding.jl")
include("../src/net.jl")
include("../src/sparse_net.jl")
include("../src/rule.jl")

export AbstractSymmetry, AbstractToken

export AbstractEnergyToken

export AbstractNet, AbstractContinuousNet, AbstractContinuousNetSimple, AbstractContinuousNetStochastic, AbstractContinuousNetMassAction, AbstractDiscreteNet, AbstractDiscreteEnergyNet, 
AbstractSparseNet, AbstractDiscreteSparseNet, AbstractDiscreteEnergySparseNet

export EnergyLookup, compute_energy!

export BasicToken, Token, BasicEnergyToken, EnergyToken, to_basic, P, T, I

export PTNet, PTNetEnergy, PTSparseNet, PTSparseEnergyNet

export compute_input_interface_places!, compute_input_interface_transitions!, compute_output_interface_places!, compute_output_interface_transitions!, compute_non_inhibitor_arcs!, compute_enabled!, compute_step!, run!

export Rule,  SparseRule, build_rule_from_code!, rebuild_net!, count_nonzero_target_elements, count_nonzero_target_elements, count_nonzero_effect_elements, count_nonzero_effect_elements, compute_enabled!, rewrite!, redistribute_marking_conserved, redistribute_marking_copy

end