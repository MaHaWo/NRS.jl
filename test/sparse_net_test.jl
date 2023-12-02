
@testset "basic_net_construction_sparse" begin 
    fixture = make_discrete_system_test_data()

    codefixture = make_discrete_encoding_test_data_sparse()

    net = NRS.BasicSparseNet(7, 5, 4, codefixture.code)

    NRS.compute_enabled!(net)

    @test net.input_interface_places isa SparseArray

    @test net.output_interface_places isa SparseArray

    @test net.input_interface_places isa SparseArray

    @test net.input_interface_transitions isa SparseArray

    @test net.output_interface_transitions isa SparseArray

    @test all(Array(net.input) .≈ fixture.in)

    @test all(Array(net.output) .≈ fixture.out)

    @test all(Array(net.marking) .≈ fixture.marking)

    @test Array(net.enabled) == fixture.enabled
end 


@testset  "interface_normal_sparse" begin 
    fixture = make_discrete_encoding_test_data_sparse()
    
    NRS.compute_input_interface_places!(fixture.net)

    NRS.compute_input_interface_transitions!(fixture.net)

    NRS.compute_output_interface_places!(fixture.net)

    NRS.compute_input_interface_transitions!(fixture.altnet)

    @test fixture.net isa NRS.BasicSparseNet

    @test fixture.net.input isa SparseArray

    @test length(nonzero_values(fixture.net.input)) == 10

    @test length(nonzero_values(fixture.net.output)) == 6

    @test fixture.net.input_interface_places == Bool[false, false, false, true, false, false, false]

    @test fixture.net.output_interface_places == Bool[false, false, true, false, false, false, true]

    @test fixture.net.input_interface_transitions == Bool[false, false, false, false, false]

    @test fixture.net.output_interface_transitions == Bool[false, false, false, false, false]
end 


@testset "noninhibitor_arcs_sparse" begin 
    fixture = make_discrete_encoding_test_data_sparse()

    NRS.compute_non_inhibitor_arcs!(fixture.net)

    noninhibitors = ones(Bool, 7, 5)

    noninhibitors[4, 5] = false

    @test fixture.net.noninhibitor_arcs == noninhibitors
end


@testset "interface_alt_sparse" begin 
    fixture = make_discrete_encoding_test_data_sparse()

    NRS.compute_input_interface_places!(fixture.altnet)
    NRS.compute_input_interface_transitions!(fixture.altnet)
    NRS.compute_input_interface_places!(fixture.altnet)
    NRS.compute_output_interface_transitions!(fixture.altnet)

    @test fixture.altnet.input_interface_places == Bool[false, false, false, true, false, false, false]

    @test fixture.altnet.output_interface_places == Bool[false, false, false, false, false, false, false]

    @test fixture.altnet.input_interface_transitions == Bool[true, false, false, false, false]

    @test fixture.altnet.output_interface_transitions == Bool[false, false, false, true, true]
end


@testset "noninhibitor_arcs_alt_sparse" begin 
    fixture = make_discrete_encoding_test_data_sparse()
    NRS.compute_non_inhibitor_arcs!(fixture.altnet)

    noninhibitors = ones(Bool, 7, 5)
    noninhibitors[4, 5] = false
    @test fixture.altnet.noninhibitor_arcs == noninhibitors
end


@testset "enabled_discrete_sparse" begin 
    fixture = make_discrete_encoding_test_data_sparse()

    NRS.compute_enabled!(fixture.net)

    @test fixture.net.enabled == Bool[true, false, false, false, false]
end


@testset "conflict_handling_sparse" begin 
    fixture = make_conflict_data_sparse()
    NRS.compute_enabled!(fixture.net)
    
    found_bv::BitVector = NRS.detect_conflict_vector(fixture.net)
    found::Bool = NRS.detect_conflict(fixture.net)

    @test fixture.net.marking ≈ fixture.marking
    @test fixture.net.enabled == [true, true]
    @test found_bv == BitVector([false, true, false])
    @test found

    # # handle conflict
    NRS.handle_conflict!(fixture.net)
    found_after = NRS.detect_conflict(fixture.net)
    @test found_after == false
    @test fixture.net.enabled == [true, false] || fixture.net.enabled == [false, true]

end



