module Delegate

export @delegate_1field1var   ,  @delegate1f1v,   # aliases for @delegate_1field1var
       @delegate_1field2vars  ,  @delegate1f2v,
       @delegate_2fields1var  ,  @delegate2f1v,
       @delegate_3fields1var  ,  @delegate3f1v,
       @delegate_2fields2vars ,  @delegate2f2v,
       @traject_1field1var    ,  @traject1f1v,    # aliases for @traject_1field1var
       @traject_1field2vars   ,  @traject1f2v,
       @traject_2fields1var   ,  @traject2f1v,
       @traject_3fields1var   ,  @traject3f1v,
       @traject_2fields2vars  ,  @traject2f2v


#=
    based on original work by John Myles White and Toivo Henningsson
    (see the end of this file for source code references)
=#



"""

A macro for type field delegation over func{T}(arg::T)
    
    import Base: length, last
    
    type AnInts     elems::Vector{Int} end;
    type MyNums{T}  elems::Vector{T}   end;
	
    @delegate_1field1var( AnInts, elems, [ length,  last ] );
    @delegate_1field1var( MyNums, elems, [ length,  last ] );
    
	myInts = AnInts([5, 4, 3, 2, 1]);
    myNums = MyNums([1.0, 2.0, 3.0]);
    
    length(myInts), length(myNums)   # 5, 3
    last(myInts),   last(myNums)     # 1, 3.0

"""
macro delegate_1field1var(sourcetype, field1, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), args...) = ($funcname)(getfield(a,($field1name)), args...)
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @delegate_1field1var
"""
macro delegate1f1v(sourcetype, field1, targets)
    quote
        @delegate_1field1var($(esc(sourcetype)), $(esc(field1)), $(esc(targets)))
    end
end

"""
see @delegate_1field1var
"""
macro delegate1f1v(sourcetype, field1, targets)
    quote
        @delegate_1field1var($(esc(sourcetype)), $(esc(field1)), $(esc(targets)))
    end
end

# for methods that take two equi-typed source arguments

"""

A macro for type field delegation over func{T}(arg1::T, arg2::T)

    import Base: (<), (<=)
    
    type AnInt  val::Int  end;

    @delegate_1field2vars( AnInt, val, [ (<), (<=) ] );

    myFirstInt  = AnInt(3)
    mySecondInt = AnInt(7)

    myFirstInt  <  mySecondInt  # true
    mySecondInt <= myFirstInt   # false

"""     
macro delegate_1field2vars(sourcetype, field1, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), b::($typesname), args...) = 
                   ($funcname)(getfield(a,($field1name)), getfield(b,($field1name)), args...)
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @delegate_1field2vars
"""
macro delegate1f2v(sourcetype, field1, targets)
    quote
        @delegate_1field2vars($(esc(sourcetype)), $(esc(field1)), $(esc(targets)))
    end
end

# for methods that use multiple fields from the source type

"""

A macro for type field delegation over two fields of T func{T}(arg::T)
    
    import Base: hypot
    
    type RightTriangle   legA::Float64; legB::Float64;  end;
    @delegate_2fields1var( RightTriangle, legA, legB, [ hypot, ] );
  
    myRightTriangle  = RightTriangle( 3.0, 4.0 )
    
    hypot(myRightTriangle)   #  5.0

"""     
macro delegate_2fields1var(sourcetype, field1, field2, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  field2name = esc(Expr(:quote, field2))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), args...) = 
                   ($funcname)(getfield(a, ($field1name)), getfield(a, ($field2name)), args...)
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @delegate_2fieldsd1var
"""
macro delegate2f1v(sourcetype, field1, field2, targets)
    quote
        @delegate_2field1var($(esc(sourcetype)), $(esc(field1)), $(esc(field2)), $(esc(targets)))
    end
end


"""

A macro for type field delegation over three fields of T func{T}(arg::T)
    
    function add3{T<:Float64}(a::T, b::T, c::T)
        ab   = a+b
        hi   = ab+c
        lo   = a-(ab-b)
        lo  += b-(ab-a)
        lo  += c-(hi-ab)
        hi, lo
    end    
    
    type ThreeFloats a::Float64; B::Float64;  C::Float64;  end;
    @delegate_3fields1var( ThreeFloats, a, b, c, [ add3, ] );
  
    myThreeFloats = ThreeFloats( sqrt(2.), sqrt(22.), sqrt(15.) )
    
    add3(myThreeFloats)   #  (9.977612668403943,-6.661338147750939e-16)
    
"""     
macro delegate_3fields1var(sourcetype, field1, field2, field3, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  field2name = esc(Expr(:quote, field2))
  field3name = esc(Expr(:quote, field3))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), args...) = 
                   ($funcname)(getfield(a, ($field1name)), getfield(a, ($field2name)), getfield(a, ($field3name)), args...)
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @delegate_3fields1var
"""
macro delegate3f1v(sourcetype, field1, field2, field3, targets)
    quote
        @delegate_3fields1var($(esc(sourcetype)), $(esc(field1)), $(esc(field2)), $(esc(field3)), $(esc(targets)))
    end
end


"""
see help for @delegate_1field2vars
"""
macro delegate_2fields2vars(sourcetype, field1, field2, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  field2name = esc(Expr(:quote, field2))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), b::($typesname), args...) = 
                     ($funcname)(getfield(a, ($field1name)), getfield(a, ($field2name)),
                                 getfield(b, ($field1name)), getfield(b, ($field2name)), 
                                 args...)
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @delegate_2fields2vars
"""
macro delegate2f2v(sourcetype, field1, field2, targets)
    quote
        @delegate_2fields2vars($(esc(sourcetype)), $(esc(field1)), $(esc(field2)), $(esc(targets)))
    end
end



# for methods that take one typed argument and return an iso-typed result

"""

A macro for type field delegation with an iso-typed result over func{T}(arg::T)
    
    import Base: (-), abs
    
    type AnInt  val::Int  end;

    @traject_1field1var( AnInt, val, [ (-), abs ] );

    myFirstInt     = AnInt(3)
    myIntNegates   = -myFirstInt              # AnInt(-3)
    myIntAbsValues = abs(myIntNegates)        # AnInt( 3)    

"""
macro traject_1field1var(sourcetype, field1, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), args...) = 
                   ($typesname)( ($funcname)(getfield(a,($field1name)), args...) )
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @traject_1field1var
"""
macro traject1f1v(sourcetype, field1, targets)
    quote
        @traject_1field1var($(esc(sourcetype)), $(esc(field1)), $(esc(targets)))
    end
end



# for methods that take two equi-typed source arguments) and return an iso-typed result

"""

A macro for type field delegation with an iso-typed result over func{T}(arg1::T, arg2::T)

    import Base: (+), (-), (*)
    
    type AnInt  val::Int  end;

    @traject_1field2vars( AnInt, val, [ (+), (-), (*) ] );

    myFirstInt   = AnInt(3)
    mySecondInt  = AnInt(7)

    myIntAdds       = myFirstInt + mySecondInt    # AnInt(10)
    myIntSubtracts  = myFirstInt - mySecondInt    # AnInt(-4)
    myIntMultiplies = myFirstInt * mySecondInt    # AnInt(21) 

"""
macro traject_1field2vars(sourcetype, field1, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), b::($typesname), args...) = 
                   ($typesname)( ($funcname)(getfield(a,($field1name)), getfield(b,($field1name)), args...) )
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @traject_1field2vars
"""
macro traject1f2v(sourcetype, field1, targets)
    quote
        @traject_1field2var($(esc(sourcetype)), $(esc(field1)), $(esc(targets)))
    end
end


# for methods that use two fields of the source type and return an iso-typed result

"""

A macro for type field delegation with an iso-typed result over two fields of T func{T}(arg::T)

    function renormalize(a::Float64, b::Float64)
        hi = a + b
        t = hi - a
        lo = (a - (hi - t)) + (b - t)
        hi,lo
    end

    type HiLo  hi::Float64; lo::Float64;   end;
    
    @traject_2fields1var( HiLo, hi, lo, [ renormalize, ] );

    myHiLo = renormalize( HiLo(12.555555555, 8000.333333333) ) # HiLo(8012.89,4.44089e-14)
    showall(myHiLo)     # HiLo(8012.888888888,4.440892098500626e-14)
"""
macro traject_2fields1var(sourcetype, field1, field2, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  field2name = esc(Expr(:quote, field2))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), args...) = 
                    ($typesname)( ($funcname)(getfield(a, ($field1name)), getfield(a, ($field2name)), args...)... )
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @traject_2fields1var
"""
macro traject2f1v(sourcetype, field1, field2, targets)
    quote
        @traject_2fields1var($(esc(sourcetype)), $(esc(field1)), $(esc(field2)), $(esc(targets)))
    end
end


"""
see help for @traject_2fields1var
"""
macro traject_3fields1var(sourcetype, field1, field2, field3, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  field2name = esc(Expr(:quote, field2))
  field3name = esc(Expr(:quote, field3))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), args...) = 
                    ($typesname)( ($funcname)(getfield(a, ($field1name)), getfield(a, ($field2name)), getfield(a, ($field3name)), args...)... )
               end
    end
  return Expr(:block, fdefs...)
end


"""
see @traject_3fields1var
"""
macro traject3f1v(sourcetype, field1, field2, field3, targets)
    quote
        @traject_3fields1var($(esc(sourcetype)), $(esc(field1)), $(esc(field2)), $(esc(field3)), $(esc(targets)))
    end
end


"""
see help for @traject_1field2vars
"""
macro traject_2fields2vars(sourcetype, field1, field2, targets)
  typesname  = esc( :($sourcetype) )
  field1name = esc(Expr(:quote, field1))
  field2name = esc(Expr(:quote, field2))
  funcnames  = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), b::($typesname), args...) = 
                    ($typesname)( ($funcname)(getfield(a, ($field1name)), getfield(a, ($field2name)),
                                              getfield(b, ($field1name)), getfield(b, ($field2name)), 
                                              args...)... )
               end
    end
  return Expr(:block, fdefs...)
end

"""
see @traject_2fields2vars
"""
macro traject2f2v(sourcetype, field1, field2, targets)
    quote
        @traject_2fields2vars($(esc(sourcetype)), $(esc(field1)), $(esc(field2)), $(esc(targets)))
    end
end




end # module Delegate

#=
    initial implementation
    (description and logic from https://gist.github.com/johnmyleswhite/5225361)
    additional macro text from
      https://github.com/JuliaLang/DataStructures.jl/blob/master/src/delegate.jl
     
    and from Toivo for delegation with nary ops
    (https://groups.google.com/forum/#!msg/julia-dev/MV7lYRgAcB0/-tS50TreaPoJ)
    
    julia> type T
               x
           end
    julia> import Base.sin, Base.cos
    julia> for f in (:+, :- )    # delegate binary + and - to T.x
               @eval $f(a::T, b::T) = $f(a.x, b.x)
           end
    julia> for f in (:sin, :cos) # delegate sin and cos
               @eval $f(a::T) = $f(a.x)
           end
=#
