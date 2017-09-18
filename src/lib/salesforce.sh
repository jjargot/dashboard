
##
# Environment
#

declare -A sf
export sf

#
# Set the default values, do not modify
sf_reset() {
  sf[loginUrl]='https://login.salesforce.com/services/Soap/c/1.0/changeme'
  sf[username]='changeme'
  sf[password]='changeme'

  # yes if last sf_login exit status was 0 and associated http code was 200
  sf[connected]=no

  # connection timeout in second
  sf[connect-timeout]=1

  # the url to connect to when sf_login was succesfull
  sf[serverUrl]=
  sf[sessionId]=
  sf[max-time]=5
  sf[exit_status]=0
  sf[http_code]=
  sf[response]=
  sf[queryString]=
  sf[responseSize]=
  sf[batchRequestBody]=
  sf[aPIVersion]=v40.0
}

sf_printenv() {
  for i in "${!sf[@]}" ; do
    printf "sf[%s]=%s\n" "${i}" "${sf[$i]}"
  done
}

#
# login to salesforce
# 
# exit status (sf[exit_status]) is 1 if sf[loginUrl] is empty or if curl command exit status is 1
# otherwise the exit status id the curl's one.
#
sf_login() {
  if [[ -z "${sf[loginUrl]}" ]] ; then
    return 1
  fi
  sf[response]=$(curl -s --connect-timeout "${sf[connect-timeout]}" --max-time "${sf[max-time]}" -w 'http_code %{http_code}' "${sf[loginUrl]}" -H 'Content-Type: text/xml; charset=UTF-8' -H 'SOAPAction: login' -d '<?xml version="1.0" encoding="utf-8" ?> <env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"> <env:Body> <n1:login xmlns:n1="urn:enterprise.soap.sforce.com"> <n1:username>'"${sf[username]}"'</n1:username> <n1:password>'"${sf[password]}"'</n1:password> </n1:login> </env:Body> </env:Envelope>')
  sf[exit_status]=$?
  if [ "${sf[exit_status]}" -eq 0 ] ; then
#    sf[http_code]=$(printf "%s" "${sf[response]}" | sed -n '${s/^.*http_code \([0-9]*\)$/\1/p}')
#    sf[response]=$(printf "%s" "${sf[response]}" | sed '${s/http_code [0-9]*$//g}')
    sf[http_code]="${sf[response]##*http_code }"
    if [ ! -z "${sf[http_code]}" -a "${sf[http_code]}" -eq 200 ] ; then
#      sf[serverUrl]=$(printf "%s" "${sf[response]}" | sed -n '${p;q};:1;H;n;$!b1;H;x;s/\n//gp' | sed 's/^.*<serverUrl>\(https:.*\)<.serverUrl>.*$/\1/')
      sf[serverUrl]="${sf[response]##*<serverUrl>}" ; sf[serverUrl]="${sf[serverUrl]%%<?serverUrl>*}"
#      sf[sessionId]=$(printf "%s" "${sf[response]}" | sed -n '${p;q};:1;H;n;$!b1;H;x;s/\n//gp' | sed 's/^.*<sessionId>\(.*\)<.sessionId>.*$/\1/')
      sf[sessionId]="${sf[response]##*<sessionId>}" ; sf[sessionId]="${sf[sessionId]%%<?sessionId>*}"
      sf[response]="${sf[response]%http_code 200}"
      sf[connected]=yes
    else
      sf[serverUrl]=
      sf[sessionId]=
      sf[connected]=no
      sf[response]=
    fi
  fi
}

#
# logout to salesforce
# 
# exit status (sf[exit_status]) is 1 if sf[loginUrl] is empty or if curl command exit status is 1
# otherwise the exit status id the curl's one.
#
sf_logout() {
  if [[ -z "${sf[serverUrl]}" ]] ; then
    return 1
  fi
  sf[response]=$(curl -s --connect-timeout "${sf[connect-timeout]}" --max-time "${sf[max-time]}" -w 'http_code %{http_code}' -X POST "${sf[serverUrl]}" -H 'Content-Type: text/xml; charset=UTF-8' -H 'SOAPAction: ""' -d '<?xml version="1.0" encoding="utf-8"?> <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com"> <soapenv:Header> <urn:SessionHeader> <urn:sessionId>'"${sf[sessionId]}"'</urn:sessionId> </urn:SessionHeader> </soapenv:Header> <soapenv:Body> <urn:logout /></soapenv:Body> </soapenv:Envelope>')
  sf[exit_status]=$?
  if [ "${sf[exit_status]}" -eq 0 ] ; then
#    sf[http_code]=$(printf "%s" "${sf[response]}" | sed -n '${s/^.*http_code \([0-9]*\)$/\1/p}'
    sf[http_code]="${sf[response]##*http_code }"
    sf[response]="${sf[response]%http_code ???}"
    sf[connected]=no
    sf[serverUrl]=
    sf[sessionId]=
  fi
}

