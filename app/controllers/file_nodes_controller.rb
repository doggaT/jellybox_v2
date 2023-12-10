class FileNodesController < ApplicationController
  before_action :set_directory
  before_action :set_file, only: %i[show edit update destroy attach_file]

  def attach_file
    @file_node.file_node.attach(params[:file_upload])
    redirect_to @directory, notice: 'File was successfully uploaded.'
  end

  # GET /Files or /Files.json
  def index
    @file_nodes = FileNode.all
  end

  # GET /Files/1 or /Files/1.json
  def show; end

  # GET /Files/new
  def new
    @file_node = FileNode.new
  end

  # GET /Files/1/edit
  def edit; end

  # POST /Files or /Files.json
  def create
    user = current_user
    directory = user.directories.find_by(id: file_params[:directory_id])

    unless directory
      redirect_to directory_file_node_path, notice: 'Directory not found'
      return
    end

    @file_node = directory.file_nodes.build(filename: file_params[:filename])
    @file_node.file_upload.attach(params[:file])

    respond_to do |format|
      if @file_node.save
        format.html { redirect_to directory_url(@file_node), notice: 'File was successfully uploaded.' }
        format.json { render :show, status: :created, location: @file_node }
      else
        format.html { render :new_subdirectory, status: :unprocessable_entity }
        format.json { render json: @file_node.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /Files/1 or /Files/1.json
  def update
    respond_to do |format|
      if @file_node.update(file_params)
        format.html { redirect_to directory_url(@file_node), notice: 'File was successfully updated.' }
        format.json { render :show, status: :ok, location: @file_node }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @file_node.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /Files/1 or /Files/1.json
  def destroy
    @file_node.destroy

    respond_to do |format|
      format.html { redirect_to directory_url, notice: 'File node was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private

  def file_params
    params.require(:file_node).permit(:filename, :directory_id)
  end

  def set_directory
    @directory = Directory.find(params[:directory_id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Directory not found'
    redirect_to root_path
  end

  def set_file
    @file_node = @directory.file_nodes.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'File not found in this directory'
    redirect_to @directory
  end
end
