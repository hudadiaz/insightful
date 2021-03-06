class VisualizationsController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_action :authenticate_user!, only: [:my, :show, :create, :edit, :update, :destroy], unless: :show_json_request?
  before_action :set_visualization, only: [:show, :standalone, :edit, :update, :destroy]
  before_action :require_ownership, only: [:show, :edit, :update, :destroy], unless: :show_json_request?

  add_breadcrumb "Data", :data_path, except: [:index, :my, :standalone]
  add_breadcrumb "Visualizations", :visualizations_path

  # GET /visualizations
  # GET /visualizations.json
  def index
    if params.has_key?(:user)
      @visualizations = User.find(params[:user]).visualizations.order("views_counter_cache DESC").page params[:page]
    elsif params.has_key?(:type)
      @visualizations = Visualization.where(type: params[:type]).order("views_counter_cache DESC").page params[:page]
    else
      @visualizations = Visualization.all.order("views_counter_cache DESC").page params[:page]
    end
  end

  def my
    add_breadcrumb "Mine"
    @visualizations = current_user.visualizations.order("views_counter_cache DESC").page params[:page]
  end

  # GET /visualizations/1
  # GET /visualizations/1.json
  def show
    # respond_to do |format|
    #   format.html {
        add_breadcrumb bc_datum_name, @visualization.datum
        add_breadcrumb bc_name
    #   }
    #   format.json { render json: Oj.dump(@visualization.processed_data) }
    # end
  end

  def standalone
    response.headers.delete "X-Frame-Options"
    if current_user != @visualization.user && !params.has_key?(:notrack)
      impressionist @visualization
    end
    render layout: false
  end

  # GET /visualizations/1/edit
  def edit
    add_breadcrumb bc_datum_name, @visualization.datum
    add_breadcrumb bc_name, @visualization
    add_breadcrumb "Edit"
  end

  # POST /visualizations
  # POST /visualizations.json
  def create
    @visualization = Visualization.new(visualization_params)
    @visualization.datum_last_updated_at = @visualization.datum.updated_at
    
    if current_user != @visualization.user
      redirect_to :root, notice: 'You are not authorized for that action!', notice_type: 'danger'
    end

    respond_to do |format|
      if @visualization.save
        format.html { render js: "window.location.href = '#{edit_visualization_path(@visualization)}'", notice: 'Visualization was successfully created.', notice_type: 'primary' }
        format.json { render :show, status: :created, location: @visualization }
      else
        format.html { render :new }
        format.json { render json: @visualization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /visualizations/1
  # PATCH/PUT /visualizations/1.json
  def update
    respond_to do |format|
      if @visualization.update(visualization_params)
        format.html { redirect_to @visualization.datum, notice: 'Visualization was successfully updated.', notice_type: 'primary' }
        format.json { render :show, status: :ok, location: @visualization }
      else
        format.html { render :edit }
        format.json { render json: @visualization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /visualizations/1
  # DELETE /visualizations/1.json
  def destroy
    datum = @visualization.datum
    @visualization.destroy
    respond_to do |format|
      format.html { redirect_to datum, notice: 'Visualization was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_visualization
      @visualization = Visualization.find(params[:id])
    end

    def require_ownership
      if current_user != @visualization.user
        redirect_to :root, notice: 'You are not authorized for that action!', notice_type: 'danger'
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def visualization_params
      params.require(:visualization).permit(:title, :caption, :type, :selections, :datum_id)
    end

    def show_json_request?
      :show && request.format.json?
    end

    def bc_datum_name
      truncate(@visualization.datum.name, :ommision => "...", :length => 15)
    end

    def bc_name
      truncate(@visualization.title, :ommision => "...", :length => 15)
    end
end
