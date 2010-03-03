module Merb
  module Test
    module RequestHelper
      class FakeRequest < Request
        def _session_secret_key
          super || self.class.superclass._session_secret_key
        end
      end
    end
  end
end
