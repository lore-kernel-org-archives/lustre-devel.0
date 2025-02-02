Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1C902C0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:48:05 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMB70GBJz1yCL;
	Sun, 02 Feb 2025 12:46:55 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmM9t6LkSz1xns
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:46:42 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm2-e204-208.ccs.ornl.gov [160.91.203.3])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 9C87817D1DE;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 955BA106BE15; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:00 -0500
Message-ID: <20250202204633.1148872-1-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 00/33] lustre: sync to OpenSFS branch May 31,
 2023
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Port the work done during the month of May on the OpenSFS tree
to the native client. Also synced the interval tree work
between both branches.

Andreas Dilger (2):
  lustre: uapi: cleanup FSFILT defines
  lustre: misc: replace obsolete ioctl numbers

Arshad Hussain (2):
  lnet: libcfs: Remove unsed LASSERT_ATOMIC_* macros
  lnet: libcfs: Remove reference to LASSERT_ATOMIC_POS

Bobi Jam (1):
  lustre: csdc: reserve layout bits for compress component

Chris Horn (2):
  lnet: Use dynamic allocation for LND tunables
  lnet: improve numeric NID to CPT hashing

James Simmons (6):
  lnet: set msg field for lnet message header
  lustre: obd: change lmd flags to bitmap
  lustre: obd: replace simple_strtoul()
  lnet: collect data about routes by using Netlink
  lnet: libcfs: use round_up directly
  lnet: ksocklnd: ksocklnd_ni_get_eth_intf_speed() must use only rtnl lock

Lai Siyao (1):
  lustre: lmv: treat unknown hash type as sane type

Li Dongyang (2):
  lustre: cksum: fix generating T10PI guard tags for partial brw page
  lustre: mdc: md_open_data should keep ref on close_req

Li Xi (1):
  lustre: llite: update comment of ll_swap_layouts_close

Mr NeilBrown (5):
  lnet: selftest: manage the workqueue state properly
  lustre: ptlrpc: switch sptlrpc_rule_set_choose to large nid
  lnet: use list_first_entry() where appropriate.
  lnet: libcfs: move cfs_expr_list_print to nidstrings.c
  lustre: ldlm: convert ldlm extent locks to linux extent-tree

Patrick Farrell (4):
  Revert "lustre: llite: Check vmpage in releasepage"
  lustre: llite: EIO is possible on a race with page reclaim
  lustre: obd: Reserve metadata overstriping flags
  lustre: llite: Fix return for non-queued aio

Qian Yingjin (2):
  lustre: llite: add __GFP_NORETRY for read-ahead page
  lustre: statahead: using try lock for batched RPCs

Timothy Day (4):
  lustre: llite: remove OBD_ -> CFS_ macros
  lustre: obd: remove OBD_ -> CFS_ macros
  lustre: ldlm: replace OBD_ -> CFS_ macros
  lustre: mdc: remove OBD_ -> CFS_ macros