@testset "discrete_system_single_step_sparse" begin 
    fixture = make_discrete_encoding_test_data_sparse()

    @test fixture.net.marking ≈ fixture.marking
    
    NRS.compute_non_inhibitor_arcs!(fixture.net)
    NRS.compute_step!(fixture.net)

    tmp_marking = SparseArray(zeros(Float64, 7, 4))
    tmp_marking[1, :] = [4.0, 0.0, 0.0, 0.0]
    tmp_marking[2, :] = [1.0, 0.0, 0.0, 0.0]
    tmp_marking[4, :] = [0.0, 0.0, 5.0, 0.0]

    @test fixture.net.tmp_marking ≈ SparseArray(zeros(Float64, 7, 4))
    @test fixture.net.marking ≈ SparseArray(tmp_marking)
end


@testset "discrete_system_run_sparse" begin 
    fixture = make_discrete_encoding_test_data_sparse()

    @test fixture.net.marking ≈ fixture.marking

    NRS.compute_non_inhibitor_arcs!(fixture.net)

    tmp_marking = SparseArray(zeros(Float64, 7, 4))
    tmp_marking[3, :] = [5.0, 0.0, 0.0, 0.0]
    tmp_marking[7, :] = [0.0, 0.0, 5.0, 0.0]

    NRS.run!(fixture.net, 10, 2e-15)

    @show fixture.net.marking
    @test fixture.net.tmp_marking ≈ SparseArray(zeros(Float64, 7, 4))
    @test fixture.net.marking ≈ tmp_marking
end

######################################################################################################################### Energy net

@testset "energy_lookup_test_sparse" begin 
    fixture = make_energy_discrete_system_test_data()

    net = NRS.EnergySparseNet(
        NRS.BasicSparseNet(5, 3, 3, fixture.code),
        NRS.EnergyLookup(fixture.resources)
    )

    net.marking[2, :] = [3., 1., 2.]

    NRS.compute_enabled!(net)

    @test all(net.enabled .≈ [true, false, false])

    # make it such that transition 2 and three enabled
    net.marking[2, :] = zeros(Float64, 3)
    net.marking[3, :] = [2., 2., 2.]

    NRS.compute_enabled!(net)
    @test all(net.enabled .≈ [false, true, true])
end

@testset "energy_based_compute_enabled_sparse" begin  
    fixture = make_energy_discrete_system_test_data()

    net = NRS.EnergySparseNet(
        NRS.BasicSparseNet(5, 3, 3, fixture.code),
        NRS.EnergyLookup(fixture.resources)
    )

    net.marking[2, :] = [3., 1., 2.]

    NRS.compute_enabled!(net)

    @test all(net.enabled .≈ [true, false, false])

    # make it such that transition 2 and three enabled
    net.marking[2, :] = zeros(Float64, 3)
    net.marking[3, :] = [2., 2., 2.]

    NRS.compute_enabled!(net)
    @test all(net.enabled .≈ [false, true, true])
end

@testset "energy_net_run_sparse" begin  

    fixture = make_energy_discrete_system_test_data()

    net = NRS.EnergySparseNet(
        NRS.BasicSparseNet(5, 3, 3, fixture.code),
        NRS.EnergyLookup(fixture.resources)
    )
    net.marking[2, :] = [3., 2., 2.]
    net.marking[1, :] = [1., 1., 1.]

    NRS.run!(net, 10, 5e-12,)

    m1::SparseArray{Float64, 2} = SparseArray{Float32, 2}(zeros(Float64, 5, 3))
    m2::SparseArray{Float64, 2} = SparseArray{Float32, 2}(zeros(Float64, 5, 3))
    m3::SparseArray{Float64, 2} = SparseArray{Float32, 2}(zeros(Float64, 5, 3))

    m1[2, :] = [1., 0., 0.]
    m1[3, :] = [1., 1., 1.]
    m1[4, :] = [1., 1., 1.]

    
    m2[2, :] = [1., 0., 0.]
    m2[5, :] = [2., 2., 2]

    m3[2, :] = [1., 0., 0.]
    m3[4, :] = [2., 2., 2]

    @test all(net.marking .≈ m1) || all(net.marking .≈ m2) || all(net.marking .≈ m3)
end
