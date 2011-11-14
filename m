From: Bruce Korb <bruce_korb@xyratex.com>
Date: Mon, 14 Nov 2011 07:11:50 -0800
Subject: [Lustre-devel] lustre-devel  packaging
Message-ID: <CAE66FB6.134A%bruce_korb@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

We at Xyratex are needing to develop some auxiliary utilities that
need internal data structures from lustre.  To accomplish this, our
sources have been reaching into the lustre build tree for the
necessary headers.  Not being a particular fan of that approach,
I developed a patch for lustre that will create another RPM:
a lustre-devel package.


It builds the packages and drops the headers into a tree that looks like
this:

usr/include/lustre
usr/include/lustre/darwin
usr/include/lustre/linux
usr/include/lustre/lnet
usr/include/lustre/lnet/darwin
usr/include/lustre/lnet/linux
usr/include/lustre/lnet/winnt
usr/include/lustre/libcfs
usr/include/lustre/libcfs/darwin
usr/include/lustre/libcfs/linux
usr/include/lustre/libcfs/winnt
usr/include/lustre/libcfs/util
usr/include/lustre/libcfs/posix
usr/include/linux
usr/include/libcfs/posix


one file is dropped into include/libcfs/posix and one file into
include/linux.
I'd have preferred not doing that, but the old code already did.
186 headers get installed.


The other files installed as part of lustre-devel are object
archives and library interface man pages:

usr/lib64/libcfsutil.a
usr/lib64/liblustreapi.a
usr/lib64/liblustre.a
usr/lib64/libptlctl.a
usr/lib64/libiam.a
usr/share/lustre/mpich-1.2.6-lustre.patch
usr/share/man/man3/llapi_quotactl.3.gz
usr/share/man/man3/llapi_file_open.3.gz
usr/share/man/man3/llapi_file_create.3.gz
usr/share/man/man3/llapi_file_get_stripe.3.gz


The rest of the lustre installation is left with the main package.

Below is my git-commit message.  Under separate cover, I'll post the
git patch under the subject "[PATCH] lustre-devel packaging"

* autoMakefile.am
  Constrain lines to 80 columns (readability)
  Per automake maintainers, configurables should be set to a
  make file macro before use.  Enables "make" time replacement.

* build/autoMakefile.am.toplevel
  Constrain lines to 80 columns (readability)

* libcfs/include/Makefile.am
  Put every header under libcfs/include into nobase_pkginclude_HEADERS.

* lnet/autoconf/lustre-lnet.m4
  The body of an m4 (autoconf) macro is indented (readability).
  "LNET_MAX_PAYLOAD" is now a configured value
  lnet/include/lnet/types.h is now a configured file
  Alphabetize and indent the configured files

* lnet/include/Makefile.am
  Collect the neaders into nobase_pkginclude_HEADERS and
  nodist_nobase_pkginclude_HEADERS (just lnet/types.h)

* lnet/include/lnet/Makefile.am
  lnet/include/lnet/types.h is now a configured file

* lnet/include/lnet/types.h
  Renamed to:
* lnet/include/lnet/types.h.in
  Add configured #define for LNET_MAX_PAYLOAD and adjust CPP testing.

* lustre.spec.in
  354 columns in a single line is too much.  Trim the egregious ones.
  add a "%package devel" directive
  In %install section, separate "devel" files from non-devel and list
  them in lustre-devel.files and lustre.files.

* lustre/autoconf/lustre-core.m4
  Add config.h #define for OBD_MAX_IOCTL_BUFFER and make it a
  substitution value as well.
  lustre/include/lustre/Makefile.am is removed.  Do not configure.

* lustre/include/Makefile.am
  The lustre/include/lustre/*.h headers get installed in pkginclude.
  Drop the rest into nodist_pkginclude_HEADER (lustre_ver.h) or
  nobase_pkginclude_HEADER (everything else).

* lustre/include/linux/Makefile.am
  The EXTRA_DIST value is obsolete.

* lustre/include/linux/lustre_acl.h
  Fix spelling of "Should not include directly".

* lustre/include/lustre/Makefile.am
  Obsolete

* lustre/include/lustre_sec.h
  Prefer "__u32" to "uint32_t".  Eliminates need for inttypes.h.

* lustre/include/lustre_ver.h.in
  Add configured #define OBD_MAX_IOCTL_BUFFER

* lustre/utils/Makefile.am
  Move obd.c and lustre_cfg.c sources to convenience library.
---
 autoMakefile.am                   |   36 ++-
 build/autoMakefile.am.toplevel    |   17 +-
 libcfs/include/Makefile.am        |    8 +
 lnet/autoconf/lustre-lnet.m4      |  102 ++++----
 lnet/include/Makefile.am          |   10 +
 lnet/include/lnet/Makefile.am     |    2 +-
 lnet/include/lnet/types.h         |  509
-------------------------------------
 lnet/include/lnet/types.h.in      |  505
++++++++++++++++++++++++++++++++++++
 lustre.spec.in                    |  156 ++++++++----
 lustre/autoconf/lustre-core.m4    |   13 +-
 lustre/include/Makefile.am        |   71 +++++-
 lustre/include/linux/Makefile.am  |    7 -
 lustre/include/linux/lustre_acl.h |    2 +-
 lustre/include/lustre/Makefile.am |   42 ---
 lustre/include/lustre_sec.h       |    4 +-
 lustre/include/lustre_ver.h.in    |   23 +-
 lustre/utils/Makefile.am          |   12 +-
 17 files changed, 814 insertions(+), 705 deletions(-)



=== 500 insertions and 500 deletions from file move.
=== patch actually 300 inserts and 200 deletes.
