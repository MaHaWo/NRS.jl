

mutable struct Net{V, T <: AbstractArray}
    input::T{V}
    output::T{V}
    enabled::T{bool}
    state:T{V}
    _state:T{V}
end

function resolve_conflict!(net: Net) end

function compute_enabled!(net::Net) end

function step!(net::Net) end

function run!(net::Net) end
