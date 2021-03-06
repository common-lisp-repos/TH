;; from
;; https://towardsdatascience.com/only-numpy-vanilla-recurrent-neural-network-back-propagation-practice-math-956fbea32704

(defpackage :rnn-simple
  (:use #:common-lisp
        #:mu
        #:th))

(in-package :rnn-simple)

(defparameter *x* (tensor '((1 0 0)
                            (1 1 0)
                            (1 1 1))))
(defparameter *y* (tensor '((1) (2) (3))))

(defparameter *wx* (tensor '((0.2))))
(defparameter *wr* (tensor '((1.5))))

(defparameter *number-of-epoch* 30000)
(defparameter *number-of-training-data* 3)
(defparameter *learnig-rate-x* 0.02)
(defparameter *learnig-rate-r* 0.0006)

(defparameter *states* (zeros 3 (1+ ($size *x* 1))))
(defparameter *grad-over-time* (zeros 3 4))

(defun forward-step (i)
  (let ((layer ($add ($mm ($index *x* 1 i) *wx*)
                     ($mm ($index *states* 1 i) *wr*))))
    (setf ($index *states* 1 (1+ i)) layer)
    layer))

(defun forward ()
  (loop :for i :from 0 :below ($size *x* 1) :do (forward-step i))
  ($index *states* 1 ($size *x* 1)))

(defun backward-time (grad-out n)
  (setf ($index *grad-over-time* 1 n) grad-out)
  (loop :for k :from (1- n) :downto 1
        :for grad = ($index *grad-over-time* 1 (1+ k))
        :do (setf ($index *grad-over-time* 1 k) ($mm grad *wr*))))

;; XXX how can i make a function for proceccing each forward/backward step?
(loop :for iter :from 0 :below *number-of-epoch*
      :for y = (forward)
      :for cost = ($div ($sum ($expt ($sub y *y*) 2)) *number-of-training-data*)
      :for grad-out = ($div ($mul ($sub y *y*) 2) *number-of-training-data*)
      :do (progn
            (backward-time grad-out ($size *x* 1))
            (let ((grad-wx ($sum ($+ ($mul ($index *grad-over-time* 1 3)
                                           ($index *x* 1 2))
                                     ($mul ($index *grad-over-time* 1 2)
                                           ($index *x* 1 1))
                                     ($mul ($index *grad-over-time* 1 1)
                                           ($index *x* 1 0)))))
                  (grad-wr ($sum ($+ ($mul ($index *grad-over-time* 1 3)
                                           ($index *states* 1 2))
                                     ($mul ($index *grad-over-time* 1 2)
                                           ($index *states* 1 1))
                                     ($mul ($index *grad-over-time* 1 1)
                                           ($index *states* 1 0))))))
              ($sub! *wx* ($mul *learnig-rate-x* grad-wx))
              ($sub! *wr* ($mul *learnig-rate-r* grad-wr))
              (when (zerop (rem iter 1000))
                (prn iter y)))))

;; final result
(progn
  (prn (forward))
  (prn *wx* *wr*))

;; ad
(let* ((x ($variable '(0)))
       (y ($sigmoid x)))
  ($bp! y)
  (prn y ($gradient x)))
