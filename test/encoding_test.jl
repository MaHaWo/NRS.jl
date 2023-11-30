include("../src/ipn.jl")

using Test

@testset "encoding_Token_test" begin 

    s = IPN.Token(
        IPN.P,
        1,
        2, 
        rand(Float64, 5), 
        rand(Float64, 5), 
        6, 
        [
            IPN.BasicToken(IPN.P, 1, 3, rand(Float64, 5), rand(Float64, 5)), 
            IPN.BasicToken(IPN.T, 2, 3, rand(Float64, 5), rand(Float64, 5)), 
            IPN.BasicToken(IPN.I, 2, 2, rand(Float64, 5), rand(Float64, 5)), 
        ], 
        rand(Float64, 5)

    )

    b = IPN.to_basic(s)

    @test b.k == IPN.P
    @test b.p == 1 
    @test b.t == 2 
    @test all(isapprox.(b.w, s.w))
    @test all(isapprox.(b.m, s.m))
end

@testset "encoding_energy_Token_test" begin 

    s = IPN.EnergyToken(
        IPN.P,
        1,
        2, 
        rand(Float64, 5), 
        rand(Float64, 5), 
        6, 
        [
            IPN.BasicToken(IPN.P, 1, 3, rand(Float64, 5), rand(Float64, 5)), 
            IPN.BasicToken(IPN.T, 2, 3, rand(Float64, 5), rand(Float64, 5)), 
            IPN.BasicToken(IPN.I, 2, 2, rand(Float64, 5), rand(Float64, 5)), 
        ], 
        rand(Float64, 5), 
        3.14
    )

    b = IPN.to_basic(s)
    @test b.k == IPN.P
    @test b.p == 1 
    @test b.t == 2 
    @test all(isapprox.(b.w, s.w))
    @test all(isapprox.(b.m, s.m))
    @test isapprox(b.e, s.e)

end

