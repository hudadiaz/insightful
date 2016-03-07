class DataController < ApplicationController
  before_action :set_datum, except: [:index, :new, :create]
  before_action :authenticate_user!

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Data", :data_path

  # GET /data
  # GET /data.json
  def index
    @data = current_user.data.order("updated_at DESC")
  end

  # GET /data/1
  # GET /data/1.json
  def show
    add_breadcrumb @datum.name, @datum

    @csv = CSV.parse(@datum.content, :headers => true)
    unless @datum.ignored.nil?
      @headers = eval(@datum.headers) - eval(@datum.ignored)
    else
      @headers = eval(@datum.headers)
    end
    # @headers = @csv.headers
    @items = @csv.map {|row| row.to_hash }
  end

  def sankey
    add_breadcrumb @datum.name, @datum
    add_breadcrumb "Sankey", sankey_datum_path(@datum)

    render_view :sankey
  end
  
  def stacked_bars
    add_breadcrumb @datum.name, @datum
    add_breadcrumb "Stacked bars", stacked_bars_datum_path(@datum)

    render_view :stacked_bars
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
    @datum.headers = assign_name_to_unnamed(CSV.parse(datum_params_copy[:content].lines.first).first)
    if @datum.content.lines.count > 1
      a = "\"" + eval(@datum.headers).join("\"\,\"") + "\""
      @datum.content.sub! @datum.content.lines.first.chomp, eval(@datum.headers).to_csv
    end

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
      @datum = current_user.data.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def datum_params
      params.require(:datum).permit(:name, :content, :ignored, :types, :file)
    end

    def render_view view
      render :template => "data/draw/"+view.to_s
    end

    def assign_name_to_unnamed headers
      arr = []
      headers.each_with_index do |h, index|
        if h.empty?
          h = 'unnamed_attribute_'+(index+1).to_s
        end
        arr << h
      end
      arr
    end
end
