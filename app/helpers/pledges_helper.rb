module PledgesHelper
  def donor_name(pledge)
    if pledge.anonymous?
      "Anonymous"
    else
      pledge.donor.full_name
    end
  end
end
