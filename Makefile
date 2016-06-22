SCRIPT=shlog
VERSION=0.0.1

PREFIX=/usr/local
BINDIR=$(PREFIX)/bin
SHAREDIR=$(PREFIX)/share/$(SCRIPT)
MANDIR=$(PREFIX)/share/man/man1

CP = cp -rvfa
RM = rm -rfv
MKDIR = mkdir -p
RONN = ronn
PATH := $(PATH):./build-deps/shinclude
SHINCLUDE = shinclude

SCRIPT_SOURCES = \
				 src/shlog.bash \
				 src/shlog-reload.bash \
				 src/shlog-usage.bash \
				 src/shlog-dump.bash \
				 src/shlog-selfdebug.bash \
				 src/shlog-pipe.bash \
				 src/shlog-profile.bash \
				 src/shlog-main.bash

PHONY: build-deps dist

#
# Install
#

install: dist
	mkdir -p $(BINDIR)
	$(CP) $(SCRIPT) $(BINDIR)/$(SCRIPT)
	chmod a+x $(BINDIR)/$(SCRIPT)
	$(MKDIR) $(MANDIR) && $(CP) -t $(MANDIR) $(SCRIPT).1
	$(MKDIR) $(SHAREDIR) && cp -t $(SHAREDIR) README.md LICENSE

#
# Uninstall
#

uninstall:
	rm -f $(BINDIR)/$(SCRIPT)
	rm -f $(MANDIR)/$(SCRIPT).1
	rm -rf $(SHAREDIR)

#
# Build
#

dist: build-deps $(SCRIPT) $(SCRIPT).1 README.md

$(SCRIPT): $(SCRIPT_SOURCES)
	cat $(SCRIPT_SOURCES) > "$@"
	chmod a+x "$@"

$(SCRIPT).1: doc/$(SCRIPT).1.md $(SCRIPT)
	$(SHINCLUDE) -c markdown doc/$(SCRIPT).1.md \
		| $(RONN) --date=`date -I` --name="shlog" --pipe --roff \
		> "$@"

README.md: $(wildcard doc/* src/*)
	$(SHINCLUDE) -c xml doc/README.md > README.md

#
# Test
#

test: $(SCRIPT)
	./test/tsht

#
# Clean
#

clean:
	$(RM) $(SCRIPT) $(SCRIPT).1

realclean: clean
	$(RM) README.md build-deps

#
# Build dependencies
#

build-deps: build-deps/shinclude
	@which ronn >/dev/null || { \
		which gem >/dev/null  || { \
			echo "Ruby is required for ronn."; exit 1; }; \
		gem install --user-install ronn; }

build-deps/shinclude:
	git clone https://github.com/kba/shinclude "$@"
