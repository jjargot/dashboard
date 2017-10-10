#!/bin/bash --

#./test-dashboard.sh test.environment ../src/bin/dashboard.sh dashboard.tst 

testsuite="${0%.*}";testsuite="${testsuite##*/test-}"
export testsuite

HTML_RESOURCES_DIR="${PWD}"/../resources
export HTML_RESOURCES_DIR
CONFIG_DIR="${PWD}"
export CONFIG_DIR
LIB_DIR=../src/lib
export LIB_DIR
CONFIGURATION_FILE="${PWD}"/"${1}"
export CONFIGURATION_FILE
BUILD_DIR=dashboard_htmlfiles
if [ ! -d "${BUILD_DIR}" ] ; then
  mkdir "${BUILD_DIR}"
fi

unset TEST_DASHBOARD
TEST_DASHBOARD=yes
export TEST_DASHBOARD

# empty cache
rm -rf /tmp/dashboard.cache/

htmlFile="${BUILD_DIR}"/dashboard1.html
printf "%s->Production condition -> %s " "${testsuite}" "${htmlFile}"
DBG=ALL "${2}" > "${htmlFile}"
printf " - done \n"
# save for debug
cp /tmp/dashboard.cache/salesforceRequest.last /tmp/dashboard.cache/salesforceRequest.test1

