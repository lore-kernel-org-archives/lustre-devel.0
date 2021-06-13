Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA888C48BE8
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:11:43 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 36F0D611CA
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:11:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36F0D611CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C7C4721CB87;
	Sun, 13 Jun 2021 16:11:42 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4D2D721C959
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:40 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A6A06100B004;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9EB5B9C303; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:10 -0400
Message-Id: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/27] lustre: sync to 2.14.52
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

Update the linux client to support OpenSFS versoon 2.14.52

Alex Zhuravlev (1):
  lustre: mdc: start changelog thread upon first access

Alexander Boyko (1):
  lustre: llog: changelog purge deletes plain llog

Andreas Dilger (2):
  lnet: libcfs: allow comma-separated masks
  lustre: lmv: change default hash type to crush

Artem Blagodarenko (2):
  lustre: obd: check if sbi->ll_md_exp is initialized
  lnet: do not crash if lnet_sock_getaddr returns error

Bobi Jam (2):
  lustre: flr: mmap write/punch does not stale other mirrors
  lustre: llite: refresh layout after mirror merge/split

Chris Horn (2):
  lnet: Fix destination NID for discovery PUSH
  lnet: Check if discovery toggled off in ping reply

James Simmons (2):
  lustre: uapi: rename CONFIG_T_* to MGS_CFG_T_*
  lustre: rename tgt_pool_* functions.

Lai Siyao (2):
  lustre: llite: default lsm update may memory leak
  lustre: pcc: don't alloc FID in LLITE for pcc open

Li Xi (1):
  lustre: osc: cleanup comment in osc_object_is_contended

Mr NeilBrown (1):
  lnet: o2iblnd: fix bug in list_first_entry() change.

Olaf Faaland (1):
  lnet: simplify lnet_ni_add_interface

Oleg Drokin (1):
  lustre: update version to 2.14.52

Patrick Farrell (2):
  lustre: osc: Batch gang_lookup cbs
  lustre: llite: Return errors for aio

Qian Yingjin (1):
  lustre: ptlrpc: move more members in PTLRPC request into pill

Sebastien Buisson (2):
  lustre: sec: forbid file rename from enc to unencrypted dir
  lustre: llite: add selinux testing

Sergey Cheremencev (1):
  lustre: quota: default OST Pool Quotas

Vitaly Fertman (2):
  lustre: ptlrpc: do not match reply with resent RPC
  lustre: vvp: wait for nrpages to be updated

Yang Sheng (1):
  lustre: uapi: add mdt_hash_name

 fs/lustre/include/cl_object.h           |   5 ++
 fs/lustre/include/lu_object.h           |  12 +--
 fs/lustre/include/lustre_disk.h         |   3 +-
 fs/lustre/include/lustre_lmv.h          |  19 +++--
 fs/lustre/include/lustre_net.h          |  75 ++--------------
 fs/lustre/include/lustre_osc.h          |   7 +-
 fs/lustre/include/lustre_req_layout.h   |  78 ++++++++++++++++-
 fs/lustre/include/obd.h                 |   2 +-
 fs/lustre/include/obd_class.h           |  11 +--
 fs/lustre/include/obd_support.h         |   5 ++
 fs/lustre/llite/dcache.c                |   6 +-
 fs/lustre/llite/dir.c                   |  32 ++++---
 fs/lustre/llite/file.c                  |   6 +-
 fs/lustre/llite/llite_internal.h        |   5 +-
 fs/lustre/llite/llite_lib.c             | 110 ++++++++++++------------
 fs/lustre/llite/llite_mmap.c            |   4 +-
 fs/lustre/llite/llite_nfs.c             |   2 +-
 fs/lustre/llite/namei.c                 |  48 ++++++-----
 fs/lustre/llite/rw26.c                  |   3 +-
 fs/lustre/llite/statahead.c             |   2 +-
 fs/lustre/llite/vvp_io.c                |   3 +-
 fs/lustre/llite/vvp_object.c            |   9 +-
 fs/lustre/lmv/lmv_intent.c              |   6 +-
 fs/lustre/lmv/lmv_obd.c                 |   5 +-
 fs/lustre/lov/lov_io.c                  |   8 +-
 fs/lustre/lov/lov_obd.c                 |  12 +--
 fs/lustre/lov/lov_pool.c                |  10 +--
 fs/lustre/mdc/mdc_acl.c                 |   3 +-
 fs/lustre/mdc/mdc_changelog.c           |  54 ++++++++----
 fs/lustre/mdc/mdc_dev.c                 |  52 +++++------
 fs/lustre/mdc/mdc_internal.h            |  36 ++++----
 fs/lustre/mdc/mdc_lib.c                 | 146 ++++++++++++++++---------------
 fs/lustre/mdc/mdc_locks.c               |  10 +--
 fs/lustre/mdc/mdc_reint.c               |  13 +--
 fs/lustre/mdc/mdc_request.c             |  43 +++++-----
 fs/lustre/mgc/mgc_internal.h            |   8 +-
 fs/lustre/mgc/mgc_request.c             |  29 ++++---
 fs/lustre/obdclass/cl_page.c            |   3 +
 fs/lustre/obdclass/llog.c               |   4 +
 fs/lustre/obdclass/lprocfs_status.c     |   1 +
 fs/lustre/obdclass/lu_tgt_pool.c        |  28 +++---
 fs/lustre/obdclass/obd_mount.c          |   4 +-
 fs/lustre/obdecho/echo_client.c         |   4 +-
 fs/lustre/osc/osc_cache.c               | 147 +++++++++++++++++---------------
 fs/lustre/osc/osc_io.c                  |  33 ++++---
 fs/lustre/osc/osc_lock.c                |  19 +++--
 fs/lustre/osc/osc_object.c              |   4 -
 fs/lustre/ptlrpc/client.c               |  21 +++--
 fs/lustre/ptlrpc/layout.c               |  32 +++++--
 fs/lustre/ptlrpc/niobuf.c               |  20 +++--
 fs/lustre/ptlrpc/pack_generic.c         |  70 ++++++++-------
 fs/lustre/ptlrpc/ptlrpc_internal.h      |   2 +-
 fs/lustre/ptlrpc/sec.c                  |   6 +-
 fs/lustre/ptlrpc/sec_plain.c            |   4 +-
 fs/lustre/ptlrpc/service.c              |  18 +++-
 fs/lustre/ptlrpc/wiretest.c             |  10 ++-
 include/linux/lnet/lib-types.h          |   2 +
 include/uapi/linux/lustre/lustre_idl.h  |  14 +--
 include/uapi/linux/lustre/lustre_user.h |  14 +--
 include/uapi/linux/lustre/lustre_ver.h  |   4 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c        |   2 +-
 net/lnet/klnds/socklnd/socklnd.c        |   5 +-
 net/lnet/libcfs/libcfs_string.c         |   6 +-
 net/lnet/lnet/acceptor.c                |   5 +-
 net/lnet/lnet/config.c                  |  27 +++---
 net/lnet/lnet/peer.c                    |  80 +++++++----------
 66 files changed, 798 insertions(+), 673 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
