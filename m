From: James Simmons <jsimmons@infradead.org>
Date: Fri, 18 Nov 2016 11:48:34 -0500
Subject: [lustre-devel] [PATCH 00/10] checkpatch fixes and style cleanups
	for libcfs headers
Message-ID: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This patch set contains various cleanups that were reported
with checkpatch. Also remove the NULL and 0 comparisons which
is not kernel style. Lastly the uXX types are sorted out in
the libcfs headers. Only the macro mess is left that needs
cleaning up.

James Simmons (10):
  staging: lustre: libcfs: fixup all header block comments
  staging: lustre: libcfs: remove header's bare unsigned use
  staging: lustre: libcfs: name parameters for function prototypes
  staging: lustre: libcfs: remove blank line in header
  staging: lustre: libcfs: correct spelling in libcfs_cpu.h
  staging: lustre: libcfs: use bit macro in libcfs headers
  staging: lustre: libcfs: remove whitespace in libcfs_fail.h
  staging: lustre: libcfs: remove NULL comparisons in headers
  staging: lustre: libcfs: remove zero comparisons in headers
  staging: lustre: libcfs: use uXX instead of __uXX types in headers

 .../staging/lustre/include/linux/libcfs/curproc.h  |   20 +-
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    4 +-
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |    4 +-
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |   12 +-
 .../lustre/include/linux/libcfs/libcfs_fail.h      |   53 ++++---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |  183 ++++++++++---------
 .../lustre/include/linux/libcfs/libcfs_private.h   |   13 +-
 .../lustre/include/linux/libcfs/libcfs_string.h    |   24 ++--
 .../lustre/include/linux/libcfs/libcfs_workitem.h  |    4 +-
 .../lustre/include/linux/libcfs/linux/linux-cpu.h  |    8 +-
 .../lustre/include/linux/libcfs/linux/linux-time.h |    8 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 +-
 12 files changed, 179 insertions(+), 156 deletions(-)
