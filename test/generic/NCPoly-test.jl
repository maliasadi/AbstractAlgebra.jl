function test_gen_ncpoly_constructors()
   print("Generic.NCPoly.constructors...")

   R = MatrixAlgebra(ZZ, 2)
   S, y = PolynomialRing(R, "y")

   @test elem_type(S) == Generic.NCPoly{elem_type(R)}
   @test elem_type(Generic.NCPolyRing{elem_type(R)}) == Generic.NCPoly{elem_type(R)}
   @test parent_type(Generic.NCPoly{elem_type(R)}) == Generic.NCPolyRing{elem_type(R)}

   @test typeof(S) <: Generic.NCPolyRing

   @test isa(y, NCPolyElem)

   T, z = PolynomialRing(S, "z")

   @test typeof(T) <: Generic.NCPolyRing

   @test isa(z, NCPolyElem)

   f = one(R) + y^3 + z + 1

   @test isa(f, NCPolyElem)

   g = S(2)

   @test isa(g, NCPolyElem)

   h = S(rand(R, -10:10))

   @test isa(h, NCPolyElem)

   j = T(rand(R, -10:10))

   @test isa(j, NCPolyElem)

   k = S([rand(R, -10:10) for i in 1:3])

   @test isa(k, NCPolyElem)

   l = S(k)

   @test isa(l, NCPolyElem)

   m = S([1, 2, 3])

   @test isa(m, NCPolyElem)

   n = S([ZZ(1), ZZ(2), ZZ(3)])

   @test isa(n, NCPolyElem)

   println("PASS")
end

function test_gen_ncpoly_manipulation()
   print("Generic.NCPoly.manipulation...")

   R = MatrixAlgebra(ZZ, 2)
   S, y = PolynomialRing(R, "y")

   @test iszero(zero(S))

   @test isone(one(S))

   @test isgen(gen(S))

   @test isunit(one(S))

   f = 2*y + 1

   @test lead(f) == 2

   @test trail(2y^2 + 3y) == 3

   @test degree(f) == 1

   h = y^2 + 3*y + 3

   @test coeff(h, 1) == 3

   @test length(h) == 3

   @test canonical_unit(-y + 1) == -1

   @test deepcopy(h) == h

   @test isterm(rand(R, -10:10)*y^2)

   @test !ismonomial(2*y^2)

   @test ismonomial(y^2)

   @test !ismonomial(y^2 + y + 1)

   println("PASS")
end

function test_gen_ncpoly_binary_ops()
   print("Generic.NCPoly.binary_ops...")

   #  Exact ring
   R = MatrixAlgebra(ZZ, 2)
   S, y = PolynomialRing(R, "y")

   for iter = 1:100
      f = rand(S, 0:10, -10:10)
      g = rand(S, 0:10, -10:10)
      h = rand(S, 0:10, -10:10)
      @test f + g == g + f
      @test f + (g + h) == (f + g) + h
      @test f*(g + h) == f*g + f*h
      @test (f - h) + (g + h) == f + g
      @test (f + g)*(f - g) == f*f + g*f - f*g - g*g
      @test f - g == -(g - f)
   end

   println("PASS")
end

function test_gen_ncpoly_adhoc_binary()
   print("Generic.NCPoly.adhoc_binary...")

   # Exact ring
   R = MatrixAlgebra(ZZ, 2)
   S, y = PolynomialRing(R, "y")
   for iter = 1:500
      f = rand(S, 0:10, -10:10)
      c1 = rand(R, -10:10)
      c2 = rand(R, -10:10)

      @test c1*f - c2*f == (c1 - c2)*f
      @test c1*f + c2*f == (c1 + c2)*f

      @test f*c1 - f*c2 == f*(c1 - c2)
      @test f*c1 + f*c2 == f*(c1 + c2)
   end

   # Generic tower
   R = MatrixAlgebra(ZZ, 2)
   S, y = PolynomialRing(R, "y")
   T, z = PolynomialRing(S, "z")
   for iter = 1:100
      f = rand(T, 0:5, 0:5, -10:10)
      c1 = rand(R, -10:10)
      c2 = rand(R, -10:10)
      d1 = rand(S, 0:5, -10:10)
      d2 = rand(S, 0:5, -10:10)

      @test c1*f - c2*f == (c1 - c2)*f
      @test c1*f + c2*f == (c1 + c2)*f
      @test d1*f - d2*f == (d1 - d2)*f
      @test d1*f + d2*f == (d1 + d2)*f

      @test f*c1 - f*c2 == f*(c1 - c2)
      @test f*c1 + f*c2 == f*(c1 + c2)
      @test f*d1 - f*d2 == f*(d1 - d2)
      @test f*d1 + f*d2 == f*(d1 + d2)
   end

   println("PASS")
