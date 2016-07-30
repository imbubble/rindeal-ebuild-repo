# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI='6'

PYTHON_COMPAT=( python2_7 )

DISTUTILS_SINGLE_IMPL=true

inherit distutils-r1 eutils systemd

DESCRIPTION='BitTorrent client with a client/server model'
HOMEPAGE='http://deluge-torrent.org/'
LICENSE='GPL-2'

SLOT='0'
SRC_URI="http://git.deluge-torrent.org/deluge/snapshot/${P}.tar.bz2"

KEYWORDS='~amd64 ~arm ~x86'
IUSE='console +daemon geoip +gtk +libnotify +setproctitle +sound webui'

CDEPEND="daemon? ( <net-libs/libtorrent-rasterbar-1.1:0[python,${PYTHON_USEDEP}] )"
DEPEND="${CDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-util/intltool"
RDEPEND="${CDEPEND}
	dev-python/chardet[${PYTHON_USEDEP}]
	dev-python/pyopenssl[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	>=dev-python/twisted-core-8.1[${PYTHON_USEDEP}]
	>=dev-python/twisted-web-8.1[${PYTHON_USEDEP}]

	geoip? ( dev-libs/geoip )
	gtk? (
		libnotify? ( dev-python/notify-python[${PYTHON_USEDEP}] )
		sound? ( dev-python/pygame[${PYTHON_USEDEP}] )
		dev-python/pygobject:2[${PYTHON_USEDEP}]
		>=dev-python/pygtk-2.12:2[${PYTHON_USEDEP}]
		gnome-base/librsvg
	)
	setproctitle? ( dev-python/setproctitle[${PYTHON_USEDEP}] )
	webui? ( dev-python/mako[${PYTHON_USEDEP}] )"

REQUIRED_USE='
	sound? ( gtk )
	libnotify? ( gtk )
	|| ( console daemon gtk webui )'

PLOCALES=( af ar ast be bg bn bs ca cs cy da de el en_AU en_CA en_GB eo es et eu fa fi fo fr fy ga gl
	he hi hr hu id is it ja ka kk km kn ko ku ky la lb lt lv mk ml ms nb nds nl nn oc pl pt pt_BR ro
	ru si sk sl sr sv ta te th tl tlh tr uk ur vi zh_CN zh_HK zh_TW )
PLOCALES_MASK=( nap pms iu )
inherit l10n

python_prepare_all() {
	eapply "${FILESDIR}/1.3.12-Scheduler_Revert_erroneous_fix_backported_from_develop_branch.patch"

	local args

	args=(
		-e 's|build_libtorrent = True|build_libtorrent = False|'
		-e "/Compiling po file/a \\\tuptoDate = False" )
	sed -i "${args[@]}" \
        -- 'setup.py' || die
	args=(
		-e 's|"new_release_check": True|"new_release_check": False|'
		-e 's|"check_new_releases": True|"check_new_releases": False|'
		-e 's|"show_new_releases": True|"show_new_releases": False|' )
	sed -i "${args[@]}" \
        -- 'deluge/core/preferencesmanager.py' || die

	local loc_dir='deluge/i18n' loc_pre='' loc_post='.po'
	l10n_find_plocales_changes "${loc_dir}" "${loc_pre}" "${loc_post}"
	rm_loc() {
		rm -vf "${loc_dir}/${loc_pre}${1}${loc_post}" || die
	}
	l10n_for_each_disabled_locale_do rm_loc

	distutils-r1_python_prepare_all
}

esetup.py() {
	# bug 531370: deluge has its own plugin system. No need to relocate its egg info files.
	# Override this call from the distutils-r1 eclass.
	# This does not respect the distutils-r1 API. DO NOT copy this example.
	set -- "${PYTHON}" setup.py "$@"
	echo "$@"
	"$@" || die
}

python_install_all() {
	distutils-r1_python_install_all

	local rm_paths=()

	if use daemon ; then
		newinitd "${FILESDIR}/deluged.init" 'deluged'
		newconfd "${FILESDIR}/deluged.conf" 'deluged'

		systemd_dounit "${FILESDIR}/deluged@.service"
	else
		rm_paths+=(
			"${ED}/usr/bin/deluged"
			"${ED}/usr/share/man/man1"/deluged.* )
	fi

	if use webui ; then
		newinitd "${FILESDIR}/deluge-web.init" 'deluge-web'
		newconfd "${FILESDIR}/deluge-web.conf" 'deluge-web'
	else
		rm_paths+=(
			"${ED}/usr/bin/deluge-web"
			"${ED}/usr"/lib*/py*/*-packages/deluge/ui/web/
			"${ED}/usr/share/man/man1"/deluge-web.* )
	fi

	if ! use gtk ; then
		rm_paths+=(
			"${ED}/usr/bin/deluge-gtk"
			"${ED}/usr"/lib*/py*/*-packages/deluge/ui/gtkui/
			"${ED}/usr/share/applications/"
			"${ED}/usr/share/icons/"
			"${ED}/usr/share/man/man1"/deluge-gtk.* )
	fi

	if ! use console ; then
		rm_paths+=(
			"${ED}/usr/bin/deluge-console"
			"${ED}/usr"/lib*/py*/*-packages/deluge/ui/console/*
			"${ED}/usr/share/man/man1"/deluge-console.* )
	fi

	if ! use gtk && ! use webui ; then
		rm_paths+=(
			"${ED}/usr/share/pixmaps/"
			"${ED}/usr"/lib*/py*/*-packages/deluge/data/pixmaps/ )
	fi

	rm -rvf "${rm_paths[@]}" || die
}
