-- Aula 12: representando semântica formal.

import Mathlib.Tactic.Basic
import Mathlib.Data.Nat.Defs


section TOY

  -- sintaxe de uma linguagem de expressões (sem tipos)

  inductive Tm : Type where
  | C : ℕ → Tm
  | P : Tm → Tm → Tm

  -- semântica denotacional

  @[simp]
  def evalTm (t : Tm) : ℕ :=
    match t with
    | Tm.C n => n
    | Tm.P t1 t2 => evalTm t1 + evalTm t2

  -- semântica big-step

  inductive TmValue : Tm → Prop where
  | Tm_Val : ∀ {n}, TmValue (Tm.C n)

  inductive Eval : Tm → ℕ → Prop where
  | Ev_Const : ∀ {n}, Eval (Tm.C n) n
  | Ev_Plus : ∀ {t1 n1 t2 n2},
                Eval t1 n1 →
                Eval t2 n2 →
                Eval (Tm.P t1 t2)
                     (n1 + n2)


  lemma Eval_eval (t : Tm) : Eval t (evalTm t) := by
    induction t with
    | C n =>
      simp ; constructor
    | P t1 t2 IH1 IH2 =>
      simp
      constructor <;> assumption

  -- semântica small step

  inductive Step : Tm → Tm → Prop where
  | SPlusConst : ∀ n1 n2, Step (Tm.P (Tm.C n1) (Tm.C n2))
                               (Tm.C (n1 + n2))
  | SPlus1 : ∀ t1 t1' t2, Step t1 t1' →
                          Step (Tm.P t1 t2) (Tm.P t1' t2)
  | SPlus2 : ∀ n1 t2 t2', Step t2 t2' →
                          Step (Tm.P (Tm.C n1) t2)
                               (Tm.P (Tm.C n1) t2')

  lemma Step_deterministic (t1 t2 t3 : Tm)
    : Step t1 t2 → Step t1 t3 → t2 = t3 := by
    intros Ht1
    induction Ht1 generalizing t3 with
    | SPlusConst n1 n2 =>
      intros H1
      cases H1 with
      | SPlusConst => rfl
      | SPlus1 t3 t4 t5 H1 =>
        cases H1
      | SPlus2 n4 t5 t5' H2 =>
        cases H2
    | SPlus1 t4 t5 t6 H1 IH1 =>
      intros H2
      cases H2 with
      | SPlusConst n1 n2 =>
        rcases H1
      | SPlus1 t7 t8 H1 IH2 =>
        have H3 : t5 = t8 := by
          apply IH1 ; assumption
        simp [*]
      | SPlus2 t7 t8 H2 IH1 =>
        rcases H1
    | SPlus2 t7 t8 t9 H2 IH2 =>
      intros H3
      cases H3 with
      | SPlusConst n1 n2 =>
        rcases H2
      | SPlus1 n2 t7 H2 H3 =>
        rcases H3
      | SPlus2 t4 t5 H3 H4 =>
        simp
        apply IH2 ; assumption

  -- Exercício

  theorem strong_progress (t : Tm) : TmValue t ∨ ∃ t', Step t t' := by
    sorry

end TOY

section ARITH

  inductive Exp where
  | True : Exp
  | False : Exp
  | Zero : Exp
  | Succ : Exp → Exp
  | Pred : Exp → Exp
  | IsZero : Exp → Exp
  | If : Exp → Exp → Exp → Exp

  -- small step semantics

  inductive BoolVal : Exp → Prop where
  | ValTrue : BoolVal Exp.True
  | ValFalse : BoolVal Exp.False

  inductive NatVal : Exp → Prop where
  | ValZero : NatVal Exp.Zero
  | ValSucc : ∀ n, NatVal n → NatVal (Exp.Succ n)

  abbrev ExpVal (e : Exp) := BoolVal e ∨ NatVal e

  inductive EStep : Exp → Exp → Prop where
  | EPredZ : EStep (Exp.Pred Exp.Zero) Exp.Zero
  | EPredS : ∀ n, NatVal n →
                  EStep (Exp.Pred (Exp.Succ n))
                        n
  | EIsZeroZ : EStep (Exp.IsZero Exp.Zero) Exp.True
  | EIsZeroS : ∀ n, NatVal n →
                    EStep (Exp.IsZero (Exp.Succ n))
                          Exp.False
  | EIfT : ∀ t1 t2, EStep (Exp.If Exp.True t1 t2)
                          t1
  | EIfF : ∀ t1 t2, EStep (Exp.If Exp.False t1 t2)
                          t2
  | ESucc : ∀ t1 t1', EStep t1 t1' →
                      EStep (Exp.Succ t1) (Exp.Succ t1')
  | EPred : ∀ t1 t1', EStep t1 t1' →
                      EStep (Exp.Pred t1) (Exp.Pred t1')
  | EIsZero : ∀ t1 t1', EStep t1 t1' →
                        EStep (Exp.IsZero t1)
                              (Exp.IsZero t1')
  | EIf : ∀ t1 t1' t2 t3, EStep t1 t1' →
                          EStep (Exp.If t1 t2 t3)
                                (Exp.If t1' t2 t3)

  -- Exercício

  lemma NatValDontStep : ∀ (n : Exp), NatVal n → ¬ ∃ e, EStep n e := by
    intros n H
    induction H with
    | ValZero =>
      intros H2
      rcases H2 with ⟨ x , H2 ⟩
      rcases H2
    | ValSucc n Hn IH =>
      intros H2
      rcases H2 with ⟨ e, H2 ⟩
      cases H2 with
      | ESucc e2 e3 H =>
        apply IH
        exists e3

  theorem EStep_deterministic (e1 e2 e3 : Exp)
    : EStep e1 e2 → EStep e1 e3 → e2 = e3 := sorry
    -- intros H1
    -- induction H1 generalizing e3 with
    -- | EPredZ =>
    --   intros H2
    --   cases H2 with
    --   | EPredZ => rfl
    --   | EPred en1 en2 H =>
    --     cases H
    -- | EPredS n Hn =>
    --   intros H2
    --   cases H2 with
    --   | EPredS m Hm => rfl
    --   | EPred en1 en2 H =>
    --     cases H with
    --     | ESucc e4 e5 H3 =>
    --       have H4 : ¬ ∃ e, EStep n e := by
    --         apply NatValDontStep
    --         assumption
    --       have H5 : ∃ e, EStep n e := by
    --         exists e5
    --       contradiction
    -- | EIsZeroZ => sorry
    -- | EIsZeroS => sorry
    --


  -- type system

  inductive Ty where
  | nat | bool

  inductive EType : Exp → Ty → Prop where
  | TZero : EType Exp.Zero Ty.nat
  | TSucc : ∀ e, EType e Ty.nat → EType (Exp.Succ e) Ty.nat
  | TTrue : EType Exp.True Ty.bool
  | TFalse : EType Exp.False Ty.bool
  | TPred : ∀ e, EType e Ty.nat → EType (Exp.Pred e) Ty.nat
  | TIsZero : ∀ e, EType e Ty.nat → EType (Exp.IsZero e) Ty.bool
  | TIf : ∀ e1 e2 e3 t, EType e1 Ty.bool →
                        EType e2 t →
                        EType e3 t →
                        EType (Exp.If e1 e2 e3) t

  -- Exercício

  theorem EType_deterministic (e1 : Exp)(t1 t2 : Ty)
    : EType e1 t1 → EType e1 t2 → t1 = t2 := sorry
    -- intros H1
    -- induction H1 with
    -- | TZero => intros H2 ; cases H2 ; rfl
    -- | TSucc e H1 IH1 =>
    --   intros H2
    --   cases H2 with
    --   | TSucc e3 H3 => rfl
    -- | TTrue => intros H2 ; cases H2 ; rfl


  theorem Epreservation (e e' : Exp)(t : Ty)
    : EType e t → EStep e e' → EType e' t := by
    induction e generalizing e' t with
    | True =>
      intros _H1 H2
      cases H2
    | False =>
      intros _H1 H2
      cases H2
    | Zero =>
      intros _H1 H2
      cases H2
    | Succ e1 IH1 =>
      intros H1 H2
      cases H2
      case ESucc e2 H2 =>
      cases H1
      constructor
      apply IH1 <;> assumption
    | Pred e1 IH1 =>
      intros H1 H2
      cases H2
      case EPredZ =>
        cases H1
        case TPred H =>
          constructor
      case EPredS n =>
        cases H1
        case TPred H =>
          cases H ; assumption
      case EPred e2 H2 =>
        cases H1
        case TPred =>
          constructor
          apply IH1 <;> assumption
    | IsZero e1 IH1 =>
      intros H1 H2
      cases H2
      case EIsZeroZ =>
        cases H1
        constructor
      case EIsZeroS n H =>
        cases H1
        constructor
      case EIsZero e2 H2 =>
        cases H1
        case TIsZero H3 =>
          constructor
          apply IH1 <;> assumption
    | If e1 e2 e3 IH1 _IH2 _IH3 =>
      intros H1 H2
      cases H2
      case EIfT =>
        cases H1
        case TIf H3 H4 H5 =>
          assumption
      case EIfF =>
        cases H1
        case TIf H3 H4 H5 =>
          assumption
      case EIf e4 H4 =>
        cases H1
        case TIf H1 H2 H3 =>
          constructor <;> try assumption
          apply IH1 <;> assumption

  -- Exercício

theorem progress e t : EType e t → ExpVal e ∨ ∃ e', EStep e e' := by
  intros H
  induction H with
  | TZero =>
      left
      right
      exact NatVal.ValZero
  | TSucc e H1 IH =>
      cases IH
      case inl Hval =>
          cases Hval
          case inr Hnv =>
              left
              right
              exact NatVal.ValSucc e Hnv
          case inl h H =>
              cases H
              ·
                contradiction
              ·
                contradiction
      case inr Hstep =>
          right
          cases Hstep with | intro e' Hstep1 =>
          exists Exp.Succ e'
          apply EStep.ESucc
          assumption
  | TTrue =>
      left
      left
      exact BoolVal.ValTrue
  | TFalse =>
      left
      left
      exact BoolVal.ValFalse
  | TPred e H1 IH =>
      cases IH
      case inl Hval =>
          cases Hval
          case inr Hnv =>
              cases Hnv
              case ValZero =>
                  right
                  exists Exp.Zero
                  apply EStep.EPredZ
              case ValSucc n Hn =>
                  right
                  exists n
                  apply EStep.EPredS
                  assumption
          case inl h H =>
              cases H
              ·
                contradiction
              ·
                contradiction
      case inr Hstep =>
          right
          cases Hstep with | intro e' Hstep1 =>
          exists Exp.Pred e'
          apply EStep.EPred
          assumption
  | TIsZero e H1 IH =>
      cases IH
      case inl Hval =>
          cases Hval
          case inr Hnv =>
              cases Hnv
              case ValZero =>
                  right
                  exists Exp.True
                  apply EStep.EIsZeroZ
              case ValSucc n Hn =>
                  right
                  exists Exp.False
                  apply EStep.EIsZeroS
                  assumption
          case inl h H =>
              cases H
              ·
                contradiction
              ·
                contradiction
      case inr Hstep =>
          right
          cases Hstep with | intro e' Hstep1 =>
          exists Exp.IsZero e'
          apply EStep.EIsZero
          assumption
  | TIf e1 e2 e3 _ Hcond _ _ IHcond _ _ =>
      cases IHcond
      case inl Hval =>
          cases Hval
          case inl Hbv =>
              cases Hbv
              case ValTrue =>
                  right
                  exists e2
                  apply EStep.EIfT
              case ValFalse =>
                  right
                  exists e3
                  apply EStep.EIfF
          case inr h H =>
              cases H
              ·
                contradiction
              ·
                contradiction
      case inr Hstep =>
          right
          cases Hstep with | intro e1' Hstep1 =>
          exists Exp.If e1' e2 e3
          apply EStep.EIf
          assumption

end ARITH
