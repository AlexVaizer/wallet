get '/api/customer/info/schema' do
	@c = Controller::Api::GetDataModel.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end

get '/api/customer/info/schema/:model' do
	@c = Controller::Api::GetDataModel.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end


get '/api/admin/props' do
	@c = Controller::Api::GetProps.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end

get '/api/admin/props/:id' do
	@c = Controller::Api::GetProp.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end

get '/api/admin/:model/:id' do
	@c = Controller::Api::Get.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end
get '/api/admin/:model' do
	@c = Controller::Api::GetList.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end

delete '/api/admin/:model/:id' do
	@c = Controller::Api::Delete.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end
patch '/api/admin/:model/:id' do
	@c = Controller::Api::Patch.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end
put '/api/admin/:model/:id' do
	@c = Controller::Api::Put.new(request).run!
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end
post '/api/admin/:model' do
	@c = Controller::Api::Post.new(request).run!	
	status @c.response.status
	headers @c.response.headers
	body @c.response.to_h.to_json
end