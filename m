Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19137C433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:02:52 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 81E6560230
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:02:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81E6560230
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0921E32F4B2;
	Wed, 14 Apr 2021 21:02:51 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6EBF032F3FA
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:46 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 489EA100F32E;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3F41991883; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:01:52 -0400
Message-Id: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/49] lustre: sync to OpenSFS as of March 30
 2021
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

New backport of patches from OpenSFS tree as of March 30, 2021.
Include a few missing fixes that were lacking in the Linux client.
This covers a few pool quota patches and the NRS delay policy.

Andreas Dilger (4):
  lustre: llite: mark extended attr and inode flags
  lustre: mds: add enums for MDS_ATTR flags
  lustre: uapi: remove OBD_IOC_LOV_GET_CONFIG
  lustre: lmv: handle default stripe_count=-1 properly

Bobi Jam (1):
  lustre: lov: fault page update cp_lov_index

Chris Horn (10):
  lnet: lnet_notify sets route aliveness incorrectly
  lnet: Prevent discovery on peer marked deletion
  lnet: Prevent discovery on deleted peer
  lnet: Transfer disc src NID when merging peers
  lnet: Lookup lpni after discovery
  lnet: Correct asymmetric route detection
  lustre: ptlrpc: Implement NRS Delay Policy
  lnet: Age peer NI out of recovery
  lnet: Only recover known good peer NIs
  lnet: Recover peer NI w/exponential backoff interval

Emoly Liu (1):
  lustre: lov: return valid stripe_count/size for PFL files

Etienne AUJAMES (1):
  lustre: obdclass: Protect cl_env_percpu[]

James Simmons (4):
  lustre: llite: update and fix module loading bug in mounting code
  lustre: llite: create file_operations registration function.
  lnet: uapi: move userland only nidstr.h handling
  lustre: use tgt_pool for lov layer

Lai Siyao (1):
  lustre: lmv: striped directory as subdirectory mount

Lei Feng (1):
  lustre: log: Add ending newline for some messages.

Mikhail Pershin (1):
  lustre: llite: mirror extend/copy keeps sparseness

Mr NeilBrown (14):
  lustre: lmv: iput() can safely be passed NULL.
  lnet: socklnd: change various ints to bool.
  lustre: fixup ldlm_pool and lu_object shrinker failure cases
  lustre: use with_imp_locked() more broadly.
  lnet: o2iblnd: change some ints to bool.
  lustre: osc: fix performance regression in osc_extent_merge()
  lnet: libcfs: restore LNET_DUMP_ON_PANIC functionality.
  lnet: libcfs: don't depend on sysctl support for debugfs
  lustre: ptlrpc: rename cfs_binheap to simply binheap
  lustre: ptlrpc: mark some functions as static
  lustre: quota: call rhashtable_lookup near params decl
  lnet: libcfs: discard cfs_trace_console_buffers[]
  lnet: libcfs: discard cfs_trace_copyin_string()
  lustre: lmv: don't use lqr_alloc spinlock in lmv

Mr. NeilBrown (2):
  lnet: convert lpni_refcount to a kref
  lnet: libcfs: discard cfs_array_alloc()

NeilBrown (1):
  lustre: ptlrpc: don't use list_for_each_entry_safe unnecessarily.

Nikitas Angelinas (1):
  lustre: ptlrpc: Add a binary heap implementation

Oleg Drokin (1):
  lustre: update version to 2.14.51

Sebastien Buisson (1):
  lustre: sec: fix migrate for encrypted dir

Sergey Cheremencev (1):
  lustre: quota: make used for pool correct

Shaun Tancheff (1):
  lnet: libcfs: Fix for unconfigured arch_stackwalk

Vitaly Fertman (2):
  lustre: ldlm: not freed req on enqueue
  lustre: lov: cancel layout lock on replay deadlock

