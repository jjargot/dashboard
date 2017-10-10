#!/bin/bash --
##
## C O N F I G U R A T I O N
##

# test can provide environment

if [[ -z "${CONFIG_DIR}"  ]] ; then
  CONFIG_DIR=/etc/dashboard
fi

# idem
if [ -f "${CONFIG_DIR}"/install.env ] ; then
  # must defined:
  #    LIB_DIR
  #    CONFIGURATION_FILE 
  # may defined:
  #    HTML_RESOURCES_DIR
  . "${CONFIG_DIR}"/install.env
fi

##
## D E P E N D E N C I E S
## 

# Defines variables and functions and initializes the libs
. "${LIB_DIR}"/salesforce.sh
. "${LIB_DIR}"/atlassian-JIRA.sh


##
## ASSOCIATIVE ARRAY DECLARATION
##
unset sfData
declare -A sfData

unset jiraData
declare -A jiraData

unset cache
declare -A cache

unset motd
declare -A motd


##
## F U N C T I O N S 
##

#
# return ISO date and time of the next working 18 hours
# the output is formated is a way it can be used in a SOQL query 
getNext18HoursOfWorkISODateTime() {
  dayOfTheWeek=$(date -u "+%u")
  currentDateTimeInSecondsSinceEPOCH=$(date -u "+%s")
  if ((  dayOfTheWeek == 7 )) ; then
    # Sunday => outside Business Hour
    delayInSecondsToNextGrenobleOfficeOpeningHour=$(date -u -d 'TZ="Europe/Paris" next monday '"${grenobleOfficeOpeningHourParisTZ}" "+%s ${currentDateTimeInSecondsSinceEPOCH}-p" | dc)
    next18hoursLimitDateTime=$(date --iso-8601=seconds -u -d "+18 hour ${delayInSecondsToNextGrenobleOfficeOpeningHour} second")
    printf "%sZ" "${next18hoursLimitDateTime%??????}"
    return 0
  else
    sanFranciscoOfficeClosingDateTimeInSecondsSinceEPOCH=$(date -u -d 'TZ="Europe/Paris" '"${sanFranscicoOfficeClosingParisTZ}" "+%s")
    # 18 hours <=> 64800 seconds
    if (( dayOfTheWeek == 6 )) ; then
      # Saturday
      if (( currentDateTimeInSecondsSinceEPOCH >= sanFranciscoOfficeClosingDateTimeInSecondsSinceEPOCH )) ; then
        # => outside Business Hour
        delayInSecondsToNextGrenobleOfficeOpeningHour=$(date -u -d 'TZ="Europe/Paris" next monday '"${grenobleOfficeOpeningHourParisTZ}" "+%s ${currentDateTimeInSecondsSinceEPOCH}-p" | dc)
        next18hoursLimitDateTime=$(date --iso-8601=seconds -u -d "+18 hour ${delayInSecondsToNextGrenobleOfficeOpeningHour} second")
        printf "%sZ" "${next18hoursLimitDateTime%??????}"
        return 0
      else
        # => Business Hour
        nextSanFranciscoOfficeClosingDateTimeInSecondsSinceEPOCH=sanFranciscoOfficeClosingDateTimeInSecondsSinceEPOCH
        delayInSecondsToSanFranciscoClosingHour=$(( nextSanFranciscoOfficeClosingDateTimeInSecondsSinceEPOCH - currentDateTimeInSecondsSinceEPOCH ))
        nextGrenobleOfficeOpeningDateTimeInSecondsSinceEPOCH=$(date -u -d 'TZ="Europe/Paris" next monday '"${grenobleOfficeOpeningHourParisTZ}" "+%s")
        next18hoursLimitInSecondsSinceEPOCH=$(( (nextGrenobleOfficeOpeningDateTimeInSecondsSinceEPOCH + 64800) - delayInSecondsToSanFranciscoClosingHour ))
        next18hoursLimitDateTime=$(date --iso-8601=seconds -u -d "@${next18hoursLimitInSecondsSinceEPOCH}")
        printf "%sZ" "${next18hoursLimitDateTime%??????}"
        return 0
      fi
    else
      GrenobleOfficeOpeningDateTimeInSecondsSinceEPOCH=$(date -u -d 'TZ="Europe/Paris" '"${grenobleOfficeOpeningHourParisTZ}" "+%s")
      if (( dayOfTheWeek == 1 )) ; then
        # Monday
        if (( currentDateTimeInSecondsSinceEPOCH <= GrenobleOfficeOpeningDateTimeInSecondsSinceEPOCH )) ; then
          # => outside Business Hour
          delayInSecondsToNextGrenobleOfficeOpeningHour=$(( GrenobleOfficeOpeningDateTimeInSecondsSinceEPOCH - currentDateTimeInSecondsSinceEPOCH ))
          next18hoursLimitDateTime=$(date --iso-8601=seconds -u -d "+18 hour ${delayInSecondsToNextGrenobleOfficeOpeningHour} second")
          printf "%sZ" "${next18hoursLimitDateTime%??????}"
          return 0
        else
          # => Business Hour
          nextSanFranciscoOfficeClosingDateTimeInSecondsSinceEPOCH=$(date -u -d 'TZ="Europe/Paris" +1 day '"${sanFranscicoOfficeClosingParisTZ}" "+%s")
          delayInSecondsToSanFranciscoClosingHour=$(( nextSanFranciscoOfficeClosingDateTimeInSecondsSinceEPOCH - currentDateTimeInSecondsSinceEPOCH ))
          nextGrenobleOfficeOpeningDateTimeInSecondsSinceEPOCH=$(date -u -d 'TZ="Europe/Paris" +1 day '"${grenobleOfficeOpeningHourParisTZ}" "+%s")
          next18hoursLimitInSecondsSinceEPOCH=$(( (nextGrenobleOfficeOpeningDateTimeInSecondsSinceEPOCH + 64800) - delayInSecondsToSanFranciscoClosingHour ))
          next18hoursLimitDateTime=$(date --iso-8601=seconds -u -d "@${next18hoursLimitInSecondsSinceEPOCH}")
          printf "%sZ" "${next18hoursLimitDateTime%??????}"
          return 0
        fi
      else
        # [ Tuesday .. Friday ]
        if (( currentDateTimeInSecondsSinceEPOCH >= sanFranciscoOfficeClosingDateTimeInSecondsSinceEPOCH && currentDateTimeInSecondsSinceEPOCH <= GrenobleOfficeOpeningDateTimeInSecondsSinceEPOCH )) ; then
          # => outside Business Hour
          delayInSecondsToNextGrenobleOfficeOpeningHour=$(date -u -d 'TZ="Europe/Paris" '"${grenobleOfficeOpeningHourParisTZ}" "+%s ${currentDateTimeInSecondsSinceEPOCH}-p" | dc)
          next18hoursLimitDateTime=$(date --iso-8601=seconds -u -d "+18 hour ${delayInSecondsToNextGrenobleOfficeOpeningHour} second")
          printf "%sZ" "${next18hoursLimitDateTime%??????}"
          return 0
        else
          # => Business Hour
          if (( currentDateTimeInSecondsSinceEPOCH < sanFranciscoOfficeClosingDateTimeInSecondsSinceEPOCH )) ; then
            nextSanFranciscoOfficeClosingDateTimeInSecondsSinceEPOCH=sanFranciscoOfficeClosingDateTimeInSecondsSinceEPOCH
          else
            # currentDateTimeInSecondsSinceEPOCH > GrenobleOfficeOpeningDateTimeInSecondsSinceEPOCH
            nextSanFranciscoOfficeClosingDateTimeInSecondsSinceEPOCH=$(date -u -d 'TZ="Europe/Paris" +1 day '"${sanFranscicoOfficeClosingParisTZ}" "+%s")
          fi
          delayInSecondsToSanFranciscoClosingHour=$(( nextSanFranciscoOfficeClosingDateTimeInSecondsSinceEPOCH - currentDateTimeInSecondsSinceEPOCH ))
          if (( dayOfTheWeek == 5 )) ; then
            nextGrenobleOfficeOpeningDateTimeInSecondsSinceEPOCH=$(date -u -d 'TZ="Europe/Paris" next monday '"${grenobleOfficeOpeningHourParisTZ}" "+%s")
          else
            nextGrenobleOfficeOpeningDateTimeInSecondsSinceEPOCH=$(date -u -d 'TZ="Europe/Paris" +1 day '"${grenobleOfficeOpeningHourParisTZ}" "+%s")
          fi
          next18hoursLimitInSecondsSinceEPOCH=$(( (nextGrenobleOfficeOpeningDateTimeInSecondsSinceEPOCH + 64800) - delayInSecondsToSanFranciscoClosingHour ))
          next18hoursLimitDateTime=$(date --iso-8601=seconds -u -d "@${next18hoursLimitInSecondsSinceEPOCH}")
          printf "%sZ" "${next18hoursLimitDateTime%??????}"
          return 0
        fi
      fi
    fi
  fi
}

