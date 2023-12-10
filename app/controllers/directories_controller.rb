# class DirectoriesController
class DirectoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_directory, only: %i[show edit update destroy]

  # GET /directories
  def index
    @current_user = current_user
    @directories = Directory.where(user_id: @current_user.id, parent_id: nil)
    puts @directories.inspect
  end

  # GET /directories/1
  def show
    @current_user = current_user
    @current_directory = Directory.find_by(id: @directory.id, user_id: @current_user.id)
    @subdirectories = Directory.where(parent_id: @directory.id)
  end

  # GET /directories/new
  def new
    @current_user = current_user
    @directory = Directory.new(name: params[:name], user_id: @current_user.id)
  end

  # GET /directories/1/edit
  def edit; end

  # POST /directories or /directories.json
  def create
    @current_user = current_user
    @directory = current_user.directories.new(directory_params)

    respond_to do |format|
      if @directory.save
        format.html { redirect_to directory_url(@directory), notice: 'Directory was successfully created.' }
        format.json { render :show, status: :created, location: @directory }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @directory.errors, status: :unprocessable_entity }
      end
    end
  end

  helper_method :create

  # PATCH/PUT /directories/1 or /directories/1.json
  def update

    # change to insert
    respond_to do |format|
      if @directory.update(directory_params)
        format.html { redirect_to directory_url(@directory), notice: 'Directory was successfully updated.' }
        format.json { render :show, status: :ok, location: @directory }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @directory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /directories/1 or /directories/1.json
  def destroy
    @directory.destroy

    respond_to do |format|
      format.html { redirect_to directories_url, notice: 'Directory was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def attach_files
    @directory = Directory.find(params[:id])

    if params[:directory][:files].present?
      params[:directory][:files].each do |file|
        if file.respond_to?(:tempfile) && file.respond_to?(:content_type)
          filename = file.original_filename
          attached_file = ActiveStorage::Blob.create_and_upload!(
            io: file.tempfile,
            filename:,
            content_type: file.content_type
          )
          @directory.files.attach(attached_file)
        else
          puts "Invalid file parameter: #{file.inspect}"
        end
      end
    end

    redirect_to directory_url(@directory), notice: 'Files were successfully attached.'
  end

  helper_method :attach_files

  # DELETE /directories/:id/attachments/:attachment_id
  def delete_attachment
    @directory = Directory.find(params[:id])
    attachment = @directory.files.find(params[:attachment_id])

    if attachment.purge
      redirect_to directory_url(@directory), notice: 'Attachment was successfully deleted.'
    else
      redirect_to directory_url(@directory), alert: 'Failed to delete attachment.'
    end
  end

  def new_subdirectory
    @current_user = current_user
    @parent_directory = Directory.find(params[:id])
    puts @parent_directory.inspect
    @subdirectory = @parent_directory.subdirectories.build(name: params[:name], parent_id: @parent_directory.id,
                                                           user_id: @current_user.id)
    puts @subdirectory.inspect

  end

  # POST /directories/:id/create_subdirectory
  def create_subdirectory
    @parent_directory = Directory.find(params[:id])
    @subdirectory = @parent_directory.build(subdirectory_params)
    respond_to do |format|
      if @subdirectory.save
        format.html { redirect_to directory_url(@subdirectory), notice: 'Directory was successfully created.' }
        format.json { render :show, status: :created, location: @subdirectory }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @directory.errors, status: :unprocessable_entity }
      end
    end
  end

end

private

def set_directory
  @directory = Directory.find(params[:id])
  @subdirectory = Directory.find_by_parent_id(params[:id]).present?
end

private

def subdirectory_params
  params.require(:directory).permit(:name, :id, :parent_id, files: [])
end

private

def directory_params
  params.require(:directory).permit(:name, :id, :parent_id, files: [])
end

