$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))

Puppet::Type.newtype(:connectorconnectionpool) do
  @doc = "Manage Connector Connection Pools of Glassfish domains"

  ensurable

  newparam(:name) do
    desc "The name of this connection pool."
    isnamevar
  end

  newparam(:raname) do
    desc "The Resource Adapter that this config is for. This name must match the application name of the deployed rar."
  end

  newparam(:connectiondefition) do
    desc "The fully-qualified object type of this connection pool. Ex. javax.jms.ConnectionFactory"
  end

  newparam(:steadypoolsize) do
    desc "The minimum and initial pool size. The pool will not shrink below this size. The default is 8."
  end

  newparam(:maxpoolsize) do
    desc "The maximum pool size. The pool will not grow beyond this size. The default is 32."
  end

  newparam(:maxwait) do
    desc "The maximum time, in milliseconds, that a client will wait for a connection to be created or become available. The default is 60000 milliseconds."
  end

  newparam(:idletimeout) do
    desc "The minimum amount of time, in seconds, that a connection must be idle (unused) before it can be removed from the pool and released.  The default is 300 seconds."
  end

  newparam(:properties) do
    desc "The properties. Ex. user=myuser:password=mypass:url=jdbc\:mysql\://myhost.ex.com\:3306/mydatabase"
  end

  newparam(:portbase) do
    desc "The Glassfish domain port base. Default: 4800"
    defaultto '4800'

    validate do |value|
      raise ArgumentError, "%s is not a valid portbase." % value unless value =~ /^\d{4,5}$/
    end

    munge do |value|
      case value
      when String
        if value =~ /^[-0-9]+$/
          value = Integer(value)
        end
      end

      return value
    end
  end
  
  newparam(:asadminuser) do
    desc "The internal Glassfish user asadmin uses. Default: admin"
    defaultto "admin"

    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid asadmin user name." % value
      end
    end
  end

  newparam(:passwordfile) do
    desc "The file containing the password for the user."

    validate do |value|
      unless File.exists? value
        raise ArgumentError, "%s does not exists" % value
      end
    end
  end

  newparam(:user) do
    desc "The user to run the command as."

    validate do |value|
      unless Puppet.features.root?
        self.fail "Only root can execute commands as other users"
      end
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid user name." % value
      end
    end
  end

  # Validate mandatory params
  validate do
    raise Puppet::Error, 'Raname is required.' unless self[:raname]
    raise Puppet::Error, 'Connectiondefinition is required.' unless self[:connectiondefinition]
  end

  # Autorequire the user running command
  autorequire(:user) do
    self[:user]
  end

  # Autorequire the password file
  autorequire(:file) do
    self[:passwordfile]
  end

  # Autorequire the relevant domain
  autorequire(:domain) do
    self.catalog.resources.select { |res|
      next unless res.type == :domain
      res if res[:portbase] == self[:portbase]
    }.collect { |res|
      res[:name]
    }
  end
end
