(defpackage th.ad-example
  (:use #:common-lisp
        #:mu
        #:th))

(in-package :th.ad-example)

;; broadcast
(let* ((out ($broadcast (var 5) (const (tensor '(1 2 3)))))
       (gradient ($backprop out (tensor '(1 2 3)))))
  (print gradient))

;; add
(let* ((a (var (tensor '(1 1 1))))
       (b (var (tensor '(1 1 1))))
       (out ($add a b))
       (gradient ($backprop out (tensor '(1 1 1)))))
  (print gradient)
  (print ($children gradient)))

;; sub
(let* ((out ($sub (const (tensor '(1 2 3))) (var (tensor '(3 2 1)))))
       (gradient ($backprop out (tensor '(1 1 1)))))
  (print gradient)
  (print ($children gradient)))

;; dot
(let* ((x (tensor '(1 2 3)))
       (out ($dot (var x) (const x)))
       (gradient ($backprop out 2)))
  (print gradient))

;; update
(let* ((a (const (tensor '(1 1 1))))
       (b (var (tensor '(1 2 3))))
       (out ($dot a b))
       (gradient ($backprop out 1)))
  (print gradient)
  (print ($gd! gradient))
  (print b))

;; linear mapping
(let* ((X (const (tensor '((1) (3)))))
       (Y (const (tensor '(-10 -30))))
       (c (var 0))
       (b (var (tensor '(10)))))
  (loop :for i :from 0 :below 2000
        :do (let* ((d ($sub ($add ($mv X b) ($broadcast c Y)) Y))
                   (out ($dot d d))
                   (gradient ($backprop out 1)))
              (when (zerop (mod i 100)) (print (list i ($data out))))
              ($gd! gradient)))
  (print b))

(let* ((X (const (-> (range 0 10)
                     ($transpose!))))
       (Y (const (range 0 10)))
       (c (var 0))
       (b (var (tensor '(0)))))
  (loop :for i :from 0 :below 2000
        :do (let* ((Y* ($add ($mv X b) ($broadcast c Y)))
                   (d ($sub Y* Y))
                   (out ($dot d d))
                   (gradient ($backprop out 1)))
              (when (zerop (mod i 100)) (print (list i ($data out))))
              ($gd! gradient 0.001)))
  (print b))

(let* ((X (const (-> (tensor '((1 1 2)
                               (1 3 1)))
                     ($transpose!))))
       (Y (const (tensor '(1 2 3))))
       (c (var 0))
       (b (var (tensor '(1 1)))))
  (loop :for i :from 0 :below 1000
        :do (let* ((d ($sub ($add ($mv X b) ($broadcast c Y)) Y))
                   (out ($dot d d))
                   (gradient ($backprop out 1)))
              (when (zerop (mod i 100)) (print (list i ($data out))))
              ($gd! gradient 0.05)))
  (print b)
  (print c))
