###############################################################################
#
#   AbsSeries.jl : Power series over rings, capped absolute precision
#
###############################################################################

export O, abs_series, abs_series_type, max_precision, pol_length, precision,
       valuation

###############################################################################
#
#   Data type and parent object methods
#
###############################################################################

@doc Markdown.doc"""
    O(a::AbsSeriesElem{T}) where T <: RingElement

Return $0 + O(x^\mathrm{deg}(a))$. Usually this function is called with $x^n$
as parameter. Then the function returns the power series $0 + O(x^n)$, which
can be used to set the precision of a power series when constructing it.
"""
function O(a::AbsSeriesElem{T}) where T <: RingElement
   if iszero(a)
      return deepcopy(a)    # 0 + O(x^n)
   end
   prec = length(a) - 1
   return parent(a)(Array{T}(undef, 0), 0, prec)
end

###############################################################################
#
#   Basic manipulation
#
###############################################################################

length(x::AbsSeriesElem) = x.length

pol_length(x::AbsSeriesElem) = length(x)

precision(x::AbsSeriesElem) = x.prec

iszero(a::SeriesElem) = length(a) == 0

function isone(a::AbsSeriesElem)
   return (length(a) == 1 && isone(coeff(a, 0))) || precision(a) == 0
end

@doc Markdown.doc"""
    isgen(a::AbsSeriesElem)

Return `true` if the given power series is arithmetically equal to the
generator of its power series ring to its current precision, otherwise return
`false`.
"""
function isgen(a::AbsSeriesElem)
   return (valuation(a) == 1 && length(a) == 2 && isone(coeff(a, 1))) ||
           precision(a) == 0
end

isunit(a::AbsSeriesElem) = valuation(a) == 0 && isunit(coeff(a, 0))

@doc Markdown.doc"""
    valuation(a::AbsSeriesElem)

Return the valuation of the given power series, i.e. the degree of the first
nonzero term (or the precision if it is arithmetically zero).
"""
function valuation(a::AbsSeriesElem)
   for i = 1:length(a)
      if !iszero(coeff(a, i - 1))
         return i - 1
      end
   end
   return precision(a)
end

function Base.hash(a::AbsSeriesElem, h::UInt)
   b = 0xb44d6896204881f3%UInt
   for i in 0:length(a) - 1
      b = xor(b, hash(coeff(a, i), h), h)
      b = (b << 1) | (b >> (sizeof(Int)*8 - 1))
   end
   return b
end

###############################################################################
#
#   Similar and zero
#
###############################################################################

function similar(x::AbsSeriesElem, R::Ring, max_prec::Int,
                                 var::Symbol=var(parent(x)); cached::Bool=true)
   TT = elem_type(R)
   V = Vector{TT}(undef, 0)
   p = Generic.AbsSeries{TT}(V, 0, max_prec)
   # Default similar is supposed to return a Generic series
   p.parent = Generic.AbsSeriesRing{TT}(R, max_prec, var, cached)
   return p
end

function similar(x::AbsSeriesElem, R::Ring,
                                 var::Symbol=var(parent(x)); cached::Bool=true)
   return similar(x, R, max_precision(parent(x)), var; cached = cached)
end

function similar(x::AbsSeriesElem, max_prec::Int,
                                 var::Symbol=var(parent(x)); cached::Bool=true)
   return similar(x, base_ring(x), max_prec, var; cached=cached)
end

function similar(x::AbsSeriesElem,
                                 var::Symbol=var(parent(x)); cached::Bool=true)
   return similar(x, base_ring(x),
                  max_precision(parent(x)), var; cached=cached)
end

function similar(x::AbsSeriesElem, R::Ring, max_prec::Int,
                                                var::String; cached::Bool=true)
   return similar(x, R, max_prec, Symbol(var); cached=cached)
end

function similar(x::AbsSeriesElem, R::Ring, var::String; cached::Bool=true)
   return similar(x, R, max_precision(parent(x)), Symbol(var); cached=cached)
