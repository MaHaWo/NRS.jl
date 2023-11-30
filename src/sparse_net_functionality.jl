################################################################################
## conflict handling

"""
    detect_conflict_vector(net::N)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function detect_conflict_vector(net::N)::BitVector where {N<:AbstractSparseDiscreteNet}

    conflict::BitVector = fill(false, size(net.marking)[1])

    @inline @inbounds for p in 1:size(net.marking)[1]
        # conflict found when the sum of the weights going out from a place to enabled transitions is greater than its marking, such that they cannot all be served at once 

        if any((@tensor x[r] := net.input[p, :, :][t, r] * net.enabled[t]) .> net.marking[p, :])
            conflict[p] = true
        end
    end

    return conflict
end


"""
    detect_conflict(net::N)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function detect_conflict(net::N)::Bool where {N<:AbstractSparseDiscreteNet}

    conflict::Bool = false

    @inline @inbounds for p in 1:size(net.marking)[1]

        # conflict found when the sum of the weights going out from a place to enabled transitions is greater than its marking, such that they cannot all be served at once 
        if any((@tensor x[r] := net.input[p, :, :][t, r] * net.enabled[t]) .> net.marking[p, :])
            conflict = true

        end
    end

    return conflict
end


"""
    handle_conflict!(net::N)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function handle_conflict!(net::N) where {N<:AbstractSparseDiscreteNet}
    # randomly disable transitions until no more conflicts are detected
    @inline @inbounds while detect_conflict(net) && sum(net.enabled) > 0

        disabled::Bool = false

        @inline @inbounds while disabled == false

            # easier julia way
            idx::Int64 = rand(1:length(net.enabled))

            if net.enabled[idx]
                net.enabled[idx] = false
                disabled = true
            end

            # the way it's implemented in cpp:
            # for e in net.enabled 
            #     if e && rand(Float64) < 0.5
            #         e = false 
            #         disabled = true 
            #     end
            # end
        end

    end
end

################################################################################
## computation of enabled transitions for different types of nets 


"""
    compute_enabled!(net::N)  where {N <: AbstractBasicSparseDiscreteNet}

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_enabled!(net::N) where {N<:AbstractBasicSparseDiscreteNet}

    SparseArrayKit.zerovector!(net.enabled)

    @inline @inbounds for t in 1:size(net.input)[2]

        #declare temps and reset enabled value
        e::Bool = true

        # whether we have inhibitor arcs 
        @inline @inbounds for p in 1:size(net.input)[1]

            if all(net.input[p, t, :] .≈ 0.0)
                continue
            end

            # check that there is enough marking
            ew = all(net.marking[p, :] .> net.input[p, t, :] .|| net.marking[p, :] .≈ net.input[p, t, :])

            # check whether we have an inhibitor arc
            en = all(isapprox.(net.input[p, t, :], -1.0))

            # check whether marking is zero
            em = all(isapprox.(net.marking[p, :], 0))

            # first term before || is the normal marking when there is no inhibitors involved, second one is when there is an inhibitor involved
            e = e && ((!en && ew) || (en && em))
        end

        net.enabled[t] = e
    end
end


"""
    compute_enabled!(net::N) where{N <: AbstractEnergySparseDiscreteNet}

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_enabled!(net::N) where {N<:AbstractEnergySparseDiscreteNet}

    SparseArrayKit.zerovector!(net.enabled)

    @inline @inbounds for t in 1:size(net.input)[2]

        e::Bool = true

        @inline @inbounds for p in 1:size(net.input)[1]

            energy_m = 0.0

            energy_w = 0.0

            # build energy values
            @inline @inbounds for r in 1:size(net.input)[3]
                energy_m += net.marking[p, r] * net.energy.lookup_table[r]

                energy_w += net.input[p, t, r] * net.energy.lookup_table[r]
            end


            ew = energy_m > energy_w || isapprox(energy_m, energy_w)

            # check whether we have an inhibitor arc
            en = all(isapprox.(net.input[p, t, :], -1.0))

            # check whether marking energy is zero
            em = all(isapprox.(energy_m, 0.0))

            e = e && ((!en && ew) || (en && em))
        end

        net.enabled[t] = e
    end
end

################################################################################
## steps and runs of nets 

"""
    compute_step!(net::N)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_step!(net::N) where {N<:AbstractSparseDiscreteNet}

    compute_enabled!(net)

    handle_conflict!(net)

    if hasfield(typeof(net), :tmp_marking)

        @tensor begin
            net.tmp_marking[p, r] = (net.output[p, t, r] - (SparseArray{Float64,3}(net.input .* net.noninhibitor_arcs))[p, t, r]) * net.enabled[t] + net.marking[p, r]
        end

        net.marking = deepcopy(net.tmp_marking)

        SparseArrayKit.zerovector!(net.tmp_marking)

    elseif hasfield(typeof(net), :basenet)
        @tensor begin
            net.basenet.tmp_marking[p, r] = (net.basenet.output[p, t, r] - (SparseArray{Float64,3}(net.basenet.input .* net.basenet.noninhibitor_arcs))[p, t, r]) * net.basenet.enabled[t] + net.basenet.marking[p, r]
        end

        net.basenet.marking = deepcopy(net.basenet.tmp_marking)

        fill!(net.basenet.tmp_marking, 0.0)
    else
        throw(ErrorException("Error, unknown net makeup - neither :basenet nor basic net constituents are elements of the net"))
    end
end



"""
    run!(net::N, maxiter::Int64, tol::Float64)

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
- `maxiter`: DESCRIPTION
- `tol`: DESCRIPTION
"""
function run!(net::N, maxiter::Int64, tol::Float64) where {N<:AbstractSparseDiscreteNet}

    iter = 1

    old_marking = SparseArray(zeros(Float64, size(net.marking)...))

    if hasfield(typeof(net), :tmp_marking)

        while iter < maxiter && (dot(net.marking - old_marking, net.marking - old_marking) > tol)

            old_marking = net.marking

            compute_step!(net)

            iter += 1
        end

    elseif hasfield(typeof(net), :basenet)

        while iter < maxiter && (dot(net.basenet.marking - old_marking, net.basenet.marking - old_marking) > tol)

            old_marking = net.basenet.marking

            compute_step!(net)

            iter += 1
        end

    else
        throw(ErrorException("Error, unknown field in running net"))
    end
end