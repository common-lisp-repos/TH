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
           #:$contiguous!
           #:$contiguousp
           #:$resize!
           #:$copy!
           #:$swap!
           #:$expand
           #:$expand!
           #:$fill
           #:$fill!
           #:$zero
           #:$zero!
           #:$one
           #:$one!
           #:$clone
           #:$sizep
           #:$set!
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
           #:$index
           #:$gather
           #:$scatter!
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
           #:$cmax
           #:$cmax!
           #:$cmin
           #:$cmin!
           #:$mean
           #:$mean!
           #:$median
           #:$median!
           #:$mode
           #:$mode!
           #:$kth
           #:$kth!
           #:$topk
           #:$topk!
           #:$sort
           #:$sort!
           #:$prd
           #:$prd!
           #:$sum
           #:$sum!
           #:$sd
           #:$sd!
           #:$var
           #:$var!
           #:$uniform!
           #:$normal!
           #:$bernoulli!
           #:$norm
           #:$norm!
           #:$renorm
           #:$renorm!
           #:$dist
           #:$trace
           #:$conv2
           #:$conv2!
           #:$xcorr2
           #:$xcorr2!
           #:$conv3
           #:$conv3!
           #:$xcorr3
           #:$xcorr3!
           #:$gesv
           #:$gesv!
           #:$trtrs
           #:$trtrs!
           #:$potrf
           #:$potrf!
           #:$pstrf
           #:$pstrf!
           #:$potrs
           #:$potrs!
           #:$potri
           #:$potri!
           #:$gels
           #:$gels!
           #:$syev
           #:$syev!
           #:$ev
           #:$ev!
           #:$svd
           #:$svd!
           #:$inverse
           #:$inverse!
           #:$qr
           #:$qr!
           #:$multinomial
           #:file.disk
           #:file.pipe
           #:file.memory
           #:$fopenedp
           #:$fquietp
           #:$fpedanticp
           #:$freadablep
           #:$fwritablep
           #:$fbinaryp
           #:$fasciip
           #:$fautospacingp
           #:$fnoautospacingp
           #:$ferrorp
           #:$freadbyte
           #:$freadchar
           #:$freadshort
           #:$freadint
           #:$freadlong
           #:$freadfloat
           #:$freaddouble
           #:$fread
           #:$fwritebyte
           #:$fwritechar
           #:$fwriteshort
           #:$fwriteint
           #:$fwritelong
           #:$fwritefloat
           #:$fwritedouble
           #:$fwrite
           #:$fsync
           #:$feek
           #:$fseekend
           #:$ftell
           #:$fclose
           #:$fname
           #:parameters
           #:$push
           #:$parameter
           #:$data
           #:$gradient
           #:$parameterp
           #:$append
           #:$broadcast
           #:$clear
           #:$krows
           #:$kcols
           #:$gs!
           #:$cg!
           #:$reset!
           #:$gd!
           #:$mgd!
           #:$agd!
           #:$amgd!
           #:$rmgd!
           #:$adgd!
           #:$bce
           #:$bce*
           #:$cee
           #:$mse
           #:$cnll
           #:$cec
           #:$square
           #:$relu
           #:$lrelu
           #:$elu
           #:$selu
           #:$softmax
           #:$logsoftmax
           #:$softplus
           #:$mish
           #:$swish
           #:$gelu
           #:$celu
           #:$bnorm
           #:$bn
           #:$dropout
           #:$conv1d
           #:$maxpool1d
           #:$rowconv1d
           #:$conv2d
           #:$maxpool2d
           #:$avgpool2d
           #:$dlconv2d
           #:$dlmaxpool2d
           #:$dconv2d
           #:$affine
           #:$affine2
           #:$addm2
           #:$xwpb
           #:$wimb
           #:$rnn
           #:$lstm
           #:$rn!
           #:$ru!
           #:$rnt!
           #:$xavieru!
           #:$xaviern!
           #:$heu!
           #:$hen!
           #:$lecunu!
           #:$lecunn!
           #:vrn
           #:vru
           #:vrnt
           #:vxavier
           #:vhe
           #:vlecun
           #:vselu
           #:with-foreign-memory-limit))
