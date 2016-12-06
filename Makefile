
master  = $(shell echo "$(CURDIR)" | sed -e s/.gh-pages//)

target  = index.html

main    = README.md
license = LICENSE
coc     = code_of_conduct.md

sources = $(main) $(license) $(coc)

markdown = ./markdown

.PHONY: all
all: $(target)

$(target): $(sources) head tail
	cat head > $@.tmp
	$(markdown) $(main) >> $@.tmp
	echo -n '<pre id="license" class="no-highlight">' >> $@.tmp
	cat $(license) >> $@.tmp
	echo '</pre>' >> $@.tmp
	$(markdown) $(coc) >> $@.tmp
	cat tail >> $@.tmp
	mv $@.tmp $@

define FROM_MASTER
$(1): $(master)/$(1)
	cp $< $@
endef
$(foreach source,$(sources),$(eval $(call FROM_MASTER,$(source))))

