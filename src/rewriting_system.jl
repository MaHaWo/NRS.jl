########################################################################################################################
## 

"""
    SparseNetRewritingSystem{N <: AbstractSparseNet, R <: AbstractSparseRule}

DOCSTRING

# Fields:
- `rules::Dict{Int64, R}`: DESCRIPTION
- `net::N`: DESCRIPTION
"""
mutable struct SparseNetRewritingSystem{N <: AbstractSparseDiscreteNet, R <: AbstractSparseRule} <: AbstractSparseNetRewritingSystem

    rules::Dict{Int64, R}
    net::N

    SparseNetRewritingSystem(rs::Dict{Int64, R}, n::N) where {N <: AbstractSparseDiscreteNet, R <: AbstractSparseRule} = new{Dict{Int64, R}, N}(rs, n)
end


"""
    build_rule_codes!(code::Vector{S})

DOCSTRING

# Arguments:
- `code`: DESCRIPTION
"""
function build_rule_codes(code::Vector{S}) where {S <: AbstractRuleToken} 

    rule_codes = Dict()

    for token in code   
    
        if isempty(token.replace) == false 
            push!(rule_codes[token.label], token)
        end

    end

    return rule_codes
end


"""
    SparseNetRewritingSystem(::Type{N}, psize::Int64, tsize::Int64, rsize::Int64, marking_redistribution::Function, code::Vector{S})

DOCSTRING

# Arguments:
- `psize`: DESCRIPTION
- `tsize`: DESCRIPTION
- `rsize`: DESCRIPTION
- `marking_redistribution`: DESCRIPTION
- `code`: DESCRIPTION
"""
function SparseNetRewritingSystem(::Type{N}, psize::Int64, tsize::Int64, rsize::Int64, marking_redistribution::Function, code::Vector{S}) where {N <: AbstractSparseDiscreteNet, S <: AbstractRuleToken } 

    rules = Dict()
    
    for (label, rulecode) in build_rule_codes(code)
        rules[label] = SparseRule(psize, tsize, rsize, marking_redistribution, rulecode)    
    end 

    net = N(psize, tsize, rsize, code)

    return SparseNetRewritingSystem(rules, net)

end


"""
    DenseNetRewritingSystem{N <: AbstractDenseNet, R <: AbstractDenseRule}

DOCSTRING

# Fields:
- `net::N`: DESCRIPTION
- `rules::Dict{Int64, R}`: DESCRIPTION
"""
mutable struct DenseNetRewritingSystem{N <: AbstractDenseDiscreteNet, R <: AbstractDenseRule} <: AbstractDenseNetRewritingSystem 
    
    rules::Dict{Int64, R}
    net::N

    DenseNetRewritingSystem(rs::Dict{Int64, R}, n::N) where {N <: AbstractDenseDiscreteNet, R <: AbstractDenseRule} = new{Dict{Int64, R}, N}(rs, n)

end


"""
    DenseNetRewritingSystem(::Type{N}, psize::Int64, tsize::Int64, rsize::Int64, marking_redistribution::Function, code::Vector{S})

DOCSTRING

# Arguments:
- `psize`: DESCRIPTION
- `tsize`: DESCRIPTION
- `rsize`: DESCRIPTION
- `marking_redistribution`: DESCRIPTION
- `code`: DESCRIPTION
"""
function DenseNetRewritingSystem(::Type{N}, psize::Int64, tsize::Int64, rsize::Int64, marking_redistribution::Function, code::Vector{S}) where {S <: AbstractRuleToken, N <: AbstractDenseDiscreteNet} 

    rules = Dict()
    
    for (label, rulecode) in build_rule_codes(code)
        rules[label] = SparseRule(psize, tsize, rsize, marking_redistribution, rulecode)    
    end 

    net = N(psize, tsize, rsize, code)

    return DenseNetRewritingSystem(rules, net)
end


########################################################################################################################
## 

"""
    rulelabels(nrs::N)

DOCSTRING

# Arguments:
- `nrs`: DESCRIPTION
"""
function rulelabels(nrs::N) where {N <: AbstractNetRewritingSystem}
    return keys(nrs.rules)
end  

"""
    rules(nrs::N)

DOCSTRING

# Arguments:
- `nrs`: DESCRIPTION
"""
function rules(nrs::N) where {N <: AbstractNetRewritingSystem}
    return values(nrs.rules)
end


"""
    apply_rule!(nrs::N, rulelabel::Int64, nets::Vector{Ns}, with_control_marking::Bool, with_weight_check::Bool)

DOCSTRING

# Arguments:
- `nrs`: DESCRIPTION
- `rulelabel`: DESCRIPTION
- `nets`: DESCRIPTION
- `with_control_marking`: DESCRIPTION
- `with_weight_check`: DESCRIPTION
"""
function apply_rule!(nrs::N, rulelabel::Int64, nets::Vector{Ns}, with_control_marking::Bool, with_weight_check::Bool) where {N <: AbstractNetRewritingSystem, Ns <: AbstractDiscreteNet}
    rewrite!(nrs.rules[rulelabel], nrs.net, nets, with_control_marking, with_weight_check)
end