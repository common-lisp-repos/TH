(defpackage :cartpole-dqn
  (:use #:common-lisp
        #:mu
        #:th
        #:th.layers
        #:th.env
        #:th.env.cartpole-regulator))

(in-package :cartpole-dqn)

(defun model (&optional (ni 5) (no 1))
  (let ((h1 5)
        (h2 5))
    (sequential-layer
     (affine-layer ni h1 :weight-initializer :random-uniform)
     (affine-layer h1 h2 :weight-initializer :random-uniform)
     (affine-layer h2 no :weight-initializer :random-uniform))))

(defun best-action-selector (model)
  (lambda (state)
    (let* ((state ($reshape state 1 4))
           (qleft ($evaluate model ($concat state (zeros 1 1) 1)))
           (qright ($evaluate model ($concat state (ones 1 1) 1))))
      (if (>= ($ qleft 0 0) ($ qright 0 0)) 1 0))))

(defun sample-experiences (experiences nbatch)
  (let ((nr ($count experiences)))
    (if (> nr nbatch)
        (loop :repeat nbatch :collect ($ experiences (random nr)))
        experiences)))

(defun generate-dataset (model experiences &optional (gamma 0.95D0))
  (let* ((nr ($count experiences))
         (state-list (mapcar #'$0 experiences))
         (states (-> (apply #'$concat state-list)
                     ($reshape! nr 4)))
         (actions (-> (tensor (mapcar #'$1 experiences))
                      ($reshape! nr 1)))
         (costs (-> (tensor (mapcar #'$2 experiences))
                    ($reshape! nr 1)))
         (next-states (-> (apply #'$concat (mapcar #'$3 experiences))
                          ($reshape! nr 4)))
         (dones (-> (tensor (mapcar (lambda (e) (if ($4 e) 1 0)) experiences))
                    ($reshape! nr 1)))
         (xs ($concat states actions 1))
         (qleft ($evaluate model ($concat next-states (zeros nr 1) 1)))
         (qright ($evaluate model ($concat next-states (ones nr 1) 1)))
         (qns ($min ($concat qleft qright 1) 1))
         (tqvs ($+ costs ($* gamma qns ($- 1 dones)))))
    (list xs tqvs)))

(defun train (model xs ts)
  (let* ((ys ($execute model xs))
         (loss ($mse ys ts)))
    ($rpgd! model)
    ($data loss)))

(defvar *init-experience* nil)
(defvar *increment-experience* T)
(defvar *hint-to-goal* nil)
(defvar *max-buffer-size* 4096)
(defvar *batch-size* 512)
(defvar *max-epochs* 1000)
(defvar *sync-period* 15)

(setf *init-experience* nil
      *hint-to-goal* nil)

(defun report (epoch loss ntrain ctrain neval ceval success)
  (when (or success (zerop (rem epoch 20)))
    (let ((fmt "EPOCH ~4D | TRAIN ~3D / ~4,2F | EVAL ~4D / ~5,2F | TRAIN.LOSS ~,4F"))
      (prn (format nil fmt epoch ntrain ctrain neval ceval loss)))))

(defun sync-models (target online)
  ($cg! (list target online))
  (loop :for pt :in ($parameters target)
        :for po :in ($parameters online)
        :do ($set! ($data pt) ($data po))))

(with-max-heap ()
  (let* ((train-env (cartpole-regulator-env :train))
         (eval-env (cartpole-regulator-env :eval))
         (model-target (model))
         (model-online (model))
         (experiences '())
         (total-cost 0)
         (success nil))
    (sync-models model-target model-online)
    (when *init-experience*
      (let* ((exsi (collect-experiences train-env))
             (exs (car exsi))
             (ecost (cadr exsi)))
        (setf experiences exs)
        (incf total-cost ecost)))
    (loop :for epoch :from 1 :to *max-epochs*
          :while (not success)
          :do (let ((ctrain 0)
                    (ntrain 0))
                (when *increment-experience*
                  (let* ((exsi (collect-experiences train-env (best-action-selector model-target)))
                         (exs (car exsi)))
                    (setf ctrain (cadr exsi))
                    (setf ntrain ($count exs))
                    (setf experiences (let ((ne ($count experiences)))
                                        (if (> ne *max-buffer-size*)
                                            (append (nthcdr (- ne *max-buffer-size*) experiences)
                                                    exs)
                                            (append experiences exs))))
                    (incf total-cost ctrain)))
                (let* ((xys (generate-dataset model-target
                                              (sample-experiences experiences *batch-size*)
                                              0.95D0))
                       (xs (car xys))
                       (ys (cadr xys)))
                  (when *hint-to-goal*
                    (let ((gxys (generate-goal-patterns)))
                      (setf xs ($concat xs (car gxys) 0))
                      (setf ys ($concat ys (cadr gxys) 0))))
                  (let* ((loss (train model-online xs ys))
                         (eres (evaluate eval-env (best-action-selector model-online)))
                         (neval ($0 eres))
                         (ceval ($2 eres)))
                    (setf success ($1 eres))
                    (report epoch loss ntrain ctrain neval ceval success)))
                (when (zerop (rem epoch *sync-period*))
                  (sync-models model-target model-online))))
    (when success
      (prn (format nil "*** TOTAL ~6D / ~4,2F" ($count experiences) total-cost)))))
