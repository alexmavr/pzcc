# A recursive makefile for all subdirectories of the project.

SUBDIRS = source library
CLEAN_DIRS = $(SUBDIRS:%=clean-%)
DISTCLEAN_DIRS = $(SUBDIRS:%=distclean-%)
INSTALL_DIRS = $(SUBDIRS:%=install-%)
UNINSTALL_DIRS = $(SUBDIRS:%=uninstall-%)

.PHONY: build clean distclean install uninstall
.PHONY: $(SUBDIRS) $(CLEAN_DIRS) $(DISTCLEAN_DIRS) $(INSTALL_DIRS) $(UNINSTALL_DIRS)

build: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

clean: $(CLEAN_DIRS)
$(CLEAN_DIRS):
	$(MAKE) -C $(@:clean-%=%) clean

distclean: $(DISTCLEAN_DIRS)
$(DISTCLEAN_DIRS):
	$(MAKE) -C $(@:distclean-%=%) distclean

install: $(INSTALL_DIRS)
$(INSTALL_DIRS):
	$(MAKE) -C $(@:install-%=%) install

uninstall: $(UNINSTALL_DIRS)
$(UNINSTALL_DIRS):
	$(MAKE) -C $(@:uninstall-%=%) uninstall
