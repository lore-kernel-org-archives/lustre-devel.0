From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 May 2018 22:16:58 -0400
Subject: [lustre-devel] [PATCH 0/5] staging: lustre: llite: remaining xattr
 fixes
Message-ID: <1526350623-4616-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Fixed the bugs in the set_acl patch pointed out by Dan Carpenter.
Rebased the next patch 'remove unused parameter..." on the parent
patch. Added newer xattr fixes that were recently pushed.

Andrew Perepechko (1):
  staging: lustre: mdc: excessive memory consumption by the xattr cache

Dmitry Eremin (1):
  staging: lustre: llite: add support set_acl method in inode operations

Fan Yong (1):
  staging: lustre: acl: increase ACL entries limitation

John L. Hammond (2):
  staging: lustre: llite: remove unused parameters from md_{get,set}xattr()
  staging: lustre: mdc: use large xattr buffers for old servers

 .../lustre/include/uapi/linux/lustre/lustre_idl.h  |  2 +-
 drivers/staging/lustre/lustre/include/lustre_acl.h |  7 ++-
 drivers/staging/lustre/lustre/include/obd.h        |  7 +--
 drivers/staging/lustre/lustre/include/obd_class.h  | 21 +++----
 drivers/staging/lustre/lustre/llite/file.c         | 65 +++++++++++++++++++++-
 .../staging/lustre/lustre/llite/llite_internal.h   |  4 ++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  3 +-
 drivers/staging/lustre/lustre/llite/namei.c        | 10 +++-
 drivers/staging/lustre/lustre/llite/xattr.c        |  6 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 22 ++++----
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      | 42 +++++++++++---
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |  2 +
 drivers/staging/lustre/lustre/mdc/mdc_request.c    | 38 ++++++++-----
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |  4 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |  4 +-
 15 files changed, 171 insertions(+), 66 deletions(-)

-- 
1.8.3.1
