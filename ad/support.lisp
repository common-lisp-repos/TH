(in-package :th)

(defgeneric $relu (x))
(defgeneric $softmax (x))

(defgeneric $bce (a b))
(defgeneric $mse (a b))
(defgeneric $cee (a b))

(defmethod $bce ((a tensor) (b tensor))
  (let ((output ($empty a)))
    (nn-bce-criterion-update-output a b output t nil)
    output))

(defun dbce (input target gradient)
  (let ((dinput ($empty input)))
    (nn-bce-criterion-update-grad-input input target gradient dinput t nil)
    dinput))

(defun bce-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((a ($c0 node))
                                 (b ($c1 node)))
                             (list (if ($gradientp a)
                                       ($bp! a (dbce ($data a) ($data b) gradient))
                                       a)
                                   (if ($gradientp b)
                                       ($bp! b (dbce ($data b) ($data a) gradient))
                                       b)))))
  node)

(defmethod $bce ((a node) (b node))
  (let ((result (node ($bce ($data a) ($data b)))))
    (setf ($children result) (list a b))
    (setf ($gradientp result) (or ($gradientp a) ($gradientp b)))
    (setf ($bpfn result) #'bce-backprop)
    result))

(defmethod $mse ((a tensor) (b tensor))
  (let ((output ($empty a)))
    (nn-mse-criterion-update-output a b output t)
    output))

(defun dmse (input target gradient)
  (let ((dinput ($empty input)))
    (nn-mse-criterion-update-grad-input input target gradient dinput t)
    dinput))

(defun mse-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((a ($c0 node))
                                 (b ($c1 node)))
                             (list (if ($gradientp a)
                                       ($bp! a (dmse ($data a) ($data b) gradient))
                                       a)
                                   (if ($gradientp b)
                                       ($bp! b (dmse ($data b) ($data a) gradient))
                                       b)))))
  node)

(defmethod $mse ((a node) (b node))
  (let ((result (node ($mse a b))))
    (setf ($children result) (list a b))
    (setf ($gradientp result) (or ($gradientp a) ($gradientp b)))
    (setf ($bpfn result) #'mse-backprop)
    result))

(defmethod $cee ((a tensor) (b tensor))
  (let ((tiny 1D-7)
        (nbatch (if (eq 1 ($ndim a)) 1 ($size a 0))))
    (/ (- ($sum ($mul! ($log ($add a tiny)) b))) nbatch)))

(defmethod $cee ((a node) (b node))
  (let ((tiny ($broadcast ($constant 1D-7) a))
        (nbatch ($constant (if (eq 1 ($ndim a)) 1 ($size a 0)))))
    ($div ($neg ($sum ($mul ($log ($add a tiny)) b))) nbatch)))

(defmethod $relu ((x number)) (max 0 x))

(defmethod $relu ((x tensor))
  (let ((output ($empty x)))
    (nn-threshold-update-output x output 0 0 nil)
    output))

(defun drelu (input gradient)
  (let ((dinput ($empty input)))
    (nn-threshold-update-grad-input input gradient dinput 0 0 nil)
    dinput))

(defun relu-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node)))
                             (list (if ($gradientp x)
                                       ($bp! x (drelu ($data x) gradient))
                                       x)))))
  node)

(defmethod $relu ((x node))
  (let ((result (node ($relu ($data x)))))
    (setf ($children result) (list x))
    (setf ($gradientp result) ($gradientp x))
    (setf ($bpfn result) #'relu-backprop)
    result))

(defmethod $softmax ((x tensor))
  (let ((output ($empty x)))
    (nn-softmax-update-output x output)
    output))

(defun dsoftmax (input output gradient)
  (let ((dinput ($empty input)))
    (nn-softmax-update-grad-input input gradient dinput output)
    dinput))

(defun softmax-backprop (node gradient)
  (setf ($gradient node) gradient)
  (setf ($children node) (when ($children node)
                           (let ((x ($c0 node)))
                             (list (if ($gradientp x)
                                       ($bp! x (dsoftmax ($data x) ($data node) gradient))
                                       x)))))
  node)

(defmethod $softmax ((x node))
  (let ((result (node ($softmax ($data x)))))
    (setf ($children result) (list x))
    (setf ($gradientp result) ($gradientp x))
    (setf ($bpfn result) #'softmax-backprop)
    result))
