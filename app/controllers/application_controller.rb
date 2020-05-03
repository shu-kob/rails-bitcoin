class ApplicationController < ActionController::Base
  layout :set_layout

  class Unauthorized < Lightning::RPCError
  end

  rescue_from Unauthorized, with: :rescue401

  private def set_layout
    if params[:controller].match(%r{¥A(user)/})
      Regexp.last_match[1]
    else
      "user"
    end
  end

  private def rescue401(e)
    @exception = e
    render "errors/unauthorized"
  end
end
