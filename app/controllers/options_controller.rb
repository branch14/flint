class OptionsController < ApplicationController

  # GET /options
  # GET /options.xml
  def index
    conditions = params[:code] ? ['code = ?', params[:code]] : []
    @options = Option.all(:conditions => conditions, :order => 'template DESC, id ASC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @options }
    end
  end

  # GET /options/1
  # GET /options/1.xml
  def show
    @option = Option.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @option }
    end
  end

  # GET /options/new
  # GET /options/new.xml
  def new
    @option = Option.new
    @option.code = params[:code]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @option }
    end
  end

  # GET /options/1/edit
  def edit
    @option = Option.find(params[:id])
  end

  # POST /options
  # POST /options.xml
  def create
    @option = Option.new(params[:option])

    respond_to do |format|
      if @option.save
        flash[:notice] = 'Option was successfully created.'
        format.html { redirect_to(@option) }
        format.xml  { render :xml => @option, :status => :created, :location => @option }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @option.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /options/1
  # PUT /options/1.xml
  def update
    @option = Option.find(params[:id])

    respond_to do |format|
      if @option.update_attributes(params[:option])
        flash[:notice] = 'Option was successfully updated.'
        # format.html { redirect_to(@option) }
        format.html { redirect_to(options_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @option.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /options/1
  # DELETE /options/1.xml
  def destroy
    @option = Option.find(params[:id])
    @option.destroy

    respond_to do |format|
      format.html { redirect_to(options_url) }
      format.xml  { head :ok }
    end
  end


  def execute
    @option = Option.find(params[:id])
    @option.execute
    flash[:notice] = "Option <i>#{@option.label}</i> executed."

    respond_to do |format|
      format.html { redirect_to(options_url) }
      format.xml  { head :ok }
    end
  end

  def execute_by_code
    @options = Option.find_all_by_code(params[:id])
    @options.reject!(&:is_expired?)
    @options.reject!(&:template)
    unless @options.empty?
      @options.each { |option| option.execute }
      flash[:notice] = "Options <i>#{@options.map(&:label)*', '}</i> executed."
    else
      # HACK!
      flash[:error] = "Not found. Click here to create a new option for code <a href='/options/new/?code=#{params[:id]}'>#{params[:id]}</a>"
    end

    respond_to do |format|
      format.html { redirect_to(options_url) }
      format.xml  { head :ok }
    end
  end

end
