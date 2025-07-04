require 'spec_helper_acceptance'

test_name 'at'

describe 'at class' do
  let(:manifest) do
    <<-EOS
      include 'at'
    EOS
  end

  let(:manifest_users) do
    <<-EOS
      class { 'at':
        users => ['joe', ' mary ']
      }
      at::user {' george': }
    EOS
  end

  let(:expected_content) do
    <<-EOS
george
joe
mary
root
    EOS
  end

  context 'on each host' do
    hosts.each do |host|
      it 'works with default values' do
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end

      it 'adds users' do
        apply_manifest_on(host, manifest_users, catch_failures: true)
        at_allout_output = on(host, 'cat /etc/at.allow')
        expect(at_allout_output.stdout).to match(expected_content)
      end
    end
  end
end
