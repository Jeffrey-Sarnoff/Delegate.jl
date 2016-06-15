using Delegate
using Base.Test

import Base: (==), (<), (<=), isequal, isless, abs, iseven, isodd, (-), (+), (*), hypot;

import Delegate: @delegate_1field1var, @delegate_1field2vars, @delegate_2fields1var, 
                 @traject_1field1var,  @traject_1field2vars,  @traject_2fields1var;

type AnInt
   val::Int
end;   


@delegate_1field1var(  AnInt, val, [ iseven, isodd ] );

@delegate_1field2vars( AnInt, val, [ (==), (<), (<=), isequal, isless ] );

@traject_1field1var(   AnInt, val, [ (-), abs ] );

@traject_1field2vars(  AnInt, val, [ (+), (-), (*) ] );



a = AnInt(3);
b = AnInt(7);

@test iseven(a) == false;
@test isodd(b)  == true;

@test -a != a;
@test -(-a) == a;
@test abs(-a) == a;

@test (a <  b) == true;
@test (b <= a) == false;

@test (a + b) == AnInt(10);
@test (a - b) == AnInt(-4);
@test (a * b) == AnInt(21);




typealias SysFloat Union{Float64,Float32};

function renormalize{T<:SysFloat}(a::T, b::T)
    hi = a + b
    t = hi - a
    lo = (a - (hi - t)) + (b - t)
    hi, lo
end;

type HiLo{T<:SysFloat}
   hi::T
   lo::T
end;

function (==){T<:SysFloat}(a::HiLo{T}, b::HiLo{T})
    (a.hi == b.hi) & (a.lo == b.lo)
end;   

@traject_2fields1var( HiLo, hi, lo, [ renormalize, ] );

myHiLo = renormalize( HiLo(12.555555555, 8000.333333333) ); 
validHiLo = HiLo(8012.888888888, 4.440892098500626e-14);

@test myHiLo == validHiLo;
