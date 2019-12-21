SAM_PATH ?= "./bin/sam"
.PHONY: sam
sam:
	$(SAM_PATH) $(filter-out $@,$(MAKECMDGOALS))
%:
	@:
