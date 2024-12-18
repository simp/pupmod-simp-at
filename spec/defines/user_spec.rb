require 'spec_helper'

describe 'at::user' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        context 'with default parameters' do
          let(:title) { 'foobar' }

          it { is_expected.to create_concat_fragment('at+foobar.user').with_content(title.to_s) }
        end

        context 'with a name that requires substitution' do
          let(:title) { 'foo/bar' }

          it { is_expected.to create_concat_fragment('at+foo__bar.user').with_content(title.to_s) }
        end

        context 'with a name with spaces' do
          let(:title) { '  foo/bar  ' }

          it { is_expected.to create_concat_fragment('at+foo__bar.user').with_content('foo/bar') }
        end
      end
    end
  end
end
