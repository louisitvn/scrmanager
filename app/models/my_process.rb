class MyProcess < ActiveRecord::Base
  def running?
    begin
      Process.kill(0, self.pid)
      return true
    rescue
      return false
    end
  end

  def resume
    run()
  end

  def start
    resume()
  end

  def restart
    Item.delete_all
    run()
  end

  def kill
    Process.kill 9, self.pid
  end

  private
  def run
    if self.running?
      # already running
    else
      process = IO.popen("ruby /home/nghi/axial.net_scraping/scraper.rb -o /home/nghi/russscr/db/development.sqlite3")
      Process.detach(process.pid)
      self.pid = process.pid
      self.save
    end
  end
end