#
# return SOQL Where clause to filter the case with SLA Deadline outside working hours
getSOQLClauseForSLADeadlineOutsideWorkingHours() {
  grenobleOfficeOpeningHour="10:00"
  parisTZ='TZ="Europe/Paris"'
  dayOfTheWeek=$(date -u "+%u")
  if ((  dayOfTheWeek == 7 || dayOfTheWeek == 6 )) ; then
    # Sunday + Saturday
    nextDate=$(date --iso-8601=seconds -u -d "${parisTZ} next monday ${grenobleOfficeOpeningHour}")
    printf "SLA_Deadline__c <= %sZ" "${nextDate%??????}"
    return 0
  fi

  grenobleOfficeClosingHour="16:30"
  sanfranciscoOfficeOpeningHour="19:00"
  sanfranciscoOfficeClosingHour="00:30"
  soqlFilter=
  currentDateTimeInSecondsSinceEPOCH=$(date -u "+%s")
  # Friday
  grenobleOfficeOpeningHourInSecondSinceEPOCH=$(date -u -d "${parisTZ} ${grenobleOfficeOpeningHour}" "+%s")
  grenobleOfficeOpeningHourDateTime=$(date --iso-8601=seconds -u -d "${parisTZ} ${grenobleOfficeOpeningHour}")
  if (( currentDateTimeInSecondsSinceEPOCH < grenobleOfficeOpeningHourInSecondSinceEPOCH )) ; then
    # before 09:30
    soqlFilter="SLA_Deadline__c <= ${grenobleOfficeOpeningHourDateTime%??????}Z"
  fi
  sanfranciscoOfficeOpeningHourInSecondSinceEPOCH=$(date -u -d "${parisTZ} ${sanfranciscoOfficeOpeningHour}" "+%s")
  if (( currentDateTimeInSecondsSinceEPOCH < sanfranciscoOfficeOpeningHourInSecondSinceEPOCH )) ; then
    if [ ! -z "${soqlFilter}" ] ; then
      soqlFilter="${soqlFilter} OR "
    fi
    grenobleOfficeClosingHourDateTime=$(date --iso-8601=seconds -u -d "${parisTZ} ${grenobleOfficeClosingHour}")
    sanfranciscoOfficeOpeningHourDateTime=$(date --iso-8601=seconds -u -d "${parisTZ} ${sanfranciscoOfficeOpeningHour}")
    soqlFilter="${soqlFilter}(SLA_Deadline__c >= ${grenobleOfficeClosingHourDateTime%??????}Z AND SLA_Deadline__c <= ${sanfranciscoOfficeOpeningHourDateTime%??????}Z)"
  fi
  if [ ! -z "${soqlFilter}" ] ; then
    soqlFilter="${soqlFilter} OR "
  fi
  sanfranciscoOfficeClosingHourDateTime=$(date --iso-8601=seconds -u -d "${parisTZ} next day ${sanfranciscoOfficeClosingHour}")
  if ((  dayOfTheWeek == 5 )) ; then
    nextGrenobleOfficeOpeningHourDateTime=$(date --iso-8601=seconds -u -d "${parisTZ} next monday ${grenobleOfficeOpeningHour}")
  else
    nextGrenobleOfficeOpeningHourDateTime=$(date --iso-8601=seconds -u -d "${parisTZ} next day ${grenobleOfficeOpeningHour}")
  fi
  if [[ "${soqlFilter}" =~ " OR " ]] ; then 
    printf '( %s )' "${soqlFilter}(SLA_Deadline__c >= ${sanfranciscoOfficeClosingHourDateTime%??????}Z AND SLA_Deadline__c <= ${nextGrenobleOfficeOpeningHourDateTime%??????}Z)"
  else
    printf '%s' "${soqlFilter}(SLA_Deadline__c >= ${sanfranciscoOfficeClosingHourDateTime%??????}Z AND SLA_Deadline__c <= ${nextGrenobleOfficeOpeningHourDateTime%??????}Z)"
  fi
}


#
# return ISO date and time of next Grenoble office working day at 09:30
# the output is formated is a way it can be used in a SOQL query 
getSanFranciscoOfficeClosingHourISODateTime() { 
  local nextDate=""
  if [ "$(date -u "+%u")" -lt 5 ] ; then
    nextDate=$(date --iso-8601=seconds -d 'TZ="Europe/Paris" +1 day 03:00' -u)
  elif [ "$(date -u "+%u")" -eq 6 ] ; then
    nextDate=$(date --iso-8601=seconds -d 'TZ="Europe/Paris" 03:00' -u)
  elif [ "$(date -u "+%u")" -eq 7 ] ; then
    nextDate=$(date --iso-8601=seconds -d 'TZ="Europe/Paris" -1 day 03:00' -u)
  fi
  printf "%sZ" "${nextDate%??????}"
}


