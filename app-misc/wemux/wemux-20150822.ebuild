# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit user

DESCRIPTION="multi-user tmux made easy"
HOMEPAGE="https://github.com/zolrath/wemux"
COMMIT="01c6541f8deceff372711241db2a13f21c4b210c"
MY_P="${PN}-${COMMIT}"
SRC_URI="https://github.com/zolrath/${PN}/archive/${COMMIT}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=">=app-misc/tmux-1.6"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	enewgroup wemux
}

src_prepare() {
	sed -i -e "s#/usr/local/etc#/etc#g" wemux

	sed -i -e "16ihost_groups=(wemux)" wemux.conf.example

	default
}

src_install() {
	dobin wemux

	doman man/wemux.1

	insinto /etc
	newins wemux.conf.example wemux.conf
}

pkg_postinst() {
	einfo "You should modify /etc/wemux.conf to"
	einfo "satisfy your needs before starting wemux."
}