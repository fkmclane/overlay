# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dns/namecoind/namecoind-0.3.72.ebuild,v 1.3 2014/06/22 11:44:15 blueness Exp $

EAPI=4

DB_VER="4.8"

inherit db-use eutils toolchain-funcs user

MY_PV="nc${PV}"
MY_P="namecoin-${MY_PV}"

DESCRIPTION="A P2P network based domain name system"
HOMEPAGE="https://namecoin.info/"
SRC_URI="https://github.com/namecoin/namecoin/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT ISC cryptopp"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ssl upnp"

RDEPEND="
	dev-libs/boost[threads(+)]
	dev-libs/glib:2
	dev-libs/crypto++
	dev-libs/openssl[-bindist]
	upnp? (
		net-libs/miniupnpc
	)
	sys-libs/db:$(db_ver_to_slot "${DB_VER}")[cxx]
"
DEPEND="${RDEPEND}
	>=app-shells/bash-4.1
"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	local UG='namecoin'
	enewgroup "${UG}"
	enewuser "${UG}" -1 -1 /var/lib/namecoin "${UG}"
}

src_prepare() {
	epatch "${FILESDIR}"/namecoind-0.3.76-makefile.patch
}

src_compile() {
	local OPTS=()

	OPTS+=("CXXFLAGS=${CXXFLAGS} -I$(db_includedir "${DB_VER}")")
	OPTS+=("LDFLAGS=${LDFLAGS} -ldb_cxx-${DB_VER}")

	use ssl  && OPTS+=(USE_SSL=1)
	use upnp && OPTS+=(USE_UPNP=1)

	cd src || die
	emake CXX="$(tc-getCXX)" "${OPTS[@]}" ${PN}
}

src_install() {
	dobin src/${PN}

	insinto /etc/namecoin
	doins "${FILESDIR}/namecoin.conf"
	fowners namecoin:namecoin /etc/namecoin/namecoin.conf
	fperms 600 /etc/namecoin/namecoin.conf

	newconfd "${FILESDIR}/namecoin.confd" ${PN}
	newinitd "${FILESDIR}/namecoin.initd" ${PN}

	keepdir /var/lib/namecoin/.namecoin
	fperms 700 /var/lib/namecoin
	fowners namecoin:namecoin /var/lib/namecoin/
	fowners namecoin:namecoin /var/lib/namecoin/.namecoin
	dosym /etc/namecoin/namecoin.conf /var/lib/namecoin/.namecoin/bitcoin.conf

	dodoc doc/README
	dodoc DESIGN-namecoin.md FAQ.md doc/README_merged-mining.md
}
