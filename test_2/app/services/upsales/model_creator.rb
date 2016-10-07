class Upsales::ModelCreator

  def initialize(loaded_attrs)
    @loaded_attrs = loaded_attrs
  end

  def process_data
    upsales_id = "upsales_#{underscored_model_name}_id"
    model = model_name.constantize
    record = model.find_by(upsales_id => loaded_attrs['id'])

    if model_name == 'Project' && record.nil?
      record = model.find_by(name: loaded_attrs['name'])
    end

    if record
      update_model(record)
    else
      record = create_model
    end

    record
  end

  protected

  def loaded_attrs
    @loaded_attrs
  end

  def create_model
    model = model_name.constantize
    model.skip_callback(:create)
    record = model.create!(_prepare_attributes)
    set_relations
    record.save
    record
  end

  def update_model(record)
    record.update_attributes(_prepare_attributes)
    clear_relations(record)
    set_relations
  end

  def _bind_model(binding_field_name, related_model, related_model_upsales_id)
    if loaded_attrs[binding_field_name].present?
      if loaded_attrs[binding_field_name].is_a?(Array)
        get_relation_from_objects_array(
          binding_field_name,
          related_model,
          related_model_upsales_id
        )
      else
        if record = related_model.find_by(
            related_model_upsales_id => loaded_attrs[binding_field_name]['id'])
          record.id
        end
      end
    end
  end

  def _bind_to_model(binding_field_name, id_field, related_model, related_model_upsales_id)
    upsales_id_field = 'upsales_' + id_field.to_s
    related_obj = model_name.constantize.find_by(upsales_id_field => loaded_attrs['id'])

    if loaded_attrs[binding_field_name].present?
      if loaded_attrs[binding_field_name].is_a?(Array)
        loaded_attrs[binding_field_name].each do |obj|
          set_one_to_many_relation(
            id_field,
            related_obj.id,
            related_model,
            related_model_upsales_id
          )
        end
      else
        set_one_to_many_relation(
          id_field,
          related_obj.id,
          related_model,
          related_model_upsales_id
        )
      end
    end
  end

  def _bind_many_to_many_models(binding_field_name, upsales_id_field, related_model, related_model_upsales_id)
    related_connection_name = related_model.to_s.underscore.pluralize

    if loaded_attrs[binding_field_name].present?
      model_name.constantize.find_by(
        upsales_id_field => loaded_attrs['id']).send(related_connection_name) <<
          make_relations_array(
            binding_field_name,
            related_model,
            related_model_upsales_id
          )
    end
  end

  def get_relation_from_objects_array(binding_field_name, related_model, related_model_upsales_id)
    if loaded_attrs[binding_field_name][0].present?
      if record = related_model.find_by(
          related_model_upsales_id => loaded_attrs[binding_field_name][0]['id'])
        record.id
      end
    end
  end

  def set_one_to_many_relation(id_field, related_id_value, related_model, related_model_upsales_id)
    if record = related_model.find_by(related_model_upsales_id => related_id_value)
      record.update_attributes(id_field => related_id_value)
    end
  end

  def make_relations_array(binding_field_name, related_model, related_model_upsales_id)
    relations = []

    loaded_attrs[binding_field_name].each do |item|
      if record = related_model.find_by(related_model_upsales_id => item['id'])
        relations << record
      end
    end

    relations
  end

  def _prepare_attributes
  end

  def clear_relations(*)
  end

  def set_relations
  end

  def model_name
    self.class.name.gsub!('Upsales::Models::', '')
  end

  def underscored_model_name
    self.class.name.gsub!('Upsales::Models::', '').underscore
  end

end
