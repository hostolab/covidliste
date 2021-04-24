FactoryBot.define do
  factory :seo_page do
    status { "draft" }
    crawlable { false }
    indexable { false }
    slug { nil }
    title { [Faker::Company.name, Faker::Company.industry].join(" - ") }
    seo_title { [Faker::Company.name, Faker::Company.industry].join(" - ") }
    seo_description { Faker::Hipster.sentences.sample * 2 }
    content { Faker::Lorem.paragraph(sentence_count: 2) }

    trait :draft do
      status { SeoPage::Status::DRAFT }
    end

    trait :review do
      status { SeoPage::Status::REVIEW }
    end

    trait :ready do
      status { SeoPage::Status::READY }
    end

    trait :online do
      status { SeoPage::Status::ONLINE }
    end

    trait :archive do
      status { SeoPage::Status::ARCHIVE }
    end
  end
end
