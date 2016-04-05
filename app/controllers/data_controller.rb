class DataController < ApplicationController
  before_action :set_datum, except: [:index, :new, :create]
  before_action :authenticate_user!, unless: :show_json_request?

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Data", :data_path

  # GET /data
  # GET /data.json
  def index
    @data = current_user.data.order("updated_at DESC").page params[:page]
  end

  # GET /data/1
  # GET /data/1.json
  def show
    add_breadcrumb @datum.name, @datum
  end

  def sankey
    add_breadcrumb @datum.name, @datum
    add_breadcrumb __method__.to_s.humanize, sankey_datum_path(@datum)

    render_view __method__.to_s
  end
  
  def stacked_bar
    add_breadcrumb @datum.name, @datum
    add_breadcrumb __method__.to_s.humanize, stacked_bar_datum_path(@datum)

    render_view __method__.to_s
  end

  def normalized_stacked_bar
    add_breadcrumb @datum.name, @datum
    add_breadcrumb __method__.to_s.humanize, normalized_stacked_bar_datum_path(@datum)

    render_view __method__.to_s
  end

  def sunburst
    add_breadcrumb @datum.name, @datum
    add_breadcrumb __method__.to_s.humanize, sunburst_datum_path(@datum)

    render_view __method__.to_s
  end

  # GET /data/new
  def new
    add_breadcrumb "New"
    
    @datum = current_user.data.new
  end

  # GET /data/1/edit
  def edit
    add_breadcrumb @datum.name, @datum
    add_breadcrumb "Edit"
  end

  # POST /data
  # POST /data.json
  def create
    datum_params_copy = datum_params.dup
    unless datum_params[:file].nil?
      file_data = datum_params[:file]
      if file_data.respond_to?(:read)
        datum_params_copy[:content] = file_data.read
      elsif file_data.respond_to?(:path)
        datum_params_copy[:content] = File.read(file_data.path)
      else
        logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
      end
      puts file_data.path
    end
    datum_params_copy.delete :file

    @datum = current_user.data.new(datum_params_copy)

    respond_to do |format|
      if @datum.save
        format.html { redirect_to edit_datum_path(@datum), notice: 'Datum was successfully created.' }
        format.json { render :show, status: :created, location: @datum }
      else
        format.html { render :new }
        format.json { render json: @datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /data/1
  # PATCH/PUT /data/1.json
  def update
    respond_to do |format|
      if @datum.update(datum_params)
        format.html { redirect_to @datum, notice: 'Datum was successfully updated.' }
        format.json { render :show, status: :ok, location: @datum }
      else
        format.html { render :edit }
        format.json { render json: @datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data/1
  # DELETE /data/1.json
  def destroy
    @datum.destroy
    respond_to do |format|
      format.html { redirect_to data_url, notice: 'Datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_datum
      @datum = Datum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def datum_params
      params.require(:datum).permit(:name, :content, :ignored, :numbers, :file)
    end

    def render_view view
      render :template => "data/draw/"+view.to_s
    end

    def show_json_request?
      :show && request.format.json?
    end
end
