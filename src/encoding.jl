
""" Enum for encoding symbols"""
@enum Kind P T I

"""
    BasicToken{T}

DOCSTRING

# Fields:
- `p::Int64`: DESCRIPTION
- `t::Int64`: DESCRIPTION
- `w::T`: DESCRIPTION
- `m::T`: DESCRIPTION
"""
struct BasicToken{T} <: AbstractToken
    k::Kind
    p::Int64
    t::Int64
    w::T
    m::T
end


"""
    Token{T}

DOCSTRING

# Fields:
- `basic::BasicToken{T}`: DESCRIPTION
- `rulelabel::Int64`: DESCRIPTION
- `replace::Vector{BasicToken{T}}`: DESCRIPTION
- `c::T`: DESCRIPTION
"""
struct Token{T} <: AbstractRuleToken
    basic::BasicToken{T}
    rulelabellabel::Int64
    replace::Vector{BasicToken{T}}
    c::T
end


"""
    Base.getproperty(y::Token, s::Symbol)

DOCSTRING

# Arguments:
- `y`: DESCRIPTION
- `s`: DESCRIPTION
"""
function Base.getproperty(y::Token, s::Symbol)
    if s in fieldnames(BasicToken)
        return getfield(y.basic, s)
    else 
        return getfield(y, s)
    end
end

"""
    Token(k::Kind, p::Int64, t::Int64, w::T, m::T, rulelabel::Int64, replace::Vector{BasicToken{T}}, c::T)

DOCSTRING

# Arguments:
- `k`: DESCRIPTION
- `p`: DESCRIPTION
- `t`: DESCRIPTION
- `w`: DESCRIPTION
- `m`: DESCRIPTION
- `rulelabel`: DESCRIPTION
- `replace`: DESCRIPTION
- `c`: DESCRIPTION
"""
function Token(k::Kind, p::Int64, t::Int64, w::T, m::T, rulelabel::Int64, replace::Vector{BasicToken{T}}, c::T ) where T 
    return Token(
        BasicToken(
            k, p, t, w, m, 
        ), 
        rulelabel, 
        replace, 
        c
    )
end

"""
    BasicEnergyToken{T}

DOCSTRING

# Fields:
- `basic::BasicToken{T}`: DESCRIPTION
- `e::T`: DESCRIPTION
"""
struct BasicEnergyToken{T} <: AbstractEnergyToken
    basic::BasicToken{T}
    e::Float64
end

"""
    Base.getproperty(y::BasicEnergyToken, s::Symbol)

DOCSTRING

# Arguments:
- `y`: DESCRIPTION
- `s`: DESCRIPTION
"""
function Base.getproperty(y::BasicEnergyToken, s::Symbol)
    if s in [:e, :basic] 
        return getfield(y, s)
    else 
        return getfield(y.basic, s)
    end
end


"""
    BasicEnergyToken(k::Kind, p::Int64, t::Int64, w::T, m::T, e::Float64)

DOCSTRING

# Arguments:
- `k`: DESCRIPTION
- `p`: DESCRIPTION
- `t`: DESCRIPTION
- `w`: DESCRIPTION
- `m`: DESCRIPTION
- `e`: DESCRIPTION
"""
function BasicEnergyToken(
    k::Kind, p::Int64, t::Int64, w::T, m::T, e::Float64
) where T
    return BasicEnergyToken(
        BasicToken(
            k, p, t, w, m
        ), 
        e
    )
end

"""
    EnergyToken{T}

DOCSTRING

# Fields:
- `basic::BasicEnergyToken{T}`: DESCRIPTION
- `rulelabel::Int64`: DESCRIPTION
- `replace::Vector{BasicToken{T}}`: DESCRIPTION
- `c::T`: DESCRIPTION
"""
struct EnergyToken{T} <: AbstractEnergyRuleToken
    basic::BasicEnergyToken{T}
    rulelabel::Int64
    replace::Vector{BasicToken{T}}
    c::T
end

"""
    Base.getproperty(y::BasicEnergyToken, s::Symbol)

DOCSTRING

# Arguments:
- `y`: DESCRIPTION
- `s`: DESCRIPTION
"""
function Base.getproperty(y::EnergyToken, s::Symbol)
    if s in [:rulelabel, :replace, :c, :basic]
        return getfield(y, s)
    else
        return Base.getproperty(y.basic, s)
    end
end


"""
    EnergyToken(k::Kind, p::Int64, t::Int64, w::T, m::T, rulelabel::Int64, replace::Vector{BasicToken{T}}, c::T, e::Float64)

DOCSTRING

# Arguments:
- `k`: DESCRIPTION
- `p`: DESCRIPTION
- `t`: DESCRIPTION
- `w`: DESCRIPTION
- `m`: DESCRIPTION
- `rulelabel`: DESCRIPTION
- `replace`: DESCRIPTION
- `c`: DESCRIPTION
- `e`: DESCRIPTION
"""
function EnergyToken(k::Kind, p::Int64, t::Int64, w::T, m::T, rulelabel::Int64, replace::Vector{BasicToken{T}}, c::T, e::Float64) where T
    EnergyToken(
        BasicEnergyToken(
            k, p, t, w, m, e,
        ), 
        rulelabel, replace, c
    )
end


"""
    to_basic(s::EnergyToken{T})

DOCSTRING
"""
function to_basic(s::Token)::BasicToken
    return s.basic
end

"""
    to_basic(s::Token{T})

DOCSTRING
"""
function to_basic(s::EnergyToken)::BasicEnergyToken
    return s.basic
end