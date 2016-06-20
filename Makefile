SCRIPT=shlog
VERSION=0.0.1

PREFIX=/usr/local
BINDIR=$(PREFIX)/bin
SHAREDIR=$(PREFIX)/share/$(PKG_NAME)
MANDIR=$(PREFIX)/share/man/man1

CP = cp -rvf
MKDIR = mkdir -p
RONN = ronn
SHINCLUDE = ./build-deps/shinclude/shinclude

.PHONY: README.md

all: $(SCRIPT) README.md shlog.1

$(SCRIPT).1: $(SCRIPT).1.md $(SCRIPT)
	$(SHINCLUDE) -i -c markdown shlog.1.md
	$(RONN) --date=`date -I` --name="shlog" --roff shlog.1.md

README.md: doc/README.md 
	$(SHINCLUDE) -c xml "$<" > "$@"

install: all
	mkdir -p $(BINDIR)
	$(SHINCLUDE) $(SCRIPT) > $(BINDIR)/$(SCRIPT)
	chmod a+x $(BINDIR)/$(SCRIPT)
	$(MKDIR) $(MANDIR) && $(CP) -t $(MANDIR) $(SCRIPT).1
	$(MKDIR) $(SHAREDIR) && cp -t $(SHAREDIR) README.md LICENSE

uninstall:
	rm -f $(BINDIR)/$(SCRIPT)
	rm -f $(MANDIR)/$(SCRIPT).1
	rm -rf $(SHAREDIR)

test:
	./test/tsht
