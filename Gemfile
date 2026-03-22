# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

gem "hanami-utils", github: "hanami/utils", branch: "main"
gem "hanami-cli", github: "hanami/cli", branch: "main"
gem "hanami", github: "hanami/hanami", branch: "main"

group :tools do
  gem "debug"
end

group :docs do
  gem "redcarpet", platform: :mri
  gem "yard"
  gem "yard-junk"
end