end

function similar(x::AbsSeriesElem, max_prec::Int,
                                                var::String; cached::Bool=true)
   return similar(x, base_ring(x), max_prec, Symbol(var); cached=cached)
end

function similar(x::AbsSeriesElem, var::String; cached::Bool=true)
   return similar(x, base_ring(x),
                  max_precision(parent(x)), Symbol(var); cached=cached)
end

function zero(a::AbsSeriesElem, R::Ring, max_prec::Int,
                                 var::Symbol=var(parent(a)); cached::Bool=true)
   return similar(a, R, max_prec, var; cached=cached)
end

function zero(a::AbsSeriesElem, R::Ring,
                                 var::Symbol=var(parent(a)); cached::Bool=true)
   return similar(a, R, max_precision(parent(a)), var; cached=cached)
end

function zero(a::AbsSeriesElem, max_prec::Int,
                                 var::Symbol=var(parent(a)); cached::Bool=true)
   return similar(a, base_ring(a), max_prec, var; cached=cached)
end

zero(a::AbsSeriesElem, var::Symbol=var(parent(a)); cached::Bool=true) =
   similar(a, base_ring(a), max_precision(parent(a)), var; cached=cached)

function zero(a::AbsSeriesElem, R::Ring, max_prec::Int,
                                                var::String; cached::Bool=true)
   return zero(a, R, max_prec, Symbol(var); cached=cached)
end

zero(a::AbsSeriesElem, R::Ring, var::String; cached::Bool=true) =
   zero(a, R, max_precision(parent(a)), Symbol(var); cached=cached)

zero(a::AbsSeriesElem, max_prec::Int, var::String; cached::Bool=true) =
   zero(a, base_ring(a), max_prec, Symbol(var); cached=cached)

zero(a::AbsSeriesElem, var::String; cached::Bool=true) =
   zero(a, base_ring(a), max_precision(parent(a)), Symbol(var); cached=cached)

###############################################################################
#
#   abs_series constructor
#
###############################################################################

function abs_series(R::Ring, arr::Vector{T}, len::Int, prec::Int, var::AbstractString="x"; max_precision::Int=prec, cached::Bool=true) where T
   prec < len && error("Precision too small for given data")
   TT = elem_type(R)
   coeffs = T == Any && length(arr) == 0 ? elem_type(R)[] : map(R, arr)
   p = Generic.AbsSeries{TT}(coeffs, len, prec)
   # Default is supposed to return a Generic polynomial
   p.parent = Generic.AbsSeriesRing{TT}(R, max_precision, Symbol(var), cached)
   return p
end

###############################################################################
#
#   AbstractString I/O
#
###############################################################################

function expressify(a::AbsSeriesElem,
                                    x = var(parent(a)); context = nothing)
    sum = Expr(:call, :+)
    v = valuation(a)
    len = length(a)

    for k in 0:len - 1
        c = coeff(a, k)
        if !iszero(c)
            if k == 0
                xk = 1
            elseif k == 1
                xk = x
            else
                xk = Expr(:call, :^, x, k)
            end
            if isone(c)
                push!(sum.args, Expr(:call, :*, xk))
            else
                push!(sum.args, Expr(:call, :*, expressify(c, context = context), xk))
            end
        end
    end
    push!(sum.args, Expr(:call, :O, Expr(:call, :^, x, precision(a))))
    return sum
end

###############################################################################
#
#   Unary operators
#
###############################################################################

function -(a::AbsSeriesElem)
   len = length(a)
   z = parent(a)()
   z = set_precision!(z, precision(a))
   fit!(z, len)
   for i = 1:len
      z = setcoeff!(z, i - 1, -coeff(a, i - 1))
   end
   return z
end

###############################################################################
#
#   Binary operators
#
###############################################################################

