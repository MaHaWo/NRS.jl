using TensorOperations
using Test
using LinearAlgebra 
using SparseArrayKit

include("../src/NRS.jl")
include("./testhelpers.jl")


include("./encoding_test.jl")
include("./dense_net_test.jl")
include("./sparse_net_test.jl")

