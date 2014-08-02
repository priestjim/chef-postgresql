#
# Cookbook Name:: postgresql
# Recipe:: contrib
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Based on code found in https://github.com/hw-cookbooks/postgresql

::Chef::Recipe.send(:include, ::Chef::Mixin::ShellOut)

#######
# Function to execute an SQL statement in the template1 database.
#   Input: Query could be a single String or an Array of String.
#   Output: A String with |-separated columns and \n-separated rows.
#           Note an empty output could mean psql couldn't connect.
# This is easiest for 1-field (1-row, 1-col) results, otherwise
# it will be complex to parse the results.
def execute_sql(query)
  # query could be a String or an Array of String
  statement = query.is_a?(String) ? query : query.join("\n")
  @execute_sql ||= begin
    cmd = shell_out("psql -q --tuples-only --no-align -d template1 -f -",
          :user => "postgres",
          :input => statement
    )
    # If psql fails, generally the postgresql service is down.
    # Instead of aborting chef with a fatal error, let's just
    # pass these non-zero exitstatus back as empty cmd.stdout.
    if (cmd.exitstatus() == 0 and !cmd.stderr.empty?)
      # An SQL failure is still a zero exitstatus, but then the
      # stderr explains the error, so let's rais that as fatal.
      Chef::Log.fatal("psql failed executing this SQL statement:\n#{statement}")
      Chef::Log.fatal(cmd.stderr)
      raise "SQL ERROR"
    end
    cmd.stdout.chomp
  end
end

#######
# Function to determine if a standard contrib extension is already installed.
#   Input: Extension name
#   Output: true or false
# Best use as a not_if gate on bash "install-#{pg_ext}-extension" resource.
def extension_installed?(pg_ext)
  @extension_installed ||= begin
    installed=execute_sql("select 'installed' from pg_extension where extname = '#{pg_ext}';")
    installed =~ /^installed$/
  end
end

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
    not_if {extension_installed?(pg_ext)}
  end
end
