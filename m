Return-Path: <SRS0=HxeM=ML=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91CBDC07E9B
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:20 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 310596112D
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 310596112D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 22A0534F969;
	Mon, 19 Jul 2021 05:32:19 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C30F334F962
 for <lustre-devel@lists.lustre.org>; Mon, 19 Jul 2021 05:32:16 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8A18F6A1;
 Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7F971BD; Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 19 Jul 2021 08:31:55 -0400
Message-Id: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/18] lustre: sync to OpenSFS as of July 18,
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

Backport patches from OpenSFS tree as of July 18, 2021.

Amir Shehata (1):
  lnet: RMDA infrastructure updates

Arshad Hussain (1):
  lnet: libcfs: Add checksum speed under /sys/fs

Bobi Jam (1):
  lustre: llite: failed ASSERTION(ldlm_has_layout(lock))

Chris Horn (1):
  lnet: Correct peer NI recovery age out calculation

Dominique Martinet (1):
  lnet: annotate LNET_WIRE_HANDLE_COOKIE_NONE as u64

Lai Siyao (2):
  lustre: lmv: compare space to mkdir on parent MDT
  lustre: llite: reset pfid after dir migration

Mike Marciniszyn (2):
  lnet: o2iblnd: Move racy NULL assignment
  lnet: o2iblnd: Avoid double posting invalidate

Mikhail Pershin (1):
  lustre: uapi: per-user changelog names and mask

Mr. NeilBrown (1):
  lustre: statahead: update task management code

Qian Yingjin (2):
  lustre: llite: simplify callback handling for async getattr
  lustre: pcc: introducing OBD_CONNECT2_PCCRO flag

Sebastien Buisson (2):
  lustre: quota: nodemap squashed root cannot bypass quota
  lustre: sec: migrate/extend/split on encrypted file

Serguei Smirnov (1):
  lnet: use ni fatal error when calculating net health

Wang Shilong (2):
  lustre: quota: add get/set project support for non-dir/file
  lustre: readahead: fix to reserve min pages

 fs/lustre/include/lu_object.h           |   3 +-
 fs/lustre/include/lustre_crypto.h       |   2 +
 fs/lustre/include/obd.h                 |  34 +--
 fs/lustre/include/obd_class.h           |   4 +-
 fs/lustre/llite/dir.c                   |   2 +
 fs/lustre/llite/file.c                  | 117 +++++++--
 fs/lustre/llite/llite_internal.h        |  12 +-
 fs/lustre/llite/llite_lib.c             |  28 ++-
 fs/lustre/llite/namei.c                 | 101 +++++++-
 fs/lustre/llite/rw.c                    |   8 +-
 fs/lustre/llite/statahead.c             | 420 ++++++++++++--------------------
 fs/lustre/lmv/lmv_obd.c                 |  23 +-
 fs/lustre/mdc/mdc_internal.h            |   3 +-
 fs/lustre/mdc/mdc_locks.c               |  31 ++-
 fs/lustre/obdclass/llog_swab.c          |  17 +-
 fs/lustre/obdclass/lu_tgt_descs.c       |  11 +-
 fs/lustre/obdclass/obd_sysfs.c          |  61 +++++
 fs/lustre/osc/osc_cache.c               |   2 +-
 fs/lustre/ptlrpc/wiretest.c             |  29 ++-
 include/linux/libcfs/libcfs_crypto.h    |   3 +
 include/linux/lnet/lib-lnet.h           |   1 +
 include/linux/lnet/lib-types.h          |   2 +
 include/uapi/linux/lnet/lnet-types.h    |   2 +-
 include/uapi/linux/lustre/lustre_idl.h  |  22 ++
 include/uapi/linux/lustre/lustre_user.h |  18 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c        |   4 +-
 net/lnet/klnds/o2iblnd/o2iblnd.h        |   1 +
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c     |  16 +-
 net/lnet/libcfs/linux-crypto.c          |   3 +-
 net/lnet/lnet/api-ni.c                  |   5 +-
 net/lnet/lnet/lib-md.c                  |  29 ++-
 net/lnet/lnet/peer.c                    |   3 +-
 32 files changed, 625 insertions(+), 392 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
