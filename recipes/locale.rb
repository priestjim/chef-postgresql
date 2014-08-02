#
# Cookbook Name:: postgresql
# Recipe:: locale
# Author:: David Crane (<davidc@donorschoose.org>)
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Based on code found in https://github.com/hw-cookbooks/postgresql
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#######
# Locale Configuration

# Function to test the date order.
# Used in recipes/config_initdb.rb to set this attribute:
#    node.default['postgresql']['datestyle']
def locale_date_order
    # Test locale conversion of mon=11, day=22, year=33
    testtime = DateTime.new(2033,11,22,0,0,0,"-00:00")
            #=> #<DateTime: 2033-11-22T00:00:00-0000 ...>

    # %x - Preferred representation for the date alone, no time
    res = testtime.strftime("%x")

    if res.nil?
       return 'mdy'
    end

    posM = res.index("11")
    posD = res.index("22")
    posY = res.index("33")

    if (posM.nil? || posD.nil? || posY.nil?)
        return 'mdy'
    elseif (posY < posM && posM < posD)
        return 'ymd'
    elseif (posD < posM)
        return 'dmy'
    else
        return 'mdy'
    end
end

#######
# This recipe is derived from the setup_config() source code in the
# PostgreSQL initdb utility. It determines postgresql.conf settings that
# conform to the system's locale and timezone configuration, and also
# sets the error reporting and logging settings.
#
# See http://doxygen.postgresql.org/initdb_8c_source.html for the
# original initdb source code.
#
# By examining the system configuration, this recipe will set the
# following node.default['postgresql'] attributes:
#
# - Locale and Formatting -
#   * datestyle
#   * lc_messages
#   * lc_monetary
#   * lc_numeric
#   * lc_time
#   * default_text_search_config
#

#######
# Locale Configuration

# See libraries/default.rb for the locale_date_order() method.
node.default['postgresql']['datestyle'] = "iso, #{locale_date_order()}"

# According to the locale(1) manpage, the locale settings are determined
# by environment variables according to the following precedence:
# LC_ALL > (LC_MESSAGES, LC_MONETARY, LC_NUMERIC, LC_TIME) > LANG.

node.default['postgresql']['lc_messages'] =
  [ ENV['LC_ALL'], ENV['LC_MESSAGES'], ENV['LANG'] ].compact.first

node.default['postgresql']['lc_monetary'] =
  [ ENV['LC_ALL'], ENV['LC_MONETARY'], ENV['LANG'] ].compact.first

node.default['postgresql']['lc_numeric'] =
  [ ENV['LC_ALL'], ENV['LC_NUMERIC'], ENV['LANG'] ].compact.first

node.default['postgresql']['lc_time'] =
  [ ENV['LC_ALL'], ENV['LC_TIME'], ENV['LANG'] ].compact.first

node.default['postgresql']['default_text_search_config'] =
  case ENV['LANG']
  when /da_.*/
    'pg_catalog.danish'
  when /nl_.*/
    'pg_catalog.dutch'
  when /en_.*/
    'pg_catalog.english'
  when /fi_.*/
    'pg_catalog.finnish'
  when /fr_.*/
    'pg_catalog.french'
  when /de_.*/
    'pg_catalog.german'
  when /hu_.*/
    'pg_catalog.hungarian'
  when /it_.*/
    'pg_catalog.italian'
  when /no_.*/
    'pg_catalog.norwegian'
  when /pt_.*/
    'pg_catalog.portuguese'
  when /ro_.*/
    'pg_catalog.romanian'
  when /ru_.*/
    'pg_catalog.russian'
  when /es_.*/
    'pg_catalog.spanish'
  when /sv_.*/
    'pg_catalog.swedish'
  when /tr_.*/
    'pg_catalog.turkish'
  else
    nil
  end
