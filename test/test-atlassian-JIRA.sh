#!/bin/bash --

. "${2}"
. "${1}"

printf "test->Nominal\n"
searchJql
if [ "${jira[exit_status]}" -ne 0 ] ; then
  printf "curl failed with %s exit status\n" "${jira[resturn_status]}" >&2
  exit "${jira[resturn_status]}"
fi
if [[ "${jira[http_code]}" -ne 200 ]] ; then
  printf "http_code is not equal to 200: %s\n" "${jira[http_code]}" >&2
  exit 1
fi

printf "test->jira[server]=non_existing_server.fr.fg\n"
jira[server]="non_existing_server.fr.fg"
searchJql
if [ "${jira[exit_status]}" -eq 0 ] ; then
  printf "curl suceeded while it should have not.\n" >&2
  exit 2
fi

printf "test->jira[password]=changemewrong\n"
. "${1}"
jira[password]=changemewrong
searchJql
if [ "${jira[exit_status]}" -ne 0 ] ; then
  printf "curl failed with %s exit status\n" "${jira[resturn_status]}" >&2
  exit "${jira[resturn_status]}"
fi
if [[ "${jira[http_code]}" -ne 401 ]] ; then
  printf "http_code is not equal to 401: %s\n" "${jira[http_code]}" >&2
  exit 1
fi

printf "test->jira[jql]=randomwrong\n"
. "${1}"
jira[jql]=randomwrong
searchJql
if [ "${jira[exit_status]}" -ne 0 ] ; then
  printf "curl failed with %s exit status\n" "${jira[resturn_status]}" >&2
  exit "${jira[resturn_status]}"
fi
if [[ "${jira[http_code]}" -ne 400 ]] ; then
  printf "http_code is not equal to 400: %s\n" "${jira[http_code]}" >&2
  exit 1
fi

printf "test->jira[jql]=%s\n" "${jira[testjql]}"
. "${1}"
jira[jql]="${jira[testjql]}"
searchJql
if [ "${jira[exit_status]}" -ne 0 ] ; then
  printf "curl failed with %s exit status\n" "${jira[resturn_status]}" >&2
  exit "${jira[resturn_status]}"
fi
if [[ "${jira[http_code]}" -ne 200 ]] ; then
  printf "http_code is not equal to 200: %s\n" "${jira[http_code]}" >&2
  exit 1
fi
if [[ "${jira[response]}" != '{"startAt":0,"maxResults":50,"total":0,"issues":[]}' ]] ; then
  printf "some bugs had been found: %s\n" "${jira[response]}" >&2
  exit 1
fi
touch "${3}"
