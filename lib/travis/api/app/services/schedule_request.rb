require 'multi_json'
require 'travis/sidekiq/build_request'
require 'travis/services/base'

class Travis::Api::App
  module Services
    class ScheduleRequest < Travis::Services::Base
      register :schedule_request

      def run
        repo && active? ? schedule_request : not_found
      end

      def messages
        @messages ||= []
      end

      private

        def schedule_request
          Metriks.meter('api.request.create').mark
          Travis::Sidekiq::BuildRequest.perform_async(type: 'api', payload: payload, credentials: {})
          messages << { notice: 'Build request scheduled.' }
          :success
        end

        def not_found
          messages << { error: "Repository #{slug} not found." }
          :not_found
        end

        def active?
          Travis::Features.owner_active?(:request_create, repo.owner)
        end

        def payload
          data = params.merge(user: { id: current_user.id })
          data[:repository][:id] = repo.github_id
          MultiJson.encode(data)
        end

        def repo
          @repo ||= Repository.by_slug(slug).first
        end

        def slug
          repo = params[:repository] || {}
          repo.values_at(:owner_name, :name).join('/')
        end
    end
  end
end
