require "csv"
class HomeController < ApplicationController
  def index
  end

  def restart
    f = MyProcess.first
    f.restart
    render json: {}
  end

  def resume
    f = MyProcess.first
    f.resume
    render json: {}
  end

  def kill
    f = MyProcess.first
    f.kill
    render json: {}
  end

  def progress
    f = MyProcess.first
    p "AAAAAAAA", f
    render json: {status: f.running?, count: Item.count}
  end

  def download
    tmp = '/tmp/data'
    csv_str = CSV.generate do |csv|
      csv << Item.first.attributes.reject!{ |k| ['locations', 'page', 'html', 'created_at', 'updated_at', 'id'].include? k.to_s }.keys
      Item.all.each_with_index do |item, index|
        csv << item.attributes.reject!{ |k| ['locations', 'page', 'html', 'created_at', 'updated_at', 'id'].include? k.to_s }.values
      end
    end

    headers["Content-Type"] ||= 'text/csv'
    send_data csv_str, :filename => 'data.csv'
  end

end