#
# return the ISO date of the day that is 183 days in the past
# the output is formated is a way it can be used in a SOQL query 
get183daysInPastISODate() {
  local nextDate
  nextDate=$(date --iso-8601=seconds -d '-183 days' -u)
  printf "%sZ" "${nextDate%??????}"
}

#
# return the ISO date of the day that is 14 days in the past
# the output is formated is a way it can be used in a SOQL query 
get14daysInPastISODate() {
  local nextDate
  nextDate=$(date --iso-8601=seconds -d '-14 days' -u)
  printf "%sZ" "${nextDate%??????}"
}

#
# set sfData[response] and jiraData[response] from their cache
# is cached data is expired, requests are sent to salesforce and request to retrieve the info
getDataWithCache() {
  durationInSecondsSinceTheCacheWasUpdated=${cache[timeToLiveInSeconds]}
  useCache=yes
  if [[ ! -z "${HTTP_PRAGMA}" ]] ; then
    if [[ "${HTTP_PRAGMA}" == no-cache ]] ; then
      useCache=no
    fi
  fi
  if [[ ! -z "${HTTP_CACHE_CONTROL}" ]] ; then
    if [[ "${HTTP_CACHE_CONTROL}" == no-cache ]] ; then
      useCache=no
    fi
  fi
  if [[ -f "${cache[sfFile]}" && "${useCache}" = yes ]] ; then
    durationInSecondsSinceTheCacheWasUpdated=$(date -d "$(stat "${cache[sfFile]}" | sed -n 's/^Modify: //p')" -u "+""$(date -u +%s)"" %s-p" | dc)
  fi
  if [[ ( "${useCache}" = no && "${durationInSecondsSinceTheCacheWasUpdated}" -ge "${minimalTimeWithoutRequestsInSeconds}" ) || "${durationInSecondsSinceTheCacheWasUpdated}" -ge "${cache[timeToLiveInSeconds]}" ]] ; then
    sfData[source]="(i)"
    sfData[serverUrl]='https://eu4.salesforce.com/services/Soap/c/26.0/00D20000000NBwJ/0DFD00000000uIk'
    sfData[response]='{"hasErrors":false,"results":[{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Service_Requests":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Incident_Requests":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Usage_Questions":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_S1":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_S2":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_S3":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_of_Cases_With_SLADeadline_Outside_Office_Hour":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Open_Cases_With_Bugs":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Old_Cases_Without_Bug":0}]}},{"statusCode":200,"result":
{"totalSize":0,"done":true,"records":[]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Cases_In_Worklist":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Open_Cases":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Active_Cases":0}]}}]}'
    sf_login
    if [[ ! -z "${sf[exit_status]}" && ! -z "${sf[http_code]}" ]] ; then 
      if [[ "${sf[exit_status]}" -eq 0 && "${sf[http_code]}" -eq 200 ]] ; then       
        sf_batch
        if [[ ! -z "${sf[exit_status]}" && ! -z "${sf[http_code]}" ]] ; then 
          if [[ "${sf[exit_status]}" -eq 0 && "${sf[http_code]}" -eq 200 ]] ; then
            sfData[source]=
            sfData[serverUrl]="${sf[serverUrl]}"
            sfData[response]="${sf[response]}"
            printf '{ "serverUrl": "%s", "response": %s }' "${sfData[serverUrl]}" "${sfData[response]}" > "${cache[sfFile]}"
          fi
        fi
        # sf_logout is useless and take 1 sec approx
      fi      
    fi
  else
    sfData[source]="(c)"
    sfData[serverUrl]="$(jq -r '.serverUrl' "${cache[sfFile]}")"
    sfData[response]="$(jq -r '.response' "${cache[sfFile]}")"
  fi
  durationInSecondsSinceTheCacheWasUpdated=${cache[timeToLiveInSeconds]}
  if [[ -f "${cache[jiraFile]}" && "${useCache}" = yes ]] ; then
    durationInSecondsSinceTheCacheWasUpdated=$(date -d "$(stat "${cache[jiraFile]}" | sed -n 's/^Modify: //p')" -u "+""$(date -u +%s)"" %s-p" | dc)
  fi
  if [[ ( "${useCache}" = no && "${durationInSecondsSinceTheCacheWasUpdated}" -ge "${minimalTimeWithoutRequestsInSeconds}" ) || "${durationInSecondsSinceTheCacheWasUpdated}" -ge "${cache[timeToLiveInSeconds]}" ]] ; then
    jiraData[source]="(i)"
    jiraData[issues]='{ "expand": "schema,names", "startAt": 0, "maxResults": 0, "total": 0, "issues": [] }'
    jiraData[patchCount]=0
    searchJql
    if [[ ! -z "${jira[exit_status]}" && ! -z "${jira[http_code]}" ]] ; then
      if [[ "${jira[exit_status]}" -eq 0 && "${jira[http_code]}" -eq 200 ]] ; then
        jiraData[source]=
        jiraData[issues]="${jira[response]}"
      fi
    fi
    jira[maxResults]=0
    jira[jql]="${jira[patchCount]}"
    searchJql
    if [[ ! -z "${jira[exit_status]}" && ! -z "${jira[http_code]}" ]] ; then
      if [[ "${jira[exit_status]}" -eq 0 && "${jira[http_code]}" -eq 200 ]] ; then
        jiraData[patchCount]=$(printf '%s' "${jira[response]}" | jq -r .total)
      fi
    fi
    printf '{ "issues": %s, "patches": {"startAt":0,"maxResults":0,"total":%s,"issues":[]} }' "${jiraData[issues]}" "${jiraData[patchCount]}"  > "${cache[jiraFile]}"
  else
    jiraData[source]="(c)"
    jiraData[issues]="$(jq .issues "${cache[jiraFile]}")"
    jiraData[patchCount]="$(jq -r .patches.total "${cache[jiraFile]}")"
  fi
}

##
## VARIABLES
## 

sfTabHeight=400px

grenobleOfficeOpeningHourParisTZ='09:00'
sanFranscicoOfficeClosingParisTZ='03:00'

. "${CONFIGURATION_FILE}"

if [ -z "${cache[directory]}" ] ; then
  cache[directory]=/tmp/dashboard.cache
fi
if [ -z "${cache[sfFile]}" ] ; then
  cache[sfFile]="${cache[directory]}"/salesforceRequest.last
fi
if [ -z "${cache[jiraFile]}" ] ; then
  cache[jiraFile]="${cache[directory]}"/jiraRequest.last
fi

if [ -z "${cache[timeToLiveInSeconds]}" ] ; then
  cache[timeToLiveInSeconds]=60
fi

if [ -z "${minimalTimeWithoutRequestsInSeconds}" ] ; then
  minimalTimeWithoutRequestsInSeconds=$(( cache[timeToLiveInSeconds] / 2 ))
fi

if [ ! -d "${cache[directory]}" ] ; then
  mkdir -p "${cache[directory]}" >/dev/null 2>&1
fi 

#
# initialize the sfData associative array (or map): defined the original set of keys of the map for AggregateResult (single value). used to create the jqFilter below
sfData[Number_Of_Service_Requests]=""
sfData[Number_Of_Incident_Requests]=""
sfData[Number_Of_Usage_Questions]=""
sfData[Number_Of_S1]=""
sfData[Number_Of_S2]=""
sfData[Number_Of_S3]=""
sfData[Number_of_Cases_With_SLADeadline_Outside_Office_Hour]=""
sfData[Number_Of_Open_Cases_With_Bugs]=""
sfData[Number_Of_Old_Cases_Without_Bug]=""
sfData[Number_Of_Cases_In_Worklist]=""
sfData[Number_Of_Open_Cases]=""
sfData[Number_Of_Active_Cases]=""
sfData[Number_Of_Escalated_Cases]=""
sfData[Number_Of_Cases_Closed_Last_Two_Weeks]=""
sfData[Number_Of_Cases_Open_Last_Two_Weeks]=""

#
# jq filter to retrieve the single values from the JSON in the salesforce answer PLUS the Number_Of_Cases_In_Worklist
# see the sfData keys defines in the init()
jqFilter='select(.hasErrors == false) | .results[] | select (.statusCode == 200) | .result | .records[] | '
jqFilterEnd=$(printf ',(@sh "sfData[%s]=\(select(.%s) |.%s)")' $(printf "%s\n" "${!sfData[@]}" "${!sfData[@]}" "${!sfData[@]}" | sort))
jqFilter="${jqFilter}${jqFilterEnd:1}"


if [ ! -z "${DBG}" ] ; then
  exec 2> /tmp/dbg.dashboard
  set -x 
fi
#
# batch of salesforce requests
sf[batchRequestBody]='{ "batchRequests" : ['
sf[batchRequestBody]="${sf[batchRequestBody]}"'{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfActiveServiceRequestSQL}")'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"',{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfActiveIncidentRequestSQL}")'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"',{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfActiveUsageQuestionSQL}")'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"',{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfActiveSeverity1SQL}")'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"',{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfActiveSeverity2SQL}")'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"',{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfActiveSeverity3SQL}")'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"',{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfCaseswithSLADeadLineprefix} Number_of_Cases_With_SLADeadline_Outside_Office_Hour ${sfCaseswithSLADeadLinesuffix} AND ""$(getSOQLClauseForSLADeadlineOutsideWorkingHours)")'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"',{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfOpenCasesWithBugsSOQL}")'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"',{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfOpenCasesSOQLprefix} Number_Of_Old_Cases_Without_Bug ${sfOpenCasesSOQLsuffix} and Issues__c = null and CreatedDate < "$(get14daysInPastISODate))'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"',{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfWorkListSOQL}")'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"',{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfCountWorkListSOQL}")'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"',{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfOpenCasesSOQL}")'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"',{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfActiveCasesSOQL}")'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"',{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfEscalatedCasesSOQL}")'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"',{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfClosedLastTwoWeeksSOQL}")'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"',{"method" : "GET", "url" : "'"${sf[aPIVersion]}"'/query/?q='$(python -c "import urllib;print urllib.quote(raw_input())" <<< "${sfOpenLastTwoWeeksSOQL}")'"}'
sf[batchRequestBody]="${sf[batchRequestBody]}"']}'
if [ ! -z "${DBG}" ] ; then
  set +x 
