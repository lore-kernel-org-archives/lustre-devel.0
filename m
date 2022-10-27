Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8931DECAAA1
	for <lustre-devel@archiver.kernel.org>; Thu, 27 Oct 2022 14:06:12 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MynX52WPVz1y4W;
	Thu, 27 Oct 2022 07:05:57 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MynWs5k1zz1wLC
 for <lustre-devel@lists.lustre.org>; Thu, 27 Oct 2022 07:05:45 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 6AE8E10090F0;
 Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 5E538E8CAE; Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 27 Oct 2022 10:05:27 -0400
Message-Id: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/15] lustre: sync to OpenSFS Oct 27, 2022
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

Backport the latest work that has landed to OpenSFS as of Oct 27, 2022.

Andreas Dilger (2):
  lustre: ptlrpc: reduce lock contention in ptlrpc_free_committed
  lustre: llite: only statfs for projid if PROJINHERIT set

Bobi Jam (1):
  lustre: llite: adjust read count as file got truncated

Chris Horn (2):
  lnet: o2iblnd: Avoid NULL md deref
  lnet: Discovery queue and deletion race

James Simmons (1):
  lnet: ksocklnd: fix irq lock inversion while calling sk_data_ready()

Jian Yu (2):
  lnet: use 'fallthrough' pseudo keyword for switch
  lustre: use 'fallthrough' pseudo keyword for switch

Li Dongyang (1):
  lustre: obdclass: fix race in class_del_profile

Mr NeilBrown (1):
  lnet: support IPv6 in lnet_inet_enumerate()

Qian Yingjin (1):
  lustre: statahead: avoid to block ptlrpcd interpret context

Sebastien Buisson (1):
  lustre: sec: retry ro mount if read-only flag set

Serguei Smirnov (1):
  lnet: add mechanism for dumping lnd peer debug info

Vitaly Fertman (2):
  lustre: llite: revert: "lustre: llite: prevent mulitple group locks"
  lustre: ldlm: group lock fix

 fs/lustre/fld/fld_request.c             |   1 +
 fs/lustre/include/lu_object.h           |   1 +
 fs/lustre/include/lustre_import.h       |   6 ++
 fs/lustre/include/lustre_intent.h       |   2 -
 fs/lustre/include/lustre_osc.h          |  15 +++
 fs/lustre/include/obd.h                 |   6 +-
 fs/lustre/ldlm/ldlm_lib.c               |  13 ++-
 fs/lustre/ldlm/ldlm_request.c           |   5 +-
 fs/lustre/llite/dir.c                   |   4 +-
 fs/lustre/llite/file.c                  | 160 +++++++++++++++++++----------
 fs/lustre/llite/glimpse.c               |   7 +-
 fs/lustre/llite/llite_internal.h        |   9 --
 fs/lustre/llite/llite_lib.c             |  39 +++----
 fs/lustre/llite/namei.c                 |   6 +-
 fs/lustre/llite/statahead.c             | 173 +++++++++++++-------------------
 fs/lustre/lmv/lmv_obd.c                 |  23 +++--
 fs/lustre/lov/lov_cl_internal.h         |   6 +-
 fs/lustre/lov/lov_object.c              |  16 +--
 fs/lustre/mdc/mdc_dev.c                 |  46 +++++++--
 fs/lustre/mdc/mdc_locks.c               |   3 +-
 fs/lustre/obdclass/genops.c             |   1 +
 fs/lustre/obdclass/lu_tgt_descs.c       |   5 +-
 fs/lustre/obdclass/obd_config.c         |  23 +++--
 fs/lustre/obdecho/echo_client.c         |   2 +-
 fs/lustre/osc/osc_cache.c               |   2 +-
 fs/lustre/osc/osc_lock.c                | 159 +++++++++++++++++++++++++++--
 fs/lustre/osc/osc_object.c              |  16 +++
 fs/lustre/ptlrpc/client.c               |  99 +++++++++++++++---
 fs/lustre/ptlrpc/pack_generic.c         |   8 +-
 fs/lustre/ptlrpc/ptlrpc_module.c        |  12 +--
 include/linux/lnet/lib-lnet.h           |  15 ++-
 include/uapi/linux/lustre/lustre_user.h |   2 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c        | 104 +++++++++++++++++--
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c     |  14 +--
 net/lnet/klnds/socklnd/socklnd.c        |  93 ++++++++++++++---
 net/lnet/klnds/socklnd/socklnd_cb.c     |   2 +-
 net/lnet/klnds/socklnd/socklnd_lib.c    |   4 +-
 net/lnet/lnet/config.c                  |  77 ++++++++++++--
 net/lnet/lnet/lib-move.c                |   4 +-
 net/lnet/lnet/net_fault.c               |   2 +-
 net/lnet/lnet/peer.c                    |  39 +++----
 net/lnet/selftest/conctl.c              |   2 +-
 net/lnet/selftest/module.c              |   8 +-
 net/lnet/selftest/rpc.c                 |  21 ++--
 44 files changed, 903 insertions(+), 352 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
