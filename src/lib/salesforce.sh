
##
# Environment
#

declare -A sf
export sf

#
# Set the default values
sf_reset() {
  sf[loginUrl]='https://login.salesforce.com/services/Soap/c/1.0/changeme'
  sf[username]='changeme'
  sf[password]='changeme'
  sf[connected]=no
  sf[connect-timeout]=1
  sf[serverUrl]=
  sf[sessionId]=
  sf[max-time]=5
  sf[exit_status]=0
  sf[http_code]=
  sf[response]=
  sf[queryString]=
  sf[responseSize]=
}

sf_printenv() {
  for i in "${!sf[@]}" ; do
    printf "sf[%s]=%s\n" "${i}" "${sf[$i]}"
  done
}

#
# login to salesforce
# 
# exit status is 1 if sf[loginUrl] is empty
#
sf_login() {
  if [[ -z "${sf[loginUrl]}" ]] ; then
    return 1
  fi
  sf[response]=$(curl -s --connect-timeout "${sf[connect-timeout]}" --max-time "${sf[max-time]}" -w 'http_code %{http_code}' "${sf[loginUrl]}" -H 'Content-Type: text/xml; charset=UTF-8' -H 'SOAPAction: login' -d '<?xml version="1.0" encoding="utf-8" ?> <env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"> <env:Body> <n1:login xmlns:n1="urn:enterprise.soap.sforce.com"> <n1:username>'"${sf[username]}"'</n1:username> <n1:password>'"${sf[password]}"'</n1:password> </n1:login> </env:Body> </env:Envelope>')
  sf[exit_status]=$?
  if [ "${sf[exit_status]}" -eq 0 ] ; then
    sf[http_code]=$(printf "%s" "${sf[response]}" | sed -n '${s/^.*http_code \([0-9]*\)$/\1/p}')
    sf[response]=$(printf "%s" "${sf[response]}" | sed '${s/http_code [0-9]*$//g}')
    if [[ "${sf[http_code]}" -eq 200 ]] ; then
      sf[serverUrl]=$(printf "%s" "${sf[response]}" | sed -n '${p;q};:1;H;n;$!b1;H;x;s/\n//gp' | sed 's/^.*<serverUrl>\(https:.*\)<.serverUrl>.*$/\1/')
      sf[sessionId]=$(printf "%s" "${sf[response]}" | sed -n '${p;q};:1;H;n;$!b1;H;x;s/\n//gp' | sed 's/^.*<sessionId>\(.*\)<.sessionId>.*$/\1/')
      sf[connected]=yes
    else
      sf[serverUrl]=
      sf[sessionId]=
      sf[connected]=no
    fi
  fi
}

#
# logout to salesforce
# 
# exit status is 1 if sf[serverUrl] is empty
#
sf_logout() {
  if [[ -z "${sf[serverUrl]}" ]] ; then
    return 1
  fi
  sf[response]=$(curl -s --connect-timeout "${sf[connect-timeout]}" --max-time "${sf[max-time]}" -w 'http_code %{http_code}' -X POST "${sf[serverUrl]}" -H 'Content-Type: text/xml; charset=UTF-8' -H 'SOAPAction: ""' -d '<?xml version="1.0" encoding="utf-8"?> <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com"> <soapenv:Header> <urn:SessionHeader> <urn:sessionId>'"${sf[sessionId]}"'</urn:sessionId> </urn:SessionHeader> </soapenv:Header> <soapenv:Body> <urn:logout /></soapenv:Body> </soapenv:Envelope>')
  sf[exit_status]=$?
  if [ "${sf[exit_status]}" -eq 0 ] ; then
    sf[http_code]=$(printf "%s" "${sf[response]}" | sed -n '${s/^.*http_code \([0-9]*\)$/\1/p}')
    sf[response]=$(printf "%s" "${sf[response]}" | sed '${s/http_code [0-9]*$//g}')
    sf[connected]=no
    sf[serverUrl]=
    sf[sessionId]=
  fi
}

#
# Execute a SOQL request
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
# generate HTML table lines for last query
#
# exit status is 1 if one of teh is empty
#
sf_table() {
  records="${response#*?queryLocator xsi:nil=?true?/?}"
  records="${records%<size>*}"
  while read record ; do
    accountName="${record#*><sf:Account xsi:type=?sf:Account?><sf:Id xsi:nil=?true?/><sf:Name>}" ; accountName="${accountName%</sf:Name></sf:Account>*}"
  done < <(printf "%s" "${records}" | sed 's%</records>%</records>\n%g')
}

#
# Execute a SOQL request
# 
# exit status is 1 if one of sf[serverUrl] or sf[queryString] is empty
#
#sf_generateHTMLTable() {
#
#}

#
# INIT
#
sf_reset
