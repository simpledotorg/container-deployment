hosts = sample/playground
branch = master
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

.PHONY: help init all
# HELP sourced from https://gist.github.com/prwhite/8168133

# Add help text after each target name starting with '\#\#'
# A category can be added with @category
HELP_FUNC = \
    %help; \
    while(<>) { \
        if(/^([a-z0-9_-]+):.*\#\#(?:@(\w+))?\s(.*)$$/) { \
            push(@{$$help{$$2}}, [$$1, $$3]); \
        } \
    }; \
    print "usage: make [target] hosts=<sample/playground>\n\n"; \
    for ( sort keys %help ) { \
        print "$$_:\n"; \
        printf("  %-20s %s\n", $$_->[0], $$_->[1]) for @{$$help{$$_}}; \
        print "\n"; \
    }

help: ##@Miscellaneous Show this help.
	@perl -e '$(HELP_FUNC)' $(MAKEFILE_LIST)

init: ##@Setup Install ansible plugins and dependencies
	ansible-galaxy install -r requirements.yml
	ansible-galaxy collection install -r requirements.yml -p ~/.ansible/collections
	pip install jmespath

all: ##@Setup Install simple-server on hosts. Runs the all.yml playbook
	ansible-playbook $@.yml -i hosts/$(hosts)

debug: ##@Debug Fetch debug information from hosts
	ansible-playbook debug.yml -i hosts/$(hosts)
