# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit python-r1 multiprocessing pax-utils qmake-utils virtualx

DESCRIPTION="A headless WebKit scriptable with a JavaScript API"
HOMEPAGE="http://phantomjs.org"
SRC_URI="https://github.com/ariya/phantomjs/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test examples"

# http://phantomjs.org/build.html - says pretty much nothing
# https://anonscm.debian.org/cgit/collab-maint/phantomjs.git/tree/debian
RDEPEND="
	>=dev-qt/qtcore-5.5:5
	>=dev-qt/qtwebkit-5.5:5
	>=dev-qt/qtwidgets-5.5:5
	>=dev-qt/qtprintsupport-5.5:5
	>=dev-qt/qtnetwork-5.5:5
	>=dev-qt/qtgui-5.5:5

	dev-libs/icu:=
	dev-libs/openssl:0
	sys-libs/zlib

	media-libs/mesa
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libpng:0=
	virtual/jpeg:0
"

DEPEND="${RDEPEND}
	${PYTHON_DEPS}

	x11-libs/libXext
	x11-libs/libX11

	test? ( dev-lang/ruby )
"

pkg_setup() {
	python_setup
}

src_prepare() {
	epatch "${FILESDIR}/phantomjs-no-ghostdriver.patch"
	epatch "${FILESDIR}/phantomjs-qt-components.patch"
	epatch "${FILESDIR}/phantomjs-qt55-evaluateJavaScript.patch"
	epatch "${FILESDIR}/phantomjs-qt55-no-websecurity.patch"
	epatch "${FILESDIR}/phantomjs-qt55-print.patch"

	# c&p from emake5()
	local qmake_args=(
		-makefile
		QMAKE_AR="$(tc-getAR) cqs"
		QMAKE_CC="$(tc-getCC)"
		QMAK_ELINK_C="$(tc-getCC)"
		QMAKE_LINK_C_SHLIB="$(tc-getCC)"
		QMAKE_CXX="$(tc-getCXX)"
		QMAKE_LINK="$(tc-getCXX)"
		QMAKE_LINK_SHLIB="$(tc-getCXX)"
		QMAKE_OBJCOPY="$(tc-getOBJCOPY)"
		QMAKE_RANLIB=
		QMAKE_STRIP=
		QMAKE_CFLAGS="${CFLAGS}"
		QMAKE_CFLAGS_RELEASE=
		QMAKE_CFLAGS_DEBUG=
		QMAKE_CXXFLAGS="${CXXFLAGS}"
		QMAKE_CXXFLAGS_RELEASE=
		QMAKE_CXXFLAGS_DEBUG=
		QMAKE_LFLAGS="${LDFLAGS}"
		QMAKE_LFLAGS_RELEASE=
		QMAKE_LFLAGS_DEBUG=
	)

	sed -i -r \
		-e "s|qmake = qmakePath.*|qmake = \"$(qt5_get_bindir)/qmake\"|" \
		-e "s|command = \[qmake\].*|command = [qmake, $( printf '"%s",' "${qmake_args[@]}" )\"\"]|" \
		build.py || die

	default
}

src_compile() {
	local args=(
		'--confirm'
		'--release'
		'--jobs' $(makeopts_jobs)

		'--skip-git'
		'--skip-qtbase'
		'--skip-qtwebkit'
	)

	"$PYTHON" ./build.py "${args[@]}" || die
}

src_test() {
	virtx test/run-tests.py || die
}

src_install() {
	pax-mark m bin/phantomjs || die
	dobin bin/phantomjs

	dodoc ChangeLog README.md
	doman "${FILESDIR}/${PN}.1"

	if use examples; then
		docinto examples
		dodoc examples/*
	fi
}