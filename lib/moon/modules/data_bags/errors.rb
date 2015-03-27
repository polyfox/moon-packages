module Moon #:nodoc:
  # An Error that occurs when writing to a dataset or buffer that is too small,
  # or already full.
  class OverflowError < RuntimeError
  end

  # An Error that occurs when writing to a dataset or buffer with data that
  # will not fully occupy it.
  class UnderflowError < RuntimeError
  end
end
