# A bit of a dummy role that just references the IAB recipe

name "iab_server"
description "The role for an InsuranceInABox server"

run_list [
    "recipe[mysql::server]",
    "recipe[apache2]",
    "recipe[django]",
    "recipe[iab_server]",
]
