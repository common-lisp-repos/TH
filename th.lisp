(in-package :th)

(defgeneric $validp (generator)
  (:documentation "Returns whether generator is valid one or not."))

(defgeneric $seed (generator)
  (:documentation "Returns current seed of generator."))

(defgeneric $random (generator)
  (:documentation "Returns random number from generator."))

(defgeneric $uniform (object a b)
  (:documentation "Returns uniform random number between a and b."))
(defgeneric $normal (object mean stdv)
  (:documentation "Returns normal random number from N(mean,stdv)."))
(defgeneric $exponential (object lam)
  (:documentation "Returns exponential random number with rate lam."))
(defgeneric $cauchy (object median sigma)
  (:documentation "Returns cauchy random number."))
(defgeneric $lognormal (object mean stdv)
  (:documentation "Returns log normal random number from N(mean,stdv)."))
(defgeneric $geometric (object p)
  (:documentation "Returns geometric random number."))
(defgeneric $bernoulli (object p)
  (:documentation "Returns bernoulli random number."))

(defgeneric $storagep (object)
  (:documentation "Returns whether object is storage or not."))
(defgeneric $tensorp (object)
  (:documentation "Returns whether object is tensor or not."))

(defgeneric $empty (object)
  (:documentation "Returns empty new object from object type."))
(defgeneric $list (object)
  (:documentation "Returns contents of object as a list."))

(defgeneric $handle (object)
  (:documentation "Returns native handle of the object."))
(defgeneric $pointer (object)
  (:documentation "Returns pointer of the data of the object."))
(defgeneric $type (object)
  (:documentation "Returns native type tag of the object."))
(defgeneric $storage (tensor)
  (:documentation "Returns storage of tensor."))
(defgeneric $offset (tensor)
  (:documentation "Returns storage offset."))
(defgeneric $ndim (tensor)
  (:documentation "Returns the number of dimensions of tensor."))
(defgeneric $size (object &optional dimension)
  (:documentation "Returns size of the object along dimension."))
(defgeneric $stride (tensor &optional dimension)
  (:documentation "Returns stride of the tensor along dimension."))

(defgeneric $coerce (object value)
  (:documentation "Returns coerced value for the given object type."))
(defgeneric $acoerce (object value)
  (:documentation "Returns coerced value for accumulation."))

(defgeneric $contiguous (tensor)
  (:documentation "Returns a new contiguously allocated tensor if it's not."))
(defgeneric $contiguousp (tensor)
  (:documentation "Returns whether tensor is contiguously allocated."))

(defgeneric $resize (object size &optional stride)
  (:documentation "Resizes object as size and stride."))
(defgeneric $copy (object source)
  (:documentation "Copies content from source."))
(defgeneric $swap (object1 object2)
  (:documentation "Swaps the contents of objects."))

(defgeneric $fill (object value)
  (:documentation "Returns a new tensor filled with value."))
(defgeneric $fill! (object value)
  (:documentation "Returns a tensor filled with value."))
(defgeneric $zero (tensor)
  (:documentation "Returns a new tensor of whose elements of tensor as zero."))
(defgeneric $zero! (tensor)
  (:documentation "Fills elements of tensor as zero."))
(defgeneric $one (tensor)
  (:documentation "Fills elements of tensor as one."))
(defgeneric $one! (tensor)
  (:documentation "Returns a new tensor of whose elements of tensor as one."))

(defgeneric $clone (tensor)
  (:documentation "Returns a new cloned tensor."))
(defgeneric $sizep (tensor other)
  (:documentation "Checks whether tensor has the same size of other or other dimension."))

(defgeneric $set (tensor source &optional offset size stride)
  (:documentation "Sets the storage contents of source to tensor."))
(defgeneric $setp (tensor source)
  (:documentation "Checks whether tensor is set with source."))

(defgeneric $transpose (tensor &optional dimension0 dimension1)
  (:documentation "Returns a new transposed tensor between dimensions."))
(defgeneric $transpose! (tensor &optional dimension0 dimension1)
  (:documentation "Returns a transposed tensor between dimensions."))

(defgeneric $view (tensor &rest sizes)
  (:documentation "Returns a new tensor which has different dimension of the same storage."))
(defgeneric $subview (tensor &rest index-sizes)
  (:documentation "Returns a new tensor which is a subview of the tensor."))

