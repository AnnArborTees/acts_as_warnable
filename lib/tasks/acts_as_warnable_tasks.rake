namespace :acts_as_warnable do
  desc "Merge duplicate warnings (same warnable, source, message and dismissal state) into one row, summing occurrences"
  task merge_duplicates: :environment do
    logger = Logger.new($stdout)
    logger.formatter = proc { |_sev, _time, _prog, msg| "#{msg}\n" }

    stats = ActsAsWarnable::Warning.merge_duplicates!(logger: logger)

    puts "Merged #{stats[:groups]} group(s) of duplicate warnings, removing #{stats[:removed]} row(s)."
  end
end
