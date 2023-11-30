module NRS

using TensorOperations
using SparseArrayKit
using LinearAlgebra
using AutomaticDocstrings # not necessary for the running of the module
AutomaticDocstrings.options[:min_args] = 1
AutomaticDocstrings.options[:kwargs_header] = "# Keyword arguments:"

# auxilliary stuff
include("../src/types.jl")
include("../src/symmetries.jl")
include("../src/encoding.jl")

# networks
include("../src/common_net_functionality.jl")
include("../src/dense_net.jl")
include("../src/dense_net_functionality.jl")
include("../src/sparse_net.jl")
include("../src/sparse_net_functionality.jl")

# rewriting
include("../src/rewriting_rule.jl")
include("../src/rewriting_system.jl")


########################################################################################################################
## Utilities

########################################################################################################################
## encoding 
export AbstractToken, AbstractEnergyToken, AbstractRuleToken
export BasicToken, Token, BasicEnergyToken, EnergyToken, to_basic, P, T, I

########################################################################################################################
## network 

########################################################################################################################
## symmetries 
export AbstractSymmetry
export EnergyLookup, compute_energy!


########################################################################################################################
## Rewriting rules


########################################################################################################################
## Rewriting systems

end