(defgeneric $select (tensor dimension slice-index)
  (:documentation "Returns a new tensor slice at slice-index along dimension."))
(defgeneric $select! (tensor dimension slice-index)
  (:documentation "Returns a tensor slice at slice-index along dimension"))
(defgeneric $narrow (tensor dimension first-index size)
  (:documentation "Returns a new tensor that is a narrowed."))
(defgeneric $narrow! (tensor dimension first-index size)
  (:documentation "Returns a tensor that is a narrowed."))

(defgeneric $unfold (tensor dimension size step)
  (:documentation "Returns a new tensor with all slices of the given size by step."))
(defgeneric $unfold! (tensor dimension size step)
  (:documentation "Returns a tensor with all slices of the given size by step."))

(defgeneric $expand (tensor &rest sizes)
  (:documentation "Returns a new tensor whose singleton dimension can be expanded."))
(defgeneric $expand! (tensor &rest sizes)
  (:documentation "Returns a tensor whose singleton dimension can be expanded."))

(defgeneric $index (tensor dimension index)
  (:documentation "Returns a new tensor with contents selected by index along dimension."))

(defgeneric $gather (tensor dimension indices)
  (:documentation "Returns a new tensor by gathering elements from indices along dimension."))
(defgeneric $scatter (tensor dimension indices value)
  (:documentation "Writes value specified by indices along dimension."))

(defgeneric $masked (tensor mask)
  (:documentation "Returns one dimensional tensor with elements selected by mask."))

(defgeneric $repeat (tensor &rest sizes)
  (:documentation "Returns a new tensor with repeated tensors of grid defined by sizes."))

(defgeneric $squeeze (tensor &optional dimension)
  (:documentation "Returns a new tensor with singleton dimension removed."))
(defgeneric $squeeze! (tensor &optional dimension)
  (:documentation "Returns a tensor with singleton dimension removed."))
(defgeneric $unsqueeze (tensor dimension)
  (:documentation "Returns a new tensor with singleton dimension."))
(defgeneric $unsqueeze! (tensor dimension)
  (:documentation "Returns a tensor with singleton dimension."))

(defgeneric $permute (tensor &rest dimensions)
  (:documentation "Returns a new tensor where the dimensions are permuted as specified."))

(defgeneric $split (tensor size &optional dimension)
  (:documentation "Splits tensor by size along dimension."))
(defgeneric $chunk (tensor n &optional dimension)
  (:documentation "Splits tensor by n approximately equal partitions along dimension."))

(defgeneric $cat (dimension tensor &rest tensors)
  (:documentation "Returns a new tensor which is a concatenation of tensors along dimension."))

(defgeneric $diag (tensor &optional k)
  (:documentation "Returns a new diagonal matrix from tensor."))
(defgeneric $diag! (tensor &optional k)
  (:documentation "Returns a diagonal matrix from tensor."))

(defgeneric $eye (tensor m &optional n)
  (:documentation "Returns a new identity matrix of size m by n"))
(defgeneric $eye! (tensor m &optional n)
  (:documentation "Returns a identity matrix of size m by n"))

(defgeneric $compare (spec a b)
  (:documentation "Returns a byte tensor as boolean for given comparison spec."))
(defgeneric $lt (a b)
  (:documentation "Returns a byte tensor as boolean for elementwise a < b."))
(defgeneric $le (a b)
  (:documentation "Returns a byte tensor as boolean for elementwise a <= b."))
(defgeneric $gt (a b)
  (:documentation "Returns a byte tensor as boolean for elementwise a > b."))
(defgeneric $ge (a b)
  (:documentation "Returns a byte tensor as boolean for elementwise a >= b."))
(defgeneric $eq (a b)
  (:documentation "Returns a byte tensor as boolean for elementwise a = b."))
(defgeneric $ne (a b)
  (:documentation "Returns a byte tensor as boolean for elementwise a ~= b."))

(defgeneric $nonzero (tensor)
  (:documentation "Returns a long tensor which contains indices of nonzero elements."))

(defgeneric $fmap (fn tensor &rest tensors)
  (:documentation "Applies fn elementwise where only non-nil result will be updated, new tensor."))
(defgeneric $fmap! (fn tensor &rest tensors)
  (:documentation "Applies fn elementwise where only non-nil result will be updated on 1st tensor"))
