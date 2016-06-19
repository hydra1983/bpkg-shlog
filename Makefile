PKG_NAME=shlog
VERSION=0.0.1

PREFIX=/usr/local
BINDIR=$(PREFIX)/bin
SHAREDIR=$(PREFIX)/share/$(PKG_NAME)
MANDIR=$(PREFIX)/share/man/man1

.PHONY: README.md

shlog.1: shlog.1.md shlog.sh
	shinclude -i -c markdown shlog.1.md
	ronn --date=`date -I` --name="shlog" --roff shlog.1.md

README.md:
	shinclude -i -c xml README.md

install: shlog.sh README.md shlog.1
	mkdir -p $(BINDIR)
	shinclude shlog.sh > $(BINDIR)/shlog
	chmod a+x $(BINDIR)/shlog
	mkdir -p $(MANDIR)
	cp shlog.1 $(MANDIR)
	mkdir -p $(SHAREDIR)
	cp README.md $(SHAREDIR)
	cp LICENSE $(SHAREDIR)

uninstall:
	rm -f $(BINDIR)/shlog
	rm -f $(MANDIR)/shlog.1
	rm -rf $(SHAREDIR)

test:
	./test/tsht
