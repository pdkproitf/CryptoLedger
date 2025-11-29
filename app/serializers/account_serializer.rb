# frozen_string_literal: true

class AccountSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :currency, :balance, :status, :created_at, :updated_at
end
