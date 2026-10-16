require 'rails/generators'
require 'rails/generators/active_record'

class ActsAsWarnable::OccurrencesGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.expand_path('../../templates', __FILE__)

  desc "Adds occurrences/last_issued_at to warnings so repeated warnings are counted instead of duplicated"

  def self.next_migration_number(dirname)
    ActiveRecord::Generators::Base.next_migration_number(dirname)
  end

  def create_migration_file
    migration_template 'add_occurrences_to_warnings.rb.erb', 'db/migrate/add_occurrences_to_warnings.rb'
  end

  private

  def migration_version
    "#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}"
  end
end
