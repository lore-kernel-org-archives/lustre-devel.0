Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DC75CC19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:38:28 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4LyrwM5bw5z1y7r;
	Wed,  3 Aug 2022 18:38:27 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwK1fcmz1y73
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:25 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A0D02100AFE4;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9A70780795; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:37:45 -0400
Message-Id: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/32] lustre: Update to OpenSFS as of Aug 3
 2022
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
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Sync to latest OpenSFS tree except for crush2 support which exposed
several hidden bugs. Will need to resolve the issue. Also need to
see how Lustre's handling of fscrypt not fully implemented for 2.14.

Alexey Lyashkov (1):
  lnet: Replace msg_rdma_force with a new md_flag LNET_MD_FLAG_GPU.

Andreas Dilger (1):
  lustre: llite: add projid to debug logs

Chris Horn (4):
  lnet: socklnd: Duplicate ksock_conn_cb
  lnet: Ensure round robin across nets
  lnet: Define KFILND network type
  lnet: Adjust niov checks for large MD

Cyril Bordage (1):
  lnet: o2iblnd: add debug messages for IB

Etienne AUJAMES (1):
  lustre: llog: Add LLOG_SKIP_PLAIN to skip llog plain

Gian-Carlo DeFazio (1):
  lnet: asym route inconsistency warning

Hongchao Zhang (1):
  lustre: quota: skip non-exist or inact tgt for lfs_quota

James Simmons (1):
  lustre: ec: code to add support for M to N parity

John L. Hammond (4):
  lustre: echo: remove client operations from echo objects
  lustre: clio: remove cl_page_export() and cl_page_is_vmlocked()
  lustre: clio: remove cpo_own and cpo_disown
  lustre: clio: remove cpo_assume, cpo_unassume, cpo_fini

Lai Siyao (5):
  lustre: llite: enforce ROOT default on subdir mount
  lustre: lmv: support striped LMVs
  lustre: mdc: pack default LMV in open reply
  lustre: llite: use max default EA size to get default LMV
  lustre: llite: pass dmv inherit depth instead of dir depth

Mikhail Pershin (1):
  lustre: client: able to cleanup devices manually

Mr NeilBrown (3):
  lnet: discard some peer_ni lookup functions
  lnet: change lnet_*_peer_ni to take struct lnet_nid
  lnet: libcfs: debugfs file_operation should have an owner

Oleg Drokin (1):
  lustre: mdc: Remove entry from list before freeing

Patrick Farrell (2):
  lustre: flr: Don't assume RDONLY implies SOM
  lustre: ldlm: Prioritize blocking callbacks

Qian Yingjin (2):
  lustre: som: disabling xattr cache for LSOM on client
  lustre: llite: dont restart directIO with IOCB_NOWAIT

Sebastien Buisson (2):
  lustre: enc: enc-unaware clients get ENOKEY if file not found
  lustre: sec: handle read-only flag

Serguei Smirnov (1):
  lnet: o2iblnd: debug message is missing a newline

 fs/lustre/Makefile                      |   2 +-
 fs/lustre/ec/Makefile                   |   4 +
 fs/lustre/ec/ec_base.c                  | 352 +++++++++++++++++++++
 fs/lustre/include/cl_object.h           |  84 +----
 fs/lustre/include/erasure_code.h        | 142 +++++++++
 fs/lustre/include/lustre_lmv.h          |  29 +-
 fs/lustre/include/lustre_log.h          |  18 +-
 fs/lustre/include/lustre_net.h          |   4 +-
 fs/lustre/include/obd_support.h         |   8 +-
 fs/lustre/ldlm/ldlm_lockd.c             |  39 ++-
 fs/lustre/llite/crypto.c                |  35 ++-
 fs/lustre/llite/dir.c                   |  98 +++---
 fs/lustre/llite/file.c                  |  10 +-
 fs/lustre/llite/llite_internal.h        |   7 +
 fs/lustre/llite/llite_lib.c             | 101 +++++-
 fs/lustre/llite/namei.c                 |   4 +-
 fs/lustre/llite/rw.c                    |  53 ++--
 fs/lustre/llite/rw26.c                  |   6 +-
 fs/lustre/llite/vvp_dev.c               |   3 +-
 fs/lustre/llite/vvp_internal.h          |   3 -
 fs/lustre/llite/vvp_page.c              | 188 +----------
 fs/lustre/llite/xattr.c                 |   3 +-
 fs/lustre/llite/xattr_cache.c           |   4 +
 fs/lustre/lmv/lmv_obd.c                 |  29 +-
 fs/lustre/lov/lov_io.c                  |   7 -
 fs/lustre/lov/lov_obd.c                 |  21 +-
 fs/lustre/lov/lov_page.c                |   2 +-
 fs/lustre/mdc/mdc_changelog.c           |   8 +-
 fs/lustre/mdc/mdc_lib.c                 |   1 +
 fs/lustre/mdc/mdc_locks.c               |   2 +
 fs/lustre/mdc/mdc_request.c             |   7 +-
 fs/lustre/obdclass/cl_io.c              |  15 +-
 fs/lustre/obdclass/cl_page.c            | 264 ++++++++--------
 fs/lustre/obdecho/echo_client.c         | 542 +-------------------------------
 fs/lustre/osc/osc_lock.c                |   2 +-
 fs/lustre/osc/osc_request.c             |   3 +
 fs/lustre/ptlrpc/import.c               |   4 +-
 fs/lustre/ptlrpc/layout.c               |   1 +
 fs/lustre/ptlrpc/niobuf.c               |   3 +-
 fs/lustre/ptlrpc/pers.c                 |   3 +
 fs/lustre/ptlrpc/wiretest.c             |   2 +
 include/linux/libcfs/libcfs.h           |   4 +-
 include/linux/lnet/lib-lnet.h           |  12 +-
 include/linux/lnet/lib-types.h          |  14 +-
 include/uapi/linux/lnet/lnet-types.h    |   2 +
 include/uapi/linux/lnet/nidstr.h        |   1 +
 include/uapi/linux/lustre/lustre_user.h |   5 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c        |   2 +-
 net/lnet/klnds/o2iblnd/o2iblnd.h        |  23 +-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c     |  50 ++-
 net/lnet/klnds/socklnd/socklnd.c        |  19 +-
 net/lnet/klnds/socklnd/socklnd_cb.c     |   5 +-
 net/lnet/libcfs/module.c                |  43 ++-
 net/lnet/lnet/api-ni.c                  |  40 ++-
 net/lnet/lnet/lib-md.c                  |   3 +
 net/lnet/lnet/lib-move.c                | 114 ++++---
 net/lnet/lnet/module.c                  |   1 +
 net/lnet/lnet/nidstrings.c              |  10 +
 net/lnet/lnet/peer.c                    | 237 ++++++--------
 net/lnet/lnet/router.c                  |  21 +-
 net/lnet/lnet/router_proc.c             |  10 +-
 net/lnet/lnet/udsp.c                    |   8 +-
 62 files changed, 1399 insertions(+), 1338 deletions(-)
 create mode 100644 fs/lustre/ec/Makefile
 create mode 100644 fs/lustre/ec/ec_base.c
 create mode 100644 fs/lustre/include/erasure_code.h

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