function +(a::AbsSeriesElem{T}, b::AbsSeriesElem{T}) where T <: RingElement
   check_parent(a, b)
   lena = length(a)
   lenb = length(b)
   prec = min(precision(a), precision(b))
   lena = min(lena, prec)
   lenb = min(lenb, prec)
   lenz = max(lena, lenb)
   z = parent(a)()
   fit!(z, lenz)
   z = set_precision!(z, prec)
   i = 1
   while i <= min(lena, lenb)
      z = setcoeff!(z, i - 1, coeff(a, i - 1) + coeff(b, i - 1))
      i += 1
   end
   while i <= lena
      z = setcoeff!(z, i - 1, deepcopy(coeff(a, i - 1)))
      i += 1
   end
   while i <= lenb
      z = setcoeff!(z, i - 1, deepcopy(coeff(b, i - 1)))
      i += 1
   end
   z = set_length!(z, normalise(z, i - 1))
   return z
end

function -(a::AbsSeriesElem{T}, b::AbsSeriesElem{T}) where T <: RingElement
   check_parent(a, b)
   lena = length(a)
   lenb = length(b)
   prec = min(precision(a), precision(b))
   lena = min(lena, prec)
   lenb = min(lenb, prec)
   lenz = max(lena, lenb)
   z = parent(a)()
   fit!(z, lenz)
   z = set_precision!(z, prec)
   i = 1
   while i <= min(lena, lenb)
      z = setcoeff!(z, i - 1, coeff(a, i - 1) - coeff(b, i - 1))
      i += 1
   end
   while i <= lena
      z = setcoeff!(z, i - 1, deepcopy(coeff(a, i - 1)))
      i += 1
   end
   while i <= lenb
      z = setcoeff!(z, i - 1, -coeff(b, i - 1))
      i += 1
   end
   z = set_length!(z, normalise(z, i - 1))
   return z
end

function *(a::AbsSeriesElem{T}, b::AbsSeriesElem{T}) where T <: RingElement
   check_parent(a, b)

   lena = length(a)
   lenb = length(b)

   aval = valuation(a)
   bval = valuation(b)

   prec = min(precision(a) + bval, precision(b) + aval)
   prec = min(prec, max_precision(parent(a)))

   lena = min(lena, prec)
   lenb = min(lenb, prec)

   if lena == 0 || lenb == 0
      return parent(a)(Array{T}(undef, 0), 0, prec)
   end
   t = base_ring(a)()
   lenz = min(lena + lenb - 1, prec)
   d = Array{T}(undef, lenz)
   for i = 1:min(lena, lenz)
      d[i] = coeff(a, i - 1)*coeff(b, 0)
   end
   if lenz > lena
      for j = 2:min(lenb, lenz - lena + 1)
          d[lena + j - 1] = coeff(a, lena - 1)*coeff(b, j - 1)
      end
   end
   for i = 1:lena - 1
      if lenz > i
         for j = 2:min(lenb, lenz - i + 1)
            t = mul!(t, coeff(a, i - 1), coeff(b, j - 1))
            d[i + j - 1] = addeq!(d[i + j - 1], t)
         end
      end
   end
   z = parent(a)(d, lenz, prec)
   z = set_length!(z, normalise(z, lenz))
   return z
end

###############################################################################
#
#   Ad hoc binary operators
#
###############################################################################

function *(a::T, b::AbsSeriesElem{T}) where {T <: RingElem}
   len = length(b)
   z = parent(b)()
   fit!(z, len)
   z = set_precision!(z, precision(b))
   for i = 1:len
      z = setcoeff!(z, i - 1, a*coeff(b, i - 1))
   end
   z = set_length!(z, normalise(z, len))
   return z
end

function *(a::Union{Integer, Rational, AbstractFloat}, b::AbsSeriesElem)
   len = length(b)
   z = parent(b)()
   fit!(z, len)
   z = set_precision!(z, precision(b))
   for i = 1:len
      z = setcoeff!(z, i - 1, a*coeff(b, i - 1))
   end
   z = set_length!(z, normalise(z, len))
   return z
end

