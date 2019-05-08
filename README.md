## Delegate.jl

### this package has been replaced by [TypedDelegation.jl](https://github.com/JuliaArbTypes/TypedDelegation.jl)

```Ruby
                                    Jeffrey Sarnoff © 2016-Mar-22 in New York City
```  
###### Delegate functions into field[s] of typed variable[s] or through field[s] of typed variable[s].  
<br>

      *family*      | *type of resulting value*
      :---          | :---: 
      __@delegate__ | the result is `bare`, having the return type of delegated function
                    |  
      __@traject__  | the result is `wrapped`, returning a value of the same type processed


#### Use

```julia
    import Base: (<), (<=), isequal, isless
    
    type MyInt  val::Int  end;

    # IMPORTANT: include isless, isequal with any of ==,!=,<,<=,>=,>
    @delegate_1field2vars( MyInt, val, [ (<), (<=), isequal, isless ] );
  
    myFirstInt  = MyInt(3)
    mySecondInt = MyInt(7)
    
    myFirstInt  <  mySecondInt  # true
    mySecondInt <= myFirstInt   # false
```    

```julia
    import Base: log, tan
    
    type MyFloat  val::Float64  end;

    @traject_1field1var( MyFloat, val, [ log, tan ] );

    myFirstFloat   = MyFloat(1.0)
    mySecondFloat  = MyFloat(0.25)

    myFloatLogs    = log(myFirsFloat)    # MyFloat(0.0)
    myFloatTans    = tan(mySecondFloat)  # MyFloat(0.5463024898437905)
```    

```julia
    import Base: (+), (-), (*)
    
    type MyInt  val::Int  end;

    @traject_1field2vars( MyInt, val, [ (+), (-), (*) ] );

    myFirstInt   = MyInt(3)
    mySecondInt  = MyInt(7)

    myIntAdds       = myFirstInt + mySecondInt    # MyInt(10)
    myIntSubtracts  = myFirstInt - mySecondInt    # MyInt(-4)
    myIntMultiplies = myFirstInt * mySecondInt    # MyInt(21) 
```    

```julia
    import Base: hypot
    
    type RightTriangle   legA::Float64; legB::Float64;  end;

    @delegate_2fields1var( RightTriangle, legA, legB, [ hypot, ] );
  
    myRightTriangle  = RightTriangle( 3.0, 4.0 )
    
    hypot(myRightTriangle)   #  5.0
```    

```julia
    function renormalize(a::Float64, b::Float64)
        hi = a + b
        t = hi - a
        lo = (a - (hi - t)) + (b - t)
        hi, lo
    end
    
    type HiLo  hi::Float64; lo::Float64;   end;
    
    @traject_2fields1var HiLo hi lo [ renormalize, ];
  
    myHiLo = renormalize( HiLo(12.555555555, 8000.333333333) ) 
    # HiLo(8012.89,4.44089e-14)
    showall(myHiLo)                                            
    # HiLo(8012.888888888,4.440892098500626e-14)
```

```julia
    import Base: length, last
    
    type MyInts     elems::Vector{Int} end;
    type MyNums{T}  elems::Vector{T}   end;

    @delegate_1field1var( MyInts, elems, [ length,  last ] );
    @delegate_1field1var( MyNums, elems, [ length,  last ] );
       
    myInts = MyInts([5, 4, 3, 2, 1]);
    myNums = MyNums([1.0, 2.0, 3.0]);
    
    length(myInts), length(myNums) # 5, 3
    last(myInts), last(myNums)     # 1, 3.0
```

#### Exports

    # macros that return values typed as the function delegated returns
    # (providing the delegated function result as directly computed)
    
    @delegate_1field1var,   @delegate_1field2vars,
    @delegate_2fields1var,  @delegate_3fields1var,
    @delegate_2fields2vars, 
    
    # macros that return values typed as the parameter[s] of the delegation
    # (wrapping the delegated function result in the dispatching type)

    @traject_1field1var,   @traject_1field2vars,
    @traject_2fields1var,  @traject_3fields1var,
    @traject_2fields2vars
    
    # aliases
    
    @delegate1f1v      # aliases @delegate_1field1var
    @traject1f1v       # aliases @traject_1field1var
                       # others patterned as
    @delgate1f2v       # aliases @delegate_1field2vars       
    @traject2f1v       # aliases @traject_2fields1var  


Please see the online help for each macro, or read the source file, for more examples.  

#### Credits

This module is based on original work by John Myles White and Toivo Henningsson.  
Relevant webpage references are given in src/Delegate.jl, at the end of the file.
 
</body>
</html>
