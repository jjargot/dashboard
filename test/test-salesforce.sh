#!/bin/bash --

. "${2}"
. "${1}"
printf "test->Nominal login\n"
sf_login
if [[ $? -eq 1 ]] ; then
  printf "loginUrl is empty:\n" "${sf[loginUrl]}" >&2
  exit 1
fi
if [ "${sf[exit_status]}" -ne 0 ] ; then
  printf "curl failed with %s exit status\n" "${sf[exit_status]}" >&2
  exit "${sf[exit_status]}"
fi
if [[ "${sf[http_code]}" -ne 200 ]] ; then
  printf "http_code is not equal to 200: %s\n" "${sf[http_code]}" >&2
  exit 1
fi
if [[ "${sf[connected]}" != yes ||  -z "${sf[serverUrl]}" ||  -z "${sf[sessionId]}" ]] ; then
  printf "failed to parse the XML response of the login:\n%s %s\n%s %s\n%s %s\n" serverUrl "${sf[serverUrl]}" sessionId "${sf[sessionId]}" connected "${sf[connected]}" >&2
  exit 1
fi


printf "test->Nominal logout\n"
sf_logout
if [[ $? -eq 1 ]] ; then
  printf "serverUrl is empty:\n" "${sf[serverUrl]}" >&2
  exit 1
fi
if [ "${sf[exit_status]}" -ne 0 ] ; then
  printf "curl failed with %s exit status\n" "${sf[exit_status]}" >&2
  exit "${sf[exit_status]}"
fi
if [[ "${sf[http_code]}" -ne 200 ]] ; then
  printf "http_code is not equal to 200: %s\n" "${sf[http_code]}" >&2
  exit 1
fi
if [[ "${sf[response]}" != '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:enterprise.soap.sforce.com"><soapenv:Body><logoutResponse/></soapenv:Body></soapenv:Envelope>' ]] ; then
  printf "response from salesforce server is unusual: %s\n" "${sf[response]}"
  exit 1
fi

printf "test->login with empty loginUrl\n"
sf[loginUrl]=
sf_login
exit_status=$?
if [[ $exit_status -ne 1 ]] ; then
  printf "loginUrl was empty and exit status of sf_login was not 1: %s\n" $exit_status >&2
  exit 1
fi

printf "test->login wrong username\n"
. "${1}"
sf[username]=toto
sf_login
if [ "${sf[exit_status]}" -ne 0 ] ; then
  printf "curl failed with %s exit status\n" "${sf[exit_status]}" >&2
  exit "${sf[exit_status]}"
fi
if [[ "${sf[http_code]}" -ne 500 ]] ; then
  printf "http_code is not equal to 500: %s\n" "${sf[http_code]}" >&2
  exit 1
fi
if [[ "${sf[connected]}" = yes ||  ! -z "${sf[serverUrl]}" || ! -z "${sf[sessionId]}" ]] ; then
  printf "failed to parse the XML response of the login:\n%s %s\n%s %s\n%s %s\n" serverUrl "${sf[serverUrl]}" sessionId "${sf[sessionId]}" connected "${sf[connected]}" >&2
  exit 1
fi

printf "test->logout old sessionId\n"
sf_login
sf[sessionId]='00D20000000NBwJ!ARMAQBdi6IhckF1QX9pF79VFyjmIO6nGxYrDk6YYB2Y7hfGP1Op590uTGwiog2zwM97lc.w19QeYkVRSqCK_y6qSlJuQxEO2'
sf_logout
if [ "${sf[exit_status]}" -ne 0 ] ; then
  printf "curl failed with %s exit status\n" "${sf[exit_status]}" >&2
  exit "${sf[exit_status]}"
fi
if [[ "${sf[http_code]}" -ne 500 ]] ; then
  printf "http_code is not equal to 500: %s\n" "${sf[http_code]}" >&2
  exit 1
fi
if [[ "${sf[response]}" != '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sf="urn:fault.enterprise.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault><faultcode>INVALID_LOGIN</faultcode><faultstring>INVALID_LOGIN: Invalid username, password, security token; or user locked out.</faultstring><detail><sf:LoginFault xsi:type="sf:LoginFault"><sf:exceptionCode>INVALID_LOGIN</sf:exceptionCode><sf:exceptionMessage>Invalid username, password, security token; or user locked out.</sf:exceptionMessage></sf:LoginFault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>' ]] ; then
  printf "response from salesforce server is unusual: %s\n" "${sf[response]}"
  exit 1
fi
#printf "%s %s\n" response "${sf[response]}" serverUrl "${sf[serverUrl]}" sessionId "${sf[sessionId]}" connected "${sf[connected]}"
#printf "%s\n" "${sf[response]}" | wc -l
printf "test->responseSize\n"
. "${1}"
sf_login
sf_query
if [[ ! -z "${sf[responseSize]}" && "${sf[responseSize]}" -ne 7 ]] ; then
  printf "Failed to retrieve the size of case list: %s\n" "${sf[caseListSize]}" >&2
  exit 1
fi
  printf "Failed to retrieve the size of case list: %s\n" "${sf[caseListSize]}" >&2

touch "${3}"
