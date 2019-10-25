###############################################################################
#
#   NCRings.jl : Generic not necessarily commutative rings
#
###############################################################################

include("Rings.jl")

###############################################################################
#
#   Promotion system
#
###############################################################################

promote_rule(::Type{T}, ::Type{T}) where T <: NCRingElem = T

###############################################################################
#
#   Generic catchall functions
#
###############################################################################

function +(x::S, y::T) where {S <: NCRingElem, T <: NCRingElem}
   if S == promote_rule(S, T)
      +(x, parent(x)(y))
   else
      +(parent(y)(x), y)
   end
end

+(x::NCRingElem, y::RingElement) = x + parent(x)(y)

+(x::RingElement, y::NCRingElem) = parent(y)(x) + y

function -(x::S, y::T) where {S <: NCRingElem, T <: NCRingElem}
   if S == promote_rule(S, T)
      -(x, parent(x)(y))
   else
      -(parent(y)(x), y)
   end
end

-(x::NCRingElem, y::RingElement) = x - parent(x)(y)

-(x::RingElement, y::NCRingElem) = parent(y)(x) - y

function *(x::S, y::T) where {S <: NCRingElem, T <: NCRingElem}
   if S == promote_rule(S, T)
      *(x, parent(x)(y))
   else
      *(parent(y)(x), y)
   end
end

*(x::NCRingElem, y::RingElement) = x*parent(x)(y)

*(x::RingElement, y::NCRingElem) = parent(y)(x)*y

function divexact_left(x::S, y::T) where {S <: NCRingElem, T <: NCRingElem}
   if S == promote_rule(S, T)
      divexact_left(x, parent(x)(y))
   else
      divexact_left(parent(y)(x), y)
   end
end

function divexact_right(x::S, y::T) where {S <: NCRingElem, T <: NCRingElem}
   if S == promote_rule(S, T)
      divexact_right(x, parent(x)(y))
   else
      divexact_right(parent(y)(x), y)
   end
end

function divexact_left(x::NCRingElem, y::Union{Integer, Rational, AbstractFloat})
   return divexact_left(x, parent(x)(y))
end

function divexact_right(x::NCRingElem, y::Union{Integer, Rational, AbstractFloat})
   return divexact_right(x, parent(x)(y))
end

function ==(x::S, y::T) where {S <: NCRingElem, T <: NCRingElem}
   if S == promote_rule(S, T)
      ==(x, parent(x)(y))
   else
      ==(parent(y)(x), y)
   end
end

==(x::NCRingElem, y::RingElement) = x == parent(x)(y)

==(x::RingElement, y::NCRingElem) = parent(y)(x) == y

###############################################################################
#
#   Baby-steps giant-steps powering
#
###############################################################################

@doc Markdown.doc"""
    powers(a::Union{NCRingElement, MatElem}, d::Int)
> Return an array $M$ of "powers" of `a` where $M[i + 1] = a^i$ for $i = 0..d$
"""
function powers(a::T, d::Int) where {T <: Union{NCRingElement, MatElem}}
   d <= 0 && throw(DomainError(d, "the second argument must be positive"))
   a isa MatElem && !issquare(a) && throw(DomainError(a, "matrix must be square"))
   A = Array{T}(undef, d + 1)
   A[1] = one(a)
   if d > 0
      c = a
      A[2] = a
      for i = 2:d
         c *= a
         A[i + 1] = c
      end
   end
   return A
end

###############################################################################
#
#   oftype
#
################################################################################

# This is a useful fallback when applying methods from Base to our matrices,
# see https://github.com/Nemocas/Nemo.jl/pull/637
Base.oftype(x::NCRingElem, y::NCRingElem) = parent(x)(y)

Base.oftype(x::NCRingElem, y::AbstractFloat) = parent(x)(y)

Base.oftype(x::NCRingElem, y::Integer) = parent(x)(y)

Base.oftype(x::NCRingElem, y::Rational) = parent(x)(y)

###############################################################################
#
#   BELOW: Shared functionalities for Rings and NCRings
#
################################################################################

const CNCRingElem = Union{RingElem,NCRingElem}

###############################################################################
#
#   One and zero
#
###############################################################################

one(x::CNCRingElem) = one(parent(x))

zero(x::CNCRingElem) = zero(parent(x))
