
##
# Environment
#

declare -A jira
export jira

#
# Set the default values
jira_reset() {
  jira[server]="changeme.com"
  jira[jql]='project%20=%20changeme'
  jira[username]="tom.smith"
  jira[password]="changeme"
  jira[connect-timeout]=1
  jira[max-time]=5
}

#
# Search using the jql filter provided in the jira[jql]  
#
# the variables listed below must be defined:
# jira[server] jira[jql] jira[username] jira[password] jira[connect-timeout] jira[max-time]
# 
searchJql() {
  jira[response]=$(curl -s --connect-timeout "${jira[connect-timeout]}" --max-time "${jira[max-time]}" -w 'http_code %{http_code}' -u "${jira[username]}":"${jira[password]}" -H "Content-Type: application/json" 'https://'"${jira[server]}"'/rest/api/2/search?jql='"${jira[jql]}")
  jira[exit_status]=$?
  if [ "${jira[exit_status]}" -eq 0 ] ; then
    jira[http_code]=$(printf "%s" "${jira[response]}" | sed -n '${s/^.*http_code \([0-9]*\)$/\1/p}')
    jira[response]=$(printf "%s" "${jira[response]}" | sed '${s/http_code [0-9]*$//g}')
  fi
}

#
# INIT
#
jira_reset
