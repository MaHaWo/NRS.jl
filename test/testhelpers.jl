


"""
    make_discrete_encoding_test_data()

DOCSTRING
"""
function make_discrete_encoding_test_data()
    code = [
        NRS.BasicToken(NRS.P, 1, 1, [1.0, 0.0, 0.0, 0.0], [5.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 2, 1, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 2, 2, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 3, 2, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 5, 2, [0.0, 0.0, 0.0, 1.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 5, 3, [0.0, 0.0, 0.0, 1.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.I, 4, 5, [-1.0, -1.0, -1.0, -1.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 4, 3, [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 5.0, 0.0]),
        NRS.BasicToken(NRS.T, 6, 3, [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 6, 4, [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 7, 4, [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 1, 5, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 2, 5, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),]

    altcode = [
        NRS.BasicToken(NRS.T, 2, 1, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 2, 2, [0.0, 0.0, 0.0, 1.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 3, 2, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 5, 2, [0.0, 0.0, 0.0, 1.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 5, 3, [0.0, 0.0, 0.0, 1.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.I, 4, 5, [-1.0, -1.0, - 1.0, - 1], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 6, 3, [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 4, 3, [0.0, 0.0, 1.0, 0.0], [5.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 6, 4, [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 2, 5, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
    ]

    in::Array{Float64,3} = zeros(Float64, 7, 5, 4)

    out::Array{Float64,3} = zeros(Float64, 7, 5, 4)

    mark::Array{Float64,2} = zeros(Float64, 7, 4)

    enabled::Array{Bool,1} = zeros(Bool, 5)

    NRS.build_from_code!(code, in, out, mark)

    # build the net
    net = NRS.BasicDenseNet(
        in,
        out,
        mark,
        zeros(Float64, 7, 4),
        enabled,
        zeros(Bool, 7),
        zeros(Bool, 5),
        zeros(Bool, 7),
        zeros(Bool, 5),
        zeros(Bool, 7, 5),)

    altin::Array{Float64,3} = zeros(Float64, 7, 5, 4)

    altout::Array{Float64,3} = zeros(Float64, 7, 5, 4)

    altmark::Array{Float64,2} = zeros(Float64, 7, 4)

    altenabled::Array{Bool,1} = zeros(Bool, 5)

    NRS.build_from_code!(altcode, altin, altout, altmark)

    altnet = NRS.BasicDenseNet(
        altin,
        altout,
        altmark,
        zeros(Float64, 7, 4),
        altenabled,
        zeros(Bool, 7),
        zeros(Bool, 5),
        zeros(Bool, 7),
        zeros(Bool, 5),
        ones(Bool, 7, 5),)


    return (code=code, altcode=altcode, net=net, altnet=altnet, marking=mark)
end


"""
    make_discrete_encoding_test_data_sparse()

DOCSTRING
"""
function make_discrete_encoding_test_data_sparse()
    code = [
        NRS.BasicToken(NRS.P, 1, 1, [1.0, 0.0, 0.0, 0.0], [5.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 2, 1, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 2, 2, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 3, 2, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 5, 2, [0.0, 0.0, 0.0, 1.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 5, 3, [0.0, 0.0, 0.0, 1.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.I, 4, 5, [-1.0, -1.0, -1.0, -1.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 4, 3, [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 5.0, 0.0]),
        NRS.BasicToken(NRS.T, 6, 3, [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 6, 4, [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 7, 4, [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 1, 5, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 2, 5, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),]

    altcode = [
        NRS.BasicToken(NRS.T, 2, 1, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 2, 2, [0.0, 0.0, 0.0, 1.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 3, 2, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 5, 2, [0.0, 0.0, 0.0, 1.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 5, 3, [0.0, 0.0, 0.0, 1.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.I, 4, 5, [-1.0, -1.0 - 1.0 - 1], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.T, 6, 3, [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 4, 3, [0.0, 0.0, 1.0, 0.0], [5.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 6, 4, [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
        NRS.BasicToken(NRS.P, 2, 5, [1.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]),
    ]

    in::SparseArray{Float64,3} = zeros(Float64, 7, 5, 4)

    out::SparseArray{Float64,3} = zeros(Float64, 7, 5, 4)

    mark::SparseArray{Float64,2} = zeros(Float64, 7, 4)

    enabled::SparseArray{Bool,1} = zeros(Bool, 5)

    NRS.build_from_code!(code, in, out, mark)

    # build the net
    net = NRS.BasicSparseNet(
        in,
        out,
        mark,
        zeros(Float64, 7, 4),
        enabled,
        zeros(Bool, 7),
        zeros(Bool, 5),
        zeros(Bool, 7),
        zeros(Bool, 5),
        zeros(Bool, 7, 5),)

    altin::SparseArray{Float64,3} = zeros(Float64, 7, 5, 4)

    altout::SparseArray{Float64,3} = zeros(Float64, 7, 5, 4)

    altmark::SparseArray{Float64,2} = zeros(Float64, 7, 4)

    altenabled::SparseArray{Bool,1} = zeros(Bool, 5)

    NRS.build_from_code!(altcode, altin, altout, altmark)

    altnet = NRS.BasicSparseNet(
        altin,
        altout,
        altmark,
        zeros(Float64, 7, 4),
        altenabled,
        zeros(Bool, 7),
        zeros(Bool, 5),
        zeros(Bool, 7),
        zeros(Bool, 5),
        ones(Bool, 7, 5),)


    return (code=code, altcode=altcode, net=net, altnet=altnet, marking=mark)
end



"""
    make_discrete_system_test_data()

DOCSTRING
"""
function make_discrete_system_test_data()
    # make input matrix 
    in::Array{Float64,3} = zeros(Float64, 7, 5, 4)
    in[1, 1, :] = [1.0, 0.0, 0.0, 0.0]
    in[2, 2, :] = [1.0, 0.0, 0.0, 0.0]
    in[2, 5, :] = [1.0, 0.0, 0.0, 0.0]
    in[4, 3, :] = [0.0, 0.0, 1.0, 0.0]
    in[5, 3, :] = [0.0, 0.0, 0.0, 1.0]
    in[6, 4, :] = [0.0, 0.0, 1.0, 0.0]
    in[4, 5, :] = [-1.0, -1.0, -1.0, -1.0]

    # make output matrix 
    out::Array{Float64,3} = zeros(Float64, 7, 5, 4)
    out[1, 5, :] = [1.0, 0.0, 0.0, 0.0]
    out[2, 1, :] = [1.0, 0.0, 0.0, 0.0]
    out[3, 2, :] = [1.0, 0.0, 0.0, 0.0]
    out[5, 2, :] = [0.0, 0.0, 0.0, 1.0]
    out[6, 3, :] = [0.0, 0.0, 1.0, 0.0]
    out[7, 4, :] = [0.0, 0.0, 1.0, 0.0]

    # make marking 
    mark::Array{Float64,2} = zeros(Float64, 7, 4)
    mark[1, :] = [5.0, 0.0, 0.0, 0.0]
    mark[4, :] = [0.0, 0.0, 5.0, 0.0]

    # make non-inhibitor arcs 
    noninh = ones(Bool, 7, 5)
    noninh[4, 5] = false

    # enabled vector 
    enabled = zeros(Bool, 5)
    enabled[1] = true

    final_marking = zeros(Float64, 7, 4)

    #interface 
    input_interface_places = Bool[false, false, false, true, false, false, false]
    input_interface_transitions = Bool[false, false, false, false, false]
    output_interface_places = Bool[false, false, true, false, false, false, true]
    output_interface_transitions = Bool[false, false, false, false, false]

    return (
        in=in,
        out=out,
        marking=mark,
        noninhibitors=noninh,
        input_interface_places=input_interface_places,
        input_interface_transitions=input_interface_transitions,
        output_interface_places=output_interface_places,
        output_interface_transitions=output_interface_transitions,
        enabled=enabled,
        final_marking=final_marking
    )
end


"""
    make_conflict_data()

DOCSTRING
"""
function make_conflict_data()
    code = [
        NRS.BasicToken(NRS.P, 1, 1, [1, 1,], [1, 1]),
        NRS.BasicToken(NRS.P, 2, 1, [1, 1,], [1, 1]),
        NRS.BasicToken(NRS.P, 2, 2, [2, 2,], [1, 1]),
        NRS.BasicToken(NRS.T, 3, 1, [1, 1,], [0, 0]),
        NRS.BasicToken(NRS.T, 3, 2, [1, 1,], [0, 0]),]

    in = zeros(Float64, 3, 2, 2)
    in[1, 1, :] = [1, 1]
    in[2, 1, :] = [1, 1]
    in[2, 2, :] = [2, 2]

    out = zeros(Float64, 3, 2, 2)
    out[3, 1, :] = [1, 1]
    out[3, 2, :] = [1, 1]

    marking = zeros(Float64, 3, 2)
    marking[1, :] = [1, 1]
    marking[2, :] = [2, 2]

    net = NRS.BasicDenseNet(
        3, 2, 2, code
    )

    return (
        net=net,
        in=in,
        out=out,
        marking=marking
    )
end



"""
    make_conflict_data_sparse()

DOCSTRING
"""
function make_conflict_data_sparse()
    code = [
        NRS.BasicToken(NRS.P, 1, 1, [1, 1,], [1, 1]),
        NRS.BasicToken(NRS.P, 2, 1, [1, 1,], [1, 1]),
        NRS.BasicToken(NRS.P, 2, 2, [2, 2,], [1, 1]),
        NRS.BasicToken(NRS.T, 3, 1, [1, 1,], [0, 0]),
        NRS.BasicToken(NRS.T, 3, 2, [1, 1,], [0, 0]),]

    in = zeros(Float64, 3, 2, 2)
    in[1, 1, :] = [1, 1]
    in[2, 1, :] = [1, 1]
    in[2, 2, :] = [2, 2]

    out = zeros(Float64, 3, 2, 2)
    out[3, 1, :] = [1, 1]
    out[3, 2, :] = [1, 1]

    marking = zeros(Float64, 3, 2)
    marking[1, :] = [1, 1]
    marking[2, :] = [2, 2]

    net = NRS.BasicSparseNet(
        3, 2, 2, code
    )

    return (
        net=net,
        in=in,
        out=out,
        marking=marking
    )
end


"""
    make_energy_discrete_system_test_data()

DOCSTRING
"""
function make_energy_discrete_system_test_data()

    resources = [[
            NRS.BasicEnergyToken(NRS.P, 1, 1, Float64[0, 0, 0,], Float64[0, 0, 0,], 2.0),
            NRS.BasicEnergyToken(NRS.T, 1, 2, Float64[0, 0, 0,], Float64[0, 0, 0,], 1.0),
            NRS.BasicEnergyToken(NRS.P, 2, 3, Float64[0, 0, 0,], Float64[0, 0, 0,], 2.0),
            NRS.BasicEnergyToken(NRS.I, 2, 2, Float64[0, 0, 0,], Float64[0, 0, 0,], 1.5),
        ],
        [
            NRS.BasicEnergyToken(NRS.T, 4, 1, Float64[1, 1, 1,], Float64[1, 1, 1,], 1.0),
            NRS.BasicEnergyToken(NRS.P, 4, 4, Float64[1, 1, 1,], Float64[1, 1, 1,], 2.0),
        ],
        [
            NRS.BasicEnergyToken(NRS.P, 4, 4, Float64[2, 2, 2,], Float64[0, 0, 0,], 2.0),
            NRS.BasicEnergyToken(NRS.T, 3, 2, Float64[1, 1, 1,], Float64[0, 0, 0,], 1.0),
            NRS.BasicEnergyToken(NRS.I, 3, 3, Float64[2, 2, 2,], Float64[0, 0, 0,], 1.5),
        ]]


    code = [
        NRS.BasicToken(NRS.P, 1, 1, Float64[1, 1, 1,], Float64[5, 5, 5]),
        NRS.BasicToken(NRS.T, 3, 1, Float64[2, 2, 2,], Float64[0, 0, 0]),
        NRS.BasicToken(NRS.P, 2, 1, Float64[2, 2, 2,], Float64[1, 1, 1,]),
        NRS.BasicToken(NRS.I, 2, 2, Float64[-1, -1, -1,], Float64[0, 0, 0]),
        NRS.BasicToken(NRS.T, 4, 2, Float64[1, 1, 1,], Float64[0, 0, 0]),
        NRS.BasicToken(NRS.P, 3, 3, Float64[1, 1, 1,], Float64[0, 0, 0]),
        NRS.BasicToken(NRS.T, 5, 3, Float64[1, 1, 1,], Float64[0, 0, 0]),
        NRS.BasicToken(NRS.T, 3, 2, Float64[1, 1, 1,], Float64[0, 0, 0]),
        NRS.BasicToken(NRS.T, 4, 2, Float64[1, 1, 1,], Float64[0, 0, 0]),
    ]


    energylookup = [6.5, 3.0, 4.5]


    return (resources=resources, code=code, energylookup=energylookup,)
end



"""
    make_ruletest_data()

DOCSTRING
"""
function make_ruletest_data(t::Type{T}) where {T<:AbstractArray}
    code = [
        NRS.Token(
            NRS.P,
            1,
            1,
            [1.0, 0, 0, 0], #w 
            [5.0, 0, 0, 0], #m 
            1, # rulelabel
            NRS.BasicToken{Vector{Float64}}[], # rewrite
            [5.0, 0, 0, 0] #control marking 
        ),
        NRS.Token(
            NRS.T,
            2,
            1,
            [1.0, 0, 0, 0], #w 
            [0.0, 0, 0, 0], #m 
            0, # rulelabel
            NRS.BasicToken{Vector{Float64}}[], # rewrite
            [0.0, 0.0, 0.0, 0.0] #control marking 
        ),
        NRS.Token(
            NRS.P,
            2,
            2,
            [1.0, 0, 0, 0], #w 
            [0.0, 0, 0, 0], #m  
            0, # rulelabel
            NRS.BasicToken{Vector{Float64}}[], # rewrite
            [0, 0, 0.0, 0] #control marking 
        ),
        NRS.Token(
            NRS.T,
            3,
            2,
            [0.0, 0, 1, 0],
            [0.0, 0, 0, 0],
            1,
            NRS.BasicToken{Vector{Float64}}[
                NRS.BasicToken(NRS.T, 3, 2, [0.0, 0, 1, 0], [0.0, 0, 2, 0]),
                NRS.BasicToken(NRS.P, 6, 2, [0.0, 1, 0, 0], [0, 5.0, 0, 0]),
                NRS.BasicToken(NRS.I, 6, 4, [-1.0, -1, -1, -1], [0.0, 0, 0, 0]),
                NRS.BasicToken(NRS.T, 5, 4, [0.0, 0, 0, 1], [0.0, 0, 0, 1]),
                NRS.BasicToken(NRS.I, 5, 2, [-1.0, -1, -1, -1], [0.0, 0, 0, 0]),
                NRS.BasicToken(NRS.I, 5, 4, [-1.0, -1, -1, -1], [0.0, 0, 0, 0])
            ],
            [0.0, 0, 0, 0]
        ),
        NRS.Token(
            NRS.P,
            3,
            3,
            [0, 0, 1.0, 0],
            [0, 0, 0.0, 0],
            0,
            NRS.BasicToken{Vector{Float64}}[],
            [0, 0.0, 0, 0],
        ),
        NRS.Token(
            NRS.T,
            4,
            3,
            [0, 0, 1.0, 0],
            [0, 0, 0.0, 0],
            0,
            NRS.BasicToken{Vector{Float64}}[],
            [0, 0, 0.0, 0]
        ),
    ]


    net_input::T = zeros(Float64, 15, 15, 4)
    net_input[1, 1, :] = [1.0, 0, 0, 0]
    net_input[2, 2, :] = [1.0, 0, 0, 0]
    net_input[3, 3, :] = [0, 0, 1.0, 0]

    net_output::T = zeros(Float64, 15, 15, 4)
    net_output[2, 1, :] = [1, 0, 0, 0]
    net_output[3, 2, :] = [0, 0, 1, 0]
    net_output[4, 3, :] = [0, 0, 1, 0]

    net_marking::T = zeros(Float64, 15, 4)
    net_marking[1, :] = [5, 0, 0, 0]

    rule_target_in::T = zeros(Float64, 15, 15, 4)
    rule_target_out::T = zeros(Float64, 15, 15, 4)
    rule_target_out[3, 2, :] = [0, 0, 1, 0]

    rule_effect_in = zeros(Float64, 15, 15, 4)
    rule_effect_in[6, 2, :] = [0.0, 1.0, 0.0, 0.0]
    rule_effect_in[6, 4, :] = [-1, -1, -1, -1]
    rule_effect_in[5, 2, :] = [-1, -1, -1, -1]
    rule_effect_in[5, 4, :] = [-1, -1, -1, -1]

    rule_effect_out::T = zeros(Float64, 15, 15, 4)
    rule_effect_out[5, 4, :] = [0, 0, 0, 1]
    rule_effect_out[3, 2, :] = [0, 0, 1, 0]

    rule_effect_marking::T = zeros(Float64, 15, 4)
    rule_effect_marking[3, :] = [0.0, 0, 2, 0,]
    rule_effect_marking[6, :] = [0, 5.0, 0, 0,]
    rule_effect_marking[5, :] = [0.0, 0, 0, 1]


    control_marking::T = zeros(Float64, 15, 4)
    control_marking[1, :] = [5, 0, 0, 0]

    transfer_relation_places = Dict(
        3 => Set([3,
            6,
            5])
    )

    transfer_relation_transitions = Dict(
        2 => Set([2, 4])
    )


    net_input_after_rewrite::T = zeros(Float64, 15, 15, 4)
    net_input_after_rewrite[1, 1, :] = [1.0, 0, 0, 0]
    net_input_after_rewrite[2, 2, :] = [1.0, 0, 0, 0]
    net_input_after_rewrite[3, 3, :] = [0, 0, 1.0, 0]
    net_input_after_rewrite[6, 2, :] = [0.0, 1.0, 0.0, 0.0]
    net_input_after_rewrite[6, 4, :] = [-1.0, -1, -1, -1]
    net_input_after_rewrite[5, 2, :] = [-1.0, -1, -1, -1]
    net_input_after_rewrite[5, 4, :] = [-1.0, -1, -1, -1]


    net_output_after_rewrite::T = zeros(Float64, 15, 15, 4)
    net_output_after_rewrite[2, 1, :] = [1, 0, 0, 0]
    net_output_after_rewrite[3, 2, :] = [0, 0, 1, 0]
    net_output_after_rewrite[4, 3, :] = [0, 0, 1, 0]
    net_output_after_rewrite[3, 2, :] = 
    [0.0, 0, 1, 0]
    net_output_after_rewrite[5, 4, :] = [0.0, 0, 0, 1]

    net_marking_after_rewrite::T = zeros(Float64, 15, 4)
    net_marking_after_rewrite[1, :] = [5, 0, 0, 0]
    net_marking_after_rewrite[3, :] = [0.0, 0, 2, 0]
    net_marking_after_rewrite[6, :] = [0, 5.0, 0, 0]
    net_marking_after_rewrite[5, :] = [0.0, 0, 0, 1]

    final_net_marking_after_rewrite::T = zeros(Float64, 15, 4)
    final_net_marking_after_rewrite[2, :] = [5, 0, 0, 0]
    final_net_marking_after_rewrite[4, :] = [0.0, 0, 2, 0]
    final_net_marking_after_rewrite[6, :] = [0, 5.0, 0, 0]
    final_net_marking_after_rewrite[5, :] = [0.0, 0, 0, 1]


    return (code=code,
        net_input=net_input,
        net_output=net_output,
        net_marking=net_marking,
        rule_target_in=rule_target_in,
        rule_target_out=rule_target_out,
        rule_effect_in=rule_effect_in,
        rule_effect_out=rule_effect_out,
        rule_effect_marking=rule_effect_marking,
        control_marking=control_marking,
        transfer_relation_places=transfer_relation_places,
        transfer_relation_transitions=transfer_relation_transitions,
        net_input_after_rewrite = net_input_after_rewrite,
        net_output_after_rewrite = net_output_after_rewrite,
        net_marking_after_rewrite = net_marking_after_rewrite,
        final_net_marking_after_rewrite = final_net_marking_after_rewrite,
    )
end



"""
    make_ruletest_data()

DOCSTRING
"""
function make_ruletest_data_noninhibitor(t::Type{T}) where {T<:AbstractArray}

    code = [
        NRS.Token(
            NRS.P,
            1,
            1,
            [1.0, 0, 0, 0], #w 
            [5.0, 0, 0, 0], #m 
            1, # rulelabel
            NRS.BasicToken{Vector{Float64}}[], # rewrite
            [5.0, 0, 0, 0] #control marking 
        ),
        NRS.Token(
            NRS.T,
            2,
            1,
            [1.0, 0, 0, 0], #w 
            [0.0, 0, 0, 0], #m 
            0, # rulelabel
            NRS.BasicToken{Vector{Float64}}[], # rewrite
            [0.0, 0.0, 0.0, 0.0] #control marking 
        ),
        NRS.Token(
            NRS.P,
            2,
            2,
            [1.0, 0, 0, 0], #w 
            [0.0, 0, 0, 0], #m  
            1, # rulelabel
            NRS.BasicToken{Vector{Float64}}[
                NRS.BasicToken(NRS.P, 2, 2, Float64[1,0,0,0], Float64[0,0,0,0]), 
                NRS.BasicToken(NRS.P, 2, 4, Float64[1,0,0,0], Float64[0,0,0,0]), 
                NRS.BasicToken(NRS.P, 2, 5, Float64[1,0,0,0], Float64[0,0,0,0])

            ], # rewrite
            [0, 0, 0.0, 0] #control marking 
        ),
        NRS.Token(
            NRS.T,
            3,
            2,
            [0.0, 0, 1, 0],
            [0.0, 0, 3, 0],
            1,
            NRS.BasicToken{Vector{Float64}}[
                NRS.BasicToken(NRS.T, 3, 2, Float64[0,0,1,0], Float64[0,0,0,0]), 
                NRS.BasicToken(NRS.T, 5, 4, Float64[0,0,1,0], Float64[0,0,0,0]), 
                NRS.BasicToken(NRS.T, 6, 5, Float64[0,0,1,0], Float64[0,0,0,0])
            ],
            [0.0, 0, 0, 0]
        ),
        NRS.Token(
            NRS.P,
            3,
            3,
            [0, 0, 1.0, 0],
            [0, 0, 0.0, 0],
            1,
            NRS.BasicToken{Vector{Float64}}[
                NRS.BasicToken(NRS.P, 3, 3, Float64[0,0,1,0], Float64[0,0,0,0]), 
                NRS.BasicToken(NRS.P, 5, 3, Float64[0,0,1,0], Float64[0,0,0,0]), 
                NRS.BasicToken(NRS.P, 6, 3, Float64[0,0,1,0], Float64[0,0,0,0])
            ],
            [0, 0.0, 0, 0],
        ),
        NRS.Token(
            NRS.T,
            4,
            3,
            [0, 0, 1.0, 0],
            [0, 0, 0.0, 0],
            0,
            NRS.BasicToken{Vector{Float64}}[],
            [0, 0, 0.0, 0]
        ),
    ]

    net_input::T = zeros(Float64, 15, 15, 4)
    net_input[1, 1, :] = [1.0, 0, 0, 0]
    net_input[2, 2, :] = [1.0, 0, 0, 0]
    net_input[3, 3, :] = [0, 0, 1.0, 0]

    net_output::T = zeros(Float64, 15, 15, 4)
    net_output[2, 1, :] = [1, 0, 0, 0]
    net_output[3, 2, :] = [0, 0, 1, 0]
    net_output[4, 3, :] = [0, 0, 1, 0]

    net_marking::T = zeros(Float64, 15, 4)
    net_marking[1, :] = [5, 0, 0, 0]
    net_marking[3, :] = [0, 0, 3, 0]

    rule_target_in::T = zeros(Float64, 15, 15, 4)
    rule_target_in[2, 2, :] = Float64[1,0,0,0]
    rule_target_in[3, 3, :] = Float64[0,0,1,0] 

    rule_target_out::T = zeros(Float64, 15, 15, 4)
    rule_target_out[3, 2, :] = Float64[0,0,1,0]
    
    rule_effect_in = zeros(Float64, 15, 15, 4)
    rule_effect_in[2,2,:] = Float64[1, 0, 0, 0]
    rule_effect_in[2,4,:] = Float64[1, 0, 0, 0]
    rule_effect_in[2,5,:] = Float64[1, 0, 0, 0]

    rule_effect_in[3,3,:] = Float64[0, 0, 1, 0]
    rule_effect_in[5,3,:] = Float64[0, 0, 1, 0]
    rule_effect_in[6,3,:] = Float64[0, 0, 1, 0]

    rule_effect_out::T = zeros(Float64, 15, 15, 4)
    rule_effect_out[3, 2, :] = Float64[0, 0, 1, 0]
    rule_effect_out[5, 4, :] = Float64[0, 0, 1, 0]
    rule_effect_out[6, 5, :] = Float64[0, 0, 1, 0]

    rule_effect_marking::T = zeros(Float64, 15, 4)

    net_input_after_rewrite::T = deepcopy(net_input)
    net_input_after_rewrite[2, 4, :] = Float64[1, 0, 0, 0]
    net_input_after_rewrite[2, 5, :] = Float64[1, 0, 0, 0]
    net_input_after_rewrite[5, 3, :] = Float64[0, 0, 1, 0]
    net_input_after_rewrite[6, 3, :] = Float64[0, 0, 1, 0]

    net_output_after_rewrite::T = deepcopy(net_output)
    net_output_after_rewrite[5, 4, :] = Float64[0, 0, 1, 0]
    net_output_after_rewrite[6, 5, :] = Float64[0, 0, 1, 0]

    net_marking_after_rewrite::T = zeros(Float64, 15, 4)
    net_marking_after_rewrite[1, :] = [5, 0, 0, 0]
    net_marking_after_rewrite[3, :] = [0, 0, 1, 0]
    net_marking_after_rewrite[5, :] = [0, 0, 1, 0]
    net_marking_after_rewrite[6, :] = [0, 0, 1, 0]

    net_marking_after_rewrite_copy::T = zeros(Float64, 15, 4)
    net_marking_after_rewrite_copy[1, :] = [5, 0, 0, 0]
    net_marking_after_rewrite_copy[3, :] = [0, 0, 3, 0]
    net_marking_after_rewrite_copy[5, :] = [0, 0, 3, 0]
    net_marking_after_rewrite_copy[6, :] = [0, 0, 3, 0]

    return (
        code = code,
        net_input = net_input,
        net_output = net_output,
        net_marking = net_marking,
        rule_target_in = rule_target_in,
        rule_target_out = rule_target_out,
        rule_effect_in = rule_effect_in,
        rule_effect_out = rule_effect_out,
        rule_effect_marking = rule_effect_marking,
        net_marking_after_rewrite_copy = net_marking_after_rewrite_copy,
        net_input_after_rewrite = net_input_after_rewrite,  
        net_output_after_rewrite = net_output_after_rewrite,    
        net_marking_after_rewrite = net_marking_after_rewrite,  
        )
end