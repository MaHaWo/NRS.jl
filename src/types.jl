struct AbstractNet end 
struct AbstractRule end
struct AbstractEdgeList end 
struct AbstractNRS end

struct EdgeList{T <: AbstractArray} <: AbstractEdgeList
    nodes::Vector{Int}
    weights::T
end

struct Net{T <: AbstractArray, P <: AbstractArray} <: AbstractNet
    inputs::T
    outputs::T
    markings::P 
    enabled::Vector{Bool}
end

struct Rule{T <: AbstractArray} <: AbstractRule
    conditions::EdgeList{T}
    actions::EdgeList{T}
end

struct NRS{T <: AbstractArray} <: AbstractNRS
    net::Net{T}
    rules::Rule{T}
end