fi
 
# set HTML_RESOURCES_DIR to another value for test
# used in the HTML generated
if [[ -z "${HTML_RESOURCES_DIR}"  ]] ; then
  HTML_RESOURCES_DIR=/dashboard
fi


##
## M A I N
## 
getDataWithCache

# retrieve single values from SF response and populate the sfData associative array
eval "$(printf '%s' "${sfData[response]}" | jq -r "${jqFilter}")"
eval "$(printf '%s' "${sfData[response]}" | jq -r '(@sh "sfData[Number_Of_Cases_Listed_In_Worklist]=\(select(.hasErrors == false) | .results[] | select (.statusCode == 200) | .result | first(select((.records | length) == 0 or .records[].attributes.type == "Case")) | .totalSize)")')"

# 
jiraData[maxResults]=$(printf "%s\n" "${jiraData[issues]}" |  jq -r '.maxResults')
jiraData[total]=$(printf "%s\n" "${jiraData[issues]}" |  jq -r '.total')
if [[ -z "${jiraData[maxResults]}" || -z "${jiraData[total]}" ]] ; then
  jiraData[maxResults]=0
  jiraData[total]=0
fi

if [ -z "${TEST_DASHBOARD}" ] ; then 
  printf "Content-type: text/html\n\n"
fi

printf '<!DOCTYPE html>\n<html><head><meta charset="UTF-8"><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0" /><title>Bonitasoft Support Monitoring Dashboards</title>
<link rel="stylesheet" type="text/css" href="%s/design.css" media="screen"><script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script><script type="text/javascript">
  var sec = 299; 

  google.charts.load("current", {packages:["corechart", "gauge"]});

  var typeBarChart = null;
  var severityBarChart = null;
  var next0930GaugeChart = null;
  var caseWithBugsGaugeChart = null;
  var oldCasesGaugeChart = null;

  google.charts.setOnLoadCallback(drawTypeBarChart);
  google.charts.setOnLoadCallback(drawSeverityBarChart);
  google.charts.setOnLoadCallback(drawNext0930Gauge);
  google.charts.setOnLoadCallback(drawCaseWithBugsGauge);
  google.charts.setOnLoadCallback(drawOldCasesGauge);

  function display_c() {
    if (sec <= 0) {
      document.getElementById("remaining").innerHTML = "";
      document.getElementById("next_refresh").innerHTML = "Reloading ...";
      location.reload(true);
    } else {
      var str = "";
      if (sec >= 3600) {
        str += intToTwoDigitsString(Math.floor(sec / 3600));
        str += ":";
      }
      if (sec >= 60) {
        str += intToTwoDigitsString(Math.floor((sec / 60) %% 60));
      } else {
        str += "00";
      }
      str += ":";

      if (sec > 0) {
       str += intToTwoDigitsString((sec %% 60));
      }

      document.getElementById("remaining").innerHTML = str;
      sec -= 1;
      mytime = setTimeout("display_c()", 1000);
    }
  }
  function intToTwoDigitsString(num) {
    var twodigits = "0";
    if (num < 10) {
      twodigits = twodigits + num;
    } else {
      twodigits = num.toString();
    }
    return twodigits;
  }
  function formatInBrowserTZISODate(d) {
    var dateString = intToTwoDigitsString(d.getDate()) + "/" + intToTwoDigitsString(d.getMonth()+1) + "/" + d.getFullYear() + " " + intToTwoDigitsString(d.getHours()) + ":" + intToTwoDigitsString(d.getMinutes());
    return dateString;
  }
  function formatInBrowserTZISODateString(iSODateTimeString) {
    return formatInBrowserTZISODate(new Date(iSODateTimeString));
  } ' "${HTML_RESOURCES_DIR}"

