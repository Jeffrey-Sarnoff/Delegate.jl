## Delegate.jl
#### Delegate functions into type fields or over iso-typed vars, with plain or iso-typed result.


Delegate unary, binary, trinary functions over a field in values of a type.  

Delegate unary, binary, trinary functions into fields of a type.

    The results may be `bare`, having the return type of delegated function.  
    The results may be `re-wrapped`, returning a value of the same type processed.

## exports

    # macros that return values with type that of the return type of the function delegated
    # (providing the delegated function result as directly computed)
    
    @delegateInto_1field1var,   @delegateInto_1field2vars,
    @delegateInto_2fields1var,  @delegateInto_3fields1var,
    @delegateInto_2fields2vars, 
    
    # macros that return values with type that of the parameter type of function delegated
    # (wrapping the delegated function result in the type used to dispach the delegated function)

    @delegateWith_1field1var,   @delegateWith_1field2vars,
    @delegateWith_2fields1var,  @delegateWith_3fields1var,
    @delegateWith_2fields2vars
    
    
## Use


```julia
    import Base: length, last
    
    type MyInts     elems::Vector{Int} end;
    type MyNums{T}  elems::Vector{T}   end;

    @delegateInto_1field1var MyInts.elems [ length,  last ];
    @delegateInto_1field1var MyNums.elems [ length,  last ];
       
    myInts = MyInts([5, 4, 3, 2, 1]);
    myNums = MyNums([1.0, 2.0, 3.0]);
    
    length(myInts), length(myNums) # 5, 3
    last(myInts), last(myNums)     # 1, 3.0
```

```julia
    import Base: (<), (<=)
    
    type MyInt  val::Int  end;

    @delegateInto_1field2vars MyInt.val [ (<), (<=) ];
  
    myFirstInt  = MyInt(3)
    mySecondInt = MyInt(7)
    
    myFirstInt  <  mySecondInt  # true
    mySecondInt <= myFirstInt   # false
```    

```julia
    import Base: hypot
    
    type RightTriangle   legA::Float64; legB::Float64;  end;

    @delegateInto_2fields1var RightTriangle legA legB [ hypot, ];
  
    myRightTriangle  = RightTriangle( 3.0, 4.0 )
    
    hypot(myRightTriangle)   #  5.0
```    

```julia
    import Base: (+), (-), (*)
    
    type MyInt  val::Int  end;

    @delegateWith_1field2vars MyInt.val [ (+), (-), (*) ];

    myFirstInt   = MyInt(3)
    mySecondInt  = MyInt(7)

    myIntAdds       = myFirstInt + mySecondInt    # MyInt(10)
    myIntSubtracts  = myFirstInt - mySecondInt    # MyInt(-4)
    myIntMultiplies = myFirstInt * mySecondInt    # MyInt(21) 
```    

```julia
    function renormalize(a::Float64, b::Float64)
        hi = a + b
        t = hi - a
        lo = (a - (hi - t)) + (b - t)
        hi, lo
    end
    
    type HiLo  hi::Float64; lo::Float64;   end;
    
    @delegateWith_2fields1var HiLo hi lo [ renormalize, ];
  
    myHiLo = renormalize( HiLo(12.555555555, 8000.333333333) ) 
    # HiLo(8012.89,4.44089e-14)
    showall(myHiLo)                                            
    # HiLo(8012.888888888,4.440892098500626e-14)
```

Please see the online help for each macro, or read the source file, for more examples.
