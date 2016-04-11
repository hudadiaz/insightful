class WelcomeController < ApplicationController
  include ApplicationHelper

  def index
    @visualization = Visualization.all.sort {|a,b| pageviews(visualization_url a) <=> pageviews(visualization_url b)}.last
    render layout: false
  end
end
