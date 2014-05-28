require 'net/http'

class Node < ActiveRecord::Base
  #attr_accessible :name, :adress, :port

  def list_probe
    JSON::parse(Net::HTTP.get(adress, '/probes/list', port))
  end

  def get_report probe, target
    begin
      JSON::parse(Net::HTTP.get(adress, "/probe/#{probe}/#{target}", port))
    rescue
      raise [probe, target].inspect
    end
  end
end
