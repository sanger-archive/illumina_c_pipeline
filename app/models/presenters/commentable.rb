module Presenters
  ##
  # Manage and maintain comments in a presenter
  # include Comments::Uncommented in a presenter to supress comments
  # include Comments::Commented in a presenter to support comments
  module Commentable
    module Uncommented
      def control_comments
        nil
      end
    end
    module Commented
      def control_comments
        commments = labware.comments.map(&:description)
        yield commments
        nil
      end
    end
  end
end
