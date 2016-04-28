From: James Simmons <jsimmons@infradead.org>
Date: Thu, 28 Apr 2016 12:07:30 -0400
Subject: [lustre-devel] [PATCH 0/8] staging : lustre : missing fixes for
	lustre 2.5.53
Message-ID: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This next set of patches covers what is in the upstream client that
is present in lustre 2.5.53

Alexander Boyko (1):
  staging: lustre: brw: added OBDO short io flag

Andreas Dilger (1):
  staging: lustre: llite: quiet overly verbose info message

Emoly Liu (2):
  staging: lustre: obd: add case LCFG_PARAM to osd_process_config
  staging: lustre: debugfs: improve osc/mdc "imports" connect data

John L. Hammond (1):
  staging: lustre: echo: remove echo_env_info() regions from echo_client.c

Oleg Drokin (1):
  staging: lustre: debug: initialize debug_msg_data if needed

Sebastien Buisson (1):
  staging: lustre: ldlm: dont always check max_pages_per_rpc alignement

wang di (1):
  staging: lustre: fld: add local fldb to each target

 drivers/staging/lustre/lustre/fid/fid_request.c    |  5 +-
 drivers/staging/lustre/lustre/fld/fld_internal.h   |  9 +--
 drivers/staging/lustre/lustre/fld/fld_request.c    | 79 +++++++++++++++-------
 drivers/staging/lustre/lustre/include/cl_object.h  |  6 +-
 drivers/staging/lustre/lustre/include/lu_object.h  |  6 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      | 20 +++++-
 .../staging/lustre/lustre/include/lustre_param.h   |  1 +
 .../lustre/lustre/include/lustre_req_layout.h      |  1 +
 .../staging/lustre/lustre/include/obd_support.h    |  1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  6 ++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  4 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        | 63 +++++++++++++++--
 .../staging/lustre/lustre/obdclass/obd_config.c    | 20 +++---
 .../staging/lustre/lustre/obdecho/echo_client.c    |  2 -
 drivers/staging/lustre/lustre/ptlrpc/layout.c      | 15 ++++
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  1 +
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |  4 +-
 17 files changed, 176 insertions(+), 67 deletions(-)

--
2.7.4
