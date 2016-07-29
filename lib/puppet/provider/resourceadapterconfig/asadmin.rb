$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))
require 'puppet/provider/asadmin'

Puppet::Type.type(:resourceadapterconfig).provide(:asadmin, :parent =>
                                           Puppet::Provider::Asadmin) do
  desc "Glassfish JCA resource adpater configuration support."

  def create
    args = Array.new
    args << "create-resource-adapter-config"
    args << "--threadpoolid" << @resource[:threadpoolid] if @resource[:threadpoolid] and
      not @resource[:threadpoolid].empty?
    args << "--objecttype" << @resource[:objecttype] if @resource[:objecttype] and
      not @resource[:objecttype].empty?
    if hasProperties? @resource[:properties]
      args << "--property"
      args << "\'#{prepareProperties @resource[:properties]}\'"
    end
    args << @resource[:name]
    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << "delete-resource-adapter-config" << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    args = Array.new
    args << "list-resource-adapter-configs" << "--raname" << @resource[:name]
    asadmin_exec(args).each do |line|
      return true if @resource[:name] == line.strip
    end
    return false
  end
end
