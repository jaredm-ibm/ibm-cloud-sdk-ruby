# frozen_string_literal: true

require 'ibm-cloud-sdk'
require_relative 'vpc_vcr'

methods = {
  floating_ips: IBM::Cloud::SDK::VPC::FloatingIPs,
  flowlog_collectors: IBM::Cloud::SDK::VPC::FlowLogCollectors,
  ike_policies: IBM::Cloud::SDK::VPC::IKEPolicies,
  images: IBM::Cloud::SDK::VPC::Images,
  instance_profiles: IBM::Cloud::SDK::VPC::InstanceProfiles,
  instances: IBM::Cloud::SDK::VPC::Instances,
  ipsec_policies: IBM::Cloud::SDK::VPC::IPSecPolicies,
  keys: IBM::Cloud::SDK::VPC::Keys,
  load_balancers: IBM::Cloud::SDK::VPC::LoadBalancers,
  network_acls: IBM::Cloud::SDK::VPC::NetworkACLs,
  operating_systems: IBM::Cloud::SDK::VPC::OperatingSystems,
  public_gateways: IBM::Cloud::SDK::VPC::PublicGateways,
  regions: IBM::Cloud::SDK::VPC::Regions,
  security_groups: IBM::Cloud::SDK::VPC::SecurityGroups,
  subnets: IBM::Cloud::SDK::VPC::Subnets,
  volumes: IBM::Cloud::SDK::VPC::Volumes,
  volumes_profiles: IBM::Cloud::SDK::VPC::VolumeProfiles,
  vpcs: IBM::Cloud::SDK::VPC::Vpcs,
  vpn_gateways: IBM::Cloud::SDK::VPC::VPNGateways
}.freeze

RSpec.describe 'Test vpc API', vcr: { tag: :require_2xx } do # rubocop:disable Metrics/BlockLength
  let(:log) { Logger.new($stdout).tap { |l| l.level = Logger::DEBUG } }
  let(:vpc) { VCR.use_cassette('Test_vpc_API/vpc', { tags: %i[require_2xx token_request] }) { IBM::CloudSDK.new(ENV['IBM_CLOUD_APIKEY']).vpc } }

  it 'can be instantiated' do
    expect(vpc).to be_an_instance_of(IBM::Cloud::SDK::Vpc)
  end

  it 'region can be changed' do
    old_endpoint = vpc.endpoint
    expect(vpc.endpoint).to eq(old_endpoint)
    new_region = 'us-south'
    vpc.region = new_region
    expect(vpc.region).to eq(new_region)
    # TODO: Find new_region from within string.
    expect(vpc.endpoint).not_to eq(old_endpoint)
  end

  methods.each do |k, v|
    it "#{k} can be called" do
      child = vpc.send(k)
      expect(child).to be_an_instance_of(v)
    end
  end

  methods.each do |k, _v|
    describe "#{k} vpc API", vcr: { tags: %I[require_2xx VPC_#{k}] } do
      @has_count = false
      let(:child) { vpc.send(k) }

      it 'can access fetch' do
        res = child.fetch
        expect(res.status).to eq(200)
      end

      it 'can access has_count?' do
        child.has_count?
      end

      it 'can get all' do
        expect(child.all.to_a.length).to eq(child.count) if child.has_count?
      end

      it 'can get an instance' do
        child.all.first(1) do |value|
          id = value.fetch(:id)
          data = child.instance(id).details if id
          expect(data).to be_an_instance_of(Hash)
        end
      end
    end
  end
end
