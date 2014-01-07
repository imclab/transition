class MappingsController < ApplicationController
  include PaperTrail::Controller

  before_filter :find_site
  before_filter :check_user_can_edit, only: [:new, :create, :edit, :update, :edit_multiple, :update_multiple]

  def new
    @mapping = @site.mappings.build(path: params[:path])
  end

  def create
    @mapping = @site.mappings.build(params[:mapping])
    if @mapping.save
      flash[:success] = view_context.created_mapping(@mapping)
      redirect_to edit_site_mapping_path(@site, @mapping)
    else
      render action: 'new'
    end
  end

  def index
    store_site_return_url
    if params[:contains] =~ %r{^https?://}
      begin
        params[:contains] = URI.parse(params[:contains]).path
      rescue URI::InvalidURIError
      end
    end
    @mappings = @site.mappings.filtered_by_path(params[:contains]).order(:path).page(params[:page])
  end

  def edit
    @mapping = Mapping.find(params[:id])
  end

  def update
    @mapping = @site.mappings.find(params[:id])
    if @mapping.update_attributes(params[:mapping])
      flash[:success] = 'Mapping saved'
      redirect_to edit_site_mapping_path(@site, @mapping)
    else
      render action: 'edit'
    end
  end

  def edit_multiple
    redirect_to site_return_url, notice: bulk.params_invalid_notice and return if bulk.params_invalid?

    if request.xhr?
      render 'edit_multiple_modal', layout: nil
    end
  end

  def update_multiple
    redirect_to site_return_url, notice: bulk.params_invalid_notice and return if bulk.params_invalid?

    if bulk.would_fail?
      if bulk.would_fail_on_new_url?
        @new_url_error = 'Enter a valid URL to redirect these paths to'
        render action: 'edit_multiple' and return
      else
        flash[:danger] = 'Validation failed'
        return redirect_to site_return_url
      end
    end

    bulk.update!

    if bulk.failures?
      @mappings = bulk.failures
      flash[:notice] = 'The following mappings could not be updated'
      render action: 'edit_multiple'
    else
      flash[:success] = 'Mappings updated successfully'
      redirect_to site_return_url
    end
  end

  def find
    path = @site.canonical_path(params[:path])

    if path.empty?
      notice = t('not_possible_to_edit_homepage_mapping')
      return redirect_to back_or_mappings_index, notice: notice
    end

    mapping = @site.mappings.find_by_path(path)
    if mapping.present?
      redirect_to edit_site_mapping_path(@site, mapping)
    else
      redirect_to new_site_mapping_path(@site, path: path)
    end
  end

  private
  def bulk
    @bulk ||= View::Mappings::BulkEditor.new(@site, params, site_return_url)
  end

  private
  def find_site
    @site = Site.find_by_abbr(params[:site_id])
  end

  def check_user_can_edit
    unless current_user.can_edit?(@site.organisation)
      message = "You don't have permission to edit site mappings for #{@site.organisation.title}"
      redirect_to site_mappings_path(@site), alert: message
    end
  end

  def back_or_mappings_index
    request.env['HTTP_REFERER'] || site_mappings_path(@site)
  end

  def site_return_url_key
    "return_to_#{@site.abbr}".to_sym
  end

  def store_site_return_url
    session[site_return_url_key] = request.url
  end

  def site_return_url
    session[site_return_url_key] || site_mappings_path(@site)
  end
end
