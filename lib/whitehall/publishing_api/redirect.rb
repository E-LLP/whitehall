require "securerandom"

module Whitehall
  class PublishingApi
    class Redirect
      attr_reader :base_path

      def initialize(base_path, redirects)
        @redirects = redirects
        @base_path = base_path
      end

      def as_json
        {
          content_id: SecureRandom.uuid,
          base_path: base_path,
          format: "redirect",
          publishing_app: "whitehall",
          update_type: "major",
          redirects: redirects,
        }
      end

    private

      attr_reader :redirects
    end
  end
end
