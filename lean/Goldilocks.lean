/-!
# Goldilocks

The field behind the STARKs I verify on Ethereum: `p = 2^64 - 2^32 + 1`.
Two facts make it work, and the Lean kernel checks both below.

* `p - 1 = 2^32 * (2^32 - 1)`, so the field has a multiplicative subgroup of order `2^32`.
  That is room for FFTs over domains of up to four billion points.
* `7` is not a square mod `p` (the Euler criterion: `7^((p-1)/2) = -1`), so `X^2 - 7` is
  irreducible and `F_p[X] / (X^2 - 7)` is the quadratic extension the verifier draws its
  challenges from.
-/

namespace Goldilocks

/-- The Goldilocks prime. -/
def p : Nat := 2 ^ 64 - 2 ^ 32 + 1

/-- Square-and-multiply, structurally recursive on a fuel bound, so that `decide` can run it. -/
def powMod (b e m : Nat) : Nat := go 64 (b % m) e 1
where
  go : Nat → Nat → Nat → Nat → Nat
    | 0, _, _, acc => acc
    | n + 1, b, e, acc =>
      if e = 0 then acc
      else go n (b * b % m) (e / 2) (if e % 2 = 1 then acc * b % m else acc)

theorem p_value : p = 18446744069414584321 := by decide

/-- The two-adicity of `p - 1` is 32. -/
theorem two_adic : p - 1 = 2 ^ 32 * (2 ^ 32 - 1) := by decide

theorem two_adic_exact : (p - 1) % 2 ^ 32 = 0 ∧ (p - 1) / 2 ^ 32 % 2 = 1 := by decide

/-- the Euler criterion evaluated: `7^((p-1)/2) ≡ -1 (mod p)`, so `7` is a non-residue. -/
theorem seven_is_a_nonresidue : powMod 7 ((p - 1) / 2) p = p - 1 := by decide +kernel

/-- A generator of the order-`2^32` subgroup: `7^(2^32 - 1)`, and it has order exactly `2^32`. -/
def omega : Nat := powMod 7 (2 ^ 32 - 1) p

theorem omega_order : powMod omega (2 ^ 32) p = 1 ∧ powMod omega (2 ^ 31) p = p - 1 := by decide +kernel

end Goldilocks