end

function test_gen_ncpoly_comparison()
   print("Generic.NCPoly.comparison...")

   # Exact ring
   R = MatrixAlgebra(ZZ, 2)
   S, y = PolynomialRing(R, "y")
   for iter = 1:500
      f = rand(S, 0:10, -10:10)
      g = deepcopy(f)
      h = S()
      while iszero(h)
         h = rand(S, 0:10, -10:10)
      end

      @test f == g
      @test isequal(f, g)
      @test f != g + h
   end

   println("PASS")
end

function test_gen_ncpoly_adhoc_comparison()
   print("Generic.NCPoly.adhoc_comparison...")

   # Exact ring
   R = MatrixAlgebra(ZZ, 2)
   S, y = PolynomialRing(R, "y")
   for iter = 1:500
      f = S()
      while iszero(f)
         f = rand(S, 0:10, -10:10)
      end
      c1 = rand(ZZ, -10:10)
      d1 = rand(zz, -10:10)

      @test R(c1) == c1
      @test c1 == R(c1)
      @test R(d1) == d1
      @test d1 == R(d1)

      @test R(c1) != c1 + f
      @test c1 != R(c1) + f
      @test R(d1) != d1 + f
      @test d1 != R(d1) + f
   end

   # Generic tower
   R = MatrixAlgebra(ZZ, 2)
   S, y = PolynomialRing(R, "y")
   T, z = PolynomialRing(S, "z")
   for iter = 1:100
      f = T()
      while iszero(f)
         f = rand(T, 0:10, 0:5, -10:10)
      end
      c1 = rand(ZZ, -10:10)
      d1 = rand(S, 0:5, -10:10)

      @test S(c1) == c1
      @test c1 == S(c1)
      @test S(d1) == d1
      @test d1 == S(d1)

      @test S(c1) != c1 + f
      @test c1 != S(c1) + f
      @test S(d1) != d1 + f
      @test d1 != S(d1) + f
   end

   println("PASS")
end

function test_gen_ncpoly_unary_ops()
   print("Generic.NCPoly.unary_ops...")

   #  Exact ring
   R = MatrixAlgebra(ZZ, 2)
   S, y = PolynomialRing(R, "y")
   for iter = 1:300
      f = rand(S, 0:10, -10:10)

      @test -(-f) == f
      @test iszero(f + (-f))
   end

   println("PASS")
end

function test_gen_ncpoly_truncation()
   print("Generic.NCPoly.truncation...")

   #  Exact ring
   R = MatrixAlgebra(ZZ, 2)
   S, y = PolynomialRing(R, "y")
   for iter = 1:300
      f = rand(S, 0:10, -10:10)
      g = rand(S, 0:10, -10:10)
      n = rand(0:20)

      @test truncate(f*g, n) == mullow(f, g, n)
   end

   println("PASS")
end

function test_gen_ncpoly_reverse()
   print("Generic.NCPoly.reverse...")

   #  Exact ring
   R, x = ZZ["x"]
   for iter = 1:300
      f = rand(R, 0:10, -10:10)
      len = rand(length(f):12)
      frev = reverse(f, len)

      shift = 0
      for i = 1:len
         if coeff(f, i - 1) != 0
            break
         end
         shift += 1
      end

      @test length(frev) == len - shift
      @test f == reverse(frev, len)
   end

   # Fake finite field of char 7, degree 2
   S, y = PolynomialRing(GF(7), "y")
   F = ResidueField(S, y^2 + 6y + 3)
   a = F(y)
   R, x = PolynomialRing(F, "x")
   for iter = 1:300
      f = rand(R, 0:10, 0:1)
      len = rand(length(f):12)
      frev = reverse(f, len)

      shift = 0
      for i = 1:len
         if coeff(f, i - 1) != 0
            break
         end
         shift += 1
      end

      @test length(frev) == len - shift
      @test f == reverse(frev, len)
   end

   #  Inexact field
   R, x = PolynomialRing(RealField, "x")
   for iter = 1:300
      f = rand(R, 0:10, -1:1)
      len = rand(length(f):12)
      frev = reverse(f, len)

      shift = 0
      for i = 1:len
         if coeff(f, i - 1) != 0
            break
         end
         shift += 1
      end

      @test length(frev) == len - shift
      @test f == reverse(frev, len)
   end

   #  Non-integral domain
   T = ResidueRing(ZZ, 6)
   R, x = T["x"]
   for iter = 1:300
      f = rand(R, 0:10, 0:5)
      len = rand(length(f):12)
      frev = reverse(f, len)

      shift = 0
      for i = 1:len
         if coeff(f, i - 1) != 0
            break
         end
         shift += 1
      end

      @test length(frev) == len - shift
      @test f == reverse(frev, len)
   end

   println("PASS")
