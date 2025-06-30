json.status "success"
json.message "Presigned URLs generated successfully"

json.data @blobs do |blob|
  json.signed_id blob.signed_id
  json.key blob.key
  json.direct_upload do
    json.url blob.service_url_for_direct_upload
    json.headers blob.service_headers_for_direct_upload
  end
end