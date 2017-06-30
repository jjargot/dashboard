#!/bin/bash --

##
## D E P E N D E N C I E S
## 

#INSTALL_DIR=/usr/lib/cgi-bin/dashboard
INSTALL_DIR=/home/jjargot/Documents/project/dashboard/study/prod

. "${INSTALL_DIR}"/lib/salesforce.sh
. "${INSTALL_DIR}"/lib/atlassian-JIRA.sh
. "${INSTALL_DIR}"/conf/production.environment


##
## F U N C T I O N S
## 
sf_getSingleValue() {
  sf_login
  if [ "${sf[exit_status]}" -eq 0 ] ; then
    if [ "${sf[http_code]}" -eq 200 ] ; then
      #sf[queryString]="${sfOpenCasesSOQL}"
      sf[queryString]="${1}"
      sf_query
      records="${sf[response]#*?queryLocator xsi:nil=?true?/?}"
      records="${records%<size>*}"
      responseSize="${sf[responseSize]}"
      if [ "${sf[exit_status]}" -eq 0 ] ; then
        if [ "${sf[http_code]}" -eq 200 ] ; then
          if [[ ! -z "${responseSize}" && "${responseSize}" = 1 ]] ; then
            value="${records#*<sf:expr0 xsi:type=?xsd:int?>}" ; value="${value%</sf:expr0></records>*}"
          else
            value="#Err:request:malformed_response"
          fi
        else
          value="#Err:request:http_status=${sf[http_code]}"
        fi
      else
        value="#Err:request:exit_status=${sf[exit_status]}"
      fi
      sf_logout
    else
      value="#Err:login:http_status=${sf[http_code]}"  
    fi
  else 
    value="#Err:login:exit_status=${sf[exit_status]}"
  fi
  printf "%s" "${value}"
}

getNext0930ISODate() {
  if [ $(date -u "%u") -lt 5 ] ; then
    printf "%sT09:30:00Z" $(date --iso-8601 -d "+1 day" -u) 
  else 
    printf "%sT09:30:00Z\n" $(date --iso-8601 -d "+3 days" -u)
  fi  
}

##
## M A I N
## 

