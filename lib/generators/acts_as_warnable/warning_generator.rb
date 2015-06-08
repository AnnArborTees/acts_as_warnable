class ActsAsWarnable::WarningGenerator < Rails::Generators::Base
  desc "Generates the migration for warnings"

  def create_migration
    generate 'migration', 'CreateWarnings warnable_id:integer warnable_type:string message:text'
  end
end
