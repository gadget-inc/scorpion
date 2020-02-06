# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include ArTransactionChanges
  include PgSearch
  def self.remove_blanks_for_array_assignment(*attrs)
    attrs.each do |attr|
      define_method("#{attr}=".to_sym) do |value|
        value = value.reject(&:blank?) unless value.nil?
        super(value)
      end
    end
  end

  def self.admin_searchable(*attrs)
    pg_search_scope :admin_search, against: attrs, using: %i[tsearch trigram dmetaphone]
  end
end
