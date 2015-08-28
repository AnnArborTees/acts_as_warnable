class ActsAsWarnable::WarningGenerator < Rails::Generators::Base
  desc "Generates the migration for warnings"

  def create_migrations
    generate 'migration', 'CreateWarnings warnable_id:integer warnable_type:string source:string message:text dismissed_at:datetime dismisser_id:integer'
    generate 'migration', 'AddTimestampsToWarnings created_at:datetime updated_at:datetime'
    generate 'migration', 'CreateWarningEmails model:string minutes:decimal\\{10,2\\} recipient:string url:string'
  end
end
