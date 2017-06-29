# dashboard
## Dependencies

    $ sudo apt install curl

## Download

    $ git clone https://github.com/jjargot/dashboard

## Setup
    $ cd dashboard
    $ make create-empty-test-environment
### Edit test/test.environment file
provide all connection informaiton etc. for the test
## Test and Build
    $ make all

## Troubleshoot

    $ make all
    make --directory test 
    make[1]: Entering directory '/home/jjargot/Documents/project/dashboard/study/dev/dashboard/test'
    make[1]: *** No rule to make target 'atlassian-JIRA.tst', needed by 'test'.  Stop.
    make[1]: Leaving directory '/home/jjargot/Documents/project/dashboard/study/dev/dashboard/test'
    makefile:8: recipe for target 'test' failed
    make: *** [test] Error 2

Explanation: the test/test.environment file is missing, see Setup section