*(a::AbsSeriesElem{T}, b::T) where {T <: RingElem} = b*a

*(a::AbsSeriesElem, b::Union{Integer, Rational, AbstractFloat}) = b*a

###############################################################################
#
#   Shifting
#
###############################################################################

@doc Markdown.doc"""
    shift_left(x::AbsSeriesElem{T}, n::Int) where T <: RingElement

Return the power series $x$ shifted left by $n$ terms, i.e. multiplied by
$x^n$.
"""
function shift_left(x::AbsSeriesElem{T}, n::Int) where T <: RingElement
   n < 0 && throw(DomainError(n, "n must be >= 0"))
   xlen = length(x)
   prec = precision(x) + n
   prec = min(prec, max_precision(parent(x)))
   if xlen == 0
      z = zero(parent(x))
      z = set_precision!(z, prec)
      return z
   end
   zlen = min(prec, xlen + n)
   z = parent(x)()
   fit!(z, zlen)
   z = set_precision!(z, prec)
   for i = 1:n
      z = setcoeff!(z, i - 1, zero(base_ring(x)))
   end
   for i = 1:xlen
      z = setcoeff!(z, i + n - 1, coeff(x, i - 1))
   end
   z = set_length!(z, normalise(z, zlen))
   return z
end

@doc Markdown.doc"""
    shift_right(x::AbsSeriesElem{T}, n::Int) where T <: RingElement

Return the power series $x$ shifted right by $n$ terms, i.e. divided by
$x^n$.
"""
function shift_right(x::AbsSeriesElem{T}, n::Int) where T <: RingElement
   n < 0 && throw(DomainError(n, "n must be >= 0"))
   xlen = length(x)
   if n >= xlen
      z = zero(parent(x))
      z = set_precision!(z, max(0, precision(x) - n))
      return z
   end
   z = parent(x)()
   fit!(z, xlen - n)
   z = set_precision!(z, precision(x) - n)
   for i = 1:xlen - n
      z = setcoeff!(z, i - 1, coeff(x, i + n - 1))
   end
   return z
end

###############################################################################
#
#   Truncation
#
###############################################################################

@doc Markdown.doc"""
    truncate(a::AbsSeriesElem{T}, n::Int) where T <: RingElement

Return $a$ truncated to $n$ terms.
"""
function truncate(a::AbsSeriesElem{T}, n::Int) where T <: RingElement
   n < 0 && throw(DomainError(n, "n must be >= 0"))
   len = length(a)
   if precision(a) <= n
      return a
   end
   z = parent(a)()
   fit!(z, n)
   z = set_precision!(z, n)
   for i = 1:min(n, len)
      z = setcoeff!(z, i - 1, coeff(a, i - 1))
   end
   for i = len + 1:n
      z = setcoeff!(z, i - 1, zero(base_ring(a)))
   end
   z = set_length!(z, normalise(z, n))
   return z
end

###############################################################################
#
#   Powering
#
###############################################################################

@doc Markdown.doc"""
    ^(a::AbsSeriesElem{T}, b::Int) where T <: RingElement

Return $a^b$. We require $b \geq 0$.
"""
function ^(a::AbsSeriesElem{T}, b::Int) where T <: RingElement
   b < 0 && throw(DomainError(b, "Can't take negative power"))
   # special case powers of x for constructing power series efficiently
   if b == 0
      z = one(parent(a))
      z = set_precision!(z, precision(a))
      return z
   elseif precision(a) > 0 && isgen(a) && b > 0
      # arithmetic operators must not introduce new aliasing
      return deepcopy(shift_left(a, b - 1))
   elseif length(a) == 1
      z = parent(a)(coeff(a, 0)^b)
      z = set_precision!(z, precision(a))
      return z
   elseif b == 1
      return deepcopy(a)
   else
      bit = ~((~UInt(0)) >> 1)
      while (UInt(bit) & b) == 0
         bit >>= 1
      end
      z = a
      bit >>= 1
      while bit !=0
         z = z*z
         if (UInt(bit) & b) != 0
            z *= a
         end
         bit >>= 1
      end
      return z
   end
