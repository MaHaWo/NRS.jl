
include("./encoding.jl")

mutable struct Net{V, T <: AbstractArray}
    input::T{V}
    output::T{V}
    enabled::T{bool}
    state::T{V}
    _state::T{V}
end

function Net() end
function Net() end
function Net() end

function _check_enabled(net::Net)::Bool
    return all(net.enabled .== true)
end

function _compute_step!(net::Net)::Nothing end

function resolve_conflict!(net: Net)::Nothing end

function compute_enabled!(net::Net)::Nothing end

function step!(net::Net)::Nothing
    compute_enabled!(net)
    resolve_conflict!(net)
    _compute_step!(net)
end

function run!(net::Net, num_steps::Int32)::Nothing
    t::Int32 = 0;
    while _check_enabled(net) && t < num_step
        step!(net)
        t+=1
    end
end
