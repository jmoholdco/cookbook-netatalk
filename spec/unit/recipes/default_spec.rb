#
# Cookbook Name:: netatalk
# Spec:: default
#
# The MIT License (MIT)
#
# Copyright (c) 2015 J. Morgan Lieberthal
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'spec_helper'

RSpec.describe 'netatalk::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new(opts).converge(described_recipe) }
  supported_platforms = {
    'ubuntu' => %w(14.04 15.04 15.10),
    'centos' => %w(7.0 7.1.1503),
    'debian' => %w(7.8 8.0 8.1)
  }

  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform} v#{version}" do
        let(:opts) { { platform: platform, version: version } }
        include_examples 'converges successfully'
        describe 'the avahi-daemon service' do
          it 'has started' do
            expect(chef_run).to start_service('avahi-daemon')
          end

          it 'is enabled' do
            expect(chef_run).to enable_service('avahi-daemon')
          end
        end

        describe 'the netatalk service' do
          it 'has started' do
            expect(chef_run).to start_service('netatalk')
          end

          it 'is enabled' do
            expect(chef_run).to enable_service('netatalk')
          end
        end

        case platform
        when 'centos'
          it 'includes the rpm_src recipe' do
            expect(chef_run).to include_recipe 'netatalk::rpm_src'
          end
        when 'debian'
          if version.to_f >= 8.0
            it 'includes the jessie recipe' do
              expect(chef_run).to include_recipe 'netatalk::jessie'
            end
          else
            it 'installs from source' do
              expect(chef_run).to include_recipe 'netatalk::source'
            end
          end
        else
          it 'installs from source' do
            expect(chef_run).to include_recipe 'netatalk::source'
          end
        end
      end
    end
  end
end