end

###############################################################################
#
#   Comparison
#
###############################################################################

@doc Markdown.doc"""
    ==(x::AbsSeriesElem{T}, y::AbsSeriesElem{T}) where T <: RingElement

Return `true` if $x == y$ arithmetically, otherwise return `false`. Recall
that power series to different precisions may still be arithmetically
equal to the minimum of the two precisions.
"""
function ==(x::AbsSeriesElem{T}, y::AbsSeriesElem{T}) where T <: RingElement
   b = check_parent(x, y, false)
   !b && return false

   prec = min(precision(x), precision(y))
   m1 = min(length(x), length(y))
   m2 = max(length(x), length(y))
   m1 = min(m1, prec)
   m2 = min(m2, prec)
   if length(x) >= m2
      for i = m1 + 1: m2
         if !iszero(coeff(x, i - 1))
            return false
          end
      end
   else
      for i = m1 + 1: m2
         if !iszero(coeff(y, i - 1))
            return false
          end
      end
   end
   for i = 1:m1
      if coeff(x, i - 1) != coeff(y, i - 1)
         return false
      end
   end
   return true
end

@doc Markdown.doc"""
    isequal(x::AbsSeriesElem{T}, y::AbsSeriesElem{T}) where T <: RingElement

Return `true` if $x == y$ exactly, otherwise return `false`. Only if the
power series are precisely the same, to the same precision, are they declared
equal by this function.
"""
function isequal(x::AbsSeriesElem{T}, y::AbsSeriesElem{T}) where T <: RingElement
   if parent(x) != parent(y)
      return false
   end
   if precision(x) != precision(y) || length(x) != length(y)
      return false
   end
   for i = 1:length(x)
      if !isequal(coeff(x, i - 1), coeff(y, i - 1))
         return false
      end
   end
   return true
end

###############################################################################
#
#   Approximation
#
###############################################################################

function Base.isapprox(f::AbsSeriesElem, g::AbsSeriesElem; atol::Real=sqrt(eps()))
   check_parent(f, g)
   nmin = min(precision(f), precision(g))
   i = 1
   while i <= nmin
      if !isapprox(coeff(f, i - 1), coeff(g, i - 1); atol=atol)
         return false
      end
      i += 1
   end
   return true
end

###############################################################################
#
#   Ad hoc comparison
#
###############################################################################

@doc Markdown.doc"""
    ==(x::AbsSeriesElem{T}, y::T) where {T <: RingElem}

Return `true` if $x == y$ arithmetically, otherwise return `false`.
"""
==(x::AbsSeriesElem{T}, y::T) where {T <: RingElem} = precision(x) == 0 ||
      ((length(x) == 0 && iszero(y)) || (length(x) == 1 && coeff(x, 0) == y))

@doc Markdown.doc"""
    ==(x::T, y::AbsSeriesElem{T}) where {T <: RingElem}

Return `true` if $x == y$ arithmetically, otherwise return `false`.
"""
==(x::T, y::AbsSeriesElem{T}) where {T <: RingElem} = y == x

@doc Markdown.doc"""
    ==(x::AbsSeriesElem, y::Union{Integer, Rational, AbstractFloat})

Return `true` if $x == y$ arithmetically, otherwise return `false`.
"""
==(x::AbsSeriesElem, y::Union{Integer, Rational, AbstractFloat}) = precision(x) == 0 || ((length(x) == 0 && iszero(y))
                                       || (length(x) == 1 && coeff(x, 0) == y))

@doc Markdown.doc"""
    ==(x::Union{Integer, Rational, AbstractFloat}, y::AbsSeriesElem)

Return `true` if $x == y$ arithmetically, otherwise return `false`.
"""
==(x::Union{Integer, Rational, AbstractFloat}, y::AbsSeriesElem) = y == x

###############################################################################
#
#   Exact division
#
###############################################################################