Yang Sheng (1):
  lustre: ptlrpc: fix ASSERTION on scp_rqbd_posted

 fs/lustre/include/lprocfs_status.h       |  11 +-
 fs/lustre/include/lustre_disk.h          |   5 +-
 fs/lustre/include/lustre_lmv.h           |   3 +-
 fs/lustre/include/lustre_net.h           |   1 -
 fs/lustre/include/lustre_nrs.h           |  16 +
 fs/lustre/include/lustre_nrs_delay.h     |  87 ++++
 fs/lustre/include/obd_class.h            |   5 +-
 fs/lustre/include/obd_support.h          |  30 +-
 fs/lustre/ldlm/ldlm_pool.c               |  43 +-
 fs/lustre/ldlm/ldlm_request.c            |   4 +
 fs/lustre/llite/crypto.c                 |   1 +
 fs/lustre/llite/dir.c                    |  13 +-
 fs/lustre/llite/file.c                   | 143 ++++--
 fs/lustre/llite/llite_internal.h         |  24 +-
 fs/lustre/llite/llite_lib.c              |  14 +-
 fs/lustre/llite/namei.c                  |   2 +
 fs/lustre/llite/super25.c                |  60 ++-
 fs/lustre/llite/xattr.c                  |  11 +
 fs/lustre/lmv/lmv_intent.c               |  17 +-
 fs/lustre/lmv/lmv_obd.c                  |  12 +-
 fs/lustre/lov/lov_cl_internal.h          |  10 +-
 fs/lustre/lov/lov_internal.h             |  10 +-
 fs/lustre/lov/lov_io.c                   |  37 ++
 fs/lustre/lov/lov_obd.c                  |  84 ++-
 fs/lustre/lov/lov_object.c               |  44 +-
 fs/lustre/lov/lov_pack.c                 |   7 -
 fs/lustre/lov/lov_pool.c                 | 130 +----
 fs/lustre/mdc/lproc_mdc.c                |  14 +-
 fs/lustre/mdc/mdc_lib.c                  |  10 +-
 fs/lustre/mdc/mdc_request.c              |  12 +-
 fs/lustre/mgc/mgc_request.c              |  94 ++--
 fs/lustre/obdclass/Makefile              |   4 +-
 fs/lustre/obdclass/cl_object.c           |   3 +
 fs/lustre/obdclass/class_obd.c           |  15 +-
 fs/lustre/obdclass/lu_object.c           |  39 +-
 fs/lustre/obdclass/lu_tgt_pool.c         | 241 +++++++++
 fs/lustre/osc/lproc_osc.c                |  10 +-
 fs/lustre/osc/osc_cache.c                |   5 +-
 fs/lustre/osc/osc_request.c              |  12 +-
 fs/lustre/ptlrpc/Makefile                |   3 +-
 fs/lustre/ptlrpc/client.c                |  10 +-
 fs/lustre/ptlrpc/heap.c                  | 502 ++++++++++++++++++
 fs/lustre/ptlrpc/heap.h                  | 189 +++++++
 fs/lustre/ptlrpc/import.c                |  14 +-
 fs/lustre/ptlrpc/llog_client.c           |   2 +-
 fs/lustre/ptlrpc/nrs.c                   |   4 +
 fs/lustre/ptlrpc/nrs_delay.c             | 851 +++++++++++++++++++++++++++++++
 fs/lustre/ptlrpc/pinger.c                |  21 +-
 fs/lustre/ptlrpc/ptlrpc_internal.h       |   7 +-
 fs/lustre/ptlrpc/ptlrpcd.c               |   4 +-
 fs/lustre/ptlrpc/recover.c               |  14 +-
 fs/lustre/ptlrpc/sec_config.c            |   8 +-
 fs/lustre/ptlrpc/service.c               |  26 +-
 include/linux/libcfs/libcfs.h            |   3 +
 include/linux/libcfs/libcfs_debug.h      |   2 -
 include/linux/libcfs/libcfs_private.h    |   7 -
 include/linux/lnet/lib-lnet.h            |  38 +-
 include/linux/lnet/lib-types.h           |  28 +-
 include/uapi/linux/lnet/nidstr.h         |  15 -
 include/uapi/linux/lustre/lustre_idl.h   |  50 +-
 include/uapi/linux/lustre/lustre_ioctl.h |   3 +-
 include/uapi/linux/lustre/lustre_ver.h   |   4 +-
 net/lnet/Kconfig                         |   9 +
 net/lnet/klnds/o2iblnd/o2iblnd.c         |   8 +-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c      |  26 +-
 net/lnet/klnds/socklnd/socklnd.c         |  13 +-
 net/lnet/klnds/socklnd/socklnd_cb.c      |  22 +-
 net/lnet/libcfs/debug.c                  |  37 +-
 net/lnet/libcfs/libcfs_mem.c             |  52 --
 net/lnet/libcfs/module.c                 | 133 ++++-
 net/lnet/libcfs/tracefile.c              | 220 ++++----
 net/lnet/libcfs/tracefile.h              |   2 -
 net/lnet/lnet/api-ni.c                   |  12 +
 net/lnet/lnet/lib-move.c                 | 158 +++---
 net/lnet/lnet/lib-msg.c                  |  31 +-
 net/lnet/lnet/lib-ptl.c                  |  19 +-
 net/lnet/lnet/nidstrings.c               |   1 +
 net/lnet/lnet/peer.c                     | 303 +++++++----
 net/lnet/lnet/router.c                   |  39 +-
 net/lnet/lnet/router_proc.c              |  26 +-
 80 files changed, 3194 insertions(+), 1005 deletions(-)
 create mode 100644 fs/lustre/include/lustre_nrs_delay.h
 create mode 100644 fs/lustre/obdclass/lu_tgt_pool.c
 create mode 100644 fs/lustre/ptlrpc/heap.c
 create mode 100644 fs/lustre/ptlrpc/heap.h
 create mode 100644 fs/lustre/ptlrpc/nrs_delay.c

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
