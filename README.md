# My Deep Learning Library for Common Lisp using libTH/libTHNN

## What is this?
  Common Lisp Deep Learning Library which supports automatic backpropagation. I'd like to learn how
  neural network and automatic backpropagation works and this is my personal journey on the subject.

## Why?
  There should be a tensor/neural network library in common lisp which is easy to use(byte me!).
  I'd like to learn deep learning and I think building one from scratch will be the best way.
  I hope this library can be applied to the problems of differentiable programming. You can see
  what this library can do from examples. They are mostly neural network applications.

## About libTH/libTHNN
  Refer http://torch.ch/docs/getting-started.html and build torch. After install, under lib directory,
  you can find libTH and libTHNN (this file is under lua/5.1) which are required to use my library.
  You may try to use ATen from pytorch, but this requires some patching some files and adding missing
  files. (If you want to do this, refer https://bitbucket.org/chunsj/pytorch.personal/)
  Though current version of th does not support CUDA, I have a plan to support them and for this, you
  will need libTHC and libTHCUNN under torch installation directory.

## How to Load
  1. Build torch (to get libTH/libTHNN) or if possible build those library files.
  2. You'll need my utility library mu.
  3. Link or clone this repository and mu into quicklisp's local-projects
  4. Check location of library path in the load.lisp file.
  5. Load with quicklisp (ql:quickload :th)
  6. If there's error, you need check previous processes.

## How to Use/Examples
  1. Basic tensor operations: examples/tensor.lisp
  2. Some auto-gradient/auto-backpropagation: examples/ad.lisp
  3. XOR neural network: examples/xor.lisp
  4. MNIST convolutional neural network: examples/mnist.lisp
  5. IMDB sentiment analysis: examples/sentiment.lisp (cl-ppcre is required)
  6. Binary number addition using vanilla RNN: examples/binadd.lisp
  7. Karpathy's character generation using RNN/LSTM: examples/gench{ars,-lstm,-lstm2}.lisp
  8. Sparse autoencoder: examples/autoenc.lisp
  9. Restricted Boltzmann Machine: examples/rbm.lisp
  10. Simple GAN (Fitting normal distribution): gan-simple.lisp
  11. Generative Adversarial Network: examples/{ls,c,info,w}gan[2].lisp (opticl is required)
  12. Deep Convolutional GAN: examples/dcgan.lisp
  13. Neural Arithmetic Logic Unit or NALU: examples/nalu.lisp

## Selected Book Follow Ups
  1. Deep Learning from Scratch: dlfs
  2. Grokking Deep Learning: gdl

## Test Data Support
  1. MNIST: db/mnist.lisp
  2. Fashion MNIST: db/fashion.lisp
  3. IMDB: db/imdb.lisp
  4. Misc CSV Files: data

## On Scratch
  1. Most of the code in this folder is just for testing, teasing, or random trashing.
  2. They may not work at all.

## On API - Neural Network related
  1. Variable creation: $variable
  2. Value/Constant creation: $constant
  3. State (recurrent) creation/accessing: $state, $prev
  4. Operators: $+, $-, $*, $/ $@, ...
  5. Functions: $sigmoid, $tanh, $softmax
  6. Backpropagation: $bp!, $bptt!
  7. Gradient descent or parameter update: $gd!, $mgd!, $agd!, $amgd!, $rmgd!, $adgd!
  8. Weight initialization: $rn!, $ru!, $rnt!, $xavieru!, $xaviern!, $heu!, $hen!, $lecunu!, ...
  9. Weight creation utilities: vrn, vru, vrnt, vxavier, vhe, vlecun
