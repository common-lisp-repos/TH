(defpackage :rnn-manual-check
  (:use #:common-lisp
        #:mu
        #:th))

(in-package :rnn-manual-check)

;; following code is for checking manually computed simple recurrent neural network
;; both forward and backward propagation through time

;; before
(let* ((w 0.5)
       (v 1)
       (u 1)
       (x 1)
       (ps 0)
       (a (* ps w))
       (b (* v x))
       (z (+ a b))
       (s z)
       (p (* u s))
       (y 1)
       (d (- y p))
       (l (* d d))
       (sl l))
  (prn "L1:" sl l p)
  (let* ((x 1)
         (ps s)
         (a (* ps w))
         (b (* v x))
         (z (+ a b))
         (s z)
         (p (* u s))
         (y 2)
         (d (- y p))
         (pl l)
         (l (* d d))
         (sl (+ pl l)))
    (prn "L2:" sl l p)
    (let* ((x 1)
           (ps s)
           (a (* ps w))
           (b (* v x))
           (z (+ a b))
           (s z)
           (p (* u s))
           (y 3)
           (d (- y p))
           (pl sl)
           (l (* d d))
           (sl (+ pl l)))
      (prn "L3:" sl l p))))

;; after one iteration
(let* ((alpha 0.01)
       (w (- 0.5 (* alpha -6.0)))
       (v (- 1 (* alpha -5.875)))
       (u (- 1 (* alpha -5.875)))
       (x 1)
       (ps 0)
       (a (* ps w))
       (b (* v x))
       (z (+ a b))
       (s z)
       (p (* u s))
       (y 1)
       (d (- y p))
       (l (* d d))
       (sl l))
  (prn "L1:" sl l p)
  (let* ((x 1)
         (ps s)
         (a (* ps w))
         (b (* v x))
         (z (+ a b))
         (s z)
         (p (* u s))
         (y 2)
         (d (- y p))
         (pl l)
         (l (* d d))
         (sl (+ pl l)))
    (prn "L2:" sl l p)
    (let* ((x 1)
           (ps s)
           (a (* ps w))
           (b (* v x))
           (z (+ a b))
           (s z)
           (p (* u s))
           (y 3)
           (d (- y p))
           (pl sl)
           (l (* d d))
           (sl (+ pl l)))
      (prn "L3:" sl l p))))

;; next code is a simple linear recurrent neural network.
;; the network is for counting how many 1's in the input sequence.

(defparameter *x* ($constant '((1) (1) (1))))
(defparameter *y* ($constant '((1) (2) (3))))

(defparameter *w* ($variable '((0.5))))
(defparameter *u* ($variable '((1))))
(defparameter *v* ($variable '((1))))

(loop :for iter :from 0 :below 1
      :for states = (list ($constant '((0))))
      :for losses = '()
      :do (progn
            (loop :for i :from 0 :below ($size *x* 0)
                  :for x = ($index *x* 0 i)
                  :for y = ($index *y* 0 i)
                  :for ps = ($0 states)
                  :for a = ($@ ps *w*)
                  :for b = ($@ x *v*)
                  :for s = ($+ a b)
                  :for p = ($@ s *u*)
                  :for d = ($- y p)
                  :for l = ($expt d 2)
                  :do (progn
                        (push s states)
                        (push l losses)))
            ($bptt! losses)
            ;; (prn "*******")
            ;; ($bp! ($0 losses))
            ;; ($np! ($1 losses))
            ;; ($np! ($2 losses))
            ;; (prn "*******")
            (prn ($gradient *u*))
            (prn ($gradient *v*))
            (prn ($gradient *w*))))
