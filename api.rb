get '/api/customer/schema' do
	@c = Controllers::Api::Schema.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end

get '/api/customer/schema/:model' do
	@c = Controllers::Api::Schema.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end


get '/api/admin/props' do
	@c = Controllers::Api::GetProps.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end

get '/api/admin/props/:id' do
	@c = Controllers::Api::GetProp.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end

get '/api/admin/:model/:id' do
	@c = Controllers::Api::Get.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end
get '/api/admin/:model' do
	@c = Controllers::Api::GetList.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end

delete '/api/admin/:model/:id' do
	@c = Controllers::Api::Delete.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end
patch '/api/admin/:model/:id' do
	@c = Controllers::Api::Patch.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end
put '/api/admin/:model/:id' do
	@c = Controllers::Api::Put.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end
post '/api/admin/:model' do
	@c = Controllers::Api::Post.new(request).run!	
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end