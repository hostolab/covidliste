FactoryBot.define do
  factory :seo_page do
    status { "draft" }
    visible { false }
    crawlable { false }
    slug { nil }
    title { [Faker::Company.name, Faker::Company.industry].join(" - ") }
    seo_title { [Faker::Company.name, Faker::Company.industry].join(" - ") }
    seo_description { Faker::Hipster.sentences.sample * 2 }
    body { Faker::Lorem.paragraph(sentence_count: 2) }

    trait :draft do
      status { SeoPage::Status::DRAFT }
      visible { false }
    end

    trait :review do
      status { SeoPage::Status::REVIEW }
      visible { false }
    end

    trait :ready do
      status { SeoPage::Status::READY }
      visible { true }
    end

    trait :archive do
      status { SeoPage::Status::ARCHIVE }
      visible { false }
    end
  end
end
