Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E7C35ECAAD3
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:55:43 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7l318hwz1y3F;
	Mon,  5 Sep 2022 18:55:43 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7l072Xvz1wn4
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:40 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 95F4F100AFF2;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8C87237C; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:13 -0400
Message-Id: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/24] lustre: update to OpenSFS tree Sept 5,
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

Port the patches from the OpenSFS tree to the Linux native
client as of Sept 5, 2022. The crush2 patch is still held back
and we integrated the fscrypt changes to give a big performance
boost to Lustre.

Alexey Lyashkov (1):
  lnet: selftest: use preallocate bulk for server

Andreas Dilger (2):
  lustre: obdclass: use consistent stats units
  lustre: idl: add checks for OBD_CONNECT flags

Bobi Jam (1):
  lustre: ldlm: rid of obsolete param of ldlm_resource_get()

Chris Horn (3):
  lnet: LNet peer aliveness broken
  lnet: Correct net selection for router ping
  lnet: Remove duplicate checks for peer sensitivity

Frank Sehr (1):
  lnet: Memory leak on adding existing interface

Ian Ziemba (1):
  lnet: o2iblnd: Salt comp_vector

Lai Siyao (1):
  lustre: lmv: always space-balance r-r directories

Mr NeilBrown (1):
  lnet: change ni_status in lnet_ni to u32*

Oleg Drokin (1):
  lustre: update version to 2.15.51

Patrick Farrell (3):
  lustre: llite: Rework upper/lower DIO/AIO
  lustre: llite: Unify range unlock
  lustre: llite: Refactor DIO/AIO free code

Qian Yingjin (4):
  lustre: llite: fully disable readahead in kernel I/O path
  lustre: llite: use fatal_signal_pending in range_lock
  lustre: llite: simplify callback handling for async getattr
  lustre: statahead: add total hit/miss count stats

Sebastien Buisson (4):
  lustre: sec: new connect flag for name encryption
  lustre: sec: use enc pool for bounce pages
  lustre: sec: fix detection of SELinux enforcement
  lustre: llite: fix stat attributes_mask

Serguei Smirnov (1):
  lnet: Use fatal NI if none other available

 fs/crypto/crypto.c                     |  34 +--
 fs/lustre/include/cl_object.h          |  40 ++-
 fs/lustre/include/lprocfs_status.h     |  27 +-
 fs/lustre/include/lustre_crypto.h      |   2 +
 fs/lustre/include/lustre_dlm.h         |   1 -
 fs/lustre/include/lustre_intent.h      |   2 +
 fs/lustre/include/lustre_sec.h         |   3 +
 fs/lustre/include/obd.h                |  27 +-
 fs/lustre/include/obd_class.h          |   4 +-
 fs/lustre/ldlm/ldlm_lock.c             |   6 +-
 fs/lustre/ldlm/ldlm_pool.c             |  34 ++-
 fs/lustre/ldlm/ldlm_request.c          |   4 +-
 fs/lustre/ldlm/ldlm_resource.c         |   9 +-
 fs/lustre/llite/crypto.c               |  19 +-
 fs/lustre/llite/dir.c                  |   8 +-
 fs/lustre/llite/file.c                 |  62 +++--
 fs/lustre/llite/llite_internal.h       |  52 +++-
 fs/lustre/llite/llite_lib.c            |  25 +-
 fs/lustre/llite/lproc_llite.c          |  57 +++--
 fs/lustre/llite/namei.c                |   8 +-
 fs/lustre/llite/rw26.c                 |  86 ++++---
 fs/lustre/llite/statahead.c            | 385 ++++++++++++++--------------
 fs/lustre/llite/symlink.c              |   2 +-
 fs/lustre/llite/xattr_cache.c          |   8 +-
 fs/lustre/llite/xattr_security.c       |  12 +-
 fs/lustre/lmv/lmv_obd.c                |  44 ++--
 fs/lustre/mdc/mdc_dev.c                |   5 +-
 fs/lustre/mdc/mdc_internal.h           |   3 +-
 fs/lustre/mdc/mdc_locks.c              |  32 +--
 fs/lustre/mdc/mdc_reint.c              |   2 +-
 fs/lustre/obdclass/cl_internal.h       |   1 +
 fs/lustre/obdclass/cl_io.c             | 136 ++++++----
 fs/lustre/obdclass/cl_object.c         |   6 +
 fs/lustre/obdclass/lprocfs_status.c    | 244 ++++++++++--------
 fs/lustre/obdclass/lu_object.c         |  17 +-
 fs/lustre/obdclass/range_lock.c        |   2 +-
 fs/lustre/osc/osc_object.c             |   6 +-
 fs/lustre/osc/osc_request.c            | 136 +++++++++-
 fs/lustre/ptlrpc/lproc_ptlrpc.c        |  32 +--
 fs/lustre/ptlrpc/sec_bulk.c            | 452 +++++++++++++++++++++++++++++++--
 fs/lustre/ptlrpc/wiretest.c            |   2 +
 include/linux/fscrypt.h                |  49 +++-
 include/linux/lnet/lib-lnet.h          |  52 +++-
 include/linux/lnet/lib-types.h         |   2 +-
 include/uapi/linux/lustre/lustre_idl.h | 290 ++++++++++-----------
 include/uapi/linux/lustre/lustre_ver.h |   4 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c       |  14 +-
 net/lnet/klnds/o2iblnd/o2iblnd.h       |   2 +
 net/lnet/lnet/api-ni.c                 |  19 +-
 net/lnet/lnet/lib-move.c               |  98 +++----
 net/lnet/lnet/lib-msg.c                |  37 +--
 net/lnet/lnet/router.c                 |  11 +-
 net/lnet/selftest/brw_test.c           |  67 +++--
 net/lnet/selftest/framework.c          |  18 +-
 net/lnet/selftest/rpc.c                |  51 ++--
 net/lnet/selftest/selftest.h           |  15 +-
 56 files changed, 1806 insertions(+), 960 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
