defmodule LitelistWeb.EmergencyInformationView do
  use LitelistWeb, :view
  import LitelistWeb.FormHelpers
  
  def data(resource) do
    if resource do
      %{action: "/emergency_info/#{resource.id}", fields: build_fields(), resource: resource}
    else
      %{action: "/emergency_info", fields: build_fields(), resource: resource}
    end
  end

  def build_fields() do
  	[
  		%{select: false, title: "TITLE", type: "text", po_body: "Choose a title for your post", id: "post_title"},
  		%{select: false, title: "DESCRIPTION", type: "text", po_body: "Describe the item you are trying to sell. Be detailed.", id: "post_description"},
  		%{select: false, title: "CONTACT_INFO", type: "text", po_body: "How can someone contact your business", id: "post_contact"},
  		%{select: false, title: "ORGANIZATION_NAME", type: "text", po_body: "What is the name of this business or company", id: "post_company_name"},
  		%{select: false, title: "URL", type: "text", po_body: "What URL do you want this post to be found at.  For instance: Ayashas-FORD-BRONCO.4sale.othernet or great-new-car.4sale.othernet", id: "post_url"}
  	]
  end
end
