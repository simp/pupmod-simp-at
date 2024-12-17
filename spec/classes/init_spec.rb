require 'spec_helper'

describe 'at' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'with default parameters' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('at') }
          it { is_expected.to create_package('at') }
          it { is_expected.to create_at__user('root') }
          it { is_expected.to create_concat('/etc/at.allow') }
          it { is_expected.to create_file('/etc/at.deny').with({ ensure: 'absent' }) }
          it {
            is_expected.to create_service('atd').with({
                                                        ensure: 'running',
            enable: true,
            hasstatus: true,
            hasrestart: true
                                                      })
          }
        end

        context 'with a users parameter' do
          let(:params) do
            {
              users: ['test', 'foo', 'bar']
            }
          end

          it { is_expected.to create_at__user('test') }
          it { is_expected.to create_at__user('foo') }
          it { is_expected.to create_at__user('bar') }
        end
      end
    end
  end
end
