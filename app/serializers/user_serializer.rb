class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :display_name

  def display_name
    "#{object.first_name} #{object.last_name}"
  end
end
