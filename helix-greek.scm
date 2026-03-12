; Greek.hx: GREEK mode for Helix
; Copyright (C) 2026  Anton Pyrogovskyi <anton@tech.gets.love>
; 
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.

(require "helix/keymaps.scm")
(require "helix/configuration.scm")
(require (prefix-in helix.static. "helix/static.scm"))
(require-builtin helix/core/keymaps as helix.keymaps.)

;;@doc
;; Default list of (key, char, name) associations
;; Uppercase forms are derived automatically
;; Based on MIT space cadet / CADR keyboard layout
;; This exact mechanism can also be extended to assist with entering any Unicode range
(define default-greek-table '(
  ("a" #\α "alpha")        ; U+0391 Α, U+03B1 α
  ("b" #\β "beta")         ; U+0392 Β, U+03B2 β
  ("g" #\γ "gamma")        ; U+0393 Γ, U+03B3 γ
  ("d" #\δ "delta")        ; U+0394 Δ, U+03B4 δ
  ("e" #\ε "epsilon")      ; U+0395 Ε, U+03B5 ε
  ("z" #\ζ "zeta")         ; U+0396 Ζ, U+03B6 ζ
  ("h" #\η "eta")          ; U+0397 Η, U+03B7 η
  ("q" #\θ "theta")        ; U+0398 Θ, U+03B8 θ
  ("i" #\ι "iota")         ; U+0399 Ι, U+03B9 ι
  ("j" #\ϑ "theta-symbol") ; U+0398 ϴ, U+03D1 ϑ
  ("k" #\κ "kappa")        ; U+039A Κ, U+03BA κ
  ("l" #\λ "lambda")       ; U+039B Λ, U+03BB λ
  ("m" #\μ "mu")           ; U+039C Μ, U+03BC μ
  ("n" #\ν "nu")           ; U+039D Ν, U+03BD ν
  ("x" #\ξ "xi")           ; U+039E Ξ, U+03BE ξ
  ("o" #\ο "omicron")      ; U+039F Ο, U+03BF ο
  ("p" #\π "pi")           ; U+03A0 Π, U+03C0 π
  ("r" #\ρ "rho")          ; U+03A1 Ρ, U+03C1 ρ
  ("s" #\σ "sigma")        ; U+03A3 Σ, U+03C3 σ
  ("t" #\τ "tau")          ; U+03A4 Τ, U+03C4 τ
  ("u" #\υ "upsilon")      ; U+03A5 Υ, U+03C5 υ
  ("f" #\φ "phi")          ; U+03A6 Φ, U+03C6 φ
  ("c" #\χ "chi")          ; U+03A7 Χ, U+03C7 χ
  ("y" #\ψ "psi")          ; U+03A8 Ψ, U+03C8 ψ
  ("w" #\ω "omega")        ; U+03A9 Ω, U+03C9 ω
  ("v" #\ς "sigma-final")  ; U+03A3 Σ, U+03C2 ς
))

;;@doc
;; - Define insert-<name> and insert-<Name> commands
;; - Bind them to keys in respective mode
;; - Set docstrings: unicode glyph of the letter itself
(define (setup-greek-bindings! table mode trigger)
  (define (define-single! key cmd char)
    (eval `(define (,(string->symbol cmd)) (helix.static.insert_char ,char)))
    (list (list key (string-append ":" cmd)) (list cmd (string char))))
  (define (define-dual! key char name)
    (define (string-capitalize str)
      ((λ (lst) (list->string (cons (char-upcase (car lst)) (cdr lst))))
      (string->list str)))
    (list
      (define-single! key (string-append "insert-" name) char)
      (define-single! (string-upcase key) (string-append "insert-" (string-capitalize name)) (char-upcase char))))
  (apply
    (λ (keymap docs)
      (define global-bindings (get-keybindings))
      (merge-keybindings global-bindings (hash mode (hash trigger keymap)))
      (helix.keymaps.keymap-update-documentation! global-bindings docs)
      (keybindings global-bindings))
    (fold
      (λ (x acc) (list
        (hash-insert (car acc) (caar x) (cadar x))
        (hash-insert (cadr acc) (caadr x) (cadadr x))))
      (list (hash) (hash))
      (transduce table (flat-mapping (λ (spec) (apply define-dual! spec))) (into-list)))))

(provide default-greek-table setup-greek-bindings!)

;;@doc
;; Example usage in init.scm:
; (require "helix-greek/helix-greek.scm")
; (setup-greek-bindings! default-greek-table "insert" "C-l")
