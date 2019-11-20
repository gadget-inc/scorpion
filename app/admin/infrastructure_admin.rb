# frozen_string_literal: true
Trestle.admin(:infrastructure, path: "infrastructure") do
  menu do
    item :infrastructure, icon: "fa fa-flag"
  end

  controller do
    def run_periodic_enqueue_crawls
      Infrastructure::PeriodicEnqueueCrawlsJob.enqueue
      flash[:message] = "Global enqueue crawls job enqueued"
      redirect_to admin.path
    end
  end

  routes do
    post :run_periodic_enqueue_crawls
  end
end
