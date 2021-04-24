class SeoPage < ApplicationRecord
  module Statuses
    DRAFT = "draft"
    REVIEW = "review"
    READY = "ready"
    ONLINE = "online"
    ARCHIVE = "archive"

    ALL = [DRAFT, REVIEW, READY, ONLINE, ARCHIVE].freeze
  end

  has_rich_text :content

  scope :draft, -> { where(status: SeoPage::Statuses::DRAFT) }
  scope :review, -> { where(status: SeoPage::Statuses::REVIEW) }
  scope :ready, -> { where(status: SeoPage::Statuses::READY) }
  scope :online, -> { where(status: SeoPage::Statuses::ONLINE) }
  scope :archive, -> { where(status: SeoPage::Statuses::ARCHIVE) }

  before_validation :format_fields
  before_validation :set_slug

  validates :title, presence: true
  validates :meta_title, presence: true, length: {minimum: 10, maximum: 70}, if: -> { saved_change_to_attribute?(:status) && attribute_in_database(:status) == Status::ONLINE }
  validates :meta_description, presence: true, length: {minimum: 10, maximum: 150}, if: -> { saved_change_to_attribute?(:status) && attribute_in_database(:status) == Status::ONLINE }
  validates :slug, presence: true, uniqueness: true

  after_initialize do
    if new_record?
      self.status ||= SeoPage::Statuses::DRAFT
    end
  end

  def draft?
    status == SeoPage::Statuses::DRAFT
  end

  def review?
    status == SeoPage::Statuses::REVIEW
  end

  def ready?
    status == SeoPage::Statuses::READY
  end

  def online?
    status == SeoPage::Statuses::ONLINE
  end

  def archive?
    status == SeoPage::Statuses::ARCHIVE
  end

  def to_param
    slug
  end

  private

  def set_slug
    self.slug = title.to_s.parameterize if slug.blank?
  end

  def format_fields
    self.title = title.strip.squish if title.present?
    self.seo_title = seo_title.strip.squish if seo_title.present?
    self.seo_description = seo_description.strip.squish if seo_description.present?
  end
end