end

function test_gen_ncpoly_shift()
   print("Generic.NCPoly.shift...")

   # Exact ring
   R, x = ZZ["x"]
   for iter = 1:300
      f = rand(R, 0:10, -10:10)
      s = rand(0:10)
      g = s == 0 ? R() : rand(R, 0:s - 1, -10:10)

      @test shift_right(shift_left(f, s) + g, s) == f
      @test shift_left(f, s) == x^s*f
      @test length(shift_right(f, s)) == max(0, length(f) - s)
   end

   # Fake finite field of char 7, degree 2
   S, y = PolynomialRing(GF(7), "y")
   F = ResidueField(S, y^2 + 6y + 3)
   a = F(y)
   R, x = PolynomialRing(F, "x")
   for iter = 1:300
      f = rand(R, 0:10, 0:1)
      s = rand(0:10)
      g = s == 0 ? R() : rand(R, 0:s - 1, 0:1)

      @test shift_right(shift_left(f, s) + g, s) == f
      @test shift_left(f, s) == x^s*f
      @test length(shift_right(f, s)) == max(0, length(f) - s)
   end

   # Inexact field
   R, x = PolynomialRing(RealField, "x")
   for iter = 1:300
      f = rand(R, 0:10, -1:1)
      s = rand(0:10)
      g = s == 0 ? R() : rand(R, 0:s - 1, -1:1)

      @test shift_right(shift_left(f, s) + g, s) == f
      @test shift_left(f, s) == x^s*f
      @test length(shift_right(f, s)) == max(0, length(f) - s)
   end

   # Non-integral domain
   T = ResidueRing(ZZ, 6)
   R, x = T["x"]
   for iter = 1:300
      f = rand(R, 0:10, 0:5)
      s = rand(0:10)
      g = s == 0 ? R() : rand(R, 0:s - 1, 0:5)

      @test shift_right(shift_left(f, s) + g, s) == f
      @test shift_left(f, s) == x^s*f
      @test length(shift_right(f, s)) == max(0, length(f) - s)
   end

   println("PASS")
end

function test_gen_ncpoly_powering()
   print("Generic.NCPoly.powering...")

   # Exact ring
   R, x = PolynomialRing(ZZ, "x")

   for iter = 1:10
      f = rand(R, 0:10, -10:10)
      r2 = R(1)

      for expn = 0:10
         r1 = f^expn

         @test (f == 0 && expn == 0 && r1 == 0) || r1 == r2

         r2 *= f
      end
   end

   # Fake finite field of char 7, degree 2
   S, y = PolynomialRing(GF(7), "y")
   F = ResidueField(S, y^2 + 6y + 3)
   a = F(y)
   R, x = PolynomialRing(F, "x")

   for iter = 1:10
      f = rand(R, 0:10, 0:1)
      r2 = R(1)

      for expn = 0:10
         r1 = f^expn

         @test (f == 0 && expn == 0 && r1 == 0) || r1 == r2

         r2 *= f
      end
   end

   # Inexact field
   R, x = PolynomialRing(RealField, "x")

   for iter = 1:10
      f = rand(R, 0:10, -1:1)
      r2 = R(1)

      for expn = 0:4 # cannot set high power here
         r1 = f^expn

         @test (f == 0 && expn == 0 && r1 == 0) || isapprox(r1, r2)

         r2 *= f
      end
   end

   # Non-integral domain
   for iter = 1:10
      n = rand(2:26)

      Zn = ResidueRing(ZZ, n)
      R, x = PolynomialRing(Zn, "x")

      f = rand(R, 0:10, 0:n - 1)
      r2 = R(1)

      for expn = 0:10
         r1 = f^expn

         @test (f == 0 && expn == 0 && r1 == 0) || r1 == r2

         r2 *= f
      end
   end

   println("PASS")
end

