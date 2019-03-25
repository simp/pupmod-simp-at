require 'spec_helper_acceptance'

test_name 'at'

describe 'at class' do
  let(:manifest) {
    <<-EOS
      include 'at'
    EOS
  }

  let(:manifest_users) {
    <<-EOS
      class { 'at':
        users => ['joe', ' mary ']
      }
      at::user {' george': }
    EOS
  }

  let(:expected_content) {
    <<-EOS
george
joe
mary
root
    EOS
  }

  context 'on each host' do
    hosts.each do |host|
      it 'should work with default values' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end

      it 'should add users' do
        apply_manifest_on(host, manifest_users, :catch_failures => true)
        on(host, 'cat /etc/at.allow') do
          expect(stdout).to match(expected_content)
        end
      end

    end
  end
end