printf '
  function drawTypeBarChart() {
    var barData = google.visualization.arrayToDataTable([
    ["Type", "Number", { role: "style" },{role: "annotation"}],'


nbOfActiveServiceRequest="${sfData[Number_Of_Service_Requests]}"
nbOfActiveIncidentRequest="${sfData[Number_Of_Incident_Requests]}"
nbOfActiveUsageQuestion="${sfData[Number_Of_Usage_Questions]}"
        
printf '
    ["", %s, "color: #269900", "IR: %s"],
    ["", %s, "color: #0073e6", "UQ: %s" ],
    ["", %s, "color: #cccccc", "SR: %s"]\n' "${nbOfActiveIncidentRequest}" "${nbOfActiveIncidentRequest}" "${nbOfActiveUsageQuestion}" "${nbOfActiveUsageQuestion}" "${nbOfActiveServiceRequest}" "${nbOfActiveServiceRequest}"
printf '
        ]);

        var barOptions = {
          height: screen.height*0.166,
          legend: {position: "none"},
          backgroundColor: "#000000",
          bar: { groupWidth: "95%%" },
          xAxis: { backgroundColor: "#ff8d00"},
          annotations: {
            textStyle: {
              fontSize: 28,
              bold: true,
              italic: false,
              auraColor: "#000000",
              opacity: 1
            }
          },
          chartArea: { 
            width: "95%%",
            height: "90%%"
          }
        };
        typeBarChart = new google.visualization.BarChart(document.getElementById("type_bar_chart"));
        typeBarChart.draw(barData, barOptions);
      } '

printf '
      function drawSeverityBarChart() {
        var barData = google.visualization.arrayToDataTable([
            ["Type", "Number", { role: "style" },{role: "annotation"}],'

nbOfActiveSeverity1="${sfData[Number_Of_S1]}"
nbOfActiveSeverity2="${sfData[Number_Of_S2]}"
nbOfActiveSeverity3="${sfData[Number_Of_S3]}"

printf '
            ["", %s, "color: #ff8d00", "S1: %s"],
            ["", %s, "color: #ffdb00", "S2: %s" ],
            ["", %s, "color: #cccccc", "S3: %s" ] ' "${nbOfActiveSeverity1}" "${nbOfActiveSeverity1}" "${nbOfActiveSeverity2}" "${nbOfActiveSeverity2}" "${nbOfActiveSeverity3}" "${nbOfActiveSeverity3}"
printf '
         ]);
        
        /**  height: (screen.height-560) / 2 - 100,*/
        var barOptions = {
          height: screen.height*0.166,
          legend: {position: "none"},
          backgroundColor: "#000000",
          bar: { groupWidth: "95%%" },
          xAxis: { backgroundColor: "#ff8d00"},
          annotations: {
            textStyle: {
              fontSize: 28,
              bold: true,
              italic: false,
              auraColor: "#000000",
              opacity: 1
            }
          },
          chartArea: { 
            width: "95%%",
            height: "90%%"
          }
        };
       
        severityBarChart = new google.visualization.BarChart(document.getElementById("severity_bar_chart"));
        severityBarChart.draw(barData, barOptions);
      }
      function drawNext0930Gauge() {
        var next0930GaugeData = google.visualization.arrayToDataTable([
            ["Label", "Value"],'

# sfCaseswithSLADeadLine
nbOfCasesWithDeadLineOutsideWorkingHour="${sfData[Number_of_Cases_With_SLADeadline_Outside_Office_Hour]}"
percentageCasesWithDeadLineInside18NextWorkingHours=$(( (nbOfCasesWithDeadLineOutsideWorkingHour * 85) / 10 ))
printf '
["%s at risk", %s]' "${nbOfCasesWithDeadLineOutsideWorkingHour}" "${percentageCasesWithDeadLineInside18NextWorkingHours}"


printf '
          ]);

        var next0930GaugeOptions = {
          height: screen.height*0.333, 
          redFrom: 85, redTo: 100,
          yellowFrom:65, yellowTo: 85,
          greenFrom:0, greenTo: 65,
          minorTicks: 10,
          chartArea: { 
            width: "95%%",
            height: "90%%"
          }
        };
        next0930GaugeChart = new google.visualization.Gauge(document.getElementById("next0930gauge_chart"));
        next0930GaugeChart.draw(next0930GaugeData, next0930GaugeOptions);
      }
      function drawCaseWithBugsGauge() {
        var gaugeData = google.visualization.arrayToDataTable([
            ["Label", "Value"],'

nbOfCasesWithBugs="${sfData[Number_Of_Open_Cases_With_Bugs]}"
casesWithBugsPerCentage="${nbOfCasesWithBugs}"
printf '
["With bug", %s]'  "${casesWithBugsPerCentage}"

printf '
          ]);

        var gaugeOptions = {
          height: screen.height*0.333,
          greenFrom:0, greenTo: 35,
          yellowFrom:35, yellowTo: 65,
          redFrom: 65, redTo: 100,
          minorTicks: 10,
          chartArea: { 
            width: "100%%",
            height: "100%%"
          }
        };
        caseWithBugsGaugeChart = new google.visualization.Gauge(document.getElementById("cases_with_bugs_gauge_chart"));
        caseWithBugsGaugeChart.draw(gaugeData, gaugeOptions);
      }

      function drawOldCasesGauge() {
        var oldCasesGaugeData = google.visualization.arrayToDataTable([
            ["Label", "Value"],'

nbOfOldCasesWithoutBug="${sfData[Number_Of_Old_Cases_Without_Bug]}"
oldCasesWithoutBugPerCentage="${nbOfOldCasesWithoutBug}"
printf '
["Old w/o Bug", %s]' "${oldCasesWithoutBugPerCentage}"

printf '
          ]);

        var oldCasesGaugeOptions = {
          height: screen.height*0.333,
          greenFrom:0, greenTo: 35,
          yellowFrom:35, yellowTo: 65,
          redFrom: 65, redTo: 100,
          minorTicks: 10,
          chartArea: { 
            width: "100%%",
            height: "100%%"
          }
        };
        oldCasesGaugeChart = new google.visualization.Gauge(document.getElementById("old_cases_gauge_chart"));
        oldCasesGaugeChart.draw(oldCasesGaugeData, oldCasesGaugeOptions);
      }\n</script>\n</head>\n<body onload="display_c();">\n<div style="height: %s">' "${sfTabHeight}"

nbOfRecordsDisplayed=0

