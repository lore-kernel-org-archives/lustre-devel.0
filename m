From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 21:37:09 -0400
Subject: [lustre-devel] [PATCH 00/12] staging: lustre: add patches from
	lustre 2.5.52 version
Message-ID: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Assortment of bug fixes that are present in the 2.5.52 version
of lustre that is missing in the upstream client.

Amir Shehata (2):
  staging: lustre: obd: remove newline from LCONSOLE string
  staging: lustre: obd: add newline for dumped config record

Andreas Dilger (1):
  staging: lustre: llite: debugging for ll_file_open LASSERT

Andriy Skulysh (1):
  staging: lustre: libcfs: Fix NUMA emulated mode

Dmitry Eremin (2):
  staging: lustre: ldlm: check all errors during ldlm_debugfs_setup()
  staging: lustre: llite: fixup return value ll_direct_IO_26

Lai Siyao (2):
  staging: lustre: fid: add a connect flag for open by FID
  staging: lustre: llog: we don't need vfsmount

Mikhail Pershin (2):
  staging: lustre: ptlrpc: use unified handler for OST requests
  staging: lustre: ptlrpc: initialize request session early

Swapnil Pimpale (2):
  staging: lustre: obd: cleanup client import if client_obd_setup fails
  staging: lustre: llite: check ret of ll_prep_md_op_data in ll_dir_filler

 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |  9 +++-
 .../lustre/lustre/include/lustre/lustre_idl.h      |  3 ++
 .../staging/lustre/lustre/include/lustre_disk.h    |  2 -
 .../lustre/lustre/include/lustre_req_layout.h      |  2 +-
 .../staging/lustre/lustre/include/obd_support.h    |  1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  6 +++
 drivers/staging/lustre/lustre/llite/dir.c          |  7 ++-
 drivers/staging/lustre/lustre/llite/file.c         |  4 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  2 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |  3 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      | 16 +++++--
 drivers/staging/lustre/lustre/ptlrpc/service.c     | 53 +++++++++++++---------
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |  2 +
 14 files changed, 74 insertions(+), 37 deletions(-)

--
2.7.4
