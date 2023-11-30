

################################################################################
# common functions for net functionality

"""
    compute_input_interface_places!(net::N) where N <: AbstractNet

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_input_interface_places!(net::N) where {N<:AbstractNet}

    # check all places 
    @inline @inbounds for p in 1:size(net.marking)[1]

        # input interface place: nothing comes into it -> output elements zero, 
        # stuff goes out from it: input elements nonzero

        if any(.!isapprox.(sum(net.input[p, :, :], dims=1), 0)) &&
           all(isapprox.(sum(net.output[p, :, :], dims=1), 0))
            net.input_interface_places[p] = true
        else
            net.input_interface_places[p] = false
        end
    end
end

"""
    compute_input_interface_transitions!(net::N) where N <: AbstractNet

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_input_interface_transitions!(net::N) where {N<:AbstractNet}
    @inline @inbounds for t in 1:size(net.input)[2]
        # input interface transitions -> have no input => input==0, but have output ==> output nonzero
        if any(.!isapprox.(sum(net.output[:, t, :], dims=1), 0)) &&
           all(isapprox.(sum(net.input[:, t, :], dims=1), 0))
            net.input_interface_transitions[t] = true
        else
            net.input_interface_transitions[t] = false
        end
    end
end

"""
    compute_output_interface_places!(net::N) where N <: AbstractNet

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_output_interface_places!(net::N) where {N<:AbstractNet}

    @inline @inbounds for p in 1:size(net.marking)[1]

        # input interface place: nothing comes into it -> output elements zero, 
        # stuff goes out from it: input elements nonzero
        # println("p: ", p, ", ", sum(net.output[p, :, :], dims=1))
        if any(.!isapprox.(sum(net.output[p, :, :], dims=1), 0)) &&
           all(isapprox.(sum(net.input[p, :, :], dims=1), 0))

            net.output_interface_places[p] = true
        else
            net.output_interface_places[p] = false
        end
    end
end

"""
    compute_output_interface_transitions!(net::N) where N <: AbstractNet

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_output_interface_transitions!(net::N) where {N<:AbstractNet}

    @inline @inbounds for t in 1:size(net.input)[2]
        # input interface transitions -> have no input => input==0, but have output ==> output nonzero
        if any(.!isapprox.(sum(net.input[:, t, :], dims=1), 0)) &&
           all(isapprox.(sum(net.output[:, t, :], dims=1), 0))
            net.output_interface_transitions[t] = true
        else
            net.output_interface_transitions[t] = false
        end
    end
end


"""
    compute_non_inhibitor_arcs!!(net::N) where N <: AbstractNet

DOCSTRING

# Arguments:
- `net`: DESCRIPTION
"""
function compute_non_inhibitor_arcs!(net::N) where {N<:AbstractNet}

    # inhibitor arc w(p,t) are those that have input[p, t, :] .== -1 over the resoure index r 
    @inline @inbounds net.noninhibitor_arcs = Matrix{Bool}(sum(net.input, dims=3)[:, :, 1] .!= size(net.input)[3] * -1.0)
end