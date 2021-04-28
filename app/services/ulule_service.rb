class UluleService
  include HTTParty
  base_uri "https://api.ulule.com"
  format :json

  def initialize(project_id)
    @project_id = project_id
    @api_key = ENV["ULULE_API_KEY"]
    self.class.default_options.merge!(
      headers: {
        "Authorization" => "APIKey #{@api_key}",
        "Ulule-Version" => "2020-11-10"
      }
    )
  end

  def project
    self.class.get("/v1/projects/#{@project_id}")
  end

  def supporters
    self.class.get("/v1/projects/#{@project_id}/supporters", query: {limit: 25})
  end

  def orders
    self.class.get("/v1/projects/#{@project_id}/orders", query: {limit: 10})
  end
end