printf "Content-type: text/html\n\n"
printf '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">\n<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><title>Bonitasoft Support Monitoring Dashboards</title><link rel="stylesheet" type="text/css" href="dashboard/design.css" media="screen"><script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script><script type="text/javascript">
  var sec = 59; 

  google.charts.load("current", {packages:["corechart", "gauge"]});

  var typeBarChart = null;
  var severityBarChart = null;
  var gaugeChart = null;

  google.charts.setOnLoadCallback(drawTypeBarChart);
  google.charts.setOnLoadCallback(drawSeverityBarChart);
  google.charts.setOnLoadCallback(drawGauge);

  function display_c() {
    var str = "";
    if (sec >= 3600) {
      str += Math.floor(sec / 3600);
      str += " h ";
    }
    if (sec >= 60) {
      str += Math.floor((sec / 60) %% 60);
      str += " m ";
    }
    if (sec > 0) {
      str += (sec %% 60);
      str += " s";
    }
    if (sec <= 0) {
      typeBarChart.clearChart();
      severityBarChart.clearChart();
      gaugeChart.clearChart();
      location.reload(true);
    }
    document.getElementById("remaining").innerHTML = str;
    sec -= 1;
    mytime = setTimeout("display_c()", 1000);
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
  function formatInBrowserTZISODateString(iSODateTimeString) {
    var d = new Date(iSODateTimeString);
    var dateString = intToTwoDigitsString(d.getDate()) + "/" + intToTwoDigitsString(d.getMonth()+1) + "/" + d.getFullYear() + " " + intToTwoDigitsString(d.getHours()) + ":" + intToTwoDigitsString(d.getMinutes());
    return dateString;
  }
  function drawTypeBarChart() {
    var barData = google.visualization.arrayToDataTable([
    ["Type", "Number", { role: "style" },{role: "annotation"}],'

nbOfActiveServiceRequest=$(sf_getSingleValue "${sfActiveServiceRequestSQL}")
nbOfActiveIncidentRequest=$(sf_getSingleValue "${sfActiveIncidentRequestSQL}")
nbOfActiveUsageQuestion=$(sf_getSingleValue "${sfActiveUsageQuestionSQL}")

printf '
    ["", %s, "color: #32CD32", "Incident Request %s"],
    ["", %s, "color: #00BFFF", "Usage Question: %s" ],
    ["", %s, "color: silver", "Service Request: %s"]\n' "${nbOfActiveIncidentRequest}" "${nbOfActiveIncidentRequest}" "${nbOfActiveUsageQuestion}" "${nbOfActiveUsageQuestion}" "${nbOfActiveServiceRequest}" "${nbOfActiveServiceRequest}"
printf '
        ]);

        
        var barOptions = {
          width: screen.width*0.40,
          height: (screen.height-560) / 2 - 100,
          legend: {position: "none"},
          backgroundColor: "#000000",
          bar: { groupWidth: "95%%" },
          xAxis: { backgroundColor: "#ff8d00"}
        };
        typeBarChart = new google.visualization.BarChart(document.getElementById("type_bar_chart"));
        typeBarChart.draw(barData, barOptions);
      }

      function drawSeverityBarChart() {
        var barData = google.visualization.arrayToDataTable([
            ["Type", "Number", { role: "style" },{role: "annotation"}],'

nbOfActiveSeverity1=$(sf_getSingleValue "${sfActiveSeverity1SQL}")
nbOfActiveSeverity2=$(sf_getSingleValue "${sfActiveSeverity2SQL}")
nbOfActiveSeverity3=$(sf_getSingleValue "${sfActiveSeverity3SQL}")

printf '
            ["", %s, "color: #ff0000", "Severity 1: %s"],
            ["", %s, "color: #ffdb00", "Severity 2: %s" ],
            ["", %s, "color: #ffffff", "Severity 3: %s" ] ' "${nbOfActiveSeverity1}" "${nbOfActiveSeverity1}" "${nbOfActiveSeverity2}" "${nbOfActiveSeverity2}" "${nbOfActiveSeverity3}" "${nbOfActiveSeverity3}"
printf '
         ]);
        
        var barOptions = {
          width: screen.width*0.40,
          height: (screen.height-560) / 2 - 100,
          legend: {position: "none"},
          backgroundColor: "#000000",
          bar: { groupWidth: "95%%" },
          xAxis: { backgroundColor: "#ff8d00"}
        };
       
        severityBarChart = new google.visualization.BarChart(document.getElementById("severity_bar_chart"));
        severityBarChart.draw(barData, barOptions);
      }

      function drawGauge() {
         var gaugeData = google.visualization.arrayToDataTable([
            ["Label", "Value"],
                        ["< 12h", 55],
            ["With bugs", 80],
            ["Old", 68]
         ]);

        var gaugeOptions = {
          width: screen.width*0.60, height: screen.height-560-200,
          redFrom: 90, redTo: 100,
          yellowFrom:75, yellowTo: 90,
          minorTicks: 2,
        };
        gaugeChart = new google.visualization.Gauge(document.getElementById("gauge_chart"));
        gaugeChart.draw(gaugeData, gaugeOptions);
      }\n</script>\n</head>\n<body onload="display_c();">\n<div style="height: 350px">'
sf_login
sf[queryString]="${sfWorkListSOQL}"
sf_query
records="${sf[response]#*?queryLocator xsi:nil=?true?/?}"
records="${records%<size>*}"
responseSize="${sf[responseSize]}"
sf_logout
nbOfRecordsDisplayed=0
printf '<table class="fixed" id="caseworklist"><tbody><tr><th style="width: 80px;">Case #</th><th style="width: 145px;">Status</th><th style="width: 56px; text-align: center">Sev.</th><th style="width: 200px;">SLA Deadline</th><th style="width: 115px;">owner name</th><th style="width: 650px;">Subject</th><th style="width: 300px;">Account name</th><th style="width: 125px;">Contact name</th><th style="width: 115px;">Last</th></tr>'
# 80 | 145 | 56 | 210 | 115 | 650 | 300 | 125 |115
# 1820
if [[ ! -z "${responseSize}" && "${responseSize}" =~ [0-9] ]] ; then
# seconds since 1970-01-01 00:00:00 UTC
  seconds=$(date -u "+%s") 
  itShouldRingABell=
  while read record ; do
    accountName="${record#*><sf:Account xsi:type=?sf:Account?><sf:Id xsi:nil=?true?/><sf:Name>}" ; accountName="${accountName%</sf:Name></sf:Account>*}"
    caseNumber="${record#*><sf:CaseNumber>}" ; caseNumber="${caseNumber%</sf:CaseNumber>*}"
    contactName="${record#*><sf:Contact xsi:type=?sf:Contact?><sf:Id xsi:nil=?true?/><sf:LastName>}" ; contactName="${contactName%</sf:LastName><sf:Name>*}"
    last=""
    if [[ "${record}" =~ [^/]sf:LastSupportCommentBy__c ]] ; then
      last="${record#*><sf:LastSupportCommentBy__c>}" ; last="${last%</sf:LastSupportCommentBy__c>*}"
      if [ ! -z "${last}" ] ; then
        last="${last%% *}"
      fi
    fi
    ownerName=""
    if [[ "${record}" =~ sf:FirstName ]] ; then
      ownerName="${record#*><sf:Owner xsi:type=?sf:Name?><sf:Id xsi:nil=?true?/><sf:FirstName>}" ; ownerName="${ownerName%</sf:FirstName></sf:Owner>*}"
      if [ ! -z "${ownerName}" ] ; then
        ownerName="${ownerName%% *}"
      fi
    fi
    sLADeadline="-"
    if [[ "${record}" =~ [^/]sf:SLA_Deadline__c ]] ; then  
      sLADeadline="${record#*><sf:SLA_Deadline__c>}" ; sLADeadline="${sLADeadline%</sf:SLA_Deadline__c>*}"
      diffInSeconds=$(date -d "${sLADeadline}" -u "+%s ${seconds}-p" | dc)
    fi
    sev="${record#*><sf:Severity__c>}" ; sev="${sev%</sf:Severity__c>*}"
    class="${sev,*}"_sla_td
    if [[ "${sLADeadline}" =~ [0-9] ]] ; then
      if (( "${diffInSeconds}" < 3600 )) ; then
        class=dangerous_sla_td
        itShouldRingABell=yes
      fi
    fi
    issueNotFixedYet="${record#*><sf:IssueNotFixedYet__c>}" ; issueNotFixedYet="${issueNotFixedYet%</sf:IssueNotFixedYet__c>*}"
#    if class == dangerous_sla_td => NOTHING
#    if LastCaseCommentFromBonitaSoft__c not found => NOTHING
#      if LastCaseCommentFromBonitaSoft__c == LastPublicCommentDateTime__c => NOTHING
#        if LastActiveStatusDateTime < LastCaseCommentFromBonitaSoft__c AND LastCaseCommentFromBonitaSoft__c != LastPublicCommentDateTime__c => class=dangerous_sla_td
#dbg    printf "\n ============================ caseNumber=%s\n" "${caseNumber}"  >&2
    if [[ "${issueNotFixedYet}" = false && "${class}" != dangerous_sla_td && "${record}" =~ [^/]sf:LastCaseCommentFromBonitaSoft__c ]] ; then
      lastPublicSupportCommentDateTime="${record#*><sf:LastCaseCommentFromBonitaSoft__c>}" ; lastPublicSupportCommentDateTime="${lastPublicSupportCommentDateTime%</sf:LastCaseCommentFromBonitaSoft__c>*}"
      lastPublicSupportCommentInSeconds=$(date -d "${lastPublicSupportCommentDateTime}" -u "+%s")
      lastPublicCommentDateTime="${record#*><sf:LastPublicCommentDateTime__c>}" ; lastPublicCommentDateTime="${lastPublicCommentDateTime%</sf:LastPublicCommentDateTime__c>*}"
      lastPublicCommentInSeconds=$(date -d "${lastPublicCommentDateTime}" -u "+%s")
#dbg      printf "lastPublicSupportCommentDateTime=%s\nlastPublicCommentDateTime=%s\nlastPublicSupportCommentInSeconds=%s\nlastPublicCommentInSeconds=%s\n" "${lastPublicSupportCommentDateTime}" "${lastPublicCommentDateTime}" "${lastPublicSupportCommentInSeconds}" "${lastPublicCommentInSeconds}" >&2
      if (( "${lastPublicSupportCommentInSeconds}" < ("${lastPublicCommentInSeconds}" - "${toleranceInSeconds}") )) ; then
        lastActiveStatusDateTime="${record#*><sf:LastActiveStatusDateTime__c>}" ; lastActiveStatusDateTime="${lastActiveStatusDateTime%</sf:LastActiveStatusDateTime__c>*}"
        lastActiveStatusInSeconds=$(date -d "${lastActiveStatusDateTime}" -u "+%s")
#dbg        printf "lastPublicSupportCommentDateTime != lastPublicCommentDateTime\nlastPublicSupportCommentInSeconds=%s\nlastActiveStatusDateTime=%s\nlastActiveStatusInSeconds=%s\n" "${lastPublicSupportCommentInSeconds}" "${lastActiveStatusDateTime}" "${lastActiveStatusInSeconds}" >&2
        if (( "${lastActiveStatusInSeconds}" < "${lastPublicSupportCommentInSeconds}" )) ; then
#dbg          printf "lastActiveStatusInSeconds < lastPublicSupportCommentInSeconds\n" >&2
          class=dangerous_sla_td
        fi
      fi
    fi
    status="${record#*><sf:Status>}" ; status="${status%</sf:Status>*}"
    subject="${record#*><sf:Subject>}" ; subject="${subject%</sf:Subject><*}"
    printf '<tr class="%s"><td>%s</td><td>%s</td><td>%s</td><td><script type="text/javascript">document.write(formatInBrowserTZISODateString("%s"));</script></td><td style="max-width:115px;">%s</td><td style="max-width:650px;">%s</td><td style="max-width:300px;">%s</td><td>%s</td><td>%s</td></tr>' "${class}" "${caseNumber}" "${status}" "${sev}" "${sLADeadline}" "${ownerName}" "${subject}" "${accountName}" "${contactName}" "${last}"
    nbOfRecordsDisplayed=$(( nbOfRecordsDisplayed + 1))
    if (( "${nbOfRecordsDisplayed}" == 10 )) ; then
      break
    fi
  done < <(printf "%s" "${records}" | sed 's%</records>%</records>\n%g')
fi
printf '</tbody></table></div>'
nbNotDisplayed=$(( responseSize - nbOfRecordsDisplayed ))
if (( "${nbNotDisplayed}" > 0 )) ; then
  if (( "${nbNotDisplayed}" == 1 )) ; then
    printf '<div style="color:red;text-align: center; vertical-align: middle;">%s case is not listed</div>' "${nbNotDisplayed}"
  else
    printf '<div style="color:red;text-align: center; vertical-align: middle;">%s cases are not listed</div>' "${nbNotDisplayed}"
  fi
fi

nbOfOpenCases=$(sf_getSingleValue "${sfOpenCasesSOQL}")
nbOfActiveCases=$(sf_getSingleValue "${sfActiveCasesSOQL}")

printf '<div><div style="background-color: #000000; color: #ffffff">%s active cases over a total of %s</div><div id="lastrefreshpanel"> Last refresh <script type="text/javascript">var cd=new Date(); var ctimestr = intToTwoDigitsString(cd.getHours())+":"+intToTwoDigitsString(cd.getMinutes())+":"+intToTwoDigitsString(cd.getSeconds());document.write(ctimestr);</script><br>Next refresh in <span id="remaining">25 s</span> </div></div><br /><table class="columns" style="background-color: #000000; width: 100%%;"><tr><td><div id="type_bar_chart" style="width: 40%%;height: auto;"></div><br><div id="severity_bar_chart" style="width: 40%%;height: auto;"></div></td><td><div id="gauge_chart" style="width: 60%%;height: auto;"></div></td></tr></table>' "${nbOfActiveCases}" "${nbOfOpenCases}"
if [[ ! -z "${itShouldRingABell}" ]] ; then 
  printf '<div style="margin-top: 50px;display: none"><br><audio controls="controls" autoplay="autoplay"> <source src="dashboard/bell.mp3" type="audio/mpeg"> <source src="dashboard/bell.wav" type="audio/wav">Your browser does not support the audio element. </audio><br></div>'
fi
searchJql

maxResults="$(printf "%s\n" "${jira[response]}" |  jq '.maxResults')"
total="$(printf "%s\n" "${jira[response]}" |  jq '.total')"
index=0
printf '<table id="bugWorkList" class="fixed"><tbody><tr><th style="width: 90px;">Key</th><th style="width: 980px;">Summary</th><th style="width: 95px;">Status</th><th style="width: 210px;">Resolution</th><th style="width: 200px;">Updated</th><th style="width: 115px;">Version</th><th style="width: 129px;">Assignee</th></tr>'
# 80 + 650 + 145 + 145 + 210 + 145 +115
# 1490
# 80 + 800 + 95 + 210 + 200 + 115 +129
# 1820
# 80 | 145 | 80 | 210 | 115 | 650 | 300 | 125 |115
# 1820
while (( "${index}" < "${maxResults}" && "${index}" < "${total}" )) ; do
  key="$(printf "%s\n" "${jira[response]}" |  jq '.issues['"${index}"'].key' | sed 's/^.\(.*\).$/\1/' )"
  summary="$(printf "%s\n" "${jira[response]}" |  jq '.issues['"${index}"'].fields.summary' | sed -e 's/^.\(.*\).$/\1/' -e 's/[\]//g')"
  affectedVersions="$(printf "%s\n" "${jira[response]}" |  jq '.issues['"${index}"'].fields.versions[].name' | sed -e 's/'\"'//g' -e 's/ /, /g')"
  assignee="$(printf "%s\n" "${jira[response]}" |  jq '.issues['"${index}"'].fields.assignee.displayName' | sed 's/^.\(.*\).$/\1/' )"
  if [ ! -z "${assignee}" ] ; then
    assignee="${assignee%% *}"
  fi
  status="$(printf "%s\n" "${jira[response]}" |  jq '.issues['"${index}"'].fields.status.name' | sed 's/^.\(.*\).$/\1/' )"
  resolution="$(printf "%s\n" "${jira[response]}" |  jq '.issues['"${index}"'].fields.resolution.name')"
  if [[ "${resolution}" = "null" ]] ; then
    resolution=""
  else
    resolution="$(printf "%s" "${resolution}" | sed 's/^.\(.*\).$/\1/' )"
  fi
  updatedDateTime="$(printf "%s\n" "${jira[response]}" |  jq '.issues['"${index}"'].fields.updated' | sed 's/^.\(.*\).$/\1/' )"
  printf '<tr class="s3_sla_td"><td>%s</td><td style="max-width:980px;">%s</td><td style="max-width:95px;">%s</td><td style="max-width:210px;">%s</td><td style="max-width:200px;"><script type="text/javascript">document.write(formatInBrowserTZISODateString("%s"));</script></td><td style="max-width:115px;">%s</td><td style="max-width:129px;">%s</td></tr>' "${key}" "${summary}" "${status}" "${resolution}" "${updatedDateTime}" "${affectedVersions}" "${assignee}"
  index=$((index + 1))
done
printf '</tbody></table></div>'
if (( "${index}" < "${total}" )) ; then
  nbNotDisplayed=$(( total - index ))
  if (( "${nbNotDisplayed}" == 1 )) ; then
    printf '<div style="color:red;text-align: center; vertical-align: middle;">%s bug is not listed</div>' "${nbNotDisplayed}"
  else

    printf '<div style="color:red;text-align: center; vertical-align: middle;">%s bugs are not listed</div>' "${nbNotDisplayed}"
  fi
fi
printf '</body></html>'
#printf 'jira[exit_status]=%s\njira[http_code]=%s\njira[response]=%s\n'  "${jira[exit_status]}" "${jira[http_code]}" "${jira[response]}" >&2

