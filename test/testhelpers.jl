
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
        NRS.BasicToken(NRS.I, 4, 5, [-1.0, -1.0 - 1.0 - 1], [0.0, 0.0, 0.0, 0.0]),
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
    net = NRS.SparseBasicNet(
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

    altnet = NRS.SparseBasicNet(
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
    in::Array{Float64, 3} = zeros(Float64, 7, 5, 4)
    in[1, 1, :] = [1.0, 0.0, 0.0, 0.0]
    in[2, 2, :] = [1.0, 0.0, 0.0, 0.0]
    in[2, 5, :] = [1.0, 0.0, 0.0, 0.0]
    in[4, 3, :] = [0.0, 0.0, 1.0, 0.0]
    in[5, 3, :] = [0.0, 0.0, 0.0, 1.0]
    in[6, 4, :] = [0.0, 0.0, 1.0, 0.0]
    in[4, 5, :] = [-1.0, -1.0, -1.0, -1.0]

    # make output matrix 
    out::Array{Float64, 3} = zeros(Float64, 7, 5, 4)
    out[1, 5, :] = [1.0, 0.0, 0.0, 0.0]
    out[2, 1, :] = [1.0, 0.0, 0.0, 0.0]
    out[3, 2, :] = [1.0, 0.0, 0.0, 0.0]
    out[5, 2, :] = [0.0, 0.0, 0.0, 1.0]
    out[6, 3, :] = [0.0, 0.0, 1.0, 0.0]
    out[7, 4, :] = [0.0, 0.0, 1.0, 0.0]

    # make marking 
    mark::Array{Float64, 2} = zeros(Float64, 7, 4)
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

    net = NRS.SparseBasicNet(
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