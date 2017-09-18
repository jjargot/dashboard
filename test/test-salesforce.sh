#!/bin/bash --

. "${2}"
. "${1}"

testsuite="${0%.*}";testsuite="${testsuite##*/test-}"
export testsuite

printf "%s->Nominal login" "${testsuite}"

sf_login
printf " - done "
if [[ $? -eq 1 ]] ; then
  printf "loginUrl is empty:\n" "${sf[loginUrl]}" >&2
  exit 1
fi
if [ "${sf[exit_status]}" -ne 0 ] ; then
  printf " ! ko !\ncurl failed with %s exit status\n" "${sf[exit_status]}" >&2
  exit "${sf[exit_status]}"
fi
if [[ "${sf[http_code]}" -ne 200 ]] ; then
  printf " ! ko !\nhttp_code is not equal to 200: %s\n" "${sf[http_code]}" >&2
  exit 1
fi
if [[ "${sf[connected]}" != yes ||  -z "${sf[serverUrl]}" ||  -z "${sf[sessionId]}" ]] ; then
  printf " ! ko !\nfailed to parse the XML response of the login:\n%s %s\n%s %s\n%s %s\n%s %s\n" serverUrl "${sf[serverUrl]}" sessionId "${sf[sessionId]}" connected "${sf[connected]}" response "${sf[response]}">&2
  exit 1
fi


printf " - OK\n%s->Nominal logout" "${testsuite}"
sf_logout
printf " - done "
if [[ $? -eq 1 ]] ; then
  printf " ! ko !\nserverUrl is empty:\n" "${sf[serverUrl]}" >&2
  exit 1
fi
if [ "${sf[exit_status]}" -ne 0 ] ; then
  printf " ! ko !\ncurl failed with %s exit status\n" "${sf[exit_status]}" >&2
  exit "${sf[exit_status]}"
fi
if [[ "${sf[http_code]}" -ne 200 ]] ; then
  printf " ! ko !\nhttp_code is not equal to 200: %s\n" "${sf[http_code]}" >&2
  exit 1
fi
if [[ "${sf[response]}" != '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:enterprise.soap.sforce.com"><soapenv:Body><logoutResponse/></soapenv:Body></soapenv:Envelope>' ]] ; then
  printf " ! ko !\nresponse from salesforce server is unusual: %s\n" "${sf[response]}"
  exit 1
fi

printf " - OK\n%s->login with empty loginUrl" "${testsuite}"
sf[loginUrl]=
sf_login
exit_status=$?
printf " - done "
if [[ $exit_status -ne 1 ]] ; then
  printf " ! ko !\nloginUrl was empty and exit status of sf_login was not 1: %s\n" $exit_status >&2
  exit 1
fi

printf " - OK\n%s->login wrong username" "${testsuite}"
. "${1}"
sf[username]=toto
sf_login
printf " - done "
if [ "${sf[exit_status]}" -ne 0 ] ; then
  printf " ! ko !\ncurl failed with %s exit status\n" "${sf[exit_status]}" >&2
  exit "${sf[exit_status]}"
fi
if [[ "${sf[http_code]}" -ne 500 ]] ; then
  printf " ! ko !\nhttp_code is not equal to 500: %s\n" "${sf[http_code]}" >&2
  exit 1
fi
if [[ "${sf[connected]}" = yes ||  ! -z "${sf[serverUrl]}" || ! -z "${sf[sessionId]}" ]] ; then
  printf " ! ko !\nfailed to parse the XML response of the login:\n%s %s\n%s %s\n%s %s\n" serverUrl "${sf[serverUrl]}" sessionId "${sf[sessionId]}" connected "${sf[connected]}" >&2
  exit 1
fi

