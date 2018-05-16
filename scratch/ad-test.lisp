(defpackage :th.ad-test
  (:use #:common-lisp
        #:mu
        #:th))

(in-package :th.ad-test)

(let* ((a (const (tensor '(5 5 5))))
       (c (var 5))
       (out ($broadcast c a))
       (gradient ($bp! out (tensor '(1 1 1)))))
  (unless ($eq ($data out) ($data a))
    (error "out should be the same one as a"))
  (unless (= 3 (-> gradient
                   ($children)
                   ($first)
                   ($gradient)))
    (error "should be 3")))

(let* ((a (const (tensor '(1 0 -3.21))))
       (b (const (tensor '(-1.3 2.8 -0.1)))))
  (unless (< (abs (- 11.3041 ($data ($dot a a)))) 0.0001)
    (error "invalid dot a and a"))
  (unless (< (abs (- -0.979 ($data ($dot a b)))) 0.01)
    (error "invalid dot a and b"))
  (unless ($eq ($data ($add a b)) (tensor '(-0.3 2.8 -3.31)))
    (error "invalid add a b"))
  (unless ($eq ($data ($sub a b)) (tensor '(2.3 -2.8 -3.11)))
    (error "invalid sub a b"))
  (unless ($eq ($data ($mul a b)) (tensor '(-1.3 0.0 0.321)))
    (error "invalid mul a b"))
  (unless ($eq ($data ($mv (const (tensor '((1 0 0) (0 2 0) (0 0 3)))) a))
               (tensor '(1.0 0.0 -9.63)))
    (error "invalid mm"))
  (unless ($eq ($data ($sigmoid a)) (tensor '(0.73 0.50 0.04)))
    (error "invalid sigmoid"))
  (unless ($eq ($data ($log (const (tensor '(0.2 0.9 3.21)))))
               (tensor '(-1.6094379124341003
                         -0.10536051565782628
                         1.1662709371419244)))
    (error "invalid log"))
  (unless (= ($data ($bce (const (tensor '(0.1 0.5 0.9)))
                          (const (tensor '(0 0 1)))))
             0.9038682400222361d0)
    (error "invalid bce")))

(let* ((m (var (tensor '((2 0) (0 2)))))
       (v (const (tensor '(2 3))))
       (out ($mv m v))
       (gradient ($bp! out (tensor '(1 1)))))
  (unless ($eq (-> gradient ($children) ($first) ($gradient))
               (tensor '((2.0 2.0) (3.0 3.0))))
    (print (-> gradient ($children) ($first) ($gradient)))
    (error "mv")))

(let* ((A (tensor '((1 1 1) (1 1 1))))
       (B (tensor '((0.1) (0.1) (0.1))))
       (delta (tensor '((1.0) (1.0))))
       (out ($sigmoid ($mm (var A) (var B))))
       (gradient ($bp! out delta)))
  (unless ($eq (-> gradient ($children) ($first) ($gradient))
               (tensor '((2.4445831169074586)
                         (2.4445831169074586))))
    (error "mm")))

(let* ((X (const (-> (tensor '(1 3))
                     ($transpose!))))
       (Y (const (tensor '(-10 -30))))
       (c (var 0))
       (b (var (tensor '(10)))))
  (loop :for i :from 0 :below 1000
        :do (let* ((d ($sub ($add ($mv X b) ($broadcast c Y)) Y))
                   (out ($dot d d))
                   (gradient ($bp! out 1)))
              (when (zerop (mod i 100)) (print ($data out)))
              ($gd! gradient 0.02)))
  (print ($add ($mv X b) ($broadcast c Y))))

(let* ((X (const (tensor '((5 2) (-1 0) (5 2)))))
       (Y (const (tensor '(1 0 1))))
       (c (var 0))
       (b (var (tensor '(0 0)))))
  (loop :for i :from 0 :below 1000
        :do (let* ((Y* ($sigmoid ($add ($mv X b) ($broadcast c Y))))
                   (out ($bce Y* Y))
                   (gradient ($bp! out 1)))
              (when (zerop (mod i 100)) (print ($data out)))
              ($gd! gradient 0.1)))
  (print ($sigmoid ($add ($mv X b) ($broadcast c Y)))))
