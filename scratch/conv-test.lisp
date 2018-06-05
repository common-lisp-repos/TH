(defpackage :conv-test
  (:use #:common-lisp
        #:mu
        #:th))

(in-package :conv-test)

;; some basic test on convolution
(let ((x (rnd 100 100))
      (k (rnd 10 10)))
  (print ($size ($conv2 x k)))
  (print ($size ($conv2 x k :full))))
(let ((x (rnd 50 100 100))
      (k (rnd 50 10 10)))
  (print ($size ($conv2 x k)))
  (print ($size ($conv2 x k :full))))

;; base conv2 operation
(let* ((x ($constant  '(((10 20 30 40) (41 31 21 11) (12 22 32 42) (43 33 23 13))
                        ((40 30 20 10) (11 21 31 41) (42 32 22 12) (13 23 33 43)))))
       (k ($variable '(((1 0 1) (0 1 0) (1 0 1))
                       ((1 1 1) (0 0 0) (1 1 1))))))
  (print x)
  (print ($conv2 ($data x) ($data k)))
  (print ($sum ($conv2 ($data x) ($data k)) 0))
  (print ($conv2 x k))
  (print ($sum ($conv2 x k) 0))
  (print ($reshape ($sum ($conv2 x k) 0) 1 2 2)))

(let* ((x (tensor  '(((10 20 30 40) (41 31 21 11) (12 22 32 42) (43 33 23 13))
                     ((40 30 20 10) (11 21 31 41) (42 32 22 12) (13 23 33 43)))))
       (k (tensor '((((1 0 1) (0 1 0) (1 0 1))
                     ((1 1 1) (0 0 0) (1 1 1))))))
       (b (tensor '(1)))
       (dk (apply #'zeros ($size k)))
       (db (tensor '(1)))
       (finput (tensor))
       (dfinput (tensor))
       (out (tensor))
       (gradient (tensor))
       (dout (tensor '(((301 271) (282 313))))))
  (th::nn-spatial-convolution-mm-update-output x out k b finput dfinput
                                               ($size k 2) ($size k 3) 1 1 0 0)
  (print out)
  (th::nn-spatial-convolution-mm-update-grad-input x dout gradient k finput dfinput
                                                   ($size k 2) ($size k 3) 1 1 0 0)
  (print gradient)
  (th::nn-spatial-convolution-mm-acc-grad-parameters x dout dk db finput dfinput
                                                     ($size k 2) ($size k 3) 1 1 0 0
                                                     1)
  (print dk)
  (print db))

(let* ((x ($constant  '(((10 20 30 40) (41 31 21 11) (12 22 32 42) (43 33 23 13))
                        ((40 30 20 10) (11 21 31 41) (42 32 22 12) (13 23 33 43)))))
       (k ($variable '(((1 0 1) (0 1 0) (1 0 1))
                       ((1 1 1) (0 0 0) (1 1 1)))))
       (c ($sum ($conv2 x k) 0))
       (g (tensor '((300 270) (281 311)))))
  (print c)
  ($bp! c g)
  (print ($gradient k)))

(let* ((x (tensor  '(((10 20 30 40) (41 31 21 11) (12 22 32 42) (43 33 23 13))
                     ((40 30 20 10) (11 21 31 41) (42 32 22 12) (13 23 33 43)))))
       (k (tensor '((((1 0 1) (0 1 0) (1 0 1))
                     ((1 1 1) (0 0 0) (1 1 1))))))
       (b (tensor '(1)))
       (finput (tensor))
       (dfinput (tensor))
       (c (tensor))
       (g (tensor '(((1 1) (1 1)))))
       (dx (tensor))
       (dk (apply #'zeros ($size k)))
       (db (tensor '(0))))
  (th::nn-spatial-convolution-mm-update-output x c k b finput dfinput
                                               ($size k 2) ($size k 3) 1 1 0 0)
  (print c)
  (th::nn-spatial-convolution-mm-update-grad-input x g dx k finput dfinput
                                                   ($size k 2) ($size k 3) 1 1 0 0)
  (print dx)
  (th::nn-spatial-convolution-mm-acc-grad-parameters x g dk db finput dfinput
                                                     ($size k 2) ($size k 3) 1 1 0 0
                                                     1)
  (print ($reshape dk 2 3 3))
  (print db))

(let* ((x (tensor  '(((10 20 30 40) (41 31 21 11) (12 22 32 42) (43 33 23 13))
                     ((40 30 20 10) (11 21 31 41) (42 32 22 12) (13 23 33 43)))))
       (k (tensor '((((1 0 1) (0 1 0) (1 0 1))
                     ((1 1 1) (0 0 0) (1 1 1))))))
       (b (tensor '(1))))
  (print ($conv2d x k b)))

(let* ((x (tensor  '((((10 20 30 40) (41 31 21 11) (12 22 32 42) (43 33 23 13))
                      ((40 30 20 10) (11 21 31 41) (42 32 22 12) (13 23 33 43)))
                     (((10 20 30 40) (41 31 21 11) (12 22 32 42) (43 33 23 13))
                      ((40 30 20 10) (11 21 31 41) (42 32 22 12) (13 23 33 43))))))
       (k (tensor '((((1 0 1) (0 1 0) (1 0 1))
                     ((1 1 1) (0 0 0) (1 1 1)))
                    (((1 0 1) (0 1 0) (1 0 1))
                     ((1 1 1) (0 0 0) (1 1 1))))))
       (b (tensor '(1 1))))
  (print ($conv2d x k b)))

(let* ((x ($constant '(((10 20 30 40) (41 31 21 11) (12 22 32 42) (43 33 23 13))
                       ((40 30 20 10) (11 21 31 41) (42 32 22 12) (13 23 33 43)))))
       (k ($variable '((((1 0 1) (0 1 0) (1 0 1))
                        ((1 1 1) (0 0 0) (1 1 1))))))
       (b ($variable '(1)))
       (o ($conv2d x k b))
       (g (tensor '(((1 1) (1 1))))))
  (print o)
  ($bp! o g)
  (print ($reshape ($gradient k) 2 3 3))
  (print ($gradient b))
  ($gd! o 0.01)
  (print k)
  (print ($reshape k 2 3 3))
  (print b)
  (print ($conv2d x k b)))

(let* ((x (tensor  '(((10 20 30 40 50)
                      (51 41 31 21 11)
                      (12 22 32 42 52)
                      (53 43 33 23 13)
                      (14 24 34 44 54))
                     ((10 20 30 40 50)
                      (51 41 31 21 11)
                      (12 22 32 42 52)
                      (53 43 33 23 13)
                      (14 24 34 44 54)))))
       (k (tensor '((((1 0 1) (0 1 0) (1 0 1))
                     ((1 1 1) (0 0 0) (1 1 1))))))
       (b (tensor '(1)))
       (c ($conv2d x k b))
       (p ($empty x))
       (indices (tensor.long))
       (g (tensor '(((1 1) (1 1)))))
       (dp ($empty p)))
  (th::nn-spatial-max-pooling-update-output c p indices 2 2 1 1 0 0 nil)
  (print p)
  (th::nn-spatial-max-pooling-update-grad-input c g dp indices 2 2 1 1 0 0 nil)
  (print dp))

(let* ((x (tensor  '(((10 20 30 40 50)
                      (51 41 31 21 11)
                      (12 22 32 42 52)
                      (53 43 33 23 13)
                      (14 24 34 44 54))
                     ((10 20 30 40 50)
                      (51 41 31 21 11)
                      (12 22 32 42 52)
                      (53 43 33 23 13)
                      (14 24 34 44 54)))))
       (k (tensor '((((1 0 1) (0 1 0) (1 0 1))
                     ((1 1 1) (0 0 0) (1 1 1))))))
       (b (tensor '(1)))
       (c ($conv2d x k b))
       (p ($maxpool2d c 2 2)))
  (print p))

(let* ((x ($constant '(((10 20 30 40 50)
                        (51 41 31 21 11)
                        (12 22 32 42 52)
                        (53 43 33 23 13)
                        (14 24 34 44 54))
                       ((10 20 30 40 50)
                        (51 41 31 21 11)
                        (12 22 32 42 52)
                        (53 43 33 23 13)
                        (14 24 34 44 54)))))
       (k ($variable '((((1 0 1) (0 1 0) (1 0 1))
                        ((1 1 1) (0 0 0) (1 1 1))))))
       (b ($variable '(1)))
       (c ($conv2d x k b))
       (p ($maxpool2d c 2 2))
       (g (tensor '(((1 1) (1 1))))))
  (print c)
  (print p)
  ($bp! p g)
  (print ($gradient c))
  (print ($gradient k)))

(let* ((x (tensor  '(((10 20 30 40 50)
                      (51 41 31 21 11)
                      (12 22 32 42 52)
                      (53 43 33 23 13)
                      (14 24 34 44 54))
                     ((10 20 30 40 50)
                      (51 41 31 21 11)
                      (12 22 32 42 52)
                      (53 43 33 23 13)
                      (14 24 34 44 54)))))
       (k (tensor '((((1 0 1) (0 1 0) (1 0 1))
                     ((1 1 1) (0 0 0) (1 1 1))))))
       (b (tensor '(1)))
       (c ($conv2d x k b))
       (p ($empty x))
       (g (tensor '(((1 1) (1 1)))))
       (dp ($empty p)))
  (th::nn-spatial-average-pooling-update-output c p 2 2 1 1 0 0 nil t)
  (print p)
  (th::nn-spatial-average-pooling-update-grad-input c g dp 2 2 1 1 0 0 nil t)
  (print dp))

(let* ((x ($constant '(((10 20 30 40 50)
                        (51 41 31 21 11)
                        (12 22 32 42 52)
                        (53 43 33 23 13)
                        (14 24 34 44 54))
                       ((10 20 30 40 50)
                        (51 41 31 21 11)
                        (12 22 32 42 52)
                        (53 43 33 23 13)
                        (14 24 34 44 54)))))
       (k ($variable '((((1 0 1) (0 1 0) (1 0 1))
                        ((1 1 1) (0 0 0) (1 1 1))))))
       (b ($variable '(1)))
       (c ($conv2d x k b))
       (p ($avgpool2d c 2 2))
       (g (tensor '(((1 1) (1 1))))))
  (print p)
  ($bp! p g)
  (print ($gradient c))
  (print ($gradient k)))