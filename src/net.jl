
struct Net{T<:AbstractArray,M<:AbstractArray} <: AbstractNet
    inputs::T
    outputs::T
    markings::M
    enabled::Vector{Bool}
end

function detect_conflicts(net::Net)
    # TODO:
end

function resolve_conflicts!(net::Net, conflicts::Vector{Tuple{Int,Int}};
                            rng::Random.AbstractRNG=Random.GLOBAL_RNG)
    # TODO:
end

function compute_enabled!(net::Net)
    # TODO: add tensor math for conflict
end

function step!(net::Net; rng::Random.AbstractRNG=Random.GLOBAL_RNG)
    compute_enabled!(net)
    conflicts = detect_conflicts(net)
    return resolve_conflicts!(net, conflicts; rng=rng)

    # TODO: add tensor math for step
end