Wang Shilong (1):
  lustre: remove cl_{offset,index,page_size} helpers

 fs/lustre/include/cl_object.h              |  13 +-
 fs/lustre/include/lustre_disk.h            |  51 ++-
 fs/lustre/include/lustre_dlm.h             |  22 +-
 fs/lustre/include/lustre_ioctl_old.h       |  85 ++++
 fs/lustre/include/lustre_lmv.h             |   4 +-
 fs/lustre/include/obd.h                    |  13 +-
 fs/lustre/include/obd_class.h              |   4 +-
 fs/lustre/include/obd_support.h            |   1 +
 fs/lustre/ldlm/ldlm_extent.c               |  49 ++-
 fs/lustre/ldlm/ldlm_flock.c                |  16 +-
 fs/lustre/ldlm/ldlm_lib.c                  |   4 +-
 fs/lustre/ldlm/ldlm_lock.c                 |  55 ++-
 fs/lustre/ldlm/ldlm_lockd.c                |  23 +-
 fs/lustre/ldlm/ldlm_request.c              |   8 +-
 fs/lustre/ldlm/ldlm_resource.c             |   2 +-
 fs/lustre/llite/dir.c                      |   2 +-
 fs/lustre/llite/file.c                     | 130 ++----
 fs/lustre/llite/glimpse.c                  |   2 +-
 fs/lustre/llite/llite_internal.h           |   4 +-
 fs/lustre/llite/llite_lib.c                |  27 +-
 fs/lustre/llite/llite_mmap.c               |   4 +-
 fs/lustre/llite/namei.c                    |   6 +-
 fs/lustre/llite/pcc.c                      |   8 +-
 fs/lustre/llite/rw.c                       |  31 +-
 fs/lustre/llite/rw26.c                     |  28 +-
 fs/lustre/llite/vvp_io.c                   |  53 ++-
 fs/lustre/llite/vvp_object.c               |   4 +-
 fs/lustre/llite/xattr_cache.c              |   2 +-
 fs/lustre/lmv/lmv_obd.c                    |   5 +-
 fs/lustre/lov/lov_io.c                     |  19 +-
 fs/lustre/lov/lov_lock.c                   |   8 +-
 fs/lustre/lov/lov_obd.c                    |   3 +-
 fs/lustre/lov/lov_object.c                 |   2 +-
 fs/lustre/lov/lov_page.c                   |  16 +-
 fs/lustre/mdc/mdc_dev.c                    |  12 +-
 fs/lustre/mdc/mdc_locks.c                  |   4 +-
 fs/lustre/mdc/mdc_request.c                |  23 +-
 fs/lustre/mgc/mgc_request.c                |   4 +-
 fs/lustre/obdclass/cl_page.c               |  26 +-
 fs/lustre/obdclass/class_obd.c             |  24 +-
 fs/lustre/obdclass/kernelcomm.c            |   2 +-
 fs/lustre/obdclass/llog_obd.c              |   2 +-
 fs/lustre/obdclass/lu_object.c             |   4 +-
 fs/lustre/obdclass/obd_config.c            |   2 +-
 fs/lustre/obdclass/obd_mount.c             |  64 ++-
 fs/lustre/obdecho/echo_client.c            |   2 +-
 fs/lustre/osc/osc_cache.c                  |  27 +-
 fs/lustre/osc/osc_io.c                     |  28 +-
 fs/lustre/osc/osc_lock.c                   |  20 +-
 fs/lustre/osc/osc_page.c                   |  15 +-
 fs/lustre/osc/osc_request.c                |  52 ++-
 fs/lustre/ptlrpc/batch.c                   |   6 +-
 fs/lustre/ptlrpc/layout.c                  |   8 +-
 fs/lustre/ptlrpc/pack_generic.c            |  14 +-
 fs/lustre/ptlrpc/sec.c                     |  16 +-
 fs/lustre/ptlrpc/sec_config.c              |  10 +-
 fs/lustre/ptlrpc/wiretest.c                |  14 +-
 include/linux/libcfs/libcfs_private.h      |  49 ---
 include/linux/libcfs/libcfs_string.h       |   2 -
 include/linux/lnet/lib-lnet.h              |   4 +
 include/linux/lnet/lib-types.h             |  40 ++
 include/uapi/linux/lnet/libcfs_ioctl.h     |   7 +-
 include/uapi/linux/lnet/lnet-dlc.h         |   7 +-
 include/uapi/linux/lustre/lustre_ioctl.h   |  47 +--
 include/uapi/linux/lustre/lustre_user.h    |  49 ++-
 net/lnet/klnds/o2iblnd/o2iblnd.h           |   2 +-
 net/lnet/klnds/socklnd/socklnd_modparams.c |   4 +-
 net/lnet/libcfs/libcfs_string.c            |  68 ----
 net/lnet/libcfs/module.c                   |   8 +-
 net/lnet/lnet/api-ni.c                     | 453 ++++++++++++++++++++-
 net/lnet/lnet/lib-move.c                   |   4 +-
 net/lnet/lnet/nidstrings.c                 |  68 ++++
 net/lnet/selftest/framework.c              |  29 +-
 net/lnet/selftest/module.c                 |  15 +-
 net/lnet/selftest/rpc.c                    |  31 +-
 net/lnet/selftest/selftest.h               |  27 +-
 76 files changed, 1256 insertions(+), 741 deletions(-)
 create mode 100644 fs/lustre/include/lustre_ioctl_old.h

-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