function divexact(x::AbsSeriesElem{T}, y::AbsSeriesElem{T}) where T <: RingElement
   check_parent(x, y)
   iszero(y) && throw(DivideError())
   v2 = valuation(y)
   if v2 != 0
      v1 = valuation(x)
      if v1 >= v2
         x = shift_right(x, v2)
         y = shift_right(y, v2)
      else
         error("Not an exact division")
      end
   else
      x = deepcopy(x)
   end
   y = truncate(y, precision(x))
   res = parent(x)()
   res = set_precision!(res, min(precision(x), precision(y) + valuation(x)))
   lc = coeff(y, 0)
   lc == 0 && error("Not an exact division")
   lenr = precision(x)
   for i = valuation(x):lenr - 1
      flag, q = divides(coeff(x, i), lc)
      !flag && error("Not an exact division")
      res = setcoeff!(res, i, q)
      for j = 0:min(precision(y) - 1, lenr - i - 1)
         x = setcoeff!(x, i + j, coeff(x, i + j) - coeff(y, j)*q)
      end
   end
   res = set_length!(res, normalise(res, length(res)))
   return res
end

###############################################################################
#
#   Ad hoc exact division
#
###############################################################################

function divexact(x::AbsSeriesElem, y::Union{Integer, Rational, AbstractFloat})
   y == 0 && throw(DivideError())
   lenx = length(x)
   z = parent(x)()
   fit!(z, lenx)
   z = set_precision!(z, precision(x))
   for i = 1:lenx
      z = setcoeff!(z, i - 1, divexact(coeff(x, i - 1), y))
   end
   return z
end

function divexact(x::AbsSeriesElem{T}, y::T) where {T <: RingElem}
   iszero(y) && throw(DivideError())
   lenx = length(x)
   z = parent(x)()
   fit!(z, lenx)
   z = set_precision!(z, precision(x))
   for i = 1:lenx
      z = setcoeff!(z, i - 1, divexact(coeff(x, i - 1), y))
   end
   return z
end

###############################################################################
#
#   Inversion
#
###############################################################################

@doc Markdown.doc"""
    Base.inv(a::AbsSeriesElem)

Return the inverse of the power series $a$, i.e. $1/a$.
"""
function Base.inv(a::AbsSeriesElem)
   iszero(a) && throw(DivideError())
   !isunit(a) && error("Unable to invert power series")
   R = base_ring(a)
   a1 = coeff(a, 0)
   ainv = parent(a)()
   fit!(ainv, precision(a))
   ainv = set_precision!(ainv, precision(a))
   if precision(a) != 0
      ainv = setcoeff!(ainv, 0, divexact(one(R), a1))
   end
   a1 = -a1
   s = R()
   t = R()
   for n = 2:precision(a)
      s = mul!(s, coeff(a, 1), coeff(ainv, n - 2))
      for i = 2:min(n, length(a)) - 1
         s = addmul_delayed_reduction!(s, coeff(a, i), coeff(ainv, n - i - 1), t)
      end
      s = reduce!(s)
      ainv = setcoeff!(ainv, n - 1, divexact(s, a1))
   end
   ainv = set_length!(ainv, normalise(ainv, precision(a)))
   return ainv
end

function Base.inv(a::AbsSeriesElem{T}) where T <: FieldElement
    prec = precision(a)
    @assert valuation(a) == 0
    @assert prec != 0
    R = parent(a)
    x = R(inv(coeff(a, 0)))
    x = set_precision!(x, 1)
    la = [prec]
    while la[end] > 1
        push!(la, div(la[end] + 1, 2))
    end 
    two = R(2)
    two = set_precision!(two, prec)
    n = length(la) - 1
    y = R()
    minus_a = -a
    while n > 0
        # x -> x*(2 - xa) is the lifting recursion
        x = set_precision!(x, la[n])
        y = set_precision!(y, la[n])
        y = mul!(y, minus_a, x)
        y = addeq!(y, two)
        x = mul!(x, x, y)
        n -= 1 
    end
    return x
