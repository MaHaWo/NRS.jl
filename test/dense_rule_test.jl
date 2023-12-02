
include("../src/NRS.jl")

include("./testhelpers.jl")

using Test
using SparseArrayKit

@testset "dense_rule_construction_test" begin
    data = make_ruletest_data(Array)

    net = NRS.BasicDenseNet(15, 15, 4, data.code)
    rule = NRS.DenseRule(1, 15, 15, 4, NRS.redistribute_marking_conserved, data.code)

    @test net.input ≈ data.net_input
    @test net.output ≈ data.net_output
    @test net.marking ≈ data.net_marking

    @test rule.target_in ≈ data.rule_target_in
    @test rule.target_out ≈ data.rule_target_out
    @test rule.control_marking ≈ data.control_marking

    @test rule.effect_in ≈ data.rule_effect_in
    @test rule.effect_out ≈ data.rule_effect_out

    @test rule.transfer_relation_places == data.transfer_relation_places
    @test rule.transfer_relation_transitions == data.transfer_relation_transitions

    @test rule.effect_marking ≈ data.rule_effect_marking
end


@testset "dense_rule_rewriting_test" begin 
end