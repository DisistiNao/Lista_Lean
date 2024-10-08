import Mathlib.Tactic.Basic

section PropLogic

  variable (A B C : Prop)

  theorem first_theorem : (A → B) → A → B := by
    /-
     G U {H : A} |- B
     --------------      intros H
     G |- A -> B


     H : A <- G
     -----------         exact H
     G |- A
    -/
    intros H -- introdução da implicação
    exact H

  #print first_theorem

  theorem first2 : (A → B) → A → B :=
    λ H : A → B => H


-- *** Exercício 1.

  lemma ex1 : A → B → A := by
    intros H1 _
    exact H1


-- *** Exercício 2.

  lemma ex2 : (A → B) → (B → C) → A → C := by
    intros H1 H2 H3
    /-
      G |- B -> C     G |- B
      ----------------------- apply
          G |- C
    -/
    apply H2
    apply H1
    exact H3


-- ** Conjunção
-- par

  theorem and_comm1 : (A ∧ B) → (B ∧ A) := by
    intros H1
    apply And.intro
    ·
      exact H1.right
      -- rcases H1 with ⟨ H1, _H1 ⟩
      -- exact _H1
    ·
      -- exact H1.left
      rcases H1 with ⟨ H1 , _H2 ⟩
      exact H1


  theorem and_assoc1 : A ∧ (B ∧ C) → (A ∧ B) ∧ C := by
    intros H
    rcases H with ⟨ HA , HB , HC ⟩
    apply And.intro
    ·
      -- apply And.intro
      -- ·
      --   exact HA
      -- .
      --   exact HB

      apply And.intro <;> assumption
    ·
      -- exact HC
      assumption


-- *** Exercício 3

  theorem ex3 : (A ∧ B) ∧ C → A ∧ (B ∧ C) := by
    intros H
    rcases H with ⟨ H1, HC ⟩
    rcases H1 with ⟨ HA, HB ⟩
    apply And.intro
    ·
      -- exact HA
      assumption
    ·
      -- apply And.intro
      -- ·
      --   exact HB
      -- ·
      --   exact HC
      apply And.intro <;> assumption

-- *** Exercício 4

  theorem ex4 : ((A ∧ B) → C) → (A → B → C) := by
    intros H1 HA HB
    apply H1
    -- apply
    apply And.intro <;> assumption
    -- apply And.intro
    -- ·
    --   assumption
    -- ·
    --   exact HB


-- *** Exercício 5

  theorem ex5 : (A → B → C) → ((A ∧ B) → C) := by
    intros H1 H2
    apply H1
    exact H2.left
    exact H2.right

-- *** Exercício 6

  theorem ex6 : ((A → B) ∧ (A → C)) → A → (B ∧ C) := by
    intros H1 H2
    apply And.intro
    ·
      exact H1.left H2
    ·
      exact H1.right H2

  -- A ↔ B = (A → B) ∧ (B → A)

  lemma iff_demo : (A ∧ B) ↔ (B ∧ A) := by
    apply Iff.intro           <;>
    intros H                  <;>
    rcases H with ⟨ H1 , H2 ⟩ <;>
    apply And.intro           <;>
    assumption


-- Negação
-- ¬ A ≃ A → False

  lemma modus1 : ((A → B) ∧ ¬ B) → ¬ A := by
    intros H
    rcases H with ⟨ H1 , H2 ⟩
    intros HA
    have HB : B := by
      apply H1
      exact HA
    contradiction

/-
H1 : A -> B
-----------------
B

apply H1

H1 : A -> B
--------------
A

====>
A -> B          A
------------------
       B
-/


  lemma modus2 : ((A → B) ∧ ¬ B) → ¬ A := by
    intros H
    rcases H with ⟨ H1 , H2 ⟩
    intros HA
    apply H2
    apply H1
    exact HA

  lemma contraEx : A → ¬ A → B := by
    intros H H1
    contradiction


-- disjunção
  /-
  Γ |- A ∨ B    Γ ∪ {A} |- C    Γ ∪ {B} |- C
  ------------------------------------------
        Γ |- C

  -/



  lemma or_comm1 : (A ∨ B) → (B ∨ A) := by
    intros H
    rcases H with H1 | H2
    ·
      right
      exact H1
    ·
      left
      exact H2



  lemma orex2 : ((A ∨ B) ∧ ¬ A) → B := by
    intros H
    rcases H with ⟨ H1 , H2 ⟩
    rcases H1 with H3 | H4
    ·
      contradiction
    ·
      exact H4

-- Exercício 8

  lemma ex8 : (A ∨ (B ∧ C)) → (A ∨ B) ∧ (A ∨ C) := by
    intros H
    rcases H with H1 | H2
    apply And.intro <;> left <;> exact H1
    /-
    apply And.intro
    ·
      left
      exact H1
    ·
      left
      exact H1
    -/
    apply And.intro
    ·
      right
      exact H2.left
    ·
      right
      exact H2.right


-- Lógica clássica

  open Classical

  -- excluded middle

  #check (em A)

  lemma doubleNeg : ¬ (¬ A) ↔ A := by
    apply Iff.intro
    ·
      have H1 : A ∨ ¬ A := em A
      rcases H1 with H1 | H2
      ·
        intros _H3
        exact H1
      ·
        intros H3
        contradiction
    ·
      intros H H1
      contradiction



-- Exercício 9

  lemma ex9 : (¬ B → ¬ A) → (A → B) := by
    intros H HA
    have HB : B ∨ ¬ B := em B
    rcases HB with HB1 | HB2
    ·
      exact HB1
    ·
      have _HA := H HB2
      contradiction

-- Exercício 10

  lemma ex10 : ((A → B) → A) → A := by
    intros H
    have HA := em A
    rcases HA with HA | _HA
    ·
      exact HA
    ·
      have _H : A → B := by
        intro HA
        contradiction
      exact H _H

end PropLogic