function test_gen_ncpoly_exact_division()
   print("Generic.NCPoly.exact_division...")

   # Exact ring
   R, x = PolynomialRing(ZZ, "x")

   for iter = 1:100
      f = rand(R, 0:10, -100:100)
      g = R()
      while g == 0
         g = rand(R, 0:10, -100:100)
      end

      @test divexact(f*g, g) == f
   end

   # Fake finite field of char 7, degree 2
   S, y = PolynomialRing(GF(7), "y")
   F = ResidueField(S, y^2 + 6y + 3)
   a = F(y)
   R, x = PolynomialRing(F, "x")

   for iter = 1:100
      f = rand(R, 0:10, 0:1)
      g = R()
      while g == 0
         g = rand(R, 0:10, 0:1)
      end

      @test divexact(f*g, g) == f
   end

   # Inexact field
   R, x = PolynomialRing(RealField, "x")

   for iter = 1:100
      f = rand(R, 0:10, -1:1)
      g = R()
      while g == 0
         g = rand(R, 0:10, -1:1)
      end

      @test isapprox(divexact(f*g, g), f)
   end

   # Characteristic p ring
   n = 23
   Zn = ResidueRing(ZZ, n)
   R, x = PolynomialRing(Zn, "x")

   for iter = 1:100
      f = rand(R, 0:10, 0:n - 1)
      g = R()
      while g == 0
         g = rand(R, 0:10, 0:n - 1)
      end

      @test divexact(f*g, g) == f
   end

   println("PASS")
end

function test_gen_ncpoly_adhoc_exact_division()
   print("Generic.NCPoly.adhoc_exact_division...")

   # Exact ring
   R, x = PolynomialRing(ZZ, "x")

   for iter = 1:100
      f = rand(R, 0:10, -100:100)
      g = ZZ()
      while g == 0
         g = rand(ZZ, -10:10)
      end

      @test divexact(f*g, g) == f

      h = 0
      while h == 0
         h = rand(-10:10)
      end

      @test divexact(f*h, h) == f
   end

   # Fake finite field of char 7, degree 2
   S, y = PolynomialRing(GF(7), "y")
   F = ResidueField(S, y^2 + 6y + 3)
   a = F(y)
   R, x = PolynomialRing(F, "x")

   for iter = 1:100
      f = rand(R, 0:10, 0:1)
      g = ZZ()
      while g == 0
         g = rand(ZZ, 1:6)
      end

      @test divexact(f*g, g) == f

      h = 0
      while h == 0
         h = rand(1:6)
      end

      @test divexact(f*h, h) == f
   end

   # Inexact field
   R, x = PolynomialRing(RealField, "x")

   for iter = 1:100
      f = rand(R, 0:10, -1:1)
      g = ZZ()
      while g == 0
         g = rand(RealField, -1:1)
      end

      @test isapprox(divexact(f*g, g), f)

      h = 0
      while h == 0
         h = rand(-10:10)
      end

      @test isapprox(divexact(f*h, h), f)
   end

   # Characteristic p ring
   n = 23
   Zn = ResidueRing(ZZ, n)
   R, x = PolynomialRing(Zn, "x")

   for iter = 1:100
      f = rand(R, 0:10, 0:22)
      g = rand(Zn, 1:22)

      @test divexact(f*g, g) == f

      h = 0
      while (h % n) == 0
         h = rand(-100:100)
      end

      @test divexact(f*h, h) == f
   end

   # Generic tower
   R, x = PolynomialRing(ZZ, "x")
   S, y = PolynomialRing(R, "y")

   for iter = 1:100
      f = rand(S, 0:10, 0:10, -100:100)
      g = R()
      while g == 0
         g = rand(R, 0:10, -100:100)
      end

      @test divexact(f*g, g) == f

      h = ZZ()
      while h == 0
         h = rand(ZZ, -10:10)
      end

      @test divexact(f*h, h) == f
   end

   println("PASS")
end

function test_gen_ncpoly_evaluation()
   print("Generic.NCPoly.evaluation...")

   # Exact ring
   R, x = PolynomialRing(ZZ, "x")

   for iter in 1:10
      f = rand(R, 0:4, -10:10)
      g = rand(R, 0:4, -10:10)

      d = rand(ZZ, -10:10)

      @test evaluate(g, evaluate(f, d)) == evaluate(subst(g, f), d)
   end

   for iter in 1:10
      f = rand(R, 0:4, -10:10)
      g = rand(R, 0:4, -10:10)

      d = rand(-10:10)

      @test evaluate(g, evaluate(f, d)) == evaluate(subst(g, f), d)
   end

   # Inexact field
   R, x = PolynomialRing(RealField, "x")

   for iter in 1:10
      f = rand(R, 0:4, 0:1)
      g = rand(R, 0:4, 0:1)

      d = rand(RealField, 0:1)

      @test isapprox(evaluate(g, evaluate(f, d)), evaluate(subst(g, f), d))
   end

   for iter in 1:10
      f = rand(R, 0:4, 0:1)
      g = rand(R, 0:4, 0:1)

      d = rand(-10:10)

      @test isapprox(evaluate(g, evaluate(f, d)), evaluate(subst(g, f), d))
   end

   # Non-integral domain
   Zn = ResidueRing(ZZ, 23)
   R, x = PolynomialRing(Zn, "x")

   for iter in 1:10
      f = rand(R, 0:4, 0:22)
      g = rand(R, 0:4, 0:22)

      d = rand(Zn, 0:22)

      @test evaluate(g, evaluate(f, d)) == evaluate(subst(g, f), d)
   end

   for iter in 1:10
      f = rand(R, 0:4, 0:22)
      g = rand(R, 0:4, 0:22)

      d = rand(-100:100)

      @test evaluate(g, evaluate(f, d)) == evaluate(subst(g, f), d)
   end

   println("PASS")
