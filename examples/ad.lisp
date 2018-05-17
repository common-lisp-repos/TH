(defpackage th.ad-example
  (:use #:common-lisp
        #:mu
        #:th))

(in-package :th.ad-example)

;; broadcast
(let* ((out ($broadcast (variant 5) (constant (tensor '(1 2 3)))))
       (gradient ($bp! out (tensor '(1 2 3)))))
  (print gradient))

(let* ((out ($broadcast (variant 5) (constant '(1 2 3))))
       (gradient ($bp! out (tensor '(1 2 3)))))
  (print gradient))

;; add
(let* ((a (variant (tensor '(1 1 1))))
       (b (variant (tensor '(1 1 1))))
       (out ($add a b))
       (gradient ($bp! out (tensor '(1 1 1)))))
  (print gradient)
  (print ($children gradient)))

(let* ((a (variant '(1 1 1)))
       (b (variant '(1 1 1)))
       (out ($add a b))
       (gradient ($bp! out (tensor '(1 1 1)))))
  (print gradient)
  (print ($children gradient)))

;; sub
(let* ((out ($sub (constant (tensor '(1 2 3))) (variant (tensor '(3 2 1)))))
       (gradient ($bp! out (tensor '(1 1 1)))))
  (print gradient)
  (print ($children gradient)))

(let* ((out ($sub (constant '(1 2 3)) (variant '(3 2 1))))
       (gradient ($bp! out (tensor '(1 1 1)))))
  (print gradient)
  (print ($children gradient)))

;; dot
(let* ((x (tensor '(1 2 3)))
       (out ($dot (variant x) (constant x)))
       (gradient ($bp! out 2)))
  (print gradient))

;; update
(let* ((a (constant (tensor '(1 1 1))))
       (b (variant (tensor '(1 2 3))))
       (out ($dot a b))
       (gradient ($bp! out 1)))
  (print gradient)
  (print ($gd! gradient))
  (print b))

(let* ((a (constant '(1 1 1)))
       (b (variant '(1 2 3)))
       (out ($dot a b))
       (gradient ($bp! out 1)))
  (print gradient)
  (print ($gd! gradient))
  (print b))

;; linear mapping
(let* ((X (constant (tensor '((1) (3)))))
       (Y (constant (tensor '(-10 -30))))
       (c (variant 0))
       (b (variant (tensor '(10)))))
  (loop :for i :from 0 :below 2000
        :do (let* ((d ($sub ($add ($mv X b) ($broadcast c Y)) Y))
                   (out ($dot d d))
                   (gradient ($bp! out 1)))
              (when (zerop (mod i 100)) (print (list i ($data out))))
              ($gd! gradient)))
  (print b))

(let* ((X (constant '((1) (3))))
       (Y (constant '(-10 -30)))
       (c (variant 0))
       (b (variant '(10))))
  (loop :for i :from 0 :below 2000
        :do (let* ((d ($sub ($add ($mv X b) ($broadcast c Y)) Y))
                   (out ($dot d d))
                   (gradient ($bp! out 1)))
              (when (zerop (mod i 100)) (print (list i ($data out))))
              ($gd! gradient)))
  (print b))

(let* ((X (constant (-> (range 0 10)
                        ($transpose!))))
       (Y (constant (range 0 10)))
       (c (variant 0))
       (b (variant (tensor '(0)))))
  (loop :for i :from 0 :below 2000
        :do (let* ((Y* ($add ($mv X b) ($broadcast c Y)))
                   (d ($sub Y* Y))
                   (out ($dot d d))
                   (gradient ($bp! out 1)))
              (when (zerop (mod i 100)) (print (list i ($data out))))
              ($gd! gradient 0.001)))
  (print b))

(let* ((X (constant (-> (tensor '((1 1 2)
                                  (1 3 1)))
                        ($transpose!))))
       (Y (constant (tensor '(1 2 3))))
       (c (variant 0))
       (b (variant (tensor '(1 1)))))
  (loop :for i :from 0 :below 1000
        :do (let* ((d ($sub ($add ($mv X b) ($broadcast c Y)) Y))
                   (out ($dot d d))
                   (gradient ($bp! out 1)))
              (when (zerop (mod i 100)) (print (list i ($data out))))
              ($gd! gradient 0.05)))
  (print b)
  (print c))

;; regressions
(let* ((X (constant (-> (tensor '(1 3))
                        ($transpose!))))
       (Y (constant (tensor '(-10 -30))))
       (c (variant 0))
       (b (variant (tensor '(10)))))
  (loop :for i :from 0 :below 1000
        :do (let* ((d ($sub ($add ($mv X b) ($broadcast c Y)) Y))
                   (out ($dot d d))
                   (gradient ($bp! out 1)))
              (when (zerop (mod i 100)) (print ($data out)))
              ($gd! gradient 0.02)))
  (print ($add ($mv X b) ($broadcast c Y))))

(let* ((X (constant (tensor '((5 2) (-1 0) (5 2)))))
       (Y (constant (tensor '(1 0 1))))
       (c (variant 0))
       (b (variant (tensor '(0 0)))))
  (loop :for i :from 0 :below 1000
        :do (let* ((Y* ($sigmoid ($add ($mv X b) ($broadcast c Y))))
                   (out ($bce Y* Y))
                   (gradient ($bp! out 1)))
              (when (zerop (mod i 100)) (print ($data out)))
              ($gd! gradient 0.1)))
  (print ($sigmoid ($add ($mv X b) ($broadcast c Y)))))

;; xor
(let* ((w1 (variant (rndn 2 3)))
       (w2 (variant (rndn 3 1)))
       (X (constant '((0 0) (0 1) (1 0) (1 1))))
       (Y (constant '(0 1 1 0))))
  (loop :for i :from 0 :below 1000
        :do (let* ((l1 ($sigmoid ($mm X w1)))
                   (l2 ($sigmoid ($mm l1 w2)))
                   (d ($sub l2 Y))
                   (out ($dot d d))
                   (gradient ($bp! out 1)))
              (when (zerop (mod i 100)) (print ($data out)))
              ($gd! gradient 1.0)))
  (print w1)
  (print w2)
  (print (let* ((l1 ($sigmoid ($mm X w1)))
                (l2 ($sigmoid ($mm l1 w2))))
           l2)))

(let* ((w1 (variant (rndn 2 3)))
       (w2 (variant (rndn 3 1)))
       (X (constant '((0 0) (0 1) (1 0) (1 1))))
       (Y (constant '(0 1 1 0))))
  (loop :for i :from 0 :below 1000
        :do (let* ((l1 ($tanh ($mm X w1)))
                   (l2 ($sigmoid ($mm l1 w2)))
                   (d ($sub l2 Y))
                   (out ($dot d d))
                   (gradient ($bp! out 1)))
              (when (zerop (mod i 100)) (print ($data out)))
              ($gd! gradient 1.0)))
  (print (let* ((l1 ($tanh ($mm X w1)))
                (l2 ($sigmoid ($mm l1 w2))))
           l2)))