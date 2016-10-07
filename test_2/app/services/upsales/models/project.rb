class Upsales::Models::Project < Upsales::ModelCreator

  protected

  def _prepare_attributes
    first_letter = loaded_attrs['name'] ? loaded_attrs['name'].capitalize[0] : nil

    project_data = {
      'upsales_project_id' => loaded_attrs['id'],
      'name' => loaded_attrs['name'],
      'first_letter' => first_letter,
      'start_date' => loaded_attrs['startDate'],
      'end_date' => loaded_attrs['endDate'],
      'quota' => loaded_attrs['quota'],
      'active' => loaded_attrs['active'],
      'notes' => loaded_attrs['notes']
    }
  end

  def set_relations
    _bind_many_to_many_models('users', :upsales_project_id, ::User, :upsales_user_id)
  end

  def clear_relations(project)
    user_associations = project.users
    project.users.delete(user_associations)
  end

end
