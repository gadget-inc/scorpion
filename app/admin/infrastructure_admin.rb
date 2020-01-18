# frozen_string_literal: true
Trestle.admin(:infrastructure, path: "infrastructure") do
  menu do
    item :infrastructure, icon: "fa fa-flag"
  end

  controller do
    def run_periodic_enqueue_crawls
      job = case params[:crawl_type]
        when "collect_page_info"
          Infrastructure::PeriodicEnqueueCollectPageInfoCrawlsJob
        when "collect_screenshots"
          Infrastructure::PeriodicEnqueueCollectScreenshotsCrawlsJob
        else
          raise "Unknown crawl type for enqueue: #{params[:crawl_type]}"
        end
      job.enqueue
      flash[:message] = "Global #{job.name} job enqueued"
      redirect_to admin.path
    end
  end

  routes do
    post :run_periodic_enqueue_crawls
  end
end
