Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67342C433DB
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:17:10 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 087C023A57
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:17:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 087C023A57
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 43C1A21FAED;
	Thu, 21 Jan 2021 09:17:09 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 22F9A21FA40
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:06 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 1E05D1005F1B;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 17A69F0A5; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:23 -0500
Message-Id: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/39] lustre: update to latest OpenSFS
 version as of Jan 21 2021
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

Update the Linux Lustre client to where the latest OpenSFS tree is at as of
Jan 21, 2021. Please review.

Alexander Zarochentsev (1):
  lustre: ldlm: page discard speedup

Andreas Dilger (1):
  lustre: ldlm: don't compute sumsq for pool stats

Andrew Perepechko (1):
  lustre: ptlrpc: fixes for RCU-related stalls

Andriy Skulysh (2):
  lustre: ldlm: Don't re-enqueue glimpse lock on read
  lustre: ldlm: osc_object_ast_clear() is called for mdc object on
    eviction

Bobi Jam (3):
  lustre: llite: don't check layout info for page discard
  lustre: lov: FIEMAP support for PFL and FLR file
  lustre: lov: correctly set OST obj size

Chris Horn (5):
  lnet: Correct handling of NETWORK_TIMEOUT status
  lnet: Introduce constant for net ID of LNET_NID_ANY
  lnet: lnd: Use NETWORK_TIMEOUT for txs on ibp_tx_queue
  lnet: lnd: Use NETWORK_TIMEOUT for some conn failures
  lnet: Introduce lnet_recovery_limit parameter

Etienne AUJAMES (1):
  lustre: mdc: process changelogs_catalog from the oldest rec

John L. Hammond (2):
  lustre: llite: return EOPNOTSUPP if fallocate is not supported
  lnet: use an unbound cred in kiblnd_resolve_addr()

Lai Siyao (1):
  lustre: lmv: optimize dir shard revalidate

Mikhail Pershin (3):
  lustre: lov: fix SEEK_HOLE calcs at component end
  lustre: dom: non-blocking enqueue for DOM locks
  lustre: cksum: add lprocfs checksum support in MDC/MDT

Mr NeilBrown (1):
  lnet: o2iblnd: remove FMR-pool support.

Olaf Faaland (1):
  lustre: osc: prevent overflow of o_dropped

Oleg Drokin (4):
  lustre: ldlm: Do not wait for lock replay sending if import
    dsconnected
  lustre: ldlm: Do not hang if recovery restarted during lock replay
  lustre: Use vfree_atomic instead of vfree
  lustre: update version to 2.13.57

Qian Yingjin (1):
  lustre: uapi: fix compatibility for LL_IOC_MDC_GETINFO

Sebastien Buisson (1):
  lustre: llite: fiemap set flags for encrypted files

Serguei Smirnov (2):
  lnet: o2iblnd: retry qp creation with reduced queue depth
  lnet: socklnd: announce deprecation of 'use_tcp_bonding'

Wang Shilong (5):
  lustre: llite: fix client evicition with DIO
  lustre: llite: allow DIO with unaligned IO count
  lustre: quota: df should return projid-specific values
  lustre: llite: try to improve mmap performance
  lustre: lov: instantiate components layout for fallocate

