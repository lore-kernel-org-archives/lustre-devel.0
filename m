Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9F478C0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:12:04 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLYp3BLrz1xf5;
	Thu, 30 Jan 2025 06:11:58 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLYL16Wnz1xGG
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:11:34 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D3E9917D1DE;
 Thu, 30 Jan 2025 09:11:32 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id CB8E9106BE14; Thu, 30 Jan 2025 09:11:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:10:50 -0500
Message-ID: <20250130141115.950749-1-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 00/25] lustre: sync to OpenSFS branch April
 30, 2023
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

Latest work from the Lustre community ported to the Native
Linux client.

Alex Zhuravlev (1):
  lustre: lov: refresh LOVEA with LL granted

Andreas Dilger (4):
  lustre: obdclass: improve iocontrol error messages
  lustre: mount: improve mount/unmount messages
  lustre: misc: standardize iocontrol param handling
  lustre: obdclass: init osc.*.rpc_stats start_time

Chris Horn (2):
  lustre: ptlrpc: Track highest reply XID
  lnet: Check empty list in cfs_match_nid_net

Etienne AUJAMES (2):
  lustre: tbf: pb_uid/pb_gid ptlrpc_body fields for TBF rules
  lustre: nrs: change nrs policies at run time

James Simmons (2):
  lustre: remove additional cl_env_get()
  lnet: restore IOC_LIBCFS_GET_NI

Mr NeilBrown (5):
  lustre: introduce class_parse_nid()
  lnet: change cfs_match_nid to take large nid.
  lnet: move libcfs_nidstr to UAPI headers
  lustre: obdclass: convert class_parse_nid4 to class_parse_nid
  lustre: obdclass: remove class_parse_nid4()

Oleg Drokin (1):
  lustre: obdclass: Free t10pi crypto state on error

Patrick Farrell (2):
  lustre: llite: Check for page deletion after fault
  lustre: remove obsolete OBD_FAIL_OSC_DIO_PAUSE fail_loc

Qian Yingjin (4):
  lustre: pcc: reserve flags for PCC-RO
  lustre: statahead: add stats for batch RPC requests
  lustre: ptlrpc: grow PtlRPC properly when prepare sub request
  lustre: ptlrpc: retry mechanism for overflowed batched RPCs

Sebastien Buisson (1):
  lustre: enc: make sure DoM files are correctly decrypted

Vitaly Fertman (1):
  Revert "lustre: llite: access lli_lsm_md with lock in all places"

 fs/lustre/include/cl_object.h           |   3 +
 fs/lustre/include/lustre_import.h       |   4 +-
 fs/lustre/include/lustre_net.h          |   7 +
 fs/lustre/include/lustre_nrs.h          |  12 +-
 fs/lustre/include/lustre_req_layout.h   |   3 +
 fs/lustre/include/obd.h                 |   3 +
 fs/lustre/include/obd_class.h           |  13 +-
 fs/lustre/include/obd_support.h         |   3 +-
 fs/lustre/ldlm/ldlm_lib.c               |   2 +
 fs/lustre/llite/dir.c                   |  13 +-
 fs/lustre/llite/file.c                  |  96 ++++++------
 fs/lustre/llite/llite_internal.h        |  29 ++--
 fs/lustre/llite/llite_lib.c             |  46 +++---
 fs/lustre/llite/llite_mmap.c            |  13 +-
 fs/lustre/llite/namei.c                 |  13 +-
 fs/lustre/llite/statahead.c             |   2 -
 fs/lustre/llite/vvp_io.c                |   8 +-
 fs/lustre/llite/vvp_object.c            |   9 +-
 fs/lustre/llite/vvp_page.c              |   4 +
 fs/lustre/lmv/lmv_obd.c                 |  40 +++--
 fs/lustre/lov/lov_obd.c                 |  39 ++++-
 fs/lustre/lov/lov_object.c              |  18 +++
 fs/lustre/mdc/lproc_mdc.c               |  44 ++++++
 fs/lustre/mdc/mdc_batch.c               |   2 +-
 fs/lustre/mdc/mdc_request.c             |  32 ++--
 fs/lustre/obdclass/class_obd.c          | 174 +++++++++++----------
 fs/lustre/obdclass/integrity.c          |  35 +++--
 fs/lustre/obdclass/obd_config.c         |  29 ++--
 fs/lustre/obdclass/obd_mount.c          |  34 +++--
 fs/lustre/obdecho/echo_client.c         |  17 ++-
 fs/lustre/osc/osc_request.c             |  32 +++-
 fs/lustre/ptlrpc/batch.c                | 158 +++++++++++++++++++-
 fs/lustre/ptlrpc/client.c               |  33 ++--
 fs/lustre/ptlrpc/events.c               |   3 +
 fs/lustre/ptlrpc/layout.c               | 191 +++++++++++++++++++++++-
 fs/lustre/ptlrpc/niobuf.c               |   5 +
 fs/lustre/ptlrpc/nrs.c                  | 166 +++++++++++++-------
 fs/lustre/ptlrpc/nrs_delay.c            |   3 +-
 fs/lustre/ptlrpc/nrs_fifo.c             |   2 +-
 fs/lustre/ptlrpc/pack_generic.c         | 169 +++++++++++++++++++--
 fs/lustre/ptlrpc/ptlrpcd.c              |   4 +-
 fs/lustre/ptlrpc/wiretest.c             |  26 +++-
 include/linux/lnet/lib-types.h          |  11 --
 include/uapi/linux/lnet/libcfs_ioctl.h  |   2 +-
 include/uapi/linux/lnet/nidstr.h        |  13 +-
 include/uapi/linux/lustre/lustre_idl.h  |   8 +-
 include/uapi/linux/lustre/lustre_user.h |  18 ++-
 net/lnet/lnet/api-ni.c                  |   7 +
 net/lnet/lnet/nidstrings.c              |  14 +-
 49 files changed, 1220 insertions(+), 392 deletions(-)

-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
