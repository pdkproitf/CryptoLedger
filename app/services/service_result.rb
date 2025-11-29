# frozen_string_literal: true

class ServiceResult
  attr_reader :data, :errors

  def initialize(data: nil, errors: nil)
    @data = data
    @errors = errors
  end

  def success?
    @errors.nil?
  end

  def error?
    !success?
  end
end
