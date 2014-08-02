#
# Cookbook Name:: postgresql
# Attributes:: pgtune
#
# Author:: Panagiotis Papadomitsos <pj@ezgr.net>
#
# Copyright 2014, Panagiotis Papadomitsos
#
# Based on code found in https://github.com/hw-cookbooks/postgresql

# Override these variables to override pgtune tuning parameters
# default['postgresql']['pgtune']['db_type'] = 'mixed' # One of dw, oltp, web, mixed, desktop
# default['postgresql']['pgtune']['max_connections'] = 256
# default['postgresql']['pgtune']['total_memory'] = 1024kB # In kB (lower k capital B)