end

###############################################################################
#
#   Square root
#
###############################################################################

@doc Markdown.doc"""
    sqrt(a::AbsSeriesElem)

Return the square root of the power series $a$.
"""
function Base.sqrt(a::AbsSeriesElem)
   # Given a power series f = f0 + f1*x + f2*x^2 + ..., compute the square root
   # g = g0 + g1*x + g2*x^2 + ... using the relations g0^2 = f0, 2g0*g1 = f1
   # 2g0*g2 = f2 - g1^2, 2g0*g3 = f3 - 2g1*g2, 2g0*g4 = f4 - (2g1*g3 + g2^2), etc.
   # where the terms being subtracted are those contributing to the i-th
   # coefficient of the square of g
   aval = valuation(a)
   !iseven(aval) && error("Not a square in sqrt")
   R = base_ring(a)
   !isdomain_type(elem_type(R)) && error("Sqrt not implemented over non-integral domains")
   if iszero(a)
      return deepcopy(a)
   end
   aval2 = div(aval, 2)
   prec = precision(a) - aval2
   asqrt = parent(a)()
   fit!(asqrt, prec)
   asqrt = set_precision!(asqrt, prec)
   for n = 1:aval2
      asqrt = setcoeff!(asqrt, n - 1, R())
   end
   if prec > aval2
      g = sqrt(coeff(a, aval))
      asqrt = setcoeff!(asqrt, aval2, g)
      g2 = g + g
   end
   p = R()
   for n = 1:prec - aval2 - 1
      c = R()
      for i = 1:div(n - 1, 2)
         j = n - i
         p = mul!(p, coeff(asqrt, aval2 + i), coeff(asqrt, aval2 + j))
         c = addeq!(c, p)
      end
      c *= 2
      if (n % 2) == 0
         i = div(n, 2)
         p = mul!(p, coeff(asqrt, aval2 + i), coeff(asqrt, aval2 + i))
         c = addeq!(c, p)
      end
      c = coeff(a, n + aval) - c
      c = divexact(c, g2)
      asqrt = setcoeff!(asqrt, aval2 + n, c)
   end
   asqrt = set_length!(asqrt, normalise(asqrt, prec))
   return asqrt
end

###############################################################################
#
#  Derivative and Integral
#
###############################################################################

@doc Markdown.doc"""
    derivative(f::AbsSeriesElem{T})

Return the derivative of the power series $f$.
"""
function derivative(f::AbsSeriesElem{T}) where T <: RingElement
   g = parent(f)()
   g = set_precision!(g, precision(f) - 1)
   len = length(f) - 1
   fit!(g, len)
   for i = 1:len
      g = setcoeff!(g, i - 1, i*coeff(f, i))
   end
   g = set_length!(g, normalise(g, len))
   return g
end

@doc Markdown.doc"""
    integral(f::AbsSeriesElem{T})

Return the integral of the power series $f$.
"""
function integral(f::AbsSeriesElem{T}) where T <: RingElement
   g = parent(f)()
   len = length(f) + 1
   fit!(g, len)
   g = set_precision!(g, precision(f) + 1)
   for i = 1:len - 1
      c = coeff(f, i - 1)
      if !iszero(c)
         g = setcoeff!(g, i, divexact(c, i))
      end
   end
   g = set_length!(g, normalise(g, len))
   return g
end

###############################################################################
#
#   Special functions
#
###############################################################################

