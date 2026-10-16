module ActsAsWarnable
  class Warning < ActiveRecord::Base
    self.table_name = 'warnings'

    def self.dismisser_class
      @dismisser ||= ENV['DISMISSER_CLASS'].try(:constantize) || User
    end

    # True once the host app has run the `acts_as_warnable:occurrences` generator
    # and migrated. Until then warnings behave as they always have (one row per issue).
    def self.tracks_occurrences?
      column_names.include?('occurrences')
    end

    belongs_to :warnable, polymorphic: true

    if defined? Softwear::Auth::BelongsToUser
      include Softwear::Auth::BelongsToUser
      belongs_to_user_called :dismisser
    else
      belongs_to :dismisser, class_name: dismisser_class
    end

    validates :message, :source, presence: true

    before_save :check_if_dismissed
    after_save :fire_dismissal_activity, if: :just_dismissed?

    scope :active, -> { where(dismissed_at: nil) }
    scope :inactive, -> { where.not(dismissed_at: nil) }

    # Collapses duplicate warnings - same warnable, source, message and dismissal
    # state - into a single row whose `occurrences` is the sum of the duplicates.
    # The oldest row is kept; the rest are deleted. For dismissed groups the most
    # recent dismissal (dismissed_at / dismisser) wins. Public Activity records
    # pointing at removed warnings are re-pointed to the kept one.
    #
    # Returns a hash with the number of :groups merged and rows :removed.
    def self.merge_duplicates!(scope: all, logger: nil)
      raise "warnings.occurrences column is missing - run the acts_as_warnable:occurrences generator" unless tracks_occurrences?

      stats = { groups: 0, removed: 0 }
      key_columns = [:warnable_type, :warnable_id, :source, :message]

      [scope.active, scope.inactive].each do |subset|
        subset = subset.unscope(:order, :limit, :offset)
        duplicate_keys = subset.group(*key_columns).having('COUNT(*) > 1').count.keys

        duplicate_keys.each do |key|
          conditions = key_columns.zip(key).to_h
          records = subset.where(conditions).order(:id).to_a
          next if records.size < 2

          keeper, *extras = records
          merge_warnings!(keeper, extras)

          stats[:groups]  += 1
          stats[:removed] += extras.size
          logger&.info "Merged #{extras.size} duplicate(s) into warning ##{keeper.id} (#{keeper.warnable_type} ##{keeper.warnable_id}, #{keeper.source})"
        end
      end

      stats
    end

    def self.merge_warnings!(keeper, extras)
      records = [keeper, *extras]
      extra_ids = extras.map(&:id)

      attributes = {
        occurrences:    records.sum { |w| w.occurrences || 1 },
        last_issued_at: records.filter_map(&:last_issued_at).max
      }

      if keeper.dismissed_at.present?
        latest = records.max_by { |w| w.dismissed_at || Time.at(0) }
        attributes[:dismissed_at] = latest.dismissed_at
        attributes[:dismisser_id] = latest.dismisser_id
      end

      transaction do
        keeper.update_columns(attributes)

        if defined?(PublicActivity::Activity)
          PublicActivity::Activity
            .where(recipient_type: [name, 'Warning'], recipient_id: extra_ids)
            .update_all(recipient_id: keeper.id)
        end

        where(id: extra_ids).delete_all
      end

      keeper
    end

    def dismiss(user)
      update dismissed_at: Time.now, dismisser: user
    end

    def dismissed?
      !dismissed_at.nil? && !dismisser.nil?
    end

    def just_dismissed?
      @just_dismissed
    end

    # Called when this (active) warning is issued again. Bumps the occurrence
    # count atomically and refreshes last_issued_at / updated_at.
    def record_occurrence!
      return self unless self.class.tracks_occurrences?

      self.class.update_counters(id, occurrences: 1, touch: :last_issued_at)
      reload
    end

    def occurrences
      self.class.tracks_occurrences? ? super : 1
    end

    # Falls back to created_at for warnings issued before occurrence tracking.
    def last_issued_at
      value = self.class.tracks_occurrences? ? super : nil
      value || try(:created_at)
    end

    def reissued?
      occurrences > 1
    end

    protected

    def fire_dismissal_activity
      return unless warnable.respond_to?(:create_activity)

      warnable.create_activity(
        key: 'warning.dismiss',
        recipient: self,
        owner: dismisser
      )
    end

    def check_if_dismissed
      if dismisser_id_changed?
        if dismisser_id.nil?
          self.dismissed_at = nil
        else
          self.dismissed_at = Time.now
          @just_dismissed = true
        end
      end
    end
  end
end
