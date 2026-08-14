class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private
    # Parses a "?month=YYYY-MM-DD" param into the first day of that month,
    # falling back to the current month for missing/invalid input.
    def parse_month(value)
      Date.parse(value).beginning_of_month
    rescue TypeError, ArgumentError
      Date.current.beginning_of_month
    end
end
