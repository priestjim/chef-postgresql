#
# Cookbook Name:: postgresql
# Recipe:: contrib
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Based on code found in https://github.com/hw-cookbooks/postgresql

include_recipe "postgresql"

package "postgresql-contrib-#{node["postgresql"]["version"]}"

# Install PostgreSQL contrib extentions into the template1 database,
# as specified by the node attributes.
node['postgresql']['contrib_extensions'].each do |pg_ext|
  bash "install-#{pg_ext}-extension" do
    user 'postgres'
    code <<-EOH
      echo 'CREATE EXTENSION IF NOT EXISTS "#{pg_ext}";' | psql -d template1
    EOH
    action :run
    ::Chef::Resource.send(:include, ::Postgres::ExtensionHelper)
    not_if { extension_installed?(pg_ext) }
  end
end
