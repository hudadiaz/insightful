class VisualizationsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_visualization, only: [:show, :edit, :update, :destroy]

  add_breadcrumb "Home", :root_path, except: [:index, :show]
  add_breadcrumb "Data", :data_path, except: [:index, :show]

  # GET /visualizations
  # GET /visualizations.json
  def index
    if user_signed_in?
      redirect_to data_path
    else
      @visualizations = Visualization.all.page params[:page]
    end
  end

  # GET /visualizations/1
  # GET /visualizations/1.json
  def show
    render layout: false
  end

  # GET /visualizations/1/edit
  def edit
    add_breadcrumb @visualization.datum.name, @visualization.datum
    add_breadcrumb "Edit visualization"
  end

  # POST /visualizations
  # POST /visualizations.json
  def create
    @visualization = Visualization.new(visualization_params)

    respond_to do |format|
      if @visualization.save
        format.html { render js: "window.location.href = '#{edit_visualization_path(@visualization)}'", notice: 'Visualization was successfully created.' }
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
        format.html { redirect_to @visualization.datum, notice: 'Visualization was successfully updated.' }
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def visualization_params
      params.require(:visualization).permit(:title, :caption, :type, :selections, :datum_id)
    end
end
