module Presenters
  class QCTaggedPresenter < FinalPlatePresenter
    write_inheritable_attribute :aliquot_partial, 'tagged_aliquot'
  end
end
