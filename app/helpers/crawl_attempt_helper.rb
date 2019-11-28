# frozen_string_literal: true

module CrawlAttemptHelper
  def self.logs_url(attempt)
    "https://console.cloud.google.com/logs/viewer?interval=NO_LIMIT&project=superpro-production&authuser=3&folder&organizationId&minLogLevel=0&expandAll=false&customFacets=jsonPayload.metadata.label,jsonPayload.metadata.traceContext,jsonPayload.metadata.requestId,jsonPayload.metadata.propertyId,jsonPayload.metadata.url&limitCustomFacetWidth=false&advancedFilter=resource.type%3D%22container%22%0Aresource.labels.cluster_name%3D%22alpha%22%0Aresource.labels.namespace_id%3D%22scorpion-crawler-production%22%0Aresource.labels.project_id%3D%22superpro-production%22%0Aresource.labels.zone:%22us-central1-a%22%0Aresource.labels.container_name%3D%22web%22%0AjsonPayload.metadata.propertyId%3D%22#{attempt.id}%22"
  end
end
