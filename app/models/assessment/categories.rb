# frozen_string_literal: true

# Constant describing the information architecture that all our different assessments fall into.
module Assessment
  Categories = { # rubocop:disable Naming/ConstantName
    home: {},
    navigation: {},
    browsing: {},
    products: {},
    search: {},
    cart: {},
    checkout: {},
    performance: {},
    design: {},
    seo: {},
    security: {},
  }.freeze
end
