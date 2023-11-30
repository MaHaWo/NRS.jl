module Net

using TensorOperations

using AutomaticDocstrings # not necessary for the running of the module
AutomaticDocstrings.options[:min_args] = 1
AutomaticDocstrings.options[:kwargs_header] = "# Keyword arguments:"

# """
#     compute_step!(net::AbstractContinuousNetMassAction, dt::Float64)

# DOCSTRING

# # Arguments:
# - `net`: DESCRIPTION
# - `dt`: DESCRIPTION
# """
# function compute_step!(net::AbstractContinuousNetMassAction, dt::Float64)

#     net.enabled_function(net)

#     # get old marking first
#     old_marking = net.marking

#     # then compute new marking
#     @tensor begin
#         net.marking[p, r] = dt * ((net.output[p, t, r] -
#         @notensor begin
#             (net.input[p, t, r] .* net.noninhibitor_arcs[p, t, r])
#         end) * net.enabled[t])
#     end

#     # finally build the danmn thing
#     net.marking .= net.marking .* net.enabled_weight .+ old_marking

# end

# """
#     compute_step!(net::AbstractContinuousNetSimple)

# DOCSTRING

# # Arguments:
# - `net`: DESCRIPTION
# """
# function compute_step!(net::AbstractContinuousNetSimple)

#     net.enabled_function(net)

#     handle_conflict!(net)

#     # then compute new marking
#     @tensor begin
#         net.marking[p, r] = (net.output[p, t, r] -
#         @notensor begin
#             (net.input[p, t, r] .* net.noninhibitor_arcs[p, t, r])
#         end) * net.enabled[t] * net.enabled_degree[t] +  net.marking[p, r]
#     end
# end


end