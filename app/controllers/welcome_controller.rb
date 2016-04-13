class WelcomeController < ApplicationController
  include ApplicationHelper

  def index
    @visualization = Visualization.all.order("views_counter_cache DESC").first
    render layout: false
  end
end
