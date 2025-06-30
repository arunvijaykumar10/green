
class UploadsController < ApplicationController
  # Ensure user is authenticated and company context is set
  before_action :authenticate_user
  before_action :set_company_context
  # before_action :set_payroll_config, only: [:show, :update, :destroy]

  def presigned_url
    authorize :upload, :new?

    unless Current.company && Current.company.tenant
      render json: { status: "error", message: "Company context not established for file upload." }, status: :unprocessable_entity
      return
    end

    files = params[:files] || [{ filename: params[:filename], byte_size: params[:byte_size], checksum: params[:checksum], content_type: params[:content_type] }]

    @blobs = files.map.with_index do |file, index|
      create_blob_for_file(file, index)
    end

    render :presigned_url
  rescue => e
    Rails.logger.error "Error generating presigned URL for upload: #{e.message}"
    render json: { status: "error", message: "Failed to generate presigned URL: #{e.message}" }, status: :internal_server_error
  end

  private

  def create_blob_for_file(file, index)
    filename_param = file[:filename].to_s
    safe_filename = File.basename(filename_param)
    tenant_id = Current.company.tenant.id
    company_id = Current.company.id
    custom_s3_key = "#{tenant_id}/#{company_id}/#{SecureRandom.uuid}/#{index}_#{safe_filename}"

    ActiveStorage::Blob.create_before_direct_upload!(
      filename: safe_filename,
      byte_size: file[:byte_size] || 0,
      checksum: file[:checksum] || 'anonymus',
      content_type: file[:content_type] || "application/octet-stream",
      key: custom_s3_key
    )
  end

  def blob_response(blob)
    {
      signed_id: blob.signed_id,
      direct_upload: {
        url: blob.service_url_for_direct_upload,
        headers: blob.service_headers_for_direct_upload
      }
    }
  end

end
