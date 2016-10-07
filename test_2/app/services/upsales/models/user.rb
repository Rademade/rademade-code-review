class Upsales::Models::User < Upsales::ModelCreator

  protected

  def _prepare_attributes
    user_data = {
      'upsales_user_id' => loaded_attrs['id'],
      'name' => loaded_attrs['name'],
      'email' => loaded_attrs['email'],
      'address' => loaded_attrs['userAddress'],
      'user_state' => loaded_attrs['userState'],
      'user_phone' => loaded_attrs['userPhone'],
      'user_cell_phone' => loaded_attrs['userCellPhone'],
      'active' => loaded_attrs['active']
    }
  end

end
