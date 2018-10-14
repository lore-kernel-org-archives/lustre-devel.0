From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 15:00:39 -0400
Subject: [lustre-devel] [PATCH 0/7] lustre: project quota support and
 BLKSZGET
Message-ID: <1539543646-29717-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Add support for BLKSZGET and project quota support that landed to
lustre 2.10. This patch set depends on the earlier patch set sent
and are not order independent.

Emoly Liu (1):
  lustre: ioctl: Add BLKSSZGET ioctl support

Li Xi (1):
  lustre: quota: add project quota support for Lustre

Oleg Drokin (2):
  lustre: quota: cleanup codes of quota for new type
  lustre: quota: add project id support

Wang Shilong (3):
  lustre: quota: add setting/getting project id function
  lustre: quota: add project inherit attributes
  lustre: llite: extend inode flags into GET/SETXATTR ioctl

 .../lustre/include/uapi/linux/lustre/lustre_idl.h  | 40 ++++++++--
 .../lustre/include/uapi/linux/lustre/lustre_user.h | 15 +++-
 drivers/staging/lustre/lustre/include/cl_object.h  |  6 +-
 drivers/staging/lustre/lustre/include/obd.h        |  4 +
 drivers/staging/lustre/lustre/llite/dir.c          | 28 +++++--
 drivers/staging/lustre/lustre/llite/file.c         | 88 ++++++++++++++++++++++
 .../staging/lustre/lustre/llite/llite_internal.h   | 10 ++-
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 17 ++++-
 drivers/staging/lustre/lustre/llite/vvp_object.c   |  9 ++-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |  3 +
 drivers/staging/lustre/lustre/obdclass/obdo.c      |  7 ++
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  1 +
 drivers/staging/lustre/lustre/osc/osc_quota.c      | 46 +++++++----
 drivers/staging/lustre/lustre/osc/osc_request.c    | 13 ++--
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |  8 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 30 +++++---
 16 files changed, 275 insertions(+), 50 deletions(-)

-- 
1.8.3.1
