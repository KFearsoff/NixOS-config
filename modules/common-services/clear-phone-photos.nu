#!/usr/bin/env nu

ls -a Photos-phone | where name != 'Photos-phone/.stfolder' | par-each { |it| rm -rfv $it.name } | null
