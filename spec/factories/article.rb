FactoryGirl.define do
  factory :article do
    ignore do
      user {FactoryGirl.create(:user)}
    end
    sequence(:title) {|n| "Title #{n}"}
    sequence(:abstract) {|n| "Abstract #{n}"}
    rights { Sufia.config.cc_licenses.keys.first }
    date_uploaded { Date.today }
    date_modified { Date.today }
    visibility Sufia::Models::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    before(:create) { |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
      work.creator = evaluator.user.to_s
    }

    factory :private_article do
      visibility Sufia::Models::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end
    factory :public_article do
      visibility Sufia::Models::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end
    factory :article_with_files do
      ignore do
        file_count 3
      end

      after(:create) do |work, evaluator|
        FactoryGirl.create_list(:generic_file, evaluator.file_count, batch: work, user: evaluator.user)
      end
    end
  end
end