printf '
<table id="caseworklist">
  <thead style="font-size: %s;">
      <th>Case %s</th>
      <th>Status</th>
      <th>!</th>
      <th>Sev.</th>
      <th>SLA Deadline</th>
      <th>Subject</th>
      <th>Account name</th>
      <th>Contact</th>
      <th>Owner</th>
  </thead>
  <tbody>
    <colgroup>
      <col width="0%%" />
      <col width="0%%" />
      <col width="0%%" />
      <col width="0%%" />
      <col width="0%%" />
      <col width="100%%" />
      <col width="0%%" />
      <col width="0%%" />
      <col width="0%%" />
   </colgroup>\n' "70%" "${sfData[source]}"
   
if (( sfData[Number_Of_Cases_In_Worklist] > 0 && sfData[Number_Of_Cases_Listed_In_Worklist] > 0 )) ; then
#
#
# <td><a href="foo">bar</a></td>
#
# td { padding: someValue; } td a { display: block; margin: -someValue; padding: someValue; } You may also want to add text-decoration: none to the td a. 
#
#
  # seconds since 1970-01-01 00:00:00 UTC
  seconds=$(date -u "+%s") 
  itShouldRingABell=
  records="$(printf '%s' "${sfData[response]}" | jq 'select(.hasErrors == false) | .results[] | select (.statusCode == 200) | .result | first(select(.records[].attributes.type == "Case")) | .records')"
  nbOfRecordsDisplayed=0
  serverUrl="${sfData[serverUrl]%%/services/*}"
  while (( nbOfRecordsDisplayed < sfData[Number_Of_Cases_Listed_In_Worklist] )) ; do
    if [ ! -z "${DBG}" ] ; then
      exec 2> /tmp/dbg.dashboard
      set -x 
    fi
    eval $(printf '%s' "${records}" | jq -r '.['"${nbOfRecordsDisplayed}"'] | (@sh "accountName=\(.Account.Name) caseNumber=\(.CaseNumber) contactName=\(.Contact.LastName) lastSupportEngineer=\(.LastSupportCommentBy__c) ownerName=\(.Owner.FirstName) sLADeadline=\(.SLA_Deadline__c) sev=\(.Severity__c) issueNotFixedYet=\(.IssueNotFixedYet__c) lastPublicSupportCommentDateTime=\(.LastCaseCommentFromBonitaSoft__c) lastPublicCommentDateTime=\(.LastPublicCommentDateTime__c) lastActiveStatusDateTime=\(.LastActiveStatusDateTime__c) status=\(.Status) subject=\(.Subject) caseUrl=\(.attributes.url) subscriptionId=\(.Subscription__c) isEscalated=\(.IsEscalated) ")')
    caseUrl="${serverUrl}"'/apex/CaseView?id='"${caseUrl##*/}"
    subscriptionUrl="${serverUrl}/${subscriptionId}"
    if [ ! -z "${DBG}" ] ; then
      set +x 
    fi
    last=
    if [ ! -z "${ownerName}" ] ; then
      if [[ "${ownerName}" = null || "${ownerName%% *}" = Bonitasoft ]] ; then
        ownerName=""
      else
        last="${ownerName%% *}"
      fi
    fi
    if [ ! -z "${lastSupportEngineer}" ] ; then
      lastSupportEngineer="${lastSupportEngineer%% *}"
      if [[ "${lastSupportEngineer}" != null && "${lastSupportEngineer}" != Bonitasoft ]] ; then
        last="${lastSupportEngineer}"
      fi
    fi
    if [ -z "${last}" ] ; then
      last="&nbsp;"
    fi
    diffInSeconds="36000"
    if [ "${sLADeadline}" = null ] ; then
      sLADeadline=""
    else
      diffInSeconds=$(date -d "${sLADeadline}" -u "+%s ${seconds}-p" | dc)
    fi

    class="${sev,*}"_sla_td
    if [[ "${sLADeadline}" =~ [0-9] ]] ; then
      if (( "${diffInSeconds}" < 3600 )) ; then
        class=dangerous_sla_td
        itShouldRingABell=yes
      fi
      eval "$(date -u -d "${sLADeadline}" "+yearUTC=%Y monthUTC=%m dayUTC=%d hourUTC=%H minuteUTC=%M secondUTC=%S nanosecondUTC=%N")"
      milisecondUTC="${nanosecondUTC:0:3}"
      sLADeadline='<script type="text/javascript">
                     var d=new Date();
                     d.setUTCFullYear('"${yearUTC}"');
                     d.setUTCMonth('"${monthUTC}"' - 1);
                     d.setUTCDate('"${dayUTC}"');
                     d.setUTCHours('"${hourUTC}"');
                     d.setUTCMinutes('"${minuteUTC}"');
                     d.setUTCSeconds('"${secondUTC}"');
                     d.setUTCMilliseconds('"${milisecondUTC}"');
                     document.write(formatInBrowserTZISODate(d));
                   </script>'
    else
      sLADeadline='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'
    fi
    if [[ "${issueNotFixedYet}" = false && "${class}" != dangerous_sla_td && "${lastPublicSupportCommentDateTime}" != null ]] ; then
      lastPublicSupportCommentInSeconds=$(date -d "${lastPublicSupportCommentDateTime}" -u "+%s")
      lastPublicCommentInSeconds=$(date -d "${lastPublicCommentDateTime}" -u "+%s")
      if (( "${lastPublicSupportCommentInSeconds}" < ("${lastPublicCommentInSeconds}" - "${toleranceInSeconds}") )) ; then
        lastActiveStatusInSeconds=$(date -d "${lastActiveStatusDateTime}" -u "+%s")
        if (( "${lastActiveStatusInSeconds}" < "${lastPublicSupportCommentInSeconds}" )) ; then
          class=updated_in_progress_td
        fi
      fi
    fi
    isEscalatedDiv=
    if [ "${isEscalated}" = true ] ; then
      if [[ "${class}" == dangerous_sla_td ]] ; then
        isEscalatedDiv='<div class="inner-circle dangerous_sla_td">&nbsp;</div>'
      elif [[ "${class}" == updated_in_progress_td ]] ; then
        isEscalatedDiv='<div class="inner-circle updated_in_progress_td" style="color: red">&nbsp;</div>'
      else
        isEscalatedDiv='<div class="inner-circle">&nbsp;</div>'
      fi
    fi


    printf '
    <tr>
        <td>
          <a class="%s" href="%s" target="_blank" style="display: block;">
            %s
          </a>
        </td>        
        <td>
          <a class="%s" href="%s" target="_blank" style="display: block;">
            %s
          </a>
        </td>
        <td>%s</td>
        <td>
          <a class="%s" href="%s" target="_blank" style="display: block;">
            %s
          </a>
        </td>
        <td>
          <a class="%s" href="%s" target="_blank" style="display: block;">
            %s
          </a>
        </td>
        <td style="max-width:10em; min-width:10em;">
          <a class="%s" href="%s" target="_blank" style="display: block; white-space: nowrap; text-overflow:ellipsis; overflow: hidden;">
            %s
          </a>
        </td>
        <td style="max-width:12em;">
          <a class="%s" href="%s" target="_blank" style="display: block; white-space: nowrap; text-overflow:ellipsis; overflow: hidden;">
            %s
          </a>
        </td>
        <td style="max-width:6em;">
          <a class="%s" href="%s" target="_blank" style="display: block; white-space: nowrap; text-overflow:ellipsis; overflow: hidden;">
            %s
          </a>
        </td>
        <td>
          <a class="%s" href="%s" target="_blank" style="display: block;">
            %s
          </a>
        </td>
    </tr>\n' "${class}" "${caseUrl}" "${caseNumber}" "${class}" "${caseUrl}" "${status}" "${isEscalatedDiv}" "${class}" "${caseUrl}" "${sev}" "${class}" "${caseUrl}" "${sLADeadline}" "${class}" "${caseUrl}" "${subject}" "${class}" "${subscriptionUrl}" "${accountName}" "${class}" "${caseUrl}" "${contactName}" "${class}" "${caseUrl}" "${last}"
    nbOfRecordsDisplayed=$(( nbOfRecordsDisplayed + 1))
  done
else
  printf '<tr class="s3_sla_td"><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td style="white-space: nowrap; text-overflow:ellipsis; overflow: hidden; max-width:1px;">%s</td><td style="white-space: nowrap; text-overflow:ellipsis; overflow: hidden; max-width:12em;">%s</td><td style="white-space: nowrap; text-overflow:ellipsis; overflow: hidden;max-width:6em;">%s</td><td>%s</td></tr>\n' "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"  "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" "&nbsp;" "&nbsp;&nbsp;" "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" "&nbsp;&nbsp;"  "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
fi
printf '</tbody></table></div>\n'
nbNotDisplayed=$(( sfData[Number_Of_Cases_In_Worklist] - nbOfRecordsDisplayed ))
if (( "${nbNotDisplayed}" > 0 )) ; then
  if (( "${nbNotDisplayed}" == 1 )) ; then
    printf '<div style="color:red;text-align: center; vertical-align: middle; max-width: none; width: auto; min-width: 100%%; font-size: %s;">%s case is not listed</div>' "139%" "${nbNotDisplayed}"
  else
    printf '<div style="color:red;text-align: center; vertical-align: middle; max-width: none; width: auto; min-width: 100%%; font-size: %s;">%s cases are not listed</div>' "139%" "${nbNotDisplayed}"
  fi
else
  printf '<div style="color:red;text-align: center; vertical-align: middle; max-width: none; width: auto; min-width: 100%%; font-size: %s;">&nbsp</div>' "139%"
fi
nbOfOpenCases="${sfData[Number_Of_Open_Cases]}"
nbOfActiveCases="${sfData[Number_Of_Active_Cases]}"

