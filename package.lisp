(defpackage :th
  (:use #:common-lisp
        #:mu)
  (:import-from #:cffi)
  (:export #:generator
           #:storage.byte
           #:storage.char
           #:storage.short
           #:storage.int
           #:storage.long
           #:storage.float
           #:storage.double
           #:tensor.byte
           #:tensor.char
           #:tensor.short
           #:tensor.int
           #:tensor.long
           #:tensor.float
           #:tensor.double
           #:tensor
           #:eye
           #:linspace
           #:logspace
           #:zeros
           #:ones
           #:filled
           #:range
           #:arange
           #:rnd
           #:rndn
           #:rndperm
           #:$validp
           #:$seed
           #:$random
           #:$uniform
           #:$normal
           #:$exponential
           #:$cauchy
           #:$lognormal
           #:$geometric
           #:$bernoulli
           #:$storagep
           #:$tensorp
           #:$empty
           #:$list
           #:$handle
           #:$pointer
           #:$type
           #:$storage
           #:$offset
           #:$ndim
           #:$size
           #:$stride
           #:$coerce
           #:$acoerce
           #:$contiguous
           #:$contiguousp
           #:$resize
           #:$copy
           #:$swap
           #:$fill
           #:$fill!
           #:$zero
           #:$zero!
           #:$one
           #:$one!
           #:$clone
           #:$sizep
           #:$set
           #:$setp
           #:$transpose
           #:$transpose!
           #:$view
           #:$subview
           #:$select
           #:$select!
           #:$narrow
           #:$narrow!
           #:$unfold
           #:$unfold!
           #:$expand
           #:$expand!
           #:$index
           #:$gather
           #:$scatter
           #:$masked
           #:$squeeze
           #:$squeeze!
           #:$unsqueeze
           #:$unsqueeze!
           #:$permute
           #:$split
           #:$chunk
           #:$cat
           #:$repeat
           #:$reshape
           #:$reshape!
           #:$diag
           #:$diag!
           #:$eye
           #:$eye!
           #:$tril
           #:$tril!
           #:$triu
           #:$triu!
           #:$compare
           #:$lt
           #:$le
           #:$gt
           #:$ge
           #:$eq
           #:$ne
           #:$nonzero
           #:$fmap
           #:$fmap!
           #:$abs
           #:$abs!
           #:$sign
           #:$sign!
           #:$acos
           #:$acos!
           #:$asin
           #:$asin!
           #:$atan
           #:$atan!
           #:$atan2
           #:$atan2!
           #:$ceil
           #:$ceil!
           #:$cos
           #:$cos!
           #:$cosh
           #:$cosh!
           #:$exp
           #:$exp!
           #:$floor
           #:$floor!
           #:$log
           #:$log!
           #:$log1p
           #:$log1p!
           #:$neg
           #:$neg!
           #:$cinv
           #:$cinv!
           #:$expt
           #:$expt!
           #:$round
           #:$round!
           #:$sin
           #:$sin!
           #:$sinh
           #:$sinh!
           #:$sqrt
           #:$sqrt!
           #:$rsqrt
           #:$rsqrt!
           #:$tan
           #:$tan!
           #:$tanh
           #:$tanh!
           #:$sigmoid
           #:$sigmoid!
           #:$trunc
           #:$trunc!
           #:$frac
           #:$frac!
           #:$equal
           #:$clamp
           #:$clamp!
           #:$fmod
           #:$fmod!
           #:$rem
           #:$rem!
           #:$dot
           #:$axpy
           #:$axpy!
           #:$gemv
           #:$gemv!
           #:$ger
           #:$ger!
           #:$gemm
           #:$gemm!
           #:$add
           #:$add!
           #:$sub
           #:$sub!
           #:$mul
           #:$mul!
           #:$div
           #:$div!
           #:$addmul
           #:$addmul!
           #:$adddiv
           #:$adddiv!
           #:$addmv
           #:$addmv!
           #:$addr
           #:$addr!
           #:$addmm
           #:$addmm!
           #:$addbmm
           #:$addbmm!
           #:$baddbmm
           #:$baddbamm!
           #:$vv
           #:$vv!
           #:$xx
           #:$xx!
           #:$mv
           #:$mv!
           #:$mm
           #:$mm!
           #:$bmm
           #:$bmm!
           #:$+
           #:$-
           #:$*
           #:$@
           #:$/
           #:$cumprd
           #:$cumprd!
           #:$cumsum
           #:$cumsum!
           #:$max
           #:$max!
           #:$min
           #:$min!
           #:$mean
           #:$mean!))