htmlFile="${BUILD_DIR}"/dashboard2.html
touch /tmp/dashboard.cache/*
printf "%s->Reuse the cache -> %s " "${testsuite}" "${htmlFile}"
"${2}" > "${htmlFile}"
printf " - done \n"

htmlFile="${BUILD_DIR}"/dashboard3.html
printf "%s->Long list of JIRA bugs -> %s " "${testsuite}" "${htmlFile}"
printf '{ "issues": {"expand":"names,schema","startAt":0,"maxResults":5,"total":6,"issues":[{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"43433","self":"https://bonitasoft.atlassian.net/rest/api/2/issue/43433","key":"BS-15248","fields":{"summary":"NPE","customfield_10502":"00017984 https://c.eu4.visual.force.com/apex/CaseView?id=50057000019s57W&sfdc.override=1","versions":[{"self":"https://bonitasoft.atlassian.net/rest/api/2/version/23700","id":"23700","description":"OoE 31/3","name":"7.2.2","archived":false,"released":true,"releaseDate":"2016-03-31"},{"self":"https://bonitasoft.atlassian.net/rest/api/2/version/24104","id":"24104","description":"OoE 2/05, GA 3/05","name":"7.2.3","archived":false,"released":true,"releaseDate":"2016-05-03"}],"assignee":{"self":"https://bonitasoft.atlassian.net/rest/api/2/user?username=poorav.chaudhari","name":"poorav.chaudhari","key":"poorav.chaudhari","accountId":"557058:88281f91-f129-42d7-99b8-45e9943519a8","emailAddress":"poorav.chaudhari@bonitasoft.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=48&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3FavatarId%%3D10122%%26noRedirect%%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=24&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3Fsize%%3Dsmall%%26avatarId%%3D10122%%26noRedirect%%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=16&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3Fsize%%3Dxsmall%%26avatarId%%3D10122%%26noRedirect%%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=32&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3Fsize%%3Dmedium%%26avatarId%%3D10122%%26noRedirect%%3Dtrue"},"displayName":"Poorav Chaudhari","active":true,"timeZone":"Europe/Paris"},"updated":"2017-04-07T13:56:30.000+0200","resolution":{"self":"https://bonitasoft.atlassian.net/rest/api/2/resolution/5","id":"5","description":"All attempts at reproducing this issue failed, or not enough information was available to reproduce the issue. Reading the code produces no clues as to why this behavior would occur. If more information appears later, please reopen the issue.","name":"Cannot Reproduce"},"status":{"self":"https://bonitasoft.atlassian.net/rest/api/2/status/5","description":"A resolution has been taken, and it is awaiting verification by reporter. From here issues are either reopened, or are closed.","iconUrl":"https://bonitasoft.atlassian.net/images/icons/statuses/resolved.png","name":"Resolved","id":"5","statusCategory":{"self":"https://bonitasoft.atlassian.net/rest/api/2/statuscategory/3","id":3,"key":"done","colorName":"green","name":"Done"}}}},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"43433","self":"https://bonitasoft.atlassian.net/rest/api/2/issue/43433","key":"BS-15248","fields":{"summary":"Select widget Placeholder not displayed correctly at first in IE9 an IE10","customfield_10502":"00017984 https://c.eu4.visual.force.com/apex/CaseView?id=50057000019s57W&sfdc.override=1","versions":[{"self":"https://bonitasoft.atlassian.net/rest/api/2/version/23700","id":"23700","description":"OoE 31/3","name":"7.2.2","archived":false,"released":true,"releaseDate":"2016-03-31"},{"self":"https://bonitasoft.atlassian.net/rest/api/2/version/24104","id":"24104","description":"OoE 2/05, GA 3/05","name":"7.2.3","archived":false,"released":true,"releaseDate":"2016-05-03"}],"assignee":{"self":"https://bonitasoft.atlassian.net/rest/api/2/user?username=poorav.chaudhari","name":"poorav.chaudhari","key":"poorav.chaudhari","accountId":"557058:88281f91-f129-42d7-99b8-45e9943519a8","emailAddress":"poorav.chaudhari@bonitasoft.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=48&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3FavatarId%%3D10122%%26noRedirect%%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=24&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3Fsize%%3Dsmall%%26avatarId%%3D10122%%26noRedirect%%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=16&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3Fsize%%3Dxsmall%%26avatarId%%3D10122%%26noRedirect%%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=32&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3Fsize%%3Dmedium%%26avatarId%%3D10122%%26noRedirect%%3Dtrue"},"displayName":"Poorav Chaudhari","active":true,"timeZone":"Europe/Paris"},"updated":"2017-04-07T13:56:30.000+0200","resolution":{"self":"https://bonitasoft.atlassian.net/rest/api/2/resolution/5","id":"5","description":"All attempts at reproducing this issue failed, or not enough information was available to reproduce the issue. Reading the code produces no clues as to why this behavior would occur. If more information appears later, please reopen the issue.","name":"Unresolved"},"status":{"self":"https://bonitasoft.atlassian.net/rest/api/2/status/5","description":"A resolution has been taken, and it is awaiting verification by reporter. From here issues are either reopened, or are closed.","iconUrl":"https://bonitasoft.atlassian.net/images/icons/statuses/resolved.png","name":"Open","id":"5","statusCategory":{"self":"https://bonitasoft.atlassian.net/rest/api/2/statuscategory/3","id":3,"key":"done","colorName":"green","name":"Done"}}}},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"43433","self":"https://bonitasoft.atlassian.net/rest/api/2/issue/43433","key":"BS-15248","fields":{"summary":"Select widget Placeholder not displayed correctly at first in IE9 an IE10","customfield_10502":"00017984 https://c.eu4.visual.force.com/apex/CaseView?id=50057000019s57W&sfdc.override=1","versions":[{"self":"https://bonitasoft.atlassian.net/rest/api/2/version/23700","id":"23700","description":"OoE 31/3","name":"7.2.2","archived":false,"released":true,"releaseDate":"2016-03-31"},{"self":"https://bonitasoft.atlassian.net/rest/api/2/version/24104","id":"24104","description":"OoE 2/05, GA 3/05","name":"7.2.3","archived":false,"released":true,"releaseDate":"2016-05-03"}],"assignee":{"self":"https://bonitasoft.atlassian.net/rest/api/2/user?username=poorav.chaudhari","name":"poorav.chaudhari","key":"poorav.chaudhari","accountId":"557058:88281f91-f129-42d7-99b8-45e9943519a8","emailAddress":"poorav.chaudhari@bonitasoft.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=48&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3FavatarId%%3D10122%%26noRedirect%%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=24&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3Fsize%%3Dsmall%%26avatarId%%3D10122%%26noRedirect%%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=16&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3Fsize%%3Dxsmall%%26avatarId%%3D10122%%26noRedirect%%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=32&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3Fsize%%3Dmedium%%26avatarId%%3D10122%%26noRedirect%%3Dtrue"},"displayName":"Poorav Chaudhari","active":true,"timeZone":"Europe/Paris"},"updated":"2017-04-07T13:56:30.000+0200","resolution":{"self":"https://bonitasoft.atlassian.net/rest/api/2/resolution/5","id":"5","description":"All attempts at reproducing this issue failed, or not enough information was available to reproduce the issue. Reading the code produces no clues as to why this behavior would occur. If more information appears later, please reopen the issue.","name":"Cannot Reproduce"},"status":{"self":"https://bonitasoft.atlassian.net/rest/api/2/status/5","description":"A resolution has been taken, and it is awaiting verification by reporter. From here issues are either reopened, or are closed.","iconUrl":"https://bonitasoft.atlassian.net/images/icons/statuses/resolved.png","name":"Resolved","id":"5","statusCategory":{"self":"https://bonitasoft.atlassian.net/rest/api/2/statuscategory/3","id":3,"key":"done","colorName":"green","name":"Done"}}}},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"43433","self":"https://bonitasoft.atlassian.net/rest/api/2/issue/43433","key":"BS-15248","fields":{"summary":"Select widget Placeholder not displayed correctly at first in IE9 an IE10","customfield_10502":"00017984 https://c.eu4.visual.force.com/apex/CaseView?id=50057000019s57W&sfdc.override=1","versions":[{"self":"https://bonitasoft.atlassian.net/rest/api/2/version/23700","id":"23700","description":"OoE 31/3","name":"7.2.2","archived":false,"released":true,"releaseDate":"2016-03-31"},{"self":"https://bonitasoft.atlassian.net/rest/api/2/version/24104","id":"24104","description":"OoE 2/05, GA 3/05","name":"7.2.3","archived":false,"released":true,"releaseDate":"2016-05-03"}],"assignee":{"self":"https://bonitasoft.atlassian.net/rest/api/2/user?username=poorav.chaudhari","name":"poorav.chaudhari","key":"poorav.chaudhari","accountId":"557058:88281f91-f129-42d7-99b8-45e9943519a8","emailAddress":"poorav.chaudhari@bonitasoft.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=48&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3FavatarId%%3D10122%%26noRedirect%%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=24&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3Fsize%%3Dsmall%%26avatarId%%3D10122%%26noRedirect%%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=16&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3Fsize%%3Dxsmall%%26avatarId%%3D10122%%26noRedirect%%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=32&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3Fsize%%3Dmedium%%26avatarId%%3D10122%%26noRedirect%%3Dtrue"},"displayName":"Poorav Chaudhari","active":true,"timeZone":"Europe/Paris"},"updated":"2017-04-07T13:56:30.000+0200","resolution":{"self":"https://bonitasoft.atlassian.net/rest/api/2/resolution/5","id":"5","description":"All attempts at reproducing this issue failed, or not enough information was available to reproduce the issue. Reading the code produces no clues as to why this behavior would occur. If more information appears later, please reopen the issue.","name":"Cannot Reproduce"},"status":{"self":"https://bonitasoft.atlassian.net/rest/api/2/status/5","description":"A resolution has been taken, and it is awaiting verification by reporter. From here issues are either reopened, or are closed.","iconUrl":"https://bonitasoft.atlassian.net/images/icons/statuses/resolved.png","name":"Resolved","id":"5","statusCategory":{"self":"https://bonitasoft.atlassian.net/rest/api/2/statuscategory/3","id":3,"key":"done","colorName":"green","name":"Done"}}}},{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"43433","self":"https://bonitasoft.atlassian.net/rest/api/2/issue/43433","key":"BS-15248","fields":{"summary":"Select widget Placeholder not displayed correctly at first in IE9 an IE10","customfield_10502":"00017984 https://c.eu4.visual.force.com/apex/CaseView?id=50057000019s57W&sfdc.override=1","versions":[{"self":"https://bonitasoft.atlassian.net/rest/api/2/version/23700","id":"23700","description":"OoE 31/3","name":"7.2.2","archived":false,"released":true,"releaseDate":"2016-03-31"},{"self":"https://bonitasoft.atlassian.net/rest/api/2/version/24104","id":"24104","description":"OoE 2/05, GA 3/05","name":"7.2.3","archived":false,"released":true,"releaseDate":"2016-05-03"},{"self":"https://bonitasoft.atlassian.net/rest/api/2/version/22200","id":"22200","description":"OoE 78/09","name":"7.2.1","archived":false,"released":true,"releaseDate":"2015-05-05"}],"assignee":{"self":"https://bonitasoft.atlassian.net/rest/api/2/user?username=poorav.chaudhari","name":"poorav.chaudhari","key":"poorav.chaudhari","accountId":"557058:88281f91-f129-42d7-99b8-45e9943519a8","emailAddress":"poorav.chaudhari@bonitasoft.com","avatarUrls":{"48x48":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=48&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3FavatarId%%3D10122%%26noRedirect%%3Dtrue","24x24":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=24&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3Fsize%%3Dsmall%%26avatarId%%3D10122%%26noRedirect%%3Dtrue","16x16":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=16&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3Fsize%%3Dxsmall%%26avatarId%%3D10122%%26noRedirect%%3Dtrue","32x32":"https://avatar-cdn.atlassian.com/7db78cad785886131b1fc16a701fb2cb?s=32&d=https%%3A%%2F%%2Fbonitasoft.atlassian.net%%2Fsecure%%2Fuseravatar%%3Fsize%%3Dmedium%%26avatarId%%3D10122%%26noRedirect%%3Dtrue"},"displayName":"Poorav Chaudhari","active":true,"timeZone":"Europe/Paris"},"updated":"2017-04-07T13:56:30.000+0200","resolution":{"self":"https://bonitasoft.atlassian.net/rest/api/2/resolution/5","id":"5","description":"All attempts at reproducing this issue failed, or not enough information was available to reproduce the issue. Reading the code produces no clues as to why this behavior would occur. If more information appears later, please reopen the issue.","name":"Cannot Reproduce"},"status":{"self":"https://bonitasoft.atlassian.net/rest/api/2/status/5","description":"A resolution has been taken, and it is awaiting verification by reporter. From here issues are either reopened, or are closed.","iconUrl":"https://bonitasoft.atlassian.net/images/icons/statuses/resolved.png","name":"Resolved","id":"5","statusCategory":{"self":"https://bonitasoft.atlassian.net/rest/api/2/statuscategory/3","id":3,"key":"done","colorName":"green","name":"Done"}}}}]} , "patches": {"startAt":0,"maxResults":0,"total":10,"issues":[]} }\n' > /tmp/dashboard.cache/jiraRequest.last
"${2}" > "${htmlFile}"
printf " - done \n"

htmlFile="${BUILD_DIR}"/dashboard4.html
touch /tmp/dashboard.cache/*
printf "%s->Long list of SF cases -> %s " "${testsuite}" "${htmlFile}"
printf '{ "serverUrl": "https://eu4.salesforce.com/services/Soap/c/26.0/00D20000000NBwJ/0DFD00000000uIk", "response" : {"hasErrors":false,"results":[{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Service_Requests":15}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Incident_Requests":25}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Usage_Questions":1}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_S1":4}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_S2":9}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_S3":29}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_of_Cases_With_SLADeadLine_Before_Next_French_Office_Opening":1}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Open_Cases_With_Bugs":116}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Old_Cases_Without_Bug":61}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Old_Cases":61}]}},{"statusCode":200,"result":
{"totalSize":10,"done":true,"records":[{"attributes":{"type":"Case","url":"/services/data/v40.0/sobjects/Case/5005700001XgsguAAB"},"CaseNumber":"00020224","Subscription__c":"a0b5700000BrCu8AAF","Status":"Logged","Severity__c":"S3","SLA_Deadline__c":"%s.000+0000","IssueTweet__c":null,"Owner":{"attributes":{"type":"Name","url":"/services/data/v40.0/sobjects/Group/00GD0000001BJazMAG"},"FirstName":null},"Subject":"ThemeAPI: setCustomTheme demande un cssContent","Account":{"attributes":{"type":"Account","url":"/services/data/v40.0/sobjects/Account/001D000000gYbuDIAS"},"Name":"Canton de Vaud / Etat de Vaud"},"Contact":{"attributes":{"type":"Contact","url":"/services/data/v40.0/sobjects/Contact/003D000001Gv5UKIAZ"},"LastName":"Vigniel","Name":"Richard Vigniel"},"LastSupportCommentBy__c":null,"LastActiveStatusDateTime__c":"2017-09-13T13:21:53.000+0000","LastCaseCommentFromBonitaSoft__c":null,"LastPublicCommentDateTime__c":"2017-09-13T13:21:51.000+0000","IssueNotFixedYet__c":false,"IsEscalated":true},{"attributes":{"type":"Case","url":"/services/data/v40.0/sobjects/Case/5005700001Xf5xeAAB"},"CaseNumber":"00020189","Subscription__c":"a0b5700000BrCu8AAF","Status":"In Progress","Severity__c":"S2","SLA_Deadline__c":null,"IssueTweet__c":null,"Owner":{"attributes":{"type":"Name","url":"/services/data/v40.0/sobjects/Group/00GD0000001BJazMAG"},"FirstName":null},"Subject":"message d'\''erreur 500","Account":{"attributes":{"type":"Account","url":"/services/data/v40.0/sobjects/Account/0015700001rvk5zAAA"},"Name":"Vinci Construction"},"Contact":{"attributes":{"type":"Contact","url":"/services/data/v40.0/sobjects/Contact/0035700002Bify5AAB"},"LastName":"Marie-Christine","Name":"Tony Gabilleau"},"LastSupportCommentBy__c":"Unai Gaston Caminos","LastActiveStatusDateTime__c":"2017-09-12T14:15:05.000+0000","LastCaseCommentFromBonitaSoft__c":"2017-08-31T13:38:44.000+0000","LastPublicCommentDateTime__c":"2017-09-12T14:15:05.000+0000","IssueNotFixedYet__c":false,"IsEscalated":true},{"attributes":{"type":"Case","url":"/services/data/v40.0/sobjects/Case/5005700001XgtaxAAB"},"CaseNumber":"00020225","Subscription__c":"a0b5700000BrCu8AAF","Status":"In Progress","Severity__c":"S1","SLA_Deadline__c":"%s.000+0000","IssueTweet__c":null,"Owner":{"attributes":{"type":"Name","url":"/services/data/v40.0/sobjects/Group/00GD0000001BJazMAG"},"FirstName":null},"Subject":"Data table doesn'\''t show records in given order in chrome","Account":{"attributes":{"type":"Account","url":"/services/data/v40.0/sobjects/Account/001D000000z70XXIAY"},"Name":"Saint-Gobain Isover"},"Contact":{"attributes":{"type":"Contact","url":"/services/data/v40.0/sobjects/Contact/003570000203fH5AAI"},"LastName":"Dhage","Name":"Amit Dhage"},"LastSupportCommentBy__c":"Marielle Spiteri","LastActiveStatusDateTime__c":"2017-09-14T06:45:07.000+0000","LastCaseCommentFromBonitaSoft__c":"2017-09-13T16:48:47.000+0000","LastPublicCommentDateTime__c":"2017-09-14T06:45:06.000+0000","IssueNotFixedYet__c":false,"IsEscalated":false},{"attributes":{"type":"Case","url":"/services/data/v40.0/sobjects/Case/5005700001Xf5xeAAB"},"CaseNumber":"00020988","Subscription__c":"a0b5700000BrCu8AAF","Status":"In Progress","Severity__c":"S3","SLA_Deadline__c":"%s.000+0000","IssueTweet__c":null,"Owner":{"attributes":{"type":"Name","url":"/services/data/v40.0/sobjects/Group/00GD0000001BJazMAG"},"FirstName":null},"Subject":"message d'\''erreur 500","Account":{"attributes":{"type":"Account","url":"/services/data/v40.0/sobjects/Account/0015700001rvk5zAAA"},"Name":"Vinci Construction"},"Contact":{"attributes":{"type":"Contact","url":"/services/data/v40.0/sobjects/Contact/0035700002Bify5AAB"},"LastName":"Gabilleau","Name":"Tony Gabilleau"},"LastSupportCommentBy__c":"Unai Gaston Caminos","LastActiveStatusDateTime__c":"2017-09-12T14:15:05.000+0000","LastCaseCommentFromBonitaSoft__c":"2017-08-31T13:38:44.000+0000","LastPublicCommentDateTime__c":"2017-09-12T14:15:05.000+0000","IssueNotFixedYet__c":false,"IsEscalated":true},{"attributes":{"type":"Case","url":"/services/data/v40.0/sobjects/Case/5005700001Xf5xeAAB"},"CaseNumber":"00019111","Subscription__c":"a0b5700000BrCu8AAF","Status":"In Progress","Severity__c":"S2","SLA_Deadline__c":"%s.000+0000","IssueTweet__c":null,"Owner":{"attributes":{"type":"Name","url":"/services/data/v40.0/sobjects/Group/00GD0000001BJazMAG"},"FirstName":null},"Subject":"message d'\''erreur 500","Account":{"attributes":{"type":"Account","url":"/services/data/v40.0/sobjects/Account/0015700001rvk5zAAA"},"Name":"Vinci Construction"},"Contact":{"attributes":{"type":"Contact","url":"/services/data/v40.0/sobjects/Contact/0035700002Bify5AAB"},"LastName":"Gabilleau","Name":"Tony Gabilleau"},"LastSupportCommentBy__c":"Unai Gaston Caminos","LastActiveStatusDateTime__c":"2017-09-12T14:15:05.000+0000","LastCaseCommentFromBonitaSoft__c":"2017-08-31T13:38:44.000+0000","LastPublicCommentDateTime__c":"2017-09-12T14:15:05.000+0000","IssueNotFixedYet__c":false,"IsEscalated":false},{"attributes":{"type":"Case","url":"/services/data/v40.0/sobjects/Case/5005700001Xf5xeAAB"},"CaseNumber":"00018777","Subscription__c":"a0b5700000BrCu8AAF","Status":"In Progress","Severity__c":"S1","SLA_Deadline__c":"%s.000+0000","IssueTweet__c":null,"Owner":{"attributes":{"type":"Name","url":"/services/data/v40.0/sobjects/Group/00GD0000001BJazMAG"},"FirstName":null},"Subject":"Not working","Account":{"attributes":{"type":"Account","url":"/services/data/v40.0/sobjects/Account/0015700001rvk5zAAA"},"Name":"Vinci Construction"},"Contact":{"attributes":{"type":"Contact","url":"/services/data/v40.0/sobjects/Contact/0035700002Bify5AAB"},"LastName":"Gabilleau","Name":"Tony Gabilleau"},"LastSupportCommentBy__c":"Unai Gaston Caminos","LastActiveStatusDateTime__c":"2017-09-12T14:15:05.000+0000","LastCaseCommentFromBonitaSoft__c":"2017-08-31T13:38:44.000+0000","LastPublicCommentDateTime__c":"2017-09-12T14:15:05.000+0000","IssueNotFixedYet__c":false,"IsEscalated":true},{"attributes":{"type":"Case","url":"/services/data/v40.0/sobjects/Case/5005700001Xf5xeAAB"},"CaseNumber":"00019010","Subscription__c":"a0b5700000BrCu8AAF","Status":"In Progress","Severity__c":"S3","SLA_Deadline__c":"%s.000+0000","IssueTweet__c":null,"Owner":{"attributes":{"type":"Name","url":"/services/data/v40.0/sobjects/Group/00GD0000001BJazMAG"},"FirstName":null},"Subject":"npe","Account":{"attributes":{"type":"Account","url":"/services/data/v40.0/sobjects/Account/0015700001rvk5zAAA"},"Name":"Vinci Construction"},"Contact":{"attributes":{"type":"Contact","url":"/services/data/v40.0/sobjects/Contact/0035700002Bify5AAB"},"LastName":"Gabilleau","Name":"Tony Gabilleau"},"LastSupportCommentBy__c":"Unai Gaston Caminos","LastActiveStatusDateTime__c":"2017-09-12T14:15:05.000+0000","LastCaseCommentFromBonitaSoft__c":"2017-08-31T13:38:44.000+0000","LastPublicCommentDateTime__c":"2017-09-12T14:15:05.000+0000","IssueNotFixedYet__c":false},{"attributes":{"type":"Case","url":"/services/data/v40.0/sobjects/Case/5005700001Xf5xeAAB"},"CaseNumber":"00021210","Subscription__c":"a0b5700000BrCu8AAF","Status":"In Progress","Severity__c":"S2","SLA_Deadline__c":"%s.000+0000","IssueTweet__c":null,"Owner":{"attributes":{"type":"Name","url":"/services/data/v40.0/sobjects/Group/00GD0000001BJazMAG"},"FirstName":null},"Subject":"message d'\''erreur 500","Account":{"attributes":{"type":"Account","url":"/services/data/v40.0/sobjects/Account/0015700001rvk5zAAA"},"Name":"Vinci Construction"},"Contact":{"attributes":{"type":"Contact","url":"/services/data/v40.0/sobjects/Contact/0035700002Bify5AAB"},"LastName":"Gabilleau","Name":"Tony Gabilleau"},"LastSupportCommentBy__c":"Unai Gaston Caminos","LastActiveStatusDateTime__c":"2017-09-12T14:15:05.000+0000","LastCaseCommentFromBonitaSoft__c":"2017-08-31T13:38:44.000+0000","LastPublicCommentDateTime__c":"2017-09-12T14:15:05.000+0000","IssueNotFixedYet__c":false,"IsEscalated":false},{"attributes":{"type":"Case","url":"/services/data/v40.0/sobjects/Case/5005700001Xf5xeAAB"},"CaseNumber":"00016666","Subscription__c":"a0b5700000BrCu8AAF","Status":"In Progress","Severity__c":"S1","SLA_Deadline__c":"%s.000+0000","IssueTweet__c":null,"Owner":{"attributes":{"type":"Name","url":"/services/data/v40.0/sobjects/Group/00GD0000001BJazMAG"},"FirstName":null},"Subject":"message d'\''erreur 500","Account":{"attributes":{"type":"Account","url":"/services/data/v40.0/sobjects/Account/0015700001rvk5zAAA"},"Name":"Vinci Construction"},"Contact":{"attributes":{"type":"Contact","url":"/services/data/v40.0/sobjects/Contact/0035700002Bify5AAB"},"LastName":"Gabilleau","Name":"Tony Gabilleau"},"LastSupportCommentBy__c":"Unai Gaston Caminos","LastActiveStatusDateTime__c":"%s.000+0000","LastCaseCommentFromBonitaSoft__c":"%s.000+0000","LastPublicCommentDateTime__c":"%s.000+0000","IssueNotFixedYet__c":false,"IsEscalated":true},{"attributes":{"type":"Case","url":"/services/data/v40.0/sobjects/Case/5005700001Xf5xeAAB"},"CaseNumber":"00014141","Subscription__c":"a0b5700000BrCu8AAF","Status":"In Progress","Severity__c":"S3","SLA_Deadline__c":"%s.000+0000","IssueTweet__c":null,"Owner":{"attributes":{"type":"Name","url":"/services/data/v40.0/sobjects/Group/00GD0000001BJazMAG"},"FirstName":null},"Subject":"message d'\''erreur 500, c'\''est pas possible d'\''avoir un tel probleme avec ce produit et en plus ce sujet est vraiment mais alors vraiment tres tres long.","Account":{"attributes":{"type":"Account","url":"/services/data/v40.0/sobjects/Account/0015700001rvk5zAAA"},"Name":"Vinci Construction"},"Contact":{"attributes":{"type":"Contact","url":"/services/data/v40.0/sobjects/Contact/0035700002Bify5AAB"},"LastName":"Gabilleau","Name":"Tony Gabilleau"},"LastSupportCommentBy__c":"Unai Gaston Caminos","LastActiveStatusDateTime__c":"%s.000+0000","LastCaseCommentFromBonitaSoft__c":"%s.000+0000","LastPublicCommentDateTime__c":"%s.000+0000","IssueNotFixedYet__c":false,"IsEscalated":false}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Cases_In_Worklist":15}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Open_Cases":143}]}},{"statusCode":200,"result":
  {"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Active_Cases":42}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Escalated_Cases":1}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Cases_Closed_Last_Two_Weeks":15}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Cases_Open_Last_Two_Weeks":19}]}}]}}\n' "$(date --iso-8601=seconds -d '+50 minutes' -u | cut -b 1-19 )" "$(date --iso-8601=seconds -d '+59 minutes' -u | cut -b 1-19 )" "$(date --iso-8601=seconds -d '+600 minutes' -u | cut -b 1-19 )"  "$(date --iso-8601=seconds -d '+1200 minutes' -u | cut -b 1-19 )" "$(date --iso-8601=seconds -d '+2400 minutes' -u | cut -b 1-19 )" "$(date --iso-8601=seconds -d '+3000 minutes' -u | cut -b 1-19 )" "$(date --iso-8601=seconds -d '+3600 minutes' -u | cut -b 1-19 )" "$(date --iso-8601=seconds -d '+3900 minutes' -u | cut -b 1-19 )" "$(date --iso-8601=seconds -d '+4000 minutes' -u | cut -b 1-19 )" "$(date --iso-8601=seconds -d '+4020 minutes' -u | cut -b 1-19 )" "$(date --iso-8601=seconds -d '+4040 minutes' -u | cut -b 1-19 )" "$(date --iso-8601=seconds -d '+4201 minutes' -u | cut -b 1-19 )" "$(date --iso-8601=seconds -d '+4100 minutes' -u | cut -b 1-19 )" "$(date --iso-8601=seconds -d '+4120 minutes' -u | cut -b 1-19 )" "$(date --iso-8601=seconds -d '+4140 minutes' -u | cut -b 1-19 )" > /tmp/dashboard.cache/salesforceRequest.last
"${2}" > "${htmlFile}"
printf " - done \n"

htmlFile="${BUILD_DIR}"/dashboard5.html
printf "%s->No cases and No bugs -> %s " "${testsuite}" "${htmlFile}"
printf '{ "issues": { "expand": "schema,names", "startAt": 0, "maxResults": 0, "total": 0, "issues": [] }, "patches": {"startAt":0,"maxResults":0,"total":0,"issues":[]} }\n' > /tmp/dashboard.cache/jiraRequest.last
printf '{ "serverUrl": "https://eu4.salesforce.com/services/Soap/c/26.0/00D20000000NBwJ/0DFD00000000uIk", "response" : {"hasErrors":false,"results":[{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Service_Requests":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Incident_Requests":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Usage_Questions":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_S1":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_S2":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_S3":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_of_Cases_With_SLADeadLine_Within_Next_18_Working_Hours":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Open_Cases_With_Bugs":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Old_Cases_Without_Bug":0}]}},{"statusCode":200,"result":
{"totalSize":0,"done":true,"records":[]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Cases_In_Worklist":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Open_Cases":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Active_Cases":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Escalated_Cases":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Cases_Closed_Last_Two_Weeks":0}]}},{"statusCode":200,"result":
{"totalSize":1,"done":true,"records":[{"attributes":{"type":"AggregateResult"},"Number_Of_Cases_Open_Last_Two_Weeks":0}]}}]} }\n' > /tmp/dashboard.cache/salesforceRequest.last
"${2}" > "${htmlFile}"
printf " - done \n"

touch "${3}"


