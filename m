From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:21:39 -0400
Subject: [lustre-devel] [PATCH v2 0/6] staging: lustre: llite: remaining
 xattr patches
Message-ID: <1527603705-30450-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <uja.ornl@yahoo.com>

From: James Simmons <uja.ornl@yahoo.com>

Fixed the bugs in the set_acl patch pointed out by Dan Carpenter.
Rebased the next patch 'remove unused parameter..." on the parent
patch. Created new acl.c file to match what other linx kernel file
systems do. Added newer xattr fixes that were recently pushed.

Andrew Perepechko (1):
  staging: lustre: mdc: excessive memory consumption by the xattr cache

Dmitry Eremin (1):
  staging: lustre: llite: add support set_acl method in inode operations

Fan Yong (1):
  staging: lustre: acl: increase ACL entries limitation

James Simmons (1):
  staging: lustre: llite: create acl.c file

John L. Hammond (2):
  staging: lustre: llite: remove unused parameters from md_{get,set}xattr()
  staging: lustre: mdc: use large xattr buffers for old servers

 .../lustre/include/uapi/linux/lustre/lustre_idl.h  |   2 +-
 drivers/staging/lustre/lustre/include/lustre_acl.h |   7 +-
 drivers/staging/lustre/lustre/include/obd.h        |   7 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |  21 ++--
 drivers/staging/lustre/lustre/llite/Makefile       |   2 +
 drivers/staging/lustre/lustre/llite/acl.c          | 108 +++++++++++++++++++++
 drivers/staging/lustre/lustre/llite/file.c         |  16 +--
 .../staging/lustre/lustre/llite/llite_internal.h   |   7 ++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   3 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |   6 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  22 ++---
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  42 ++++++--
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   2 +
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  38 +++++---
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   4 +-
 16 files changed, 214 insertions(+), 77 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/llite/acl.c
----------
Changelog:

v1) Initial patch set with fixes to address issues pointed by Dan.
v2) Created new acl.c file and rebased the patches due to that change

-- 
1.8.3.1
