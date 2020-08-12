(defpackage :gdrl-ch11
  (:use #:common-lisp
        #:mu
        #:th
        #:th.layers
        #:th.env
        #:th.env.cartpole))

(in-package :gdrl-ch11)

;; XXX
;; current episode collection logic is invalid. though it seems to work but it's not correct.
;; XXX

(defun mean (xs) (/ (reduce #'+ xs) (length xs)))
(defun variance (xs)
  (let* ((n (length xs))
         (m (/ (reduce #'+ xs) n)))
    (/ (reduce #'+ (mapcar (lambda (x)
                             (expt (abs (- x m)) 2))
                           xs))
       n)))
(defun sd (xs) (sqrt (variance xs)))

(defun z-scored (vs fl)
  (if fl
      (let ((m (mean vs))
            (s (sd vs)))
        (mapcar (lambda (v) (/ (- v m) s)) vs))
      vs))

(defun discounted-rewards (rewards gamma &optional standardizep)
  (let ((running 0))
    (-> (loop :for r :in (reverse rewards)
              :collect (progn
                         (setf running ($+ r (* gamma running)))
                         running))
        (reverse)
        (z-scored standardizep))))

(defun train-env (&optional (max-steps 300)) (cartpole-env :easy :reward max-steps))
(defun eval-env () (cartpole-env :eval))

;;
;; REINFORCE
;;

(defun model (&optional (ni 4) (no 2))
  (let ((h 8))
    (sequential-layer
     (affine-layer ni h :weight-initializer :random-uniform
                        :activation :relu)
     (affine-layer h no :weight-initializer :random-uniform
                        :activation :softmax))))

(defun policy (m state &optional (trainp T))
  ($execute m (if (eq ($ndim state) 1)
                  ($unsqueeze state 0)
                  state)
            :trainp trainp))

(defun select-action (m state)
  (let* ((probs (policy m state))
         (logPs ($log ($clamp probs
                              single-float-epsilon
                              (- 1 single-float-epsilon))))
         (entropy ($- ($dot ($data probs) logPs)))
         (action ($multinomial probs 1))
         (logP ($gather logPs 1 action)))
    (list ($scalar action) logP entropy)))

(defun action-selector (m)
  (lambda (state)
    (let ((probs (policy m state nil)))
      ($scalar ($argmax probs 1)))))

(defun reinforce (m &optional (max-episodes 4000))
  (let* ((gamma 0.99)
         (lr 0.001)
         (env (train-env))
         (avg-score nil)
         (success nil))
    (loop :while (not success)
          :repeat max-episodes
          :for e :from 1
          :for state = (env/reset! env)
          :for rewards = '()
          :for logPs = '()
          :for score = 0
          :for done = nil
          :do (let ((losses nil))
                (loop :while (not done)
                      :for (action logP entropy) = (select-action m state)
                      :for (next-state reward terminalp) = (cdr (env/step! env action))
                      :do (progn
                            (push logP logPs)
                            (push reward rewards)
                            (incf score reward)
                            (setf state next-state
                                  done terminalp)))
                (setf logPs (reverse logPs))
                (setf rewards (discounted-rewards (reverse rewards) gamma))
                (loop :for logP :in logPs
                      :for vt :in rewards
                      ;; in practice, we don't have to collect losses.
                      ;; each loss has independent computational graph.
                      :do (push ($- ($* logP vt)) losses))
                ($amgd! m lr)
                (if (null avg-score)
                    (setf avg-score score)
                    (setf avg-score (+ (* 0.9 avg-score) (* 0.1 score))))
                (when (zerop (rem e 100))
                  (let ((escore (cadr (evaluate (eval-env) (action-selector m)))))
                    (if (and (>= avg-score (* 0.9 300)) (>= escore 3000)) (setf success T))
                    (prn (format nil "~5D: ~8,2F / ~5,0F" e avg-score escore))))))
    avg-score))

(defun $logP (x) ($log ($clamp x single-float-epsilon (- 1 single-float-epsilon))))
(defun select-action (m state) ($scalar ($multinomial (policy m state nil) 1)))

(defun select-action (m state)
  (let* ((probs (policy m state nil))
         (logPs ($log ($clamp probs
                              single-float-epsilon
                              (- 1 single-float-epsilon))))
         (entropy ($- ($dot probs logPs)))
         (action ($multinomial probs 1))
         (logP ($gather logPs 1 action)))
    (list ($scalar action) logP entropy)
    ($scalar action)))

(defun trace-episode (env m s0 gamma)
  (let ((states nil)
        (actions nil)
        (rewards nil)
        (done nil)
        (score 0)
        (state s0))
    (loop :while (not done)
          :for action = (select-action m state)
          :for (_ next-state reward terminalp) = (env/step! env action)
          :do (progn
                (push ($list state) states)
                (push action actions)
                (push reward rewards)
                (incf score reward)
                (setf state next-state
                      done terminalp)))
    (let ((n ($count states)))
      (list (tensor (reverse states))
            (-> (tensor.long (reverse actions))
                ($reshape! n 1))
            (-> (discounted-rewards (reverse rewards) gamma T)
                (tensor)
                ($reshape! n 1))
            score))))

(defun compute-loss (m states actions rewards)
  (let ((logPs ($gather ($logP (policy m states)) 1 actions)))
    ($mean ($* -1 rewards logPs))))

(defun reinforce (m &optional (max-episodes 4000))
  (let* ((gamma 0.99)
         (lr 0.01)
         (env (train-env))
         (avg-score nil)
         (success nil))
    (loop :while (not success)
          :repeat max-episodes
          :for e :from 1
          :for state = (env/reset! env)
          :do (let* ((res (trace-episode env m state gamma))
                     (states ($0 res))
                     (actions ($1 res))
                     (rewards ($2 res))
                     (score ($3 res))
                     (loss nil))
                (setf loss (compute-loss m states actions rewards))
                ($amgd! m lr)
                (if (null avg-score)
                    (setf avg-score score)
                    (setf avg-score (+ (* 0.9 avg-score) (* 0.1 score))))
                (when (zerop (rem e 100))
                  (let ((escore (cadr (evaluate (eval-env) (action-selector m)))))
                    (if (and (>= avg-score (* 0.9 300)) (>= escore 3000)) (setf success T))
                    (prn (format nil "~5D: ~8,2F / ~5,0F ~12,4F" e avg-score escore
                                 ($scalar ($data loss))))))))
    avg-score))

(defparameter *m* (model))
(reinforce *m* 4000)

(evaluate (eval-env) (action-selector *m*))

(let ((actions (tensor.long '(0 1 0 1)))
      (probs (tensor '((1 2) (1 2) (1 2) (1 2)))))
  ($gather probs 1 ($reshape! actions 4 1)))

;;
;; VANILLA POLICY GRADIENT, VPG
;;

(defun pmodel (&optional (ni 4) (no 2))
  (let ((h 8))
    (sequential-layer
     (affine-layer ni h :weight-initializer :random-uniform
                        :activation :relu)
     (affine-layer h no :weight-initializer :random-uniform
                        :activation :softmax))))

(defun vmodel (&optional (ni 4) (no 1))
  (let ((h 16))
    (sequential-layer
     (affine-layer ni h :weight-initializer :random-uniform
                        :activation :relu)
     (affine-layer h no :weight-initializer :random-uniform
                        :activation :nil))))

(defun vpg (pm vm &optional (max-episodes 4000))
  (let* ((gamma 0.99)
         (beta 0.001)
         (plr 0.001)
         (vlr 0.001)
         (env (train-env))
         (avg-score nil)
         (success nil))
    (loop :while (not success)
          :repeat max-episodes
          :for e :from 1
          :for state = (env/reset! env)
          :for rewards = '()
          :for logPs = '()
          :for entropies = '()
          :for vals = '()
          :for score = 0
          :for done = nil
          :do (let ((plosses nil)
                    (vlosses nil))
                (loop :while (not done)
                      :for (action logP entropy) = (select-action pm state)
                      :for (_ next-state reward terminalp) = (env/step! env action)
                      :for v = ($execute vm ($unsqueeze state 0))
                      :do (progn
                            (push logP logPs)
                            (push reward rewards)
                            (push ($* beta entropy) entropies)
                            (push v vals)
                            (incf score reward)
                            (setf state next-state
                                  done terminalp)))
                (setf logPs (reverse logPs)
                      entropies (reverse entropies)
                      vals (reverse vals))
                (setf rewards (discounted-rewards (reverse rewards) gamma))
                (loop :for logP :in logPs
                      :for vt :in rewards
                      :for et :in entropies
                      :for v :in vals
                      ;; in practice, we don't have to collect losses.
                      ;; each loss has independent computational graph.
                      :do (let ((adv ($- vt v)))
                            (push ($- ($+ ($* logP ($data adv)) et)) plosses)
                            (push ($square adv) vlosses)))
                ($amgd! pm plr)
                ($amgd! vm vlr)
                (if (null avg-score)
                    (setf avg-score score)
                    (setf avg-score (+ (* 0.9 avg-score) (* 0.1 score))))
                (when (zerop (rem e 100))
                  (let ((escore (cadr (evaluate (eval-env) (action-selector pm)))))
                    (if (and (>= avg-score (* 0.9 300)) (>= escore 3000)) (setf success T))
                    (prn (format nil "~5D: ~8,2F / ~5,0F" e avg-score escore))))))
    avg-score))

(defparameter *pm* (model))
(defparameter *vm* (vmodel))
(vpg *pm* *vm* 4000)

(evaluate (eval-env) (action-selector *pm*))

;; TODO/PLAN XXX
;;
;; before proceed into actor-critic, first tacke with the n-step bootstrapping problem.
;; after that actor-critic with monte-carlo or vge could be approcheable.
;;

;;
;; ACTOR-CRITIC - SHARED NETWORK MODEL
;;

(defun ac-model (&optional (ns 4) (na 2) (nv 1))
  (let ((h 64))
    (let ((common-net (sequential-layer
                       (affine-layer ns h :weight-initializer :random-uniform
                                          :activation :tanh)
                       (affine-layer h h :weight-initializer :random-uniform
                                         :activation :tanh)))
          (policy-net (affine-layer h na :weight-initializer :random-uniform
                                         :activation :softmax))
          (value-net (affine-layer h nv :weight-initializer :random-uniform
                                        :activation :nil)))
      (sequential-layer common-net
                        (parallel-layer policy-net value-net)))))

(defun policy-and-value (m state &optional (trainp T))
  ($execute m ($unsqueeze state 0) :trainp trainp))

(defun select-action (m state)
  (let* ((out (policy-and-value m state))
         (probs ($0 out))
         (val ($1 out))
         (entropy ($- ($dot probs ($log probs))))
         (action ($multinomial ($data probs) 1))
         (pa ($gather probs 1 action)))
    (list ($scalar action) pa entropy val)))

(defun action-selector (m)
  (lambda (state)
    (let* ((policy-and-value (policy-and-value m state nil))
           (policy ($0 policy-and-value)))
      ($scalar ($argmax policy 1)))))

(defun ac (acm &optional (max-episodes 2000))
  (let* ((gamma 0.99)
         (beta 0.001)
         (lr 0.001)
         (nex 100)
         (env (cartpole-v0-env nex))
         (avg-score nil))
    (loop :repeat max-episodes
          :for e :from 1
          :for state = (env/reset! env)
          :for rewards = '()
          :for logits = '()
          :for entropies = '()
          :for vals = '()
          :for score = 0
          :for done = nil
          :do (let ((policy-loss 0)
                    (value-loss 0)
                    (ne 0)
                    (loss nil))
                (loop :while (not done)
                      :for (action prob entropy v) = (select-action acm state)
                      :for (_ next-state reward terminalp) = (env/step! env action)
                      :do (let* ((logit ($log ($clamp prob
                                                      single-float-epsilon
                                                      (- 1 single-float-epsilon)))))
                            (push logit logits)
                            (push reward rewards)
                            (push ($* beta entropy) entropies)
                            (push v vals)
                            (incf ne)
                            (incf score reward)
                            (setf state next-state
                                  done terminalp)))
                (loop :for logit :in (reverse logits)
                      :for rwds :on (reverse rewards)
                      :for et :in (reverse entropies)
                      :for v :in (reverse vals)
                      :do (let* ((returns (returns rwds gamma))
                                 (adv ($- returns v)))
                            (setf policy-loss ($- policy-loss ($+ ($* logit ($data adv)) et)))
                            (setf value-loss ($+ value-loss ($square adv)))))
                (setf loss ($+ policy-loss ($/ value-loss ne)))
                ($amgd! acm lr)
                (if (null avg-score)
                    (setf avg-score score)
                    (setf avg-score (+ (* 0.9 avg-score) (* 0.1 score))))
                (when (zerop (rem e 100))
                  (let ((escore (cadr (evaluate (cartpole-v0-env *eval-steps*)
                                                (action-selector acm)))))
                    (prn (format nil "~5D: ~8,4F ~5,0F | ~8,2F ~10,2F" e avg-score escore
                                 ($scalar policy-loss) ($scalar value-loss)))))))
    avg-score))

(defparameter *m* (ac-model))
(ac *m* 2000)

(evaluate (cartpole-v0-env 1000) (action-selector *m*))
(evaluate (cartpole-env :eval) (action-selector *m*))

;; N-STEP

(defun n-step-ac (acm &optional (max-steps 10) (max-episodes 4000))
  (let* ((gamma 0.99)
         (beta 0.001)
         (lr 0.01)
         (bstep 500)
         (env (cartpole-v0-env bstep))
         (avg-score nil))
    (loop :repeat max-episodes
          :for e :from 1
          :for state = (env/reset! env)
          :for rewards = '()
          :for logits = '()
          :for entropies = '()
          :for vals = '()
          :for score = 0
          :for done = nil
          :do (let ((policy-loss 0)
                    (value-loss 0)
                    (loss nil))
                (loop :while (not done)
                      :for steps :from 1
                      :for (action prob entropy v) = (select-action-ac acm state)
                      :for (_ next-state reward terminalp) = (env/step! env action)
                      :do (let* ((logit ($log prob)))
                            (push logit logits)
                            (push reward rewards)
                            (push ($* beta entropy) entropies)
                            (push v vals)
                            (incf score reward)
                            (when (or terminalp (zerop (rem steps max-steps)))
                              (if (and terminalp (< steps bstep))
                                  (push 0 rewards)
                                  (push ($scalar v) rewards))
                              (loop :for logit :in (reverse logits)
                                    :for rwds :on (reverse rewards)
                                    :for et :in (reverse entropies)
                                    :for v :in (reverse vals)
                                    :do (let* ((returns (returns rwds gamma))
                                               (adv ($- returns v)))
                                          (setf policy-loss ($- policy-loss
                                                                ($+ ($* logit ($data adv)) et)))
                                          (setf value-loss ($+ value-loss ($square adv)))))
                              (setf loss ($+ policy-loss ($sqrt value-loss)))
                              ($amgd! acm lr)
                              (setf rewards '()
                                    logits '()
                                    entropies '()
                                    vals '()))
                            (setf state next-state
                                  done terminalp)))
                (if (null avg-score)
                    (setf avg-score score)
                    (setf avg-score (+ (* 0.9 avg-score) (* 0.1 score))))
                (when (zerop (rem e 100))
                  (prn (format nil "~5D: ~8,2F / ~8,2F" e score avg-score)))))
    avg-score))

(defparameter *m* (ac-model))
(n-step-ac *m* 600 2000)

(evaluate-model-ac (cartpole-v0-env 1000) *m*)