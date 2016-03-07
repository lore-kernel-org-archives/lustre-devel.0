From: James Simmons <jsimmons@infradead.org>
Date: Mon,  7 Mar 2016 18:10:15 -0500
Subject: [lustre-devel] [PATCH v2 0/9] Last batch of fixes for LNet
Message-ID: <1457392224-2592-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This batch merges the remaining LNet patches from the OpenSFS
branch for the upstream client. Once merged the LNet code
will be up to date with the latest production code. Only style
issues are remaining. Still future patches being developed
for LNet will be landed to the upstream client as soon as they
are ready after extensive testing.

Changelog:

  v1)	Original patch set. One of the patches was adding a cast
	(lnet_process_id_t __user *) to a lnet_ping(). Discussed
	with Oleg and he stated that the cast should be removed
	from the OpenSFS branch. Also a __umoddi bug was reported
	for this patch set.

  v2)	Dropped the patch for the cast of the lnet_ping() parameter
	since this is incorrect. Also addressed the __umoddi issue
	reported by kbuild that was in net_fault.c. The test:

	if (!(rule->dr_stat.fs_count % attr->u.drop.da_rate))

	was changed to:

	if (!do_div(rule->dr_stat.fs_count, attr->u.drop.da_rate))

	since fs_count is __u64.

James Nunez (1):
  staging: lustre: Correct missing newline

James Simmons (3):
  staging: lustre: change test to assert in LNetGetId
  staging: lustre: rename proc_call_handler to lprocfs_call_handler
  staging: lustre: make LNet use lprocfs_call_handler

Liang Zhen (2):
  staging: lustre: LNet drop rule implementation
  staging: lustre: LNet network latency simulation

Sebastien Buisson (3):
  staging: lustre: fix 'data race condition' issue in conrpc.c
  staging: lustre: fix 'NULL pointer dereference' errors
  staging: lustre: fix 'data race condition' issue in framework.c

 .../staging/lustre/include/linux/libcfs/libcfs.h   |    4 +
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |    1 +
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   27 +
 .../staging/lustre/include/linux/lnet/lib-types.h  |    5 +
 .../staging/lustre/include/linux/lnet/lnetctl.h    |  100 ++
 drivers/staging/lustre/lnet/lnet/Makefile          |    2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   11 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   83 +-
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |    6 +
 drivers/staging/lustre/lnet/lnet/net_fault.c       | 1025 ++++++++++++++++++++
 drivers/staging/lustre/lnet/lnet/router_proc.c     |   32 +-
 drivers/staging/lustre/lnet/selftest/conctl.c      |   49 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    8 +-
 drivers/staging/lustre/lnet/selftest/framework.c   |    9 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |    2 +-
 .../lustre/lustre/include/lustre/lustre_user.h     |    3 +
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    9 +-
 drivers/staging/lustre/lustre/libcfs/module.c      |   25 +-
 drivers/staging/lustre/lustre/llite/file.c         |    8 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    4 +-
 drivers/staging/lustre/lustre/lov/lov_lock.c       |    2 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    2 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |    4 +-
 drivers/staging/lustre/lustre/lov/lov_request.c    |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    3 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |   11 +-
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |    2 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        |   26 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |    8 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    9 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    3 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    6 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |    4 +-
 36 files changed, 1353 insertions(+), 148 deletions(-)
 create mode 100644 drivers/staging/lustre/lnet/lnet/net_fault.c
