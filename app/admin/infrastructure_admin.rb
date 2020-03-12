# frozen_string_literal: true
Trestle.admin(:infrastructure, path: "infrastructure") do
  menu do
    item :infrastructure, icon: "fa fa-flag"
  end

  controller do
    def run_periodic_enqueue_crawls
      job = case params[:crawl_type]
        when "high_frequency"
          Infrastructure::PeriodicHighFrequencyEnqueueJob
        when "medium_frequency"
          Infrastructure::PeriodicMediumFrequencyEnqueueJob
        else
          raise "Unknown crawl type for enqueue: #{params[:crawl_type]}"
        end

      # Lazy
      if Rails.env.development?
        begin
          old_value = Que::Job.run_synchronously
          Que::Job.run_synchronously = true
          job.run
        ensure
          Que::Job.run_synchronously = old_value
          flash[:message] = "Global #{job.name} job run"
        end
      else
        job.enqueue
        flash[:message] = "Global #{job.name} job enqueued"
      end

      redirect_to admin.path
    end
  end

  routes do
    post :run_periodic_enqueue_crawls
  end
end
