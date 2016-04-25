class WelcomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to(data_path)
      return
    end
    @visualization = Visualization.all.order("views_counter_cache DESC").first
    render layout: false
  end
end
