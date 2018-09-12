(declaim (optimize (speed 3) (debug 1) (safety 0)))

(in-package :th)

(defgeneric $relu (x))
(defgeneric $lrelu (x &optional nv))
(defgeneric $elu (x &optional α))
(defgeneric $selu (x))
(defgeneric $softmax (x))
(defgeneric $bnorm (x gamma beta mean sd &optional trainp momentum eps))
(defgeneric $dropout (x &optional trainp p))

(defgeneric $bce (a b))
(defgeneric $mse (a b))
(defgeneric $cee (a b))
(defgeneric $cnll (a b))
(defgeneric $cec (a b))

(defmethod $bce ((a tensor) (b tensor))
  (let ((output ($resize! ($empty a) '(1))))
    (nn-bce-criterion-update-output a b output t nil)
    ($ output 0)))

(defun dbce (input target)
  (let ((dinput ($empty input)))
    (nn-bce-criterion-update-grad-input input target dinput t nil)
    dinput))

(defmethod $bce ((a node) (b node))
  (let ((result (node ($bce ($data a) ($data b)))))
    (setf ($name result) "BCE")
    ($gp! result a b)
    ($pfn! a (lambda () (dbce ($data a) ($data b))))
    ($pfn! b (lambda () (dbce ($data b) ($data a))))
    result))

(defmethod $mse ((a tensor) (b tensor))
  (let ((output ($empty a)))
    (nn-mse-criterion-update-output a b output t)
    output))

(defun dmse (input target gradient)
  (let ((dinput ($empty input)))
    (nn-mse-criterion-update-grad-input input target gradient dinput t)
    dinput))

(defmethod $mse ((a node) (b node))
  (let ((result (node ($mse ($data a) ($data b)))))
    (setf ($name result) "MSE")
    ($gp! result a b)
    ($pfn! a (lambda () (dmse ($data a) ($data b) ($gradient result))))
    ($pfn! b (lambda () (dmse ($data b) ($data a) ($gradient result))))
    result))

(defmethod $cee ((a tensor) (b tensor))
  (let ((tiny 1D-7)
        (nbatch (if (eq 1 ($ndim a)) 1 ($size a 0))))
    (/ (- ($sum ($mul! ($log ($add a tiny)) b))) nbatch)))

(defmethod $cee ((a node) (b node))
  (let ((tiny ($constant 1D-7))
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

(defmethod $relu ((x node))
  (let ((result (node ($relu ($data x)))))
    (setf ($name result) "RELU")
    ($gp! result x)
    ($pfn! x (lambda () (drelu ($data x) ($gradient result))))
    result))

(defmethod $lrelu ((x number) &optional (nv 0.01)) (max (* nv x) x))

(defmethod $lrelu ((x tensor) &optional (nv 0.01))
  (let ((output ($empty x)))
    (nn-leaky-relu-update-output x output nv nil)
    output))

(defun dlrelu (input gradient &optional (nv 0.01))
  (let ((dinput ($empty input)))
    (nn-leaky-relu-update-grad-input input gradient dinput nv nil)
    dinput))

(defmethod $lrelu ((x node) &optional (nv 0.01))
  (let ((result (node ($lrelu ($data x) nv))))
    (setf ($name result) "LEAKYRELU")
    ($gp! result x)
    ($pfn! x (lambda () (dlrelu ($data x) ($gradient result) nv)))
    result))

(defmethod $elu ((x number) &optional (α 1))
  (if (<= x 0)
      (* α (- (exp x) 1))
      x))

(defmethod $elu ((x tensor) &optional (α 1))
  (let ((output ($empty x)))
    (nn-elu-update-output x output α nil)
    output))

(defun delu (input output gradient &optional (alpha 1))
  (let ((dinput ($empty output)))
    (nn-elu-update-grad-input input gradient dinput output alpha nil)
    dinput))

(defmethod $elu ((x node) &optional (α 1))
  (let ((result (node ($elu ($data x) α))))
    (setf ($name result) "ELU")
    ($gp! result x)
    ($pfn! x (lambda () (delu ($data x) ($data result) ($gradient result) α)))
    result))

(defmethod $selu ((x number))
  (let ((alpha 1.6732632423543772848170429916717)
        (scale 1.0507009873554804934193349852946))
    (* scale
       (if (<= x 0)
           (* alpha (- (exp x) 1))
           x))))

(defmethod $selu ((x tensor))
  (let ((output ($empty x))
        (alpha 1.6732632423543772848170429916717)
        (scale 1.0507009873554804934193349852946))
    (nn-elu-update-output x output alpha scale nil)
    output))

(defun dselu (output gradient)
  (let ((dinput ($empty output))
        (alpha 1.6732632423543772848170429916717)
        (scale 1.0507009873554804934193349852946))
    (nn-elu-update-grad-input gradient dinput output alpha scale)
    dinput))

(defmethod $selu ((x node))
  (let ((result (node ($selu ($data x)))))
    (setf ($name result) "SELU")
    ($gp! result x)
    ($pfn! x (lambda () (dselu ($data result) ($gradient result))))
    result))

(defmethod $softmax ((x tensor))
  (let ((output ($empty x)))
    (nn-softmax-update-output x output)
    output))

(defun dsoftmax (input output gradient)
  (let ((dinput ($empty input)))
    (nn-softmax-update-grad-input input gradient dinput output)
    dinput))

(defmethod $softmax ((x node))
  (let ((result (node ($softmax ($data x)))))
    (setf ($name result) "SOFTMAX")
    ($gp! result x)
    ($pfn! x (lambda () (dsoftmax ($data x) ($data result) ($gradient result))))
    result))

(defmethod $logsoftmax ((x tensor))
  (let ((output ($empty x)))
    (nn-log-softmax-update-output x output)
    output))

(defun dlogsoftmax (input output gradient)
  (let ((dinput ($empty input)))
    (nn-log-softmax-update-grad-input input gradient dinput output)
    dinput))

(defmethod $logsoftmax ((x node))
  (let ((result (node ($logsoftmax ($data x)))))
    (setf ($name result) "LOGSOFTMAX")
    ($gp! result x)
    ($pfn! x (lambda () (dlogsoftmax ($data x) ($data result) ($gradient result))))
    result))

(defun runstat (x mean var trainp momentum)
  (let* ((x (if (eq 1 ($ndim x))
                (apply #'$reshape x (cons 1 ($size x)))
                x))
         (nx ($size x 0)))
    (when (and trainp (not (eq nx 1)))
      (let* ((mx ($mean x 0))
             (vx ($var x 0)))
        ($mul! mx momentum)
        ($mul! vx momentum)
        ($mul! mean (- 1 momentum))
        ($mul! var (- 1 momentum))
        ($add! mean mx)
        ($add! var vx)))))

(defmethod $bnorm ((x tensor) (gamma tensor) (beta tensor) (mean tensor) (var tensor)
                   &optional (trainp t) (momentum 0.1) (eps 1E-7))
  (runstat x mean var trainp momentum)
  (let* ((x (apply #'$reshape x (cons 1 ($size x))))
         (os (ones ($size x 0)))
         (zx ($div! ($sub x ($vv os mean)) ($sqrt! ($add var eps)))))
    ($add! ($mul! zx ($vv os gamma)) ($vv os beta))))

(defmethod $bnorm ((x tensor) (gamma null) (beta null) (mean tensor) (var tensor)
                   &optional (trainp t) (momentum 0.1) (eps 1E-7))
  (runstat x mean var trainp momentum)
  (let* ((x (apply #'$reshape x (cons 1 ($size x))))
         (os (ones ($size x 0)))
         (zx ($div! ($sub x ($vv os mean)) ($sqrt! ($add var eps)))))
    zx))

(defmethod $bnorm ((x node) (gamma node) (beta node) (mean node) (var node)
                   &optional (trainp t) (momentum 0.1) (eps 1E-7))
  (runstat ($data x) ($data mean) ($data var) trainp momentum)
  (let* ((x (if (eq 1 ($ndim x))
                ($vv (ones 1) x)
                x))
         (os ($constant (ones ($size x 0))))
         (zx ($div ($sub x ($vv os mean)) ($vv os ($sqrt ($add var ($constant eps)))))))
    ($add ($mul zx ($vv os gamma)) ($vv os beta))))

(defmethod $bnorm ((x node) (gamma null) (beta null) (mean node) (var node)
                   &optional (trainp t) (momentum 0.1) (eps 1E-7))
  (runstat ($data x) ($data mean) ($data var) trainp momentum)
  (let* ((x (if (eq 1 ($ndim x))
                ($vv (ones 1) x)
                x))
         (os ($constant (ones ($size x 0))))
         (zx ($div ($sub x ($vv os mean)) ($vv os ($sqrt ($add var ($constant eps)))))))
    zx))

(defmethod $dropout ((x tensor) &optional (trainp t) (p 0.1))
  (if trainp
      (let ((mask ($gt (apply #'rnd ($size x)) p)))
        ($mul! (tensor mask) x))
      ($mul x (- 1.0 p))))

(defmethod $dropout ((x node) &optional (trainp t) (p 0.1))
  (if trainp
      (let ((mask ($gt (apply #'rnd ($size x)) p)))
        ($mul ($constant (tensor mask)) x))
      ($mul x ($broadcast ($constant (- 1 p)) x))))

;; b should be 1-d
(defmethod $cnll ((a tensor) (b tensor))
  (let ((result (zeros 1))
        (tw (ones 1)))
    (nn-class-nll-criterion-update-output a (tensor.long ($reshape b ($count b)))
                                          result t nil tw -100)
    ($ result 0)))

(defun dcnll (input target gradient)
  (let ((dinput ($empty input)))
    (nn-class-nll-criterion-update-grad-input input (tensor.long ($reshape target ($count target)))
                                              (tensor (list gradient)) dinput t nil
                                              (ones 1) -100)
    dinput))

(defmethod $cnll ((a node) (b node))
  (let ((result (node ($cnll ($data a) ($data b)))))
    (setf ($name result) "CNLL")
    ($gp! result a)
    ($pfn! a (lambda () (dcnll ($data a) ($data b) ($gradient result))))
    result))

(defmethod $cec ((a tensor) (b tensor)) ($cnll ($logsoftmax a) b))
(defmethod $cec ((a node) (b node)) ($cnll ($logsoftmax a) b))
