Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 02F37C6FA86
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:22:22 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbly2kWFz1y6j;
	Sat, 17 Sep 2022 22:22:22 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVblt4Bl5z1wLC
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:18 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id C9451B99;
 Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C08ED37C; Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:21:50 -0400
Message-Id: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/24] lustre: update to 2.15.52
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

Bring the native Lustre client up to the 2.15.52
release in the OpenSFS tree. Resolved the crush2
issues. Update the fscrypt layer to support a
performance boost developed for Lustre. It was
rejected by the fscrypt community since no one
needs it but Lustre. Once we merge upstream that
work can be introduced.

Alex Zhuravlev (1):
  lustre: mdc: check/grab import before access

Alexander Boyko (1):
  lustre: ptlrpc: adds configurable ping interval

Alexey Lyashkov (1):
  lustre: llite: don't use a kms if it invalid.

Andreas Dilger (2):
  lustre: dne: add crush2 hash type
  lnet: selftest: revert "LU-16011 lnet: use preallocate bulk for
    server"

Bobi Jam (1):
  lustre: flr: allow layout version update from client/MDS

Chris Horn (2):
  lnet: Honor peer timeout of zero
  lnet: Always use ping reply to set route lr_alive

John L. Hammond (6):
  lustre: clio: remove vvp_page_print()
  lustre: clio: remove cpo_prep and cpo_make_ready
  lustre: clio: remove struct vvp_page
  lustre: clio: remove unused convenience functions
  lustre: clio: remove cpl_obj
  lustre: osc: remove oap_cli

Mikhail Pershin (1):
  lustre: llog: handle -EBADR for catalog processing

Mr NeilBrown (6):
  lustre: ptlrpc: change rq_self to struct lnet_nid
  lustre: ptlrpc: pass net num to ptlrpc_uuid_to_connection
  lustre: ptlrpc: change rq_peer to struct lnet_nid
  lustre: ptlrpc: change rq_source to struct lnet_nid
  lustre: ptlrpc: change bd_sender in ptlrpc_bulk_frag_ops
  lustre: ptlrpc: pass lnet_nid for self to ptl_send_buf()

Oleg Drokin (1):
  lustre: update version to 2.15.52

Patrick Farrell (1):
  lustre: osc: Remove submit time

Serguei Smirnov (1):
  lnet: allow direct messages regardless of peer NI status

 fs/lustre/include/cl_object.h           |  45 ++-------
 fs/lustre/include/lu_object.h           |  64 +++++++++++--
 fs/lustre/include/lustre_lmv.h          |  60 ++++++------
 fs/lustre/include/lustre_net.h          |  18 ++--
 fs/lustre/include/lustre_osc.h          |  12 +--
 fs/lustre/include/obd_support.h         |  10 +-
 fs/lustre/ldlm/ldlm_lib.c               |  10 +-
 fs/lustre/ldlm/ldlm_lockd.c             |   6 +-
 fs/lustre/ldlm/ldlm_request.c           |   2 +-
 fs/lustre/llite/dir.c                   |   9 +-
 fs/lustre/llite/file.c                  |  30 +++---
 fs/lustre/llite/namei.c                 |   2 -
 fs/lustre/llite/rw.c                    |  24 ++---
 fs/lustre/llite/rw26.c                  |   5 +-
 fs/lustre/llite/vvp_dev.c               |   7 +-
 fs/lustre/llite/vvp_internal.h          |  22 +----
 fs/lustre/llite/vvp_io.c                |  11 +--
 fs/lustre/llite/vvp_object.c            |   2 +-
 fs/lustre/llite/vvp_page.c              | 127 ++-----------------------
 fs/lustre/lmv/lmv_obd.c                 |   4 +-
 fs/lustre/lov/lov_internal.h            |   2 +-
 fs/lustre/lov/lov_merge.c               |  46 +++++----
 fs/lustre/lov/lov_object.c              |  23 +----
 fs/lustre/mdc/lproc_mdc.c               |  16 ++--
 fs/lustre/obdclass/cl_page.c            | 163 +++++++++++++++-----------------
 fs/lustre/obdclass/class_obd.c          |   5 +
 fs/lustre/obdclass/llog.c               |   4 +-
 fs/lustre/obdclass/obd_config.c         |   1 +
 fs/lustre/obdclass/obd_sysfs.c          |  32 ++++++-
 fs/lustre/osc/osc_cache.c               |  22 ++---
 fs/lustre/osc/osc_io.c                  |   3 +-
 fs/lustre/osc/osc_page.c                |  25 ++---
 fs/lustre/osc/osc_request.c             |   4 +-
 fs/lustre/ptlrpc/client.c               |  11 +--
 fs/lustre/ptlrpc/connection.c           |   7 +-
 fs/lustre/ptlrpc/events.c               |  27 +++---
 fs/lustre/ptlrpc/lproc_ptlrpc.c         |   6 +-
 fs/lustre/ptlrpc/niobuf.c               |  25 +++--
 fs/lustre/ptlrpc/nrs_delay.c            |   2 +-
 fs/lustre/ptlrpc/nrs_fifo.c             |   4 +-
 fs/lustre/ptlrpc/sec.c                  |   2 +-
 fs/lustre/ptlrpc/service.c              |  12 +--
 include/linux/lnet/lib-lnet.h           |   3 +-
 include/uapi/linux/lustre/lustre_user.h |  30 +++---
 include/uapi/linux/lustre/lustre_ver.h  |   4 +-
 net/lnet/lnet/api-ni.c                  |   2 +-
 net/lnet/lnet/lib-move.c                |   4 +
 net/lnet/lnet/peer.c                    |  14 ++-
 net/lnet/lnet/router.c                  |  71 +++-----------
 net/lnet/selftest/brw_test.c            |  67 ++++---------
 net/lnet/selftest/framework.c           |  18 ++--
 net/lnet/selftest/rpc.c                 |  51 ++++------
 net/lnet/selftest/selftest.h            |  15 +--
 53 files changed, 494 insertions(+), 697 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
