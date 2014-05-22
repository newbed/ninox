class DocumentsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]

  def index
    @title = "List of documents"
    @documents  = Document.order(:title).page(params[:page])
  end

  def show
    @document   = Document.find(params[:id])
    @title = @document.title
  end

  def new
    @document   = Document.new(params[:document])
    @title = "New document"
  end

  def create
    @document = Document.new(params[:document])
    @document.user = current_user
    if course_exists?(@document.course_id) && @document.save
      flash[:success] = "Document created"
      redirect_to document_path(@document)
    else
      @title = "New document"
      render 'new'
    end
  end

  def edit
    @document = Document.find(params[:id])
    if (@document.user != current_user)
      redirect_to root_path, alert: "Access denied"
    end
    @title = "Edit document"
  end

  def update
    @document = Document.find(params[:id])
    if (@document.user != current_user)
      redirect_to root_path, alert: "Forbidden operation"
    end
    if course_exists?(@document.course_id) && @document.update_attributes(params[:document])
      flash[:success] = "Document updated"
      redirect_to document_path(@document)
    else
      @title = "Edit document"
      render 'edit'
    end
  end

  def destroy
    @document = Document.find(params[:id])
    if (@document.user != current_user)
      redirect_to root_path, alert: "Forbidden operation"
    end
    @document.destroy
    flash[:success] = "Document deleted"
    redirect_to documents_path
  end

  private
    def course_exists?(course_id)
      (not Course.find_by_id(course_id).nil?) or course_id.nil?
    end
end
