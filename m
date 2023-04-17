Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5DB16C77B77
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 13:47:48 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0SzW5bS7z1yBp;
	Mon, 17 Apr 2023 06:47:35 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0SzK4ZcMz1y5y
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:47:25 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 52E531005F81;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4968F2D4; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:46:56 -0400
Message-Id: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/27] lustre: sync to OpenSFS branch April
 17, 2023
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

Latest work from the Lustre community ported to the Native
Linux client.

Alex Zhuravlev (3):
  lustre: protocol: add OBD_BRW_COMPRESSED
  lustre: obdclass: fix rpc slot leakage
  lustre: llite: only first sync to MDS matter

Andreas Dilger (3):
  lnet: libcfs: cleanup console messages
  lustre: misc: remove unnecessary ioctl typecasts
  lustre: llite: move common ioctl code to ll_iocontrol()

Bobi Jam (4):
  lustre: lov: continue fsync on other OST objs even on -ENOENT
  lustre: llite: protect cp_state with vmpage lock
  lustre: llite: call truncate_inode_pages() under inode lock
  lustre: ldlm: clear lock converting flag on resource cleanup

Chris Horn (1):
  lnet: Health logging improvements

Etienne AUJAMES (1):
  lustre: llite: fix LSOM blocks for ftruncate and close

James Simmons (1):
  lnet: handle multi-rail setups

Li Dongyang (2):
  lustre: llite: restart clio for AIO if necessary
  lustre: fid: reduce LUSTRE_DATA_SEQ_MAX_WIDTH

Mr NeilBrown (3):
  lnet: change LNetAddPeer() to take struct lnet_nid
  lustre: obdclass: change class_add/check_uuid to large nid
  lustre: obdclass: rename class_parse_nid to class_parse_nid4

Oleg Drokin (1):
  lustre: update version to 2.15.54

Qian Yingjin (3):
  lustre: llite: fix the wrong beyond read end calculation
  lustre: readahead: clip readahead with kms
  lustre: statahead: batched statahead processing

Serguei Smirnov (2):
  lnet: use discovered ni status to set initial health
  lnet: add 'lock_prim_nid" lnet module parameter

Timothy Day (2):
  lustre: uapi: fix unused function errors
  lnet: fix clang build errors

Yang Sheng (1):
  lustre: statahead: statahead thread doesn't stop

 fs/lustre/fid/lproc_fid.c              |   2 +-
 fs/lustre/include/lustre_dlm.h         |  10 +-
 fs/lustre/include/lustre_fid.h         |  65 +--------
 fs/lustre/include/lustre_req_layout.h  |   7 +
 fs/lustre/include/obd.h                |   2 +
 fs/lustre/include/obd_class.h          |  11 +-
 fs/lustre/ldlm/ldlm_lib.c              |  13 +-
 fs/lustre/ldlm/ldlm_request.c          |  80 +++++++++--
 fs/lustre/ldlm/ldlm_resource.c         |   1 +
 fs/lustre/llite/acl.c                  |   2 +
 fs/lustre/llite/dir.c                  | 128 +++--------------
 fs/lustre/llite/file.c                 | 243 ++++++++++++++-------------------
 fs/lustre/llite/lcommon_cl.c           |   4 +-
 fs/lustre/llite/llite_internal.h       |  40 ++++--
 fs/lustre/llite/llite_lib.c            | 190 +++++++++++++++++++++-----
 fs/lustre/llite/lproc_llite.c          |  47 ++++++-
 fs/lustre/llite/rw.c                   |  11 +-
 fs/lustre/llite/statahead.c            | 121 +++++++++++++---
 fs/lustre/llite/vvp_io.c               |  40 +++++-
 fs/lustre/llite/vvp_object.c           |   9 +-
 fs/lustre/llite/xattr.c                |   1 +
 fs/lustre/lmv/lmv_obd.c                |  27 ++++
 fs/lustre/lov/lov_io.c                 |  10 +-
 fs/lustre/mdc/mdc_batch.c              | 163 +++++++++++++++++++++-
 fs/lustre/mdc/mdc_dev.c                |   4 +-
 fs/lustre/mdc/mdc_internal.h           |   6 +
 fs/lustre/mdc/mdc_locks.c              |  24 ++--
 fs/lustre/mdc/mdc_request.c            |   3 +
 fs/lustre/obdclass/cl_page.c           |   6 +-
 fs/lustre/obdclass/class_obd.c         |  16 +--
 fs/lustre/obdclass/genops.c            |  11 +-
 fs/lustre/obdclass/kernelcomm.c        |   7 +-
 fs/lustre/obdclass/lustre_peer.c       |  34 ++---
 fs/lustre/obdclass/obd_config.c        |  31 +++--
 fs/lustre/obdclass/obd_mount.c         |   8 +-
 fs/lustre/osc/osc_io.c                 |   5 +
 fs/lustre/osc/osc_request.c            |   5 +-
 fs/lustre/ptlrpc/layout.c              |  40 ++++++
 fs/lustre/ptlrpc/wiretest.c            |   2 +
 include/linux/lnet/api.h               |   2 +-
 include/linux/lnet/lib-lnet.h          |   4 +-
 include/linux/lnet/lib-types.h         |   5 +
 include/uapi/linux/lnet/lnet-types.h   |   4 +-
 include/uapi/linux/lustre/lustre_fid.h |  65 +++++++++
 include/uapi/linux/lustre/lustre_idl.h |   1 +
 include/uapi/linux/lustre/lustre_ver.h |   4 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c       |  51 +++++--
 net/lnet/klnds/socklnd/socklnd.c       |  38 ++++--
 net/lnet/libcfs/libcfs_cpu.c           |  14 +-
 net/lnet/lnet/api-ni.c                 | 210 ++++++++++++++++------------
 net/lnet/lnet/lib-move.c               | 165 ++++++++++++++++++++--
 net/lnet/lnet/lib-msg.c                |  16 ++-
 net/lnet/lnet/peer.c                   | 132 +++++++++++-------
 net/lnet/selftest/conctl.c             |   7 +-
 54 files changed, 1488 insertions(+), 659 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
