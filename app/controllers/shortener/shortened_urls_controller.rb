class Shortener::ShortenedUrlsController < ActionController::Metal
  include ActionController::StrongParameters
  include ActionController::Redirecting
  include ActionController::Instrumentation
  include Rails.application.routes.url_helpers
  include Shortener

  def show
    token = ::Shortener::ShortenedUrl.extract_token(params[:id])
    track = Shortener.ignore_robots.blank? || request.human?
    url   = ::Shortener::ShortenedUrl.fetch_with_token(token: token, additional_params: params, track: track)
    check_and_expire_url(url)
    redirect_to url[:url], status: :moved_permanently
  end

  def check_and_expire_url(url)
    return unless url.category.eql?('login')

    url.expire!
  end
end
