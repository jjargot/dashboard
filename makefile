
PROJECT := dashboard

all: test target/$(PROJECT).zip
.PHONY : clean all test create-empty-test-environment

test: 
	$(MAKE) --directory test 

test/test.environment: 
	cp test/test-template.environment test/test.environment && printf "Edit test/test.environment\n"

create-empty-test-environment: test/test.environment
	:


target/$(PROJECT).zip: 
	mkdir -p target/usr/lib/cgi-bin target/var/www/ &&\
		cp -r src/bin target/usr/lib/cgi-bin/$(PROJECT) &&\
		cp -r src/lib target/usr/lib/cgi-bin/$(PROJECT) &&\
		rm -rf target/var/www/$(PROJECT) &&\
		cp -r src/resources target/var/www/$(PROJECT) &&\
		cd target &&\
		zip -9r $(PROJECT).zip *

clean:
	-rm -rf target test/test.tst
	make -C test clean
 
	


# test: test/test.tst
# install-test-environment: |../test.environment
#
#test/test.tst: 
#	$(MAKE) --directory test all && if [ ! -f $@ ] ; then touch $@ ; fi	  