#
# Execute a SOQL request via web service (SOAP)
# 
# exit status is 1 if one of sf[serverUrl] or sf[queryString] is empty
#
sf_query() {
  if [[ -z "${sf[serverUrl]}" || -z "${sf[queryString]}" ]] ; then
    return 1
  fi
  sf[response]=$(curl -s --connect-timeout "${sf[connect-timeout]}" --max-time "${sf[max-time]}" -w 'http_code %{http_code}' -X POST "${sf[serverUrl]}" -H 'Content-Type: text/xml; charset=UTF-8' -H 'SOAPAction: ""' -d '<?xml version="1.0" encoding="utf-8"?> <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com"> <soapenv:Header> <urn:SessionHeader> <urn:sessionId>'"${sf[sessionId]}"'</urn:sessionId> </urn:SessionHeader> </soapenv:Header> <soapenv:Body> <urn:query> <urn:queryString>'"${sf[queryString]}"'</urn:queryString> </urn:query> </soapenv:Body> </soapenv:Envelope>')
  sf[exit_status]=$?
  if [ "${sf[exit_status]}" -eq 0 ] ; then
    sf[http_code]=$(printf "%s" "${sf[response]}" | sed -n '${s/^.*http_code \([0-9]*\)$/\1/p}')
    sf[response]=$(printf "%s" "${sf[response]}" | sed '${s/http_code [0-9]*$//g}')
    if [[ ! -z "${sf[http_code]}" && "${sf[http_code]}" -eq 200 ]] ; then
      sf[responseSize]=$(printf "%s\n" "${sf[response]}" | sed -n 's/^.*<size>\([0-9]*\)<.size>.*$/\1/p')
    fi
  fi
}

#
# Execute a Batch 
# 
# sf_login should be call prior to this one
# 
# sf[batchRequestBody] should contains resquests see https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/requests_composite_batch.htm
# example:
# {
#   "batchRequests": [
#     {
#       "method": "GET",
#       "url": "v40.0/query/?q=select%20count%28id%29%20Number_Of_Service_Requests%20from%20Case%20where%20%28not%20Status%20like%20%27Cl%25%27%29%20and%20IsDeleted%20%3D%20false%20AND%20IsClosed%20%3D%20false%20and%20%28%20%28Status%20%3D%20%27In%20Progress%27%20AND%20SLA_Deadline__c%20%21%3D%20null%29%20OR%20Status%20%3D%20%27Logged%27%20OR%20Status%20%3D%20%27Qualified%27%20OR%20%28%20Status%20%3D%20%27Workaround%20Proposed%27%20AND%20LastModifiedDate%20%3D%20LAST_N_DAYS%3A14%29%20OR%20Status%20%3D%20%27Resolved%27%20OR%20Status%20%3D%20%27Suspended%27%29%20and%20Type%20%3D%27Service%20Request%27"
#     },
#     {
#       "method": "GET",
#       "url": "v40.0/query/?q=select%20count%28id%29%20Number_Of_Open_Cases%20from%20Case%20where%20IsDeleted%20%3D%20false%20and%20%28IsClosed%20%3D%20false%20or%20%28not%20Status%20like%20%27Cl%25%27%29%29"
#     }
#   ]
# }
#
# 
#
# exit status (sf[exit_status]) is 1 if one of sf[serverUrl] or sf[batchRequestBody] is empty or if the curl command exit status is 1
# otherwise the exit status is the curl's one.
#
# if curl exit status is 0, then sf[http_code] is set with the HTTP code from the answer, and sf[response] contains the JSON of the HTTP answer's body.
#
sf_batch() {
  if [ -z "${sf[serverUrl]}" -o -z "${sf[batchRequestBody]}" ] ; then
    return 1
  fi
  sf[response]=$(curl -s --connect-timeout "${sf[connect-timeout]}" --max-time "${sf[max-time]}" -w 'http_code %{http_code}' -X POST "${sf[serverUrl]%%Soap/c/*}"data/"${sf[aPIVersion]}"/composite/batch -H 'Content-Type: application/json' -H "Authorization: Bearer ${sf[sessionId]}" -d "${sf[batchRequestBody]}")
  sf[exit_status]=$?
  sf[http_code]=
  if [ "${sf[exit_status]}" -eq 0 ] ; then
    sf[http_code]="${sf[response]##*http_code }"
    sf[response]="${sf[response]%http_code ???}"
  fi
}

#
# INIT
#
sf_reset