@doc Markdown.doc"""
    exp(a::AbsSeriesElem)

Return the exponential of the power series $a$.
"""
function Base.exp(a::AbsSeriesElem{T}) where T <: RingElement
   if iszero(a)
      z = one(parent(a))
      z = set_precision!(z, precision(a))
      return z
   end
   z = parent(a)()
   fit!(z, precision(a))
   z = set_precision!(z, precision(a))
   z = setcoeff!(z, 0, exp(coeff(a, 0)))
   len = length(a)
   C = base_ring(a)()
   d = derivative(a)
   for k = 1 : precision(a) - 1
      s = zero(base_ring(a))
      for j = 1 : min(k + 1, len) - 1
         s = addmul_delayed_reduction!(s, coeff(d, j - 1), coeff(z, k - j), C)
      end
      s = reduce!(s)
      !isunit(base_ring(a)(k)) && error("Unable to divide in exp")
      z = setcoeff!(z, k, divexact(s, k))
   end
   z = set_length!(z, normalise(z, precision(a)))
   return z
end

function Base.exp(a::AbsSeriesElem{T}) where T <: FieldElement
   if iszero(a)
      b = parent(a)(1)
      b = set_precision!(b, precision(a))
      return b
   end
   R = base_ring(a)
   c = one(R)
   if valuation(a) == 0
      a = deepcopy(a)
      c = exp(coeff(a, 0))
      a = setcoeff!(a, 0, R())
   end
   x = parent(a)([R(1)], 1, min(2, precision(a)))
   prec = precision(a)
   la = [prec]
   while la[end] > 1
      push!(la, div(la[end] + 1, 2))
   end
   one1 = parent(a)([R(1)], 1, 2)
   n = length(la) - 1
   # x -> x*(1 - log(a) + a) is the recursion
   while n > 0
      x = set_precision!(x, la[n])
      one1 = set_precision!(one1, la[n])
      t = -log(x)
      t = addeq!(t, one1)
      t = addeq!(t, a)
      x = mul!(x, x, t)
      n -= 1 
   end
   if !isone(c)
      x *= c
   end
   return x
end

################################################################################
#
#  Map
#
################################################################################

function _make_parent(g, p::AbsSeriesElem, cached::Bool)
   R = parent(g(zero(base_ring(p))))
   S = parent(p)
   sym = String(var(S))
   max_prec = max_precision(S)
   return PowerSeriesRing(R, max_prec, sym; model=:capped_absolute, cached=cached)[1]
end

@doc Markdown.doc"""
    map_coefficients(f, p::SeriesElem{<: RingElement}; cached::Bool=true, parent::PolyRing)

Transform the series `p` by applying `f` on each non-zero coefficient.

If the optional `parent` keyword is provided, the polynomial will be an
element of `parent`. The caching of the parent object can be controlled
via the `cached` keyword argument.
"""
function map_coefficients(g, p::AbsSeriesElem{<:RingElement};
                    cached::Bool = true,
                    parent::Ring = _make_parent(g, p, cached))
   return _map(g, p, parent)
end

function _map(g, p::AbsSeriesElem, Rx)
   R = base_ring(Rx)
   new_coefficients = elem_type(R)[let c = coeff(p, i)
                                     iszero(c) ? zero(R) : R(g(c))
                                   end for i in 0:length(p) - 1]
   res = Rx(new_coefficients, length(p), precision(p))
   return set_length!(res, normalise(res, length(res)))
end

################################################################################
#
#  Change base ring
#
################################################################################

function _change_abs_series_ring(R, Rx, cached)
   P, _ = PowerSeriesRing(R, max_precision(Rx),
                       string(var(Rx)), cached = cached, model=:capped_absolute)
   return P
end

@doc Markdown.doc"""
    change_base_ring(R::Ring, p::SeriesElem{<: RingElement}; parent::PolyRing)

Return the series obtained by coercing the non-zero coefficients of `p`
into `R`.

If the optional `parent` keyword is provided, the series will be an
element of `parent`. The caching of the parent object can be controlled
via the `cached` keyword argument.
"""
function change_base_ring(R::Ring, p::AbsSeriesElem{T};
                    cached::Bool = true, parent::Ring =
          _change_abs_series_ring(R, parent(p), cached)) where T <: RingElement
   return _map(R, p, parent)
end

###############################################################################
#
#   PowerSeriesRing constructor
#
###############################################################################

# see RelSeries.jl
