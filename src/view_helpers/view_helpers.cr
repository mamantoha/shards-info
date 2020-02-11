require "ecr"

module ViewHelpers
  record Paginator, current_page : Int32, per_page : Int32, total_count : Int64, link : String do
    ECR.def_to_s "#{__DIR__}/paginate.ecr"
  end
end
