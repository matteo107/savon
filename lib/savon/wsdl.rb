require 'savon/wsdl/operation'
require 'savon/wsdl/document_collection'
require 'savon/xs/schema_collection'
require 'savon/resolver'
require 'savon/importer'

class Savon
  class WSDL

    def initialize(wsdl, http)
      @documents = WSDL::DocumentCollection.new
      @schemas = XS::SchemaCollection.new

      resolver = Resolver.new(http)
      importer = Importer.new(resolver, @documents, @schemas)
      importer.import(wsdl)
    end

    # Public: Returns the DocumentCollection.
    attr_reader :documents

    # Public: Returns the SchemaCollection.
    attr_reader :schemas

    # Public: Returns the name of the service.
    def service_name
      @documents.service_name
    end

    # Public: Returns a Hash of services and ports defined by the WSDL.
    def services
      @services ||= services!
    end

    # Public: Returns an Hash of operation names to Operations by service and port name.
    def operations(service_name, port_name)
      verify_service_exists! service_name
      verify_port_exists! service_name, port_name

      port = @documents.service_port(service_name, port_name)
      binding = port.fetch_binding(@documents)

      binding.operations.keys
    end

    # Public: Returns an Operation by service, port and operation name.
    def operation(service_name, port_name, operation_name)
      verify_operation_exists! service_name, port_name, operation_name

      port = @documents.service_port(service_name, port_name)
      endpoint = port.location

      binding = port.fetch_binding(@documents)
      binding_operation = binding.operations.fetch(operation_name)

      port_type = binding.fetch_port_type(@documents)
      port_type_operation = port_type.operations.fetch(operation_name)

      Operation.new(operation_name, endpoint, binding_operation, port_type_operation, self)
    end

    private

    def services!
      services = {}

      @documents.services.each do |service_name, service|
        ports = service.ports.map { |port_name, port|
          [port_name, { type: port.type, location: port.location }]
        }
        services[service_name] = { ports: Hash[ports] }
      end

      services
    end

    # Private: Raises a useful error in case the operation does not exist.
    def verify_operation_exists!(service_name, port_name, operation_name)
      operations = operations(service_name, port_name)

      unless operations.include? operation_name
        raise ArgumentError, "Unknown operation #{operation_name.inspect} for " \
                             "service #{service_name.inspect} and port #{port_name.inspect}.\n" \
                             "You may want to try one of #{operations.inspect}."
      end
    end

    # Private: Raises a useful error in case the port does not exist.
    def verify_port_exists!(service_name, port_name)
      ports = services.fetch(service_name)[:ports]

      unless ports.include? port_name
        raise ArgumentError, "Unknown port #{port_name.inspect} for service #{service_name.inspect}.\n" \
                             "You may want to try one of #{ports.keys.inspect}."
      end
    end

    # Private: Raises a useful error in case the service does not exist.
    def verify_service_exists!(service_name)
      unless services.include? service_name
        raise ArgumentError, "Unknown service #{service_name.inspect}.\n" \
                             "You may want to try one of #{services.keys.inspect}."
      end
    end

  end
end
