struct AbstractNet end
struct AbstractRule end
struct AbstractNRS end

struct Net{T<:AbstractArray,M<:AbstractArray} <: AbstractNet
    inputs::T
    outputs::T
    markings::M
    enabled::Vector{Bool}
end

struct Rule{T<:AbstractArray,M<:AbstractArray} <: AbstractRule
    conditions::T
    actions::T
    markings::M
end

struct NRS{T<:AbstractArray,M<:AbstractArray} <: AbstractNRS
    net::Net{T,M}
    rules::Rule{T,M}
    check_rules::Function
end
