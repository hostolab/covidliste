class UluleService
  include HTTParty
  base_uri "https://api.ulule.com"
  format :json

  CACHE_TTL = Rails.env.development? ? 5.minutes : 1.hours

  def initialize(project_id, ulule_api_key)
    @project_id = project_id

    self.class.default_options.merge!(
      headers: {
        "Authorization" => "APIKey #{ulule_api_key}",
        "Ulule-Version" => "2020-11-10"
      }
    )
  end

  def fetch_api_project
    self.class.get("/v1/projects/#{@project_id}")
  end

  def fetch_api_orders(limit, offset = 0)
    self.class.get("/v1/projects/#{@project_id}/orders", query: {limit: limit, offset: offset})
  end

  def data(force = false)
    Rails.cache.fetch(:ulule_data, expires_in: CACHE_TTL, force: force) {
      {
        project: fetch_api_project,
        bronze_orders: filter_orders(all_orders, 150, 500),
        silver_orders: filter_orders(all_orders, 500, 1000),
        gold_orders: filter_orders(all_orders, 1000, 5000),
        diamond_orders: filter_orders(all_orders, 5000, 99999999)
      }
    }
  end

  def filter_orders(rows, min = 0, max = 0)
    rows.select { |x| x["order_total"] >= min && x["order_total"] < max }
  end

  def all_orders
    @all_orders ||= begin
      pagination = 20
      results = fetch_api_orders(pagination)
      all_orders = results["orders"] || []
      while results["meta"]["next"]
        results = fetch_api_orders(pagination, all_orders.size)
        results["orders"]
        all_orders = all_orders.concat(results["orders"])
      end
      all_orders = all_orders.select { |order| !order["refunded"] && order["status"] == "payment-completed" }.uniq
      all_orders
    end
  end
end
