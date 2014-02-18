json.array!(@my_processes) do |my_process|
  json.extract! my_process, :id, :pid
  json.url my_process_url(my_process, format: :json)
end
