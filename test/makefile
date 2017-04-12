
TEST_PROPS := test.environment
TESTS      := $(shell find ../src/ -type f -name \*.sh -printf '%f\n' | sed 's/[.]sh$$/.tst/')

.PHONY : clean test
test: $(TESTS)

%.tst: ../src/lib/%.sh ./test-%.sh $(TEST_PROPS)
	./test-$(subst .tst,.sh,$@) $(TEST_PROPS) $< $@ 

%.tst: ../src/bin/%.sh ./test-%.sh $(TEST_PROPS)
	./test-$(subst .tst,.sh,$@) $(TEST_PROPS) $< $@ 


clean :
	-rm -rf *~ $(TESTS)

