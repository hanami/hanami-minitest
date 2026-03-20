# frozen_string_literal: true

require "pathname"
TEST_ROOT = Pathname(__dir__).realpath.freeze

require "minitest/autorun"
require "hanami/minitest"
require "dry/files"
require "securerandom"
require "tmpdir"

TMP = File.join(Dir.pwd, "tmp")
