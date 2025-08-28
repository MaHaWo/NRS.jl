
struct Rule{T<:AbstractArray,M<:AbstractArray} <: AbstractRule
    conditions::T
    actions::T
    markings::M
end

struct NRS{T<:AbstractArray,M<:AbstractArray} <: AbstractNRS
    net::Net{T,M}
    rules::Rule{T,M}
    check_rule::Function
end

function rewrite!(nrs::NRS, rule::Rule)
    enabled = nrs.check_rule(nrs.net, rule)
    if enabled 
        # TODO: build rewriting 
    end 
end

