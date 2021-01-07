class Point < ActiveRecord::Base
  belongs_to :owner,  polymorphic: true

  validates :lat, presence: true
  validates :lng, presence: true
  validates :map_type, presence: true
  validates :owner_type, presence: true

  def foreign_key; owner_id end

  private

    define_method :escape_javascript,
                  ActionView::Helpers::JavaScriptHelper.instance_method(:escape_javascript)
end
