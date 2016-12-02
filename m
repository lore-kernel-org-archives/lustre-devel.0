From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 14:40:44 -0500
Subject: [lustre-devel] [PATCH 0/6] Fix ups to make lustre_idl.h a proper
	UAPI header
Message-ID: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The header lustre_idl.h is a UAPI header which contains extras
that don't belong. This patch set moves a bunch of very kernel
specific material out of the header. Lastly proper byteorder
functions are used so this file can build in user space as well.

Ben Evans (5):
  staging: lustre: headers: move swab functions to new header files
  staging: lustre: headers: sort headers affected by swab move
  staging: lustre: obdclass: Create a header for obdo related functions
  staging: lustre: headers: sort headers affected by obdo move
  staging: lustre: headers: Move functions out of lustre_idl.h

James Simmons (1):
  staging: lustre: headers: use proper byteorder functions in lustre_idl.h

 drivers/staging/lustre/lustre/include/llog_swab.h  |   65 +++++
 .../staging/lustre/lustre/include/lprocfs_status.h |    2 +
 .../lustre/lustre/include/lustre/lustre_idl.h      |  289 ++------------------
 .../lustre/lustre/include/lustre/lustre_user.h     |    2 -
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   13 +
 .../staging/lustre/lustre/include/lustre_obdo.h    |   54 ++++
 drivers/staging/lustre/lustre/include/lustre_sec.h |    1 +
 .../staging/lustre/lustre/include/lustre_swab.h    |  108 ++++++++
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |    6 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   27 ++
 drivers/staging/lustre/lustre/llite/dir.c          |    2 +
 drivers/staging/lustre/lustre/llite/file.c         |    1 +
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   18 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |    7 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |    6 +
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |    4 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   13 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    8 +-
 drivers/staging/lustre/lustre/obdclass/llog.c      |    3 +-
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |    1 +
 .../staging/lustre/lustre/obdclass/obd_config.c    |    7 +-
 drivers/staging/lustre/lustre/obdclass/obdo.c      |   54 ++++
 drivers/staging/lustre/lustre/osc/osc_io.c         |    2 +
 drivers/staging/lustre/lustre/osc/osc_request.c    |   13 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   12 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    9 +-
 27 files changed, 430 insertions(+), 298 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/llog_swab.h
 create mode 100644 drivers/staging/lustre/lustre/include/lustre_obdo.h
 create mode 100644 drivers/staging/lustre/lustre/include/lustre_swab.h
