module ValidationHelper
  def required?(obj, attr)
    target = (obj.class == Class) ? obj : obj.class
    validators = target.validators_on(attr).map(&:class)
    validators.include?(ActiveModel::Validations::PresenceValidator) ||
      validators.include?(ActiveRecord::Validations::PresenceValidator)
  end
end
