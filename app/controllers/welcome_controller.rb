class WelcomeController < ApplicationController
  include ApplicationHelper

  def index
    @visualization = Visualization.all.sort {|a, b| pageviews(standalone_visualization_url a) <=> pageviews(standalone_visualization_url b)}.last
    render layout: false
  end
end
