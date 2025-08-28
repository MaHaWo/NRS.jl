function detect_conflicts(net::Net) end

function resolve_conflicts!(net::Net, nrs::NRS, conflicts::Vector{Tuple{Int,Int}}; rng::Random.AbstractRNG=Random.GLOBAL_RNG) end

function compute_enabled!(net::Net) 
    # TODO: add tensor math for conflict
end

function step!(net::Net; rng::Random.AbstractRNG=Random.GLOBAL_RNG) 
    compute_enabled!(net)
    conflicts = detect_conflicts(net)
    resolve_conflicts!(net, conflicts, rng)

    # TODO add tensor math for step
end