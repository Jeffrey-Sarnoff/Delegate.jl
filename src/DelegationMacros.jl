#=
    based on original work by John Myles White and Toivo Henningsson
    (see end of file for source code refs)
=#

"""
    macros for doing delegation
    import Base: length, last, (abs), (+)
    
    Given these types
    
       type MyInt          type MyInts                   type MyNums{T}
          i::Int              elems::Vector{Int}           elems::T
       end                 end                           end
        
    These macro calls
 
       @delegateTyped MyInt.i      [ abs, ]
       @delegateTyped2 MyInt.i     [ (+), ]
       
       @delegate MyInts.elems [ length,  last ]
       @delegate MyNums.elems [ length,  last ]
       
    produces these blocks of expressions
 
      abs(a::MyInt)           = MyInt( abs( getfield(a, :i) ) )
      (+)(a::MyInt, b::MyInt) = MyInt( (+)( getfield(a, :i), getfield(b, :i) ) ) 
 
      last( a::MyInts)  = last( getfield(a, :elems) )
      length(a::MyInts) = length( getfield(a, :elems) )
 
      last( a::MyNums)  = last( getfield(a, :elems) )
      length(a::MyNums) = length( getfield(a, :elems) )
  
    and allows
    
      myFirstInt = MyInt(-1)
      mySecondInt = MyInt(2)
      abs(myFirstInt)          # MyInt(1)
      myFirstInt + mySecondInt # MyInt(1)
      
      myInts = MyInts([5, 4, 3, 2, 1])
      myNums = MyNums([1.0, 2.0, 3.0])
      
      length(myInts) # 5
      length(myNums) # 3
      
      last(myInts)  # 1
      last(myNums)  # 3.0
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
