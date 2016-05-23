## Delegate.jl

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

```julia
    import Base: (+), (-), (*)
    
    type MyInt  val::Int  end;

    @delegateTyped2 MyInt.val [ (+), (-), (*) ];

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
    
    @delegateTyped2fields HiLo hi lo [ renormalize, ];
  
    myHiLo = renormalize( HiLo(12.555555555, 8000.333333333) ) # HiLo(8012.89,4.44089e-14)
    showall(myHiLo)                                            # HiLo(8012.888888888,4.440892098500626e-14)
```

Please see the online help for each macro, or read the source file, for more examples.
