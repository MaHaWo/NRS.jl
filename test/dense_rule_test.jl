
@testset "dense_rule_construction_test" begin
    data = make_ruletest_data(Array)

    net = NRS.BasicDenseNet(15, 15, 4, data.code)
    rule = NRS.DenseRule(1, 15, 15, 4, NRS.redistribute_marking_conserved!, data.code)

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


@testset "dense_rule_function_test" begin 
    data = make_ruletest_data(Array)

    net = NRS.BasicDenseNet(10, 10, 4, data.code)
    rule = NRS.DenseRule(1, 15, 15, 4, NRS.redistribute_marking_conserved!, data.code)

    NRS.rebuild_net!(rule, net)

    @test net.input ≈ data.net_input

    @test net.output≈ data.net_output 

    @test net.marking≈ data.net_marking

    @test NRS.count_nonzero_target_elements(rule) == Dict("in" => 0, "out" => 1)

    @test NRS.count_nonzero_effect_elements(rule) == Dict("in" => 4, "out" => 2)
    
    NRS.compute_enabled_rule!(rule; nets= [net,], with_control_marking=true, with_weight_check=true)

    @test rule.enabled == true
end


@testset "dense_nonfunctional_rules" begin 
    data = make_ruletest_data(Array)

    net = NRS.BasicDenseNet(15, 15, 6, data.code)

    rule = NRS.DenseRule(1, 15, 15, 6, NRS.redistribute_marking_conserved!, data.code)
    
    net.marking[1, 1] = 4.

    NRS.compute_enabled_rule!(rule; nets= [net,], with_control_marking=true, with_weight_check=true)

    @test rule.enabled == false
    
    NRS.compute_enabled_rule!(rule; nets= [net,], with_control_marking=false, with_weight_check=true)

    @test rule.enabled == true

end


@testset "dense_rewrite_conserved" begin

    data = make_ruletest_data_noninhibitor(Array)

    net = NRS.BasicDenseNet(15, 15, 4, data.code)

    rule = NRS.DenseRule(1, 15, 15, 4, NRS.redistribute_marking_conserved!, data.code)

    @test net.input ≈ data.net_input

    @test net.output ≈ data.net_output 

    @test net.marking ≈ data.net_marking

    @test rule.target_in ≈ data.rule_target_in

    @test rule.target_out ≈ data.rule_target_out

    @test rule.effect_in ≈ data.rule_effect_in

    @test rule.effect_out ≈ data.rule_effect_out

    NRS.rewrite!(rule, net; nets=[net,], with_weight_check=true, with_control_marking=true)

    @test SparseArray(net.input) ≈ SparseArray(data.net_input_after_rewrite)

    @test SparseArray(net.output) ≈ SparseArray(data.net_output_after_rewrite)

    @test SparseArray(net.marking) ≈ SparseArray(data.net_marking_after_rewrite)

end


@testset "dense_rewrite_copy" begin

    data = make_ruletest_data_noninhibitor(Array)

    net = NRS.BasicDenseNet(15, 15, 4, data.code)

    rule = NRS.DenseRule(1, 15, 15, 4, NRS.redistribute_marking_copy!, data.code)

    @test net.input ≈ data.net_input

    @test net.output ≈ data.net_output 

    @test net.marking ≈ data.net_marking

    @test rule.target_in ≈ data.rule_target_in

    @test rule.target_out ≈ data.rule_target_out

    @test rule.effect_in ≈ data.rule_effect_in

    @test rule.effect_out ≈ data.rule_effect_out

    NRS.rewrite!(rule, net; nets=[net,], with_weight_check=true, with_control_marking=true)

    @test SparseArray(net.input) ≈ SparseArray(data.net_input_after_rewrite)

    @test SparseArray(net.output) ≈ SparseArray(data.net_output_after_rewrite)

    @test SparseArray(net.marking) ≈ SparseArray(data.net_marking_after_rewrite_copy)

end 

