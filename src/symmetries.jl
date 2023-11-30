
# using AutomaticDocstrings # not necessary for the running of the module
# AutomaticDocstrings.options[:min_args] = 1
# AutomaticDocstrings.options[:kwargs_header] = "# Keyword arguments:"


"""
    EnergyLookup

DOCSTRING

# Fields:
- `lookup_table::Vector{Float64}`: DESCRIPTION
"""
mutable struct EnergyLookup <: AbstractSymmetry
    lookup_table::Vector{Float64}
end

"""
    Base.getindex(e::EnergyLookup, i::Int)

DOCSTRING

# Arguments:
- `e`: DESCRIPTION
- `i`: DESCRIPTION
"""
Base.getindex(e::EnergyLookup, i::Int) = e.lookup_table[i]

"""
    compute_energy!(energy_lookup::EnergyLookup, resources::Vector{Vector{S}}, e_P::Float64, e_T::Float64, e_I::Float64)

DOCSTRING

# Arguments:
- `energy_lookup`: DESCRIPTION
- `resources`: DESCRIPTION
- `e_P`: DESCRIPTION
- `e_T`: DESCRIPTION
- `e_I`: DESCRIPTION
"""
function compute_energy!(energy_lookup::EnergyLookup, resources::Vector{Vector{S}}) where {S<:AbstractEnergyToken}

    energy_lookup.lookup_table = zeros(Float64, length(resources))

    for i in 1:length(resources)
        for c in resources[i]
            if c.k == P
                energy_lookup.lookup_table[i] += c.e
            elseif c.k == T
                energy_lookup.lookup_table[i] += c.e
            elseif c.k == I
                energy_lookup.lookup_table[i] += c.e
            else
                throw(ErrorException("Error, unknown symbol"))
            end
        end
    end
end


"""
    EnergyLookup(resources::Vector{Vector{S}})

DOCSTRING

# Arguments:
- `resources`: DESCRIPTION
"""
function EnergyLookup(resources::Vector{Vector{S}}) where {S <: AbstractEnergyToken} 
    e = EnergyLookup([])

    compute_energy!(e, resources)
    
    return e
end