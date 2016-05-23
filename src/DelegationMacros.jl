module DelegationMacros

export @delegate, @delegate2, @delegateTyped, @delegateTyped2

#=
    based on original work by John Myles White and Toivo Henningsson
    (see the end of this file for source code references)
=#



"""

A macro for type field delegation over func{T}(arg::T)
    
  This
    
    import Base: length, last
    
    type MyInts     elems::Vector{Int} end;
    type MyNums{T}  elems::Vector{T}   end;

    @delegate MyInts.elems [ length,  last ];
    @delegate MyNums.elems [ length,  last ];
       
  Allows

    myInts = MyInts([5, 4, 3, 2, 1]);
    myNums = MyNums([1.0, 2.0, 3.0]);
    
    length(myInts), length(myNums) # 5, 3
    last(myInts), last(myNums)     # 1, 3.0

"""     
macro delegate(source, targets)
  typename = esc(source.args[1])
  fieldname = esc(Expr(:quote, source.args[2].args[1]))
  funcnames = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typename), args...) = ($funcname)(getfield(a,($fieldname)), args...)
               end
    end
  return Expr(:block, fdefs...)
end

# for methods that take two equi-typed source arguments

"""

A macro for type field delegation over func{T}(arg1::T, arg2::T)
    
  This

    import Base: (<), (<=)
    
    type MyInt  val::Int  end;

    @delegate2 MyInt.val [ (<), (<=) ];
  
  Allows
  
    myFirstInt  = MyInt(3)
    mySecondInt = MyInt(7)

    myFirstInt  <  mySecondInt  # true
    mySecondInt <= myFirstInt   # false

"""     
macro delegate2(sourceExemplar, targets)
  typesname = esc(sourceExemplar.args[1])
  fieldname = esc(Expr(:quote, sourceExemplar.args[2].args[1]))
  funcnames = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), b::($typesname), args...) = 
                   ($funcname)(getfield(a,($fieldname)), getfield(b,($fieldname)), args...)
               end
    end
  return Expr(:block, fdefs...)
end


# for methods that take one typed argument and return an iso-typed result

"""

A macro for type field delegation with a type wrapped result over func{T}(arg::T)
    
  This

    import Base: (-), abs
    
    type MyInt  val::Int  end;

    @delegateTyped MyInt.val [ (-), abs ];
  
  Allows
  
    myFirstInt  = MyInt(3)

    myFirstNegativeInt  = -myFirstInt              # MyInt(-3)
    myFirstIntRecovered = abs(myFirstNegativeInt)  # MyInt( 3)    

"""
macro delegateTyped(source, targets)
  typename = esc(source.args[1])
  fieldname = esc(Expr(:quote, source.args[2].args[1]))
  funcnames = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typename), args...) = 
                   ($typename)( ($funcname)(getfield(a,($fieldname)), args...) )
               end
    end
  return Expr(:block, fdefs...)
end


# for methods that take two equi-typed source arguments) and return an iso-typed result

"""

A macro for type field delegation with a type wrapped result over func{T}(arg1::T, arg2::T)

  This

    import Base: (+), (-), (*)
    
    type MyInt  val::Int  end;

    @delegateTyped2 MyInt.val [ (+), (-), (*) ];
  
  Allows
  
    myFirstInt   = MyInt(3)
    mySecondInt  = MyInt(7)

    myIntAdds       = myFirstInt + mySecondInt    # MyInt(10)
    myIntSubtracts  = myFirstInt - mySecondInt    # MyInt(-4)
    myIntMultiplies = myFirstInt * mySecondInt    # MyInt(21) 

"""
macro delegateTyped2(sourceExemplar, targets)
  typesname = esc(sourceExemplar.args[1])
  fieldname = esc(Expr(:quote, sourceExemplar.args[2].args[1]))
  funcnames = targets.args
  n = length(funcnames)
  fdefs = Array(Any, n)
  for i in 1:n
    funcname = esc(funcnames[i])
    fdefs[i] = quote
                 ($funcname)(a::($typesname), b::($typesname), args...) = 
                   ($typesname)( ($funcname)(getfield(a,($fieldname)), getfield(b,($fieldname)), args...) )
               end
    end
  return Expr(:block, fdefs...)
end


end # module DelegationMacros

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
