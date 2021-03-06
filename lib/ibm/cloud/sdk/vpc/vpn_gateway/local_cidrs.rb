# typed: true
# frozen_string_literal: true

module IBM
  module Cloud
    module SDK
      module VPC
        module VPNGATEWAY
          # A list of Connection
          class LocalCIDRs < VPCCollection
            def initialize(parent)
              @array_key = 'local_cidrs'
              @instance = Connection
              super(parent, @array_key)
            end

            def instance(cidr_prefix, prefix_length)
              super(self, "#{cidr_prefix}/#{prefix_length}")
            end
          end

          # A single Connection
          class LocalCIDR < VPCInstance
            def update(payload)
              put(payload: payload)
            end
          end
        end
      end
    end
  end
end