motdJSString='<div>&nbsp</div>'
if [[ ${#motd[@]} -gt 0 ]] ; then
  unset jsDOW
  declare -A jsDOW
  jsDOW[Sunday]=0; jsDOW[Monday]=1; jsDOW[Tuesday]=2; jsDOW[Wednesday]=3; jsDOW[Thursday]=4; jsDOW[Friday]=5; jsDOW[Saturday]=6;
  elementList=""
  for day in Sunday Monday Tuesday Wednesday Thursday Friday Saturday ; do
    if [[ ! -z ${motd[$day]} ]] ; then
      if [[ ! -z "${elementList}" ]] ; then
        elementList="${elementList}",'"'${motd[$day]}'"'
      else
        elementList='"'${motd[$day]}'"'
      fi
    else
      if [[ ! -z "${elementList}" ]] ; then
        elementList="${elementList}",'"&nbsp"'
      else
        elementList='"&nbsp"'
      fi
    fi
  done
  if [[ ! -z "${elementList}" ]] ; then
    if [[ "${elementList}" != '"&nbsp","&nbsp","&nbsp","&nbsp","&nbsp","&nbsp","&nbsp"' ]] ; then
    motdJSString='
  <div class="message">
    <script type="text/javascript">
      var motd = ['"${elementList}"'];
      document.write(motd[new Date().getDay()]);
    </script>
  <div>'
    fi 
  fi
fi
let diffOpenClosed=$(( sfData[Number_Of_Cases_Open_Last_Two_Weeks] - sfData[Number_Of_Cases_Closed_Last_Two_Weeks] ))
if (( diffOpenClosed > 0 )) ; then
  diffOpenClosedString=+"${diffOpenClosed}"
else
  diffOpenClosedString="${diffOpenClosed}"
fi

if (( sfData[Number_Of_Escalated_Cases] == 0 )) ; then
  statBannerTd='<td style="min-width: 46%;">
  '"${nbOfOpenCases}"' Open ('"${diffOpenClosedString}"') - '"${nbOfActiveCases}"' Active - 0 Escalated - '"${jiraData[patchCount]}"' Patches - '"${sfData[Number_Of_Cases_Open_Last_Two_Weeks]}"' new
  </td>'
else
  statBannerTd='<td class="escalated" style="min-width: 46%;">
  '"${nbOfOpenCases}"' Open ('"${diffOpenClosedString}"') - '"${nbOfActiveCases}"' Active - '"${sfData[Number_Of_Escalated_Cases]}"' Escalated - '"${jiraData[patchCount]}"' Patches - '"${sfData[Number_Of_Cases_Open_Last_Two_Weeks]}"' new
  </td>'
fi

#    <div class="banner">%s Open Cases -- %s Active Cases -- %s Patches
#    </div>
printf '
    <table id="banner">
      <tbody>
      <tr>
          %s     
        <td style="min-width: 54%%;">
          %s
        </td>
      </tr>
      </tbody>
    </table>
    <div id="lastrefreshpanel"> Last refresh <script type="text/javascript">var cd=new Date(); var ctimestr = intToTwoDigitsString(cd.getHours())+":"+intToTwoDigitsString(cd.getMinutes())+":"+intToTwoDigitsString(cd.getSeconds());document.write(ctimestr);</script>
        <div id="next_refresh">Next refresh in <span id="remaining">25 s</span>
        </div>
    </div>
<table style="background-color: #000000; padding: 0; margin: 0; border-collapse: collapse; max-width: none; width: auto; min-width: 100%%;">
  <tr style="background-color: #000000; padding: 0; margin: 0; border-collapse: collapse; max-width: none; width: auto; min-width: 100%%;">
    <td style="background-color: #000000; padding: 0; margin: 0; border-collapse: collapse; max-width: none; width: auto; min-width: 46%%;">
      <div id="type_bar_chart" style="height: 100%%;max-width: none; width: auto; min-width: 100%%;">
      </div>
      <div id="severity_bar_chart" style="height: 100%%;max-width: none; width: auto; min-width: 100%%;">
      </div>
    </td>
    <td style="background-color: #000000; width: 18%%;padding: 0; margin: 0; border-collapse: collapse;">
      <div id="next0930gauge_chart" style="height: 100%%;">
      </div>
    </td>
    <td style="background-color: #000000; width: 18%%;padding: 0; margin: 0; border-collapse: collapse;">
      <a href="%s" target="_blank" style="max-width: none; width: auto; min-width: 100%%;">
        <div id="cases_with_bugs_gauge_chart" style="height: 100%%;">
        </div>
      </a>
    </td>
    <td style="background-color: #000000; width: 18%%;padding: 0; margin: 0; border-collapse: collapse;">
      <a href="%s" target="_blank" style="max-width: none; width: auto; min-width: 100%%;">
        <div id="old_cases_gauge_chart" style="height: 100%%;">
        </div>
      </a>
    </td>
  </tr>
</table>' "${statBannerTd}" "${motdJSString}" "${sfCasesWithBugListHREF}" "${sfOldCasesWithoutBugListHREF}" 

if [[ ! -z "${itShouldRingABell}" ]] ; then 
  printf '<div style="margin-top: 50px;display: none"><br><audio controls="controls" autoplay="autoplay"> <source src="%s/bell.mp3" type="audio/mpeg"> <source src="%s/bell.wav" type="audio/wav">Your browser does not support the audio element. </audio><br></div>' "${HTML_RESOURCES_DIR}" "${HTML_RESOURCES_DIR}"
fi

index=0
printf '
  <table id="bugWorkList" style="min-width: 980px;">
    <thead style="font-size: %s;">
      <th>Key %s</th>
      <th>Summary</th>
      <th>Status</th>
      <th>Resolution</th>
      <th>Updated</th>
      <th>Version</th>
      <th>Assignee</th>
    </thead>
    <tbody>
    <colgroup>
      <col width="0%%" />
      <col width="100%%" />
      <col width="0%%" />
      <col width="0%%" />
      <col width="0%%" />
      <col width="0%%" />
      <col width="0%%" />
   </colgroup>' "70%" "${jiraData[source]}"
while (( "${index}" < "${jiraData[maxResults]}" && "${index}" < "${jiraData[total]}" )) ; do
  key="$(printf "%s\n" "${jiraData[issues]}" |  jq '.issues['"${index}"'].key' | sed 's/^.\(.*\).$/\1/' )"
  bugURL="${atlassianURL}${key}"
  summary="$(printf "%s\n" "${jiraData[issues]}" |  jq '.issues['"${index}"'].fields.summary' | sed -e 's/^.\(.*\).$/\1/' -e 's/[\]//g')"
  affectedVersions="$(printf "%s\n" "${jiraData[issues]}" |  jq '.issues['"${index}"'].fields.versions[].name' | sed -e 's/'\"'//g' -e 's/ /, /g')"
  assignee="$(printf "%s\n" "${jiraData[issues]}" |  jq '.issues['"${index}"'].fields.assignee.displayName' | sed 's/^.\(.*\).$/\1/' )"
  if [ ! -z "${assignee}" ] ; then
    assignee="${assignee%% *}"
  fi
  status="$(printf "%s\n" "${jiraData[issues]}" |  jq '.issues['"${index}"'].fields.status.name' | sed 's/^.\(.*\).$/\1/' )"
  resolution="$(printf "%s\n" "${jiraData[issues]}" |  jq '.issues['"${index}"'].fields.resolution.name')"
  if [[ "${resolution}" = "null" ]] ; then
    resolution=""
  else
    resolution="$(printf "%s" "${resolution}" | sed 's/^.\(.*\).$/\1/' )"
  fi
  updatedDateTime="$(printf "%s\n" "${jiraData[issues]}" |  jq '.issues['"${index}"'].fields.updated' | sed 's/^.\(.*\).$/\1/' )"
  eval "$(date -u -d "${updatedDateTime}" "+yearUTC=%Y monthUTC=%m dayUTC=%d hourUTC=%H minuteUTC=%M secondUTC=%S nanosecondUTC=%N")"
  milisecondUTC="${nanosecondUTC:0:3}"
  updatedDateTime='<script type="text/javascript">
                     var d=new Date();
                     d.setUTCFullYear('"${yearUTC}"');
                     d.setUTCMonth('"${monthUTC}"' - 1);
                     d.setUTCDate('"${dayUTC}"');
                     d.setUTCHours('"${hourUTC}"');
                     d.setUTCMinutes('"${minuteUTC}"');
                     d.setUTCSeconds('"${secondUTC}"');
                     d.setUTCMilliseconds('"${milisecondUTC}"');
                     document.write(formatInBrowserTZISODate(d));
                   </script>'

  printf '
  <tr>
    <td>
      <a class="s3_sla_td" href="%s" target="_blank" style="display: block;">
        %s
      </a>
    </td>
    <td style="max-width:10em; min-width:10em; width=auto;">
      <a class="s3_sla_td" href="%s" target="_blank" style="width=auto; display: block; white-space: nowrap; text-overflow:ellipsis; overflow: hidden; ">
        %s
      </a>
    </td>
    <td>
      <a class="s3_sla_td" href="%s" target="_blank" style="display: block;">
        %s
      </a>
    </td>
    <td>
      <a class="s3_sla_td" href="%s" target="_blank" style="display: block;">
        %s
      </a>
    </td>
    <td>
      <a class="s3_sla_td" href="%s" target="_blank" style="display: block;">
        %s
      </a>
    </td>
    <td style="max-width:9em;">
      <a class="s3_sla_td" href="%s" target="_blank" style="display: block; white-space: nowrap; text-overflow:ellipsis; overflow: hidden;">
        %s
      </a>
    </td>
    <td>
      <a class="s3_sla_td" href="%s" target="_blank" style="display: block;">
        %s
      </a>
    </td>
  </tr>' "${bugURL}" "${key}" "${bugURL}" "${summary}" "${bugURL}" "${status}" "${bugURL}" "${resolution}" "${bugURL}" "${updatedDateTime}" "${bugURL}" "${affectedVersions}" "${bugURL}" "${assignee}"
  index=$((index + 1))
done
if (( "${index}" == 0 )) ; then
  printf '<tr class="s3_sla_td"><td>%s</td><td style="white-space: nowrap; text-overflow:ellipsis; overflow: hidden; max-width:1px;">%s</td><td>%s</td><td>%s</td><td>%s</td><td style="white-space: nowrap; text-overflow:ellipsis; overflow: hidden;max-width:9em;">%s</td><td>%s</td></tr>' "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" "&nbsp;" "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
fi
printf '</tbody></table>'
if (( "${index}" < "${jiraData[total]}" )) ; then
  nbNotDisplayed=$(( jiraData[total] - index ))
  if (( "${nbNotDisplayed}" == 1 )) ; then
    printf '<div style="color:red;text-align: center; vertical-align: middle;font-size: %s;">%s bug is not listed</div>' "139%" "${nbNotDisplayed}"
  else
    printf '<div style="color:red;text-align: center; vertical-align: middle;font-size: %s;">%s bugs are not listed</div>' "139%" "${nbNotDisplayed}"
  fi
fi
printf '</body></html>'
