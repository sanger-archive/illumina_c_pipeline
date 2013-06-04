class TubeCreationController < CreationController

  def form_lookup(form_attributes = params)
    Settings.purposes[form_attributes[:purpose_uuid]][:form_class].constantize
  end

  def redirection_path(form)
    illumina_c_tube_path(form.child.uuid)
  end

end
