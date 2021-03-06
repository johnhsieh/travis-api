module Travis::API::V3
  module Renderer::Error
    extend self

    def render(error, **)
      {
        :@type         => 'error'.freeze,
        :error_type    => error.type,
        :error_message => error.message,
        **Renderer.render_value(error.payload)
      }
    end
  end
end