Yang Sheng (4):
  lustre: osc: skip 0 row for rpc_stats
  lnet: discard the callback
  lustre: mdc: avoid easize set to 0
  lustre: ldlm: Use req_mode while lock cleanup

 fs/lustre/include/cl_object.h             |   2 +-
 fs/lustre/include/lustre_dlm.h            |   4 +-
 fs/lustre/include/lustre_export.h         |   5 +
 fs/lustre/include/lustre_net.h            |  15 +-
 fs/lustre/include/lustre_osc.h            |   7 +-
 fs/lustre/include/obd.h                   |   2 +-
 fs/lustre/include/obd_class.h             |   3 +-
 fs/lustre/ldlm/ldlm_flock.c               |   2 +-
 fs/lustre/ldlm/ldlm_lib.c                 |   2 +-
 fs/lustre/ldlm/ldlm_lock.c                |  16 +-
 fs/lustre/ldlm/ldlm_pool.c                |  33 ++--
 fs/lustre/ldlm/ldlm_request.c             |  75 ++++----
 fs/lustre/llite/dir.c                     |  36 ++--
 fs/lustre/llite/file.c                    |  35 +++-
 fs/lustre/llite/llite_internal.h          |  19 ++
 fs/lustre/llite/llite_lib.c               |  57 +++++-
 fs/lustre/llite/lproc_llite.c             |  47 +++++
 fs/lustre/llite/rw.c                      | 146 +++++++++++++--
 fs/lustre/llite/rw26.c                    |  39 +++-
 fs/lustre/llite/vvp_io.c                  |   8 +-
 fs/lustre/lmv/lmv_intent.c                |  15 +-
 fs/lustre/lmv/lmv_internal.h              |   1 -
 fs/lustre/lmv/lmv_obd.c                   |   3 +-
 fs/lustre/lov/lov_cl_internal.h           |   5 +
 fs/lustre/lov/lov_internal.h              |   1 +
 fs/lustre/lov/lov_io.c                    | 134 +++++++++++--
 fs/lustre/lov/lov_lock.c                  |  31 ++-
 fs/lustre/lov/lov_object.c                | 249 +++++++++++++++---------
 fs/lustre/lov/lov_offset.c                |  10 +-
 fs/lustre/mdc/lproc_mdc.c                 | 128 ++++++++++++-
 fs/lustre/mdc/mdc_changelog.c             |   2 +-
 fs/lustre/mdc/mdc_dev.c                   | 144 ++++++++------
 fs/lustre/mdc/mdc_internal.h              |  10 +
 fs/lustre/mdc/mdc_locks.c                 |  14 +-
 fs/lustre/obdclass/lprocfs_status.c       |   1 +
 fs/lustre/osc/lproc_osc.c                 |  12 +-
 fs/lustre/osc/osc_cache.c                 |  48 +++--
 fs/lustre/osc/osc_lock.c                  |   3 +
 fs/lustre/osc/osc_object.c                |   2 +-
 fs/lustre/osc/osc_request.c               |  57 +++---
 fs/lustre/ptlrpc/client.c                 |  26 ++-
 fs/lustre/ptlrpc/niobuf.c                 |   7 +-
 fs/lustre/ptlrpc/sec.c                    |  21 ++-
 fs/lustre/ptlrpc/sec_bulk.c               |   6 +-
 fs/lustre/ptlrpc/sec_config.c             |  10 +-
 fs/lustre/ptlrpc/sec_null.c               |  24 ++-
 fs/lustre/ptlrpc/sec_plain.c              |  24 ++-
 fs/lustre/ptlrpc/service.c                |  21 ++-
 fs/lustre/ptlrpc/wiretest.c               |   3 +-
 include/linux/lnet/api.h                  |   3 +-
 include/linux/lnet/lib-lnet.h             |   2 +
 include/linux/lnet/lib-types.h            |   1 +
 include/uapi/linux/lnet/lnet-types.h      |   2 +
 include/uapi/linux/lustre/lustre_fiemap.h |  30 ++-
 include/uapi/linux/lustre/lustre_idl.h    |   8 +
 include/uapi/linux/lustre/lustre_user.h   |  21 +--
 include/uapi/linux/lustre/lustre_ver.h    |   4 +-
 mm/vmalloc.c                              |   1 +
 net/lnet/klnds/o2iblnd/o2iblnd.c          | 302 +++++++++++-------------------
 net/lnet/klnds/o2iblnd/o2iblnd.h          |  12 +-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c       | 102 ++++++----
 net/lnet/lnet/api-ni.c                    |  13 +-
 net/lnet/lnet/config.c                    |   8 +-
 net/lnet/lnet/lib-md.c                    |  25 ++-
 net/lnet/lnet/lib-move.c                  |   3 +-
 net/lnet/lnet/lib-msg.c                   |   5 +
 net/lnet/lnet/nidstrings.c                |   2 +-
 net/lnet/lnet/peer.c                      |   2 +-
 net/lnet/lnet/router.c                    |   6 +-
 69 files changed, 1434 insertions(+), 683 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
