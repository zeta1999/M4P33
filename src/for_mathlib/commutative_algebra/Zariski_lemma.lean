/-

Zariski's Lemma: if k is a field and K is a field finitely generated
as a k-algebra, then K is also finitely-generated as a k-module

-/

import ring_theory.integral_closure field_theory.subfield

import linear_algebra.finite_dimensional

import for_mathlib.finset -- Chris' lemma about S - {s}

example : 2 + 2 = 4 := rfl

open_locale classical

lemma subalgebra.mem_coe_submodule (R : Type*) [comm_ring R] (A : Type*) [comm_ring A] [algebra R A]
  (M : subalgebra R A) (x : A) : x ∈ (M : submodule R A) ↔ x ∈ M := iff.rfl

lemma subalgebra.coe_submodule_top (R : Type*) [comm_ring R] (A : Type*) [comm_ring A] [algebra R A] :
  ((⊤ : subalgebra R A) : submodule R A) = ⊤ :=
begin
  ext,
  convert iff.refl true,
  rw [eq_true, subalgebra.mem_coe_submodule],
  exact algebra.mem_top,
end

universes u

open set

-- PR accepted
theorem algebra.eq_top_iff {A R : Type*} [comm_ring A] [comm_ring R]
[algebra R A] {S : subalgebra R A} :
  S = ⊤ ↔ ∀ x : A, x ∈ S :=
⟨λ h x, by rw h; exact algebra.mem_top, λ h, by ext x; exact ⟨λ _, algebra.mem_top, λ _, h x⟩⟩

instance Zariski's_lemma
  -- let k be a field
  (k : Type u) [discrete_field k]
  -- and let k ⊆ K be another field (note: I seem to need that it's in the same universe)
  (K : Type u) [discrete_field K] [algebra k K] 
  -- Assume that there's a finite subset S of K
  (S : finset K)
  -- which generates K as a k-algebra
  -- (note: `⊤` is "the largest k-subalgebra of K", i.e., K)
  (hsgen : algebra.adjoin k (↑S : set K) = ⊤)
  -- Then
  :
  -- K is finite-dimensional as a k-vector space
  finite_dimensional k K
:=
begin
  -- I will show that if K is a field and S is a finite subset, 
  -- then for all subfields k of K, if K=k(S) then K is finite-dimensional
  -- as a k-vector space.
  unfreezeI, revert S k,
  -- We'll do it by induction on the size of S,
  intro S, apply finset.strong_induction_on S, clear S, intros S IH,
  intros k hk hka, letI := hk, letI := hka,
intro hSgen,
  -- Let's deal first with the case where all the elements of S are algebraic
  -- over k
  by_cases h_int : ∀ s ∈ S, is_integral k s,
  -- In this case, the result is standard, because K is finitely-generated
  -- and algebraic over k, so it's module-finite (use the
  -- tower law and induction)
  { convert fg_adjoin_of_finite (finset.finite_to_set S) h_int,
    rw hSgen,
    rw finite_dimensional.iff_fg,
    apply congr_arg,
    convert (subalgebra.coe_submodule_top k K).symm,
  },
  -- The remaining case is where S contains an element transcendental over k.
  push_neg at h_int,
  rcases h_int with ⟨s, hs, hsnonint⟩,
  -- We prove that this cannot happen.
  exfalso,
  -- Let L:=k(s) be the subfield of K generated by k and s.
  set L := field.closure ((set.range (algebra_map K : k → K)) ∪ {s}) with hL,
  -- then K = L(S - {s})
  -- and |S - {s}| < |S|, so by induction, K is finite-dimensional over L,
  have hKL : finite_dimensional L K,
  { refine IH (S.erase s) (finset.erase_ssubset hs) ↥L _,
    -- NB this is a proof that k(S)=L(S - {s})
    rw algebra.eq_top_iff at ⊢ hSgen,
    intro x, replace hSgen := hSgen x,
    rw ←subalgebra.mem_coe at ⊢ hSgen,
    revert hSgen x,
    show ring.closure (range (algebra_map K) ∪ ↑S) ≤
    ring.closure (range (algebra_map K) ∪ ↑(S.erase s)),
    apply ring.closure_subset,
    apply union_subset,
    { refine subset.trans _ ring.subset_closure, 
      refine subset.trans _ (subset_union_left _ _),
      rintro x ⟨x0, hx0⟩,
      suffices hx : x ∈ L,
      { use ⟨x, hx⟩,
        refl,
      },
      rw hL,
      apply field.subset_closure,
      apply subset_union_left _ _,
      use x0,
      exact hx0
    },
    { refine subset.trans _ ring.subset_closure,
      intros t ht,
      by_cases hst : t = s,
      { apply subset_union_left,
        cases hst, clear hst,
        suffices hsL : s ∈ L,
          use ⟨s, hsL⟩,
          refl,
        rw hL,
        apply field.subset_closure,
        apply subset_union_right _ _,
        apply mem_singleton
      },
      { apply subset_union_right _ _,
        exact finset.mem_erase_of_ne_of_mem hst ht,
      }
    }
  },
  sorry,
  -- Atiyah--Macdonald completion:
  -- K is finite-dimensional over L=k(s), so choose a basis y₁, y₂, … yₘ.
  -- We can write each sᵢ∈S as sᵢ=∑ⱼ aᵢⱼyⱼ 
  -- and we can write each yᵢyⱼ as Σₖ bᵢⱼₖ yₖ with the a's and b's in L.
  -- If R is the k-algebra generated by the aᵢⱼ and the bᵢⱼₖ then
  -- any polynomial in the sᵢ with coefficients in k is easily checked to
  -- be an R-linear combination of the yₖ, and in particular K is a finite R-module.
  -- Because R is Noetherian we have that K is a Noetherian R-module, and hence
  -- its submodule L is a Noetherian R-module. Because R is a finitely-generated
  -- k-algebra this means that L is also a finitely-generated k-algebra.
  -- But L=k(s) is not finitely-generated, because consider 1/(d₁d₂…dₙ+1)
  -- where the dᵢ are the denominators of a finite set of generators.

  -- Shorter completion:
  -- Each sᵢ ∈ S is hence algebraic over L, and hence integral over k[s][1/D]
  -- for some well-chosen D. Hence K is integral over k[s][1/D]. 
  -- This means k[s][1/D] is a field (a standard trick; a non-zero element of k[s][1/D]
  -- has an inverse in K, which is integral over k[s][1/D] and now multiply up
  -- and expand out), which can't happen (it implies
  -- that D is in every maximal ideal of k[s] and hence 1+D is in
  -- none of them, thus 1+D is in k, so D is too, contradiction)
end
#check algebra.is_integral_trans