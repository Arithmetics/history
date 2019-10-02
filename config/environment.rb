# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!


#jbuilder json format
Jbuilder.key_format camelize: :lower