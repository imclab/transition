class NonBlankURLValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    valid_url = begin
      uri = URI.parse(value)
      !uri.scheme.blank? && !uri.host.blank?
    rescue URI::InvalidURIError
      false
    end
    record.errors.add attribute, (options[:message] || 'is not a URL') unless valid_url
  end
end
