$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))

Puppet::Type.newtype(:connectorresource) do
  @doc = "Manage Connector Resources of Glassfish domains"

  ensurable

  newparam(:name) do
    desc "The name JNDI name of this connection resource used to lookup the associated connection pool."
    isnamevar
  end

  newparam(:poolname) do
    desc "The name of the Connector Connection Pool that this resource will reference."
  end

  newparam(:enabled) do
    desc "Determines whether this resource is enabled at runtime.  The default is true."
  end

  newparam(:objecttype) do
    desc "The fully-qualified object type of this connection pool. Ex. javax.jms.ConnectionFactory"
  end

  newparam(:properties) do
    desc "The properties. Ex. user=myuser:password=mypass:url=jdbc\:mysql\://myhost.ex.com\:3306/mydatabase"
  end

  newparam(:target) do
    desc "The target on which this resource is created.  Default is server."
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
    raise Puppet::Error, 'Poolname is required.' unless self[:poolname]
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
