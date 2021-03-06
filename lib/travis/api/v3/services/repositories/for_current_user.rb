module Travis::API::V3
  class Services::Repositories::ForCurrentUser < Service
    params :active, :private, prefix: :repository

    def run!
      raise LoginRequired unless access_control.logged_in?
      query.for_member(access_control.user)
    end
  end
end
