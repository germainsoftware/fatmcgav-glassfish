$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))
require 'puppet/provider/asadmin'

Puppet::Type.type(:connectorresource).provide(:asadmin, :parent =>
                                           Puppet::Provider::Asadmin) do
  desc "Glassfish JCA connection resource support."

  def create
    args = Array.new
    args << "create-connector-resource"
    args << "--poolname" << @resource[:poolname]
    if hasEnabled? @resource[:enabled]
      args << "--enabled" << @resource[:enabled]
    end
    if hasObjecttype? @resource[:objecttype]
      args << "--objecttype" << @resource[:objecttype]
    end
    if hasProperties? @resource[:properties]
      args << "--property"
      args << "\'#{prepareProperties @resource[:properties]}\'"
    end
    if hasTarget? @resource[:target]
      args << "--target" << @resource[:target]
    end
    args << @resource[:name]
    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << "delete-connector-resource"
    if hasTarget? @resource[:target]
      args << "--target" << @resource[:target]
    end 
    args << @resource[:name]
    asadmin_exec(args)
  end

  def exists?
    args = Array.new
    args << "list-connector-resources"
    if hasTarget? @resource[:target]
      args << @resource[:target]
    end
    asadmin_exec(args).each do |line|
      return true if @resource[:name] == line.strip
    end
    return false
  end
end
