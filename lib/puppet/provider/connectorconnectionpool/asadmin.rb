$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))
require 'puppet/provider/asadmin'

Puppet::Type.type(:connectorconnectionpool).provide(:asadmin, :parent =>
                                           Puppet::Provider::Asadmin) do
  desc "Glassfish JCA connection pool support."

  def create
    args = Array.new
    args << "create-connector-connection-pool"
    args << "--raname" << @resource[:raname]
    args << "--connectiondefinition" << @resource[:connectiondefinition]
    args << "--steadypoolsize" << @resource[:steadypoolsize] if @resource[:steadypoolsize] and
      not @resource[:steadypoolsize].empty?
    args << "--maxpoolsize" << @resource[:maxpoolsize] if @resource[:maxpoolsize] and
      not @resource[:maxpoolsize].empty?
    args << "--maxwait" << @resource[:maxwait] if @resource[:maxwait] and
      not @resource[:maxwait].empty?
    args << "--idletimeout" << @resource[:idletimeout] if @resource[:idletimeout] and
      not @resource[:idletimeout].empty?
    if hasProperties? @resource[:properties]
      args << "--property"
      args << "\'#{prepareProperties @resource[:properties]}\'"
    end
    args << @resource[:name]
    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << "delete-connector-connection-pool" << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    asadmin_exec(["list-connector-connection-pools"]).each do |line|
      return true if @resource[:name] == line.strip
    end
    return false
  end
end