end

function test_gen_ncpoly_composition()
   print("Generic.NCPoly.composition...")

   # Exact ring
   R, x = PolynomialRing(ZZ, "x")

   for iter in 1:10
      f = rand(R, 0:5, -10:10)
      g = rand(R, 0:5, -10:10)
      h = rand(R, 0:5, -10:10)

      @test compose(f, compose(g, h)) == compose(compose(f, g), h)
   end

   # Inexact field
   R, x = PolynomialRing(RealField, "x")

   for iter in 1:10
      f = rand(R, 0:5, 0:1)
      g = rand(R, 0:5, 0:1)
      h = rand(R, 0:5, 0:1)

      @test isapprox(compose(f, compose(g, h)), compose(compose(f, g), h))
   end

   # Non-integral domain
   Zn = ResidueRing(ZZ, 6)
   R, x = PolynomialRing(Zn, "x")

   for iter in 1:10
      f = rand(R, 0:5, 0:5)
      g = rand(R, 0:5, 0:5)
      h = rand(R, 0:5, 0:5)

      @test compose(f, compose(g, h)) == compose(compose(f, g), h)
   end

   println("PASS")
end

function test_gen_ncpoly_derivative()
   print("Generic.NCPoly.derivative...")

   # Exact ring
   R, x = PolynomialRing(ZZ, "x")

   for iter in 1:10
      f = rand(R, 0:4, -100:100)
      g = rand(R, 0:4, -100:100)

      @test derivative(f + g) == derivative(g) + derivative(f)

      @test derivative(g*f) == derivative(g)*f + derivative(f)*g
   end

   # Inexact field
   R, x = PolynomialRing(RealField, "x")

   for iter in 1:10
      f = rand(R, 0:4, 0:1)
      g = rand(R, 0:4, 0:1)

      @test isapprox(derivative(f + g), derivative(g) + derivative(f))

      @test isapprox(derivative(g*f), derivative(g)*f + derivative(f)*g)
   end

   # Non-integral domain
   Zn = ResidueRing(ZZ, 6)
   R, x = PolynomialRing(Zn, "x")

   for iter in 1:10
      f = rand(R, 0:4, 0:5)
      g = rand(R, 0:4, 0:5)

      @test derivative(f + g) == derivative(g) + derivative(f)

      @test derivative(g*f) == derivative(g)*f + derivative(f)*g
   end

   println("PASS")
end

function test_gen_ncpoly_generic_eval()
   print("Generic.NCPoly.generic_eval...")

   R, x = PolynomialRing(ZZ, "x")

   for iter in 1:10
      f = rand(R, 0:2, -100:100)
      g = rand(R, 0:2, -100:100)
      h = rand(R, 0:2, -100:100)

      @test f(g(h)) == f(g)(h)
   end

   R, x = PolynomialRing(ZZ, "x")

   f = x
   b = a = QQ(13)
   for i in 1:5
      g = x^2 + rand(R, 0:1, -1:1)
      f = g(f)
      b = g(b)

      @test b == f(a)
   end

   println("PASS")
end

function test_gen_ncpoly()
   test_gen_ncpoly_constructors()
   test_gen_ncpoly_manipulation()
   test_gen_ncpoly_binary_ops()
   test_gen_ncpoly_adhoc_binary()
   test_gen_ncpoly_comparison()
   test_gen_ncpoly_adhoc_comparison()
   test_gen_ncpoly_unary_ops()
   test_gen_ncpoly_truncation()
   test_gen_ncpoly_reverse()
   test_gen_ncpoly_shift()
   test_gen_ncpoly_powering()
   test_gen_ncpoly_exact_division()
   test_gen_ncpoly_adhoc_exact_division()
   test_gen_ncpoly_evaluation()
   test_gen_ncpoly_composition()
   test_gen_ncpoly_derivative()
   test_gen_ncpoly_generic_eval()

   println("")
end
