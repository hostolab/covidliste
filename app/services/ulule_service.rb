class UluleService
  include HTTParty
  base_uri "https://api.ulule.com"

  def initialize(project_id)
    @project_id = project_id
  end

  def project
    response = self.class.get(
      "/v1/projects/#{@project_id}", 
      query: {
        limit: 10
      },
      format: :json,
      headers: {
        "Ulule-Version" => "2020-11-10"
      }
    )
    return nil if response.nil?

    Rails.logger.debug(response)
    response
  end

  def supporters
    response = self.class.get(
      "/v1/projects/#{@project_id}/supporters", 
      query: {
        limit: 10
      },
      format: :json,
      headers: {
        "Ulule-Version" => "2020-11-10"
      }
    )
    return nil if response.nil?

    Rails.logger.debug(response)
    response
  end
end
