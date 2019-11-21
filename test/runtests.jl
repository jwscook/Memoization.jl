using Memoization
using Test

##

@testset "Memoization" begin
    
    local n
    
    @memoize f(x::T, y=nothing, args... ; z::Union{Int,Nothing}, w=nothing, kwargs...) where {T<:Int} = (n+=1; ((x,y,args...), (;z=z,w=w,kwargs...)))
    
    
    # args
    @test (n=0; f(1,    z=1) == ((1,nothing),(z=1,w=nothing)) && n==1)
    @test (n=0; f(1,    z=1) == ((1,nothing),(z=1,w=nothing)) && n==0)
    
    @test (n=0; f(1,1,  z=1) == ((1,1),      (z=1,w=nothing)) && n==1)
    @test (n=0; f(1,1,  z=1) == ((1,1),      (z=1,w=nothing)) && n==0)
    
    @test (n=0; f(1,1,1,z=1) == ((1,1,1),    (z=1,w=nothing)) && n==1)
    @test (n=0; f(1,1,1,z=1) == ((1,1,1),    (z=1,w=nothing)) && n==0)
    
    # kwargs
    @test (n=0; f(1,z=1,w=1)     == ((1,nothing),(z=1,w=1))     && n==1)
    @test (n=0; f(1,z=1,w=1)     == ((1,nothing),(z=1,w=1))     && n==0)
    
    @test (n=0; f(1,z=1,w=1,p=1) == ((1,nothing),(z=1,w=1,p=1)) && n==1)
    @test (n=0; f(1,z=1,w=1,p=1) == ((1,nothing),(z=1,w=1,p=1)) && n==0)
    
    # cache clear
    Memoization.empty_cache!(f)
    @test (n=0; f(1,z=1) == ((1,nothing),(z=1,w=nothing)) && n==1)
    Memoization.empty_cache!(f)
    @test (n=0; f(1,z=1) == ((1,nothing),(z=1,w=nothing)) && n==1)
    
    # Dict vs. IdDict cache
    @memoize IdDict g(x) = (n+=1; x)
    @test (n=0; g([1,2])==[1,2] && n==1)
    @test (n=0; g([1,2])==[1,2] && n==1)
    @memoize   Dict g(x) = (n+=1; x)
    @test (n=0; g([1,2])==[1,2] && n==1)
    @test (n=0; g([1,2])==[1,2] && n==0)
    
    # redefinition
    @memoize h(x) = x
    @test h(2)==2 && h(2)==2
    @memoize h(x) = 2x
    @test h(2)==4 && h(2)==4
    
    # inference
    @test @inferred((@memoize foo(x) = x)(2)) == 2
    # this is broken because @inferred is failing despite @code_warntype giving that its inferred:
    @test_broken @inferred((@memoize foo(;x) = x)(x=2)) == 2
    
    
end