printf " - OK\n%s->logout old sessionId" "${testsuite}"
. "${1}"
sf_login
sf[sessionId]='00D20000000NBwJ!ARMAQBdi6IhckF1QX9pF79VFyjmIO6nGxYrDk6YYB2Y7hfGP1Op590uTGwiog2zwM97lc.w19QeYkVRSqCK_y6qSlJuQxEO2'
sf_logout
printf " - done "
if [ "${sf[exit_status]}" -ne 0 ] ; then
  printf " ! ko !\ncurl failed with %s exit status\n" "${sf[exit_status]}" >&2
  exit "${sf[exit_status]}"
fi
if [[ "${sf[http_code]}" -ne 500 ]] ; then
  printf " ! ko !\nhttp_code is not equal to 500: %s\n" "${sf[http_code]}" >&2
  exit 1
fi
if [[ "${sf[response]}" != '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sf="urn:fault.enterprise.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault><faultcode>sf:INVALID_SESSION_ID</faultcode><faultstring>INVALID_SESSION_ID: Invalid Session ID found in SessionHeader: Illegal Session. Session not found, missing session hash: yNHBjIbNE79KEGtRRO+Qa/QH3oWryUWoKU2afYoBC0A=
This error usually occurs after a session expires or a user logs out. </faultstring><detail><sf:UnexpectedErrorFault xsi:type="sf:UnexpectedErrorFault"><sf:exceptionCode>INVALID_SESSION_ID</sf:exceptionCode><sf:exceptionMessage>Invalid Session ID found in SessionHeader: Illegal Session. Session not found, missing session hash: yNHBjIbNE79KEGtRRO+Qa/QH3oWryUWoKU2afYoBC0A=
This error usually occurs after a session expires or a user logs out. </sf:exceptionMessage></sf:UnexpectedErrorFault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>' ]] ; then
  printf "response from salesforce server is unusual: %s\n" "${sf[response]}"
  exit 1
fi
#printf "%s %s\n" response "${sf[response]}" serverUrl "${sf[serverUrl]}" sessionId "${sf[sessionId]}" connected "${sf[connected]}"
#printf "%s\n" "${sf[response]}" | wc -l
printf " - OK\n%s->Test a query and responseSize" "${testsuite}"
. "${1}"
sf_login
sf[queryString]="${sf[testQueryString]}"
sf_query
printf " - done "
if [[ "${sf[exit_status]}" != 0 ]] ; then
  printf " ! ko !\ncurl failed with %s exit status\n" "${sf[exit_status]}" >&2
  exit "${sf[exit_status]}"
fi
if [[ -z "${sf[responseSize]}" || "${sf[responseSize]}" =~ [^0-9] ]] ; then
  printf " ! ko !\nFailed to retrieve the size of case list: .%s.\n%s\n" "${sf[responseSize]}" "${sf[response]}" >&2
  exit 1
fi

printf " - OK\n%s->Test a batch" "${testsuite}"
. "${1}"
sf_login
sf_batch
printf " - done "
if [ "${sf[exit_status]}" -ne 0 ] ; then
  printf " ! ko !\ncurl failed with %s exit status\n" "${sf[exit_status]}" >&2
  exit "${sf[exit_status]}"
else
  if [ -z "${sf[http_code]}" ] ; then
    printf " ! ko !\nhttp code is not set\n" >&2
    exit 1
  fi
  if [ "${sf[http_code]}" -ne 200 ] ; then
    printf " ! ko !\nHTTP error has been encountered: %s\n" "${sf[http_code]}" >&2
    exit 1
  fi
fi

printf " - OK\n%s->TLS 1 tls1test.salesforce.com" "${testsuite}"
. "${1}"
sf[loginUrl]="${sf[tls1LoginUrl]}"
sf_login
printf " - done "
if [[ "${sf[exit_status]}" != 0 ]] ; then
  printf " ! ko !\nFailed to test the TLS 1.2 new security connection with Salesforce.\nsf[connected]=%s\nsf[sessionId]=%s\nsf[exit_status]=%s\nsf[http_code]=%s\nsf[response]=%s\n" "${sf[connected]}" "${sf[sessionId]}" "${sf[exit_status]}" "${sf[http_code]}"  "${sf[response]}"
  exit 1
fi
printf " - OK\n"

touch "${3}"
