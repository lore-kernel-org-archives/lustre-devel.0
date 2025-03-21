Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6D3D8C36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:11:36 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2n11J9Yz1xsk;
	Fri, 21 Mar 2025 06:08:05 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2m34xgsz1x9v
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:07:15 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm2-e204-208.ccs.ornl.gov [160.91.203.3])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 54D3388F92B;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 4AC1C106BE14; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:43 -0400
Message-ID: <20250321130711.3257092-1-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 00/27] lustre: sync to OpenSFS tree July 27,
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

Backport the work done in the OpenSFS tree to the native
client that was done the month of July 2023.

Alex Zhuravlev (1):
  lustre: llite: skip fast reads if layout is invalid

Andreas Dilger (1):
  lustre: client: use EOPNOTSUPP instead of ENOTSUPP

Arshad Hussain (2):
  lnet: libcfs: Remove reference to LASSERT_ATOMIC_GT
  lnet: libcfs: Remove reference to LASSERT_ATOMIC_GT_LT

Bobi Jam (1):
  lustre: llite: call truncate_inode_pages() in inode lock

Chris Horn (1):
  lustre: ptlrpc: OBD_FAIL_PTLRPC_DELAY_SEND_FAIL fixes

Etienne AUJAMES (1):
  lustre: nrs: Fix console messages

James Simmons (2):
  lustre: misc: cleanup #ifdef
  lnet: rework module loading

Lai Siyao (1):
  lustre: dne: refactor commit-on-sharing for DNE

Mr NeilBrown (4):
  lustre: fld: use list_first/last_entry() for list heads
  lnet: libcfs: move ioctl device to lnet
  lustre: llite: simplify parsing in pcc_conds_parse()
  lustre: llite: create fileattr_[get|set] functions

Patrick Farrell (3):
  lustre: llite: improve readpage debug
  lustre: llite: Rename ldp_aio to sdio
  lustre: llite: Improve sync_io comments

Sebastien Buisson (1):
  lustre: gss: no sec flavor on loopback connection

Timothy Day (8):
  lustre: obd: fix style and clang error
  lnet: remove unused, fix non-static functions
  lustre: llite: convert functions to static
  lustre: convert ec,ldlm functions to static
  lustre: osc: convert more functions to static
  lustre: convert mdc,mgc functions to static
  lustre: ptlrpc: add missing header
  lustre: obd: remove unused obd_evict_inprogress

Vitaly Fertman (1):
  lustre: llite: deadlock on lli_lsm_sem

 fs/lustre/ec/ec_base.c                  |   4 +-
 fs/lustre/fld/fld_request.c             |   2 +-
 fs/lustre/include/cl_object.h           |  21 +-
 fs/lustre/include/lustre_dlm.h          |  43 ++-
 fs/lustre/include/lustre_lmv.h          |  84 +++--
 fs/lustre/include/lustre_log.h          |   8 +-
 fs/lustre/include/obd.h                 |  30 +-
 fs/lustre/include/obd_class.h           |  24 +-
 fs/lustre/ldlm/ldlm_inodebits.c         |   4 +
 fs/lustre/ldlm/ldlm_lib.c               |   1 +
 fs/lustre/ldlm/ldlm_lock.c              |  10 +-
 fs/lustre/ldlm/ldlm_request.c           |   2 +-
 fs/lustre/ldlm/ldlm_resource.c          |   5 +-
 fs/lustre/llite/dir.c                   |  22 +-
 fs/lustre/llite/file.c                  |  50 ++-
 fs/lustre/llite/lcommon_misc.c          |   2 +-
 fs/lustre/llite/llite_foreign.c         |  26 +-
 fs/lustre/llite/llite_foreign_symlink.c |  10 +-
 fs/lustre/llite/llite_internal.h        |  65 +++-
 fs/lustre/llite/llite_lib.c             | 475 +++++++++++++-----------
 fs/lustre/llite/llite_nfs.c             |   4 +-
 fs/lustre/llite/lproc_llite.c           |   2 +-
 fs/lustre/llite/namei.c                 | 198 +++++++---
 fs/lustre/llite/pcc.c                   | 137 +++----
 fs/lustre/llite/rw.c                    |   9 +-
 fs/lustre/llite/rw26.c                  |  24 +-
 fs/lustre/llite/vvp_dev.c               |  10 +-
 fs/lustre/llite/vvp_io.c                |  10 +-
 fs/lustre/llite/vvp_object.c            |  57 ++-
 fs/lustre/llite/xattr.c                 |  52 ++-
 fs/lustre/lmv/lmv_intent.c              |  21 +-
 fs/lustre/lmv/lmv_internal.h            |  16 +-
 fs/lustre/lmv/lmv_obd.c                 | 354 +++++++++++-------
 fs/lustre/lov/lov_obd.c                 |  11 +-
 fs/lustre/lov/lov_object.c              |  62 +++-
 fs/lustre/mdc/lproc_mdc.c               |   2 +-
 fs/lustre/mdc/mdc_dev.c                 |  69 ++--
 fs/lustre/mdc/mdc_request.c             |  52 +--
 fs/lustre/mgc/lproc_mgc.c               |   8 +-
 fs/lustre/obdclass/cl_io.c              |  78 ++--
 fs/lustre/obdclass/cl_object.c          |  17 +
 fs/lustre/obdclass/genops.c             |   6 +-
 fs/lustre/obdclass/jobid.c              |   2 -
 fs/lustre/osc/lproc_osc.c               |  11 +-
 fs/lustre/osc/osc_io.c                  |   6 +-
 fs/lustre/osc/osc_request.c             |  14 +-
 fs/lustre/ptlrpc/layout.c               |   2 +
 fs/lustre/ptlrpc/niobuf.c               |   9 +-
 fs/lustre/ptlrpc/nrs.c                  |  70 ++--
 fs/lustre/ptlrpc/pack_generic.c         |   2 +-
 fs/lustre/ptlrpc/sec_config.c           |   4 +
 fs/lustre/ptlrpc/sec_null.c             |   2 +-
 fs/lustre/ptlrpc/service.c              |  10 +-
 fs/lustre/ptlrpc/wiretest.c             |  22 +-
 include/linux/libcfs/libcfs.h           |  12 +-
 include/linux/libcfs/libcfs_private.h   |  13 -
 include/linux/lnet/lib-lnet.h           |   9 +
 include/uapi/linux/lnet/libcfs_ioctl.h  |  10 +-
 include/uapi/linux/lustre/lustre_idl.h  |   5 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c        |   2 +-
 net/lnet/klnds/socklnd/socklnd.c        |   2 +-
 net/lnet/libcfs/module.c                | 232 +-----------
 net/lnet/lnet/api-ni.c                  |  46 +--
 net/lnet/lnet/lib-move.c                |   4 +-
 net/lnet/lnet/lib-msg.c                 |   4 +-
 net/lnet/lnet/module.c                  | 224 +++++++++--
 net/lnet/lnet/peer.c                    |   4 +-
 net/lnet/selftest/conctl.c              |  21 +-
 net/lnet/selftest/console.c             |   4 +-
 69 files changed, 1567 insertions(+), 1266 deletions(-)

-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
