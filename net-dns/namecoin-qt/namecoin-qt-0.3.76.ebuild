# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dns/namecoin-qt/namecoin-qt-0.3.72.ebuild,v 1.1 2013/12/01 15:24:30 blueness Exp $

EAPI=5

DB_VER="4.8"

LANGS="af_ZA ar bg ca_ES cs da de el_GR en es_CL es et eu_ES fa_IR fa fi fr_CA fr gu_IN he hi_IN hr hu it ja lt nb nl pl pt_BR pt_PT ro_RO ru sk sr sv th_TH tr uk zh_CN zh_TW"

inherit db-use eutils fdo-mime gnome2-utils kde4-functions qt4-r2

MY_PV="nc${PV}"
MY_P="namecoin-${MY_PV}"

DESCRIPTION="A P2P network based domain name system"
HOMEPAGE="https://namecoin.info/"
SRC_URI="https://github.com/namecoin/namecoin/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT ISC cryptopp GPL-3 LGPL-2.1 public-domain || ( CC-BY-SA-3.0 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dbus ipv6 upnp"

RDEPEND="
	dev-libs/boost[threads(+)]
	dev-libs/crypto++
	dev-libs/openssl:0[-bindist]
	sys-libs/db:$(db_ver_to_slot "${DB_VER}")[cxx]
	dev-qt/qtgui:4
	dbus? (
		dev-qt/qtdbus:4
	)
"
# Add this when upnp is fixed
# upnp? ( net-libs/miniupnpc)

DEPEND="${RDEPEND}
	>=app-shells/bash-4.1
"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	cd src || die

	local filt= yeslang= nolang=

	for lan in $LANGS; do
		if [ ! -e qt/locale/bitcoin_$lan.ts ]; then
			ewarn "Language '$lan' no longer supported. Ebuild needs update."
		fi
	done

	for ts in $(ls qt/locale/*.ts)
	do
		x="${ts/*bitcoin_/}"
		x="${x/.ts/}"
		if ! use "linguas_$x"; then
			nolang="$nolang $x"
			rm "$ts"
			filt="$filt\\|$x"
		else
			yeslang="$yeslang $x"
		fi
	done

	filt="bitcoin_\\(${filt:2}\\)\\.\(qm\|ts\)"
	sed "/${filt}/d" -i 'qt/bitcoin.qrc'
	einfo "Languages -- Enabled:$yeslang -- Disabled:$nolang"
}

src_configure() {
	OPTS=()

	use dbus && OPTS+=("USE_DBUS=1")

	if use upnp; then
		OPTS+=("USE_UPNP=1")
	else
		OPTS+=("USE_UPNP=-")
	fi

	OPTS+=("USE_UPNP=-")

	use ipv6 || OPTS+=("USE_IPV6=-")

	OPTS+=("USE_SYSTEM_LEVELDB=1")
	OPTS+=("BDB_INCLUDE_PATH=$(db_includedir "${DB_VER}")")
	OPTS+=("BDB_LIB_SUFFIX=-${DB_VER}")

	if has_version '>=dev-libs/boost-1.52'; then
		OPTS+=("LIBS+=-lboost_chrono\$\$BOOST_LIB_SUFFIX")
	fi

	eqmake4 namecoin-qt.pro "${OPTS[@]}"
}

#Tests are broken
#src_test() {
#	cd src || die
#	emake -f makefile.unix "${OPTS[@]}" test_namecoin
#	./test_namecoin || die 'Tests failed'
#}

src_install() {
	qt4-r2_src_install

	dobin ${PN}

	insinto /usr/share/pixmaps
	newins "src/qt/res/icons/bitcoin.ico" "${PN}.ico"

	make_desktop_entry "${PN} %u" "Namecoin-Qt" "/usr/share/pixmaps/${PN}.ico" "Qt;Network;P2P;DNS;" "MimeType=x-scheme-handler/namecoin;\nTerminal=false"
}

update_caches() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
	buildsycoca
}

pkg_postinst() {
	update_caches
}

pkg_postrm() {
	update_caches
}
