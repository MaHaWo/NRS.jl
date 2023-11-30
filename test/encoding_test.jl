
@testset "encoding_Token_test" begin 

    s = NRS.Token(
        NRS.P,
        1,
        2, 
        rand(Float64, 5), 
        rand(Float64, 5), 
        6, 
        [
            NRS.BasicToken(NRS.P, 1, 3, rand(Float64, 5), rand(Float64, 5)), 
            NRS.BasicToken(NRS.T, 2, 3, rand(Float64, 5), rand(Float64, 5)), 
            NRS.BasicToken(NRS.I, 2, 2, rand(Float64, 5), rand(Float64, 5)), 
        ], 
        rand(Float64, 5)

    )

    b = NRS.to_basic(s)

    @test b.k == NRS.P
    @test b.p == 1 
    @test b.t == 2 
    @test all(isapprox.(b.w, s.w))
    @test all(isapprox.(b.m, s.m))
end

@testset "encoding_energy_Token_test" begin 

    s = NRS.EnergyToken(
        NRS.P,
        1,
        2, 
        rand(Float64, 5), 
        rand(Float64, 5), 
        6, 
        [
            NRS.BasicToken(NRS.P, 1, 3, rand(Float64, 5), rand(Float64, 5)), 
            NRS.BasicToken(NRS.T, 2, 3, rand(Float64, 5), rand(Float64, 5)), 
            NRS.BasicToken(NRS.I, 2, 2, rand(Float64, 5), rand(Float64, 5)), 
        ], 
        rand(Float64, 5), 
        3.14
    )

    b = NRS.to_basic(s)
    @test b.k == NRS.P
    @test b.p == 1 
    @test b.t == 2 
    @test all(isapprox.(b.w, s.w))
    @test all(isapprox.(b.m, s.m))
    @test isapprox(b.e, s.e)

end

