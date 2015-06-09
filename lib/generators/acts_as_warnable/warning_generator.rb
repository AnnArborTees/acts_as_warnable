class ActsAsWarnable::WarningGenerator < Rails::Generators::Base
  desc "Generates the migration for warnings"

  def create_migration
    generate 'migration', 'CreateWarnings warnable_id:integer warnable_type:string source:string message:text dismissed_at:datetime dismisser_id:integer'
  end
end
