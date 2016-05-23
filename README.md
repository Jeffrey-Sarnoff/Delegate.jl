## DelegationMacros.jl

Delegate unary, binary, trinary functions over a field in values of a type.  

Delegate unary, binary, trinary functions into fields of a type.

    The results may be `bare`, having the return type of delegated function.  
    The results may be `re-wrapped`, returning a value of the same type being processed.

## exports

    @delegate, @delegate2, 
    @delegate2fields, @delegate3fields,
    
    @delegateTyped, @delegateTyped2, 
    @delegateTyped2fields, @delegateTyped3fields

    
## Use

Please see the online help for each macro, or read the source file, for more examples.

```julia
    import Base: length, last
    
    type MyInts     elems::Vector{Int} end;
    type MyNums{T}  elems::Vector{T}   end;

    @delegate MyInts.elems [ length,  last ];
    @delegate MyNums.elems [ length,  last ];
       
    myInts = MyInts([5, 4, 3, 2, 1]);
    myNums = MyNums([1.0, 2.0, 3.0]);
    
    length(myInts), length(myNums) # 5, 3
    last(myInts), last(myNums)     # 1, 3.0
```

```julia
    import Base: (<), (<=)
    
    type MyInt  val::Int  end;

    @delegate2 MyInt.val [ (<), (<=) ];
  
    myFirstInt  = MyInt(3)
    mySecondInt = MyInt(7)
    
    myFirstInt  <  mySecondInt  # true
    mySecondInt <= myFirstInt   # false
```    

```julia
    import Base: hypot
    
    type RightTriangle   legA::Float64; legB::Float64;  end;

    @delegate2fields RightTriangle legA legB [ hypot, ];
  
    myRightTriangle  = RightTriangle( 3.0, 4.0 )
    
    hypot(myRightTriangle)   #  5.0
```    
