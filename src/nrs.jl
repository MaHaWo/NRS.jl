using AutomaticDocstrings # not necessary for the running of the module
AutomaticDocstrings.options[:min_args] = 1
AutomaticDocstrings.options[:kwargs_header] = "# Keyword arguments:"

using SparseArrayKit


########################################################################################################################
## 

"""
    SparseNetRewritingSystem{N <: AbstractSparseNet, R <: AbstractSparseRule}

DOCSTRING

# Fields:
- `rules::Dict{Int64, R}`: DESCRIPTION
- `net::N`: DESCRIPTION
"""
mutable struct SparseNetRewritingSystem{N <: AbstractSparseNet, R <: AbstractSparseRule} <: AbstractSparseNetRewritingSystem
    rules::Dict{Int64, R}
    net::N
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
function SparseNetRewritingSystem(::Type{N}, psize::Int64, tsize::Int64, rsize::Int64, marking_redistribution::Function, code::Vector{S}) where {N <: AbstractSparseNet, S <: AbstractRuleToken} 

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
mutable struct DenseNetRewritingSystem{N <: AbstractDenseNet, R <: AbstractDenseRule} <: AbstractDenseNetRewritingSystem 
    net::N
    rules::Dict{Int64, R}
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
function DenseNetRewritingSystem(::Type{N}, psize::Int64, tsize::Int64, rsize::Int64, marking_redistribution::Function, code::Vector{S}) where {S <: AbstractRuleToken} 

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
    apply_rule_to_net!(nrs::N, rulelabel::Int64, nets::Vector{Ns}, with_control_marking::Bool, with_weight_check::Bool)

DOCSTRING

# Arguments:
- `nrs`: DESCRIPTION
- `rulelabel`: DESCRIPTION
- `nets`: DESCRIPTION
- `with_control_marking`: DESCRIPTION
- `with_weight_check`: DESCRIPTION
"""
function apply_rule_to_net!(nrs::N, rulelabel::Int64, nets::Vector{Ns}, with_control_marking::Bool, with_weight_check::Bool) where {N <: AbstractNetRewritingSystem}
    rewrite!(nrs.rules[rulelabel], nrs.net, nets, with_control_marking, with_weight_check)
end