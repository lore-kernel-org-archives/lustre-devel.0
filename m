From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:14:49 -0400
Subject: [lustre-devel] [PATCH 00/22] staging: lustre: llite: fix xattr
 handling
Message-ID: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: James Simmons <uja.ornl@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: James Simmons <uja.ornl@yahoo.com>

Lustre utilities and user land APIs heavly depend on special xattr
handling. Sadly much of the xattr handling for lustre client has
been broken for awhile. This is all the fixes needed to make xattr
handling work properly with the latest kernels.

Bobi Jam (3):
  staging: lustre: llite: break up ll_setstripe_ea function
  staging: lustre: llite: return from ll_adjust_lum() if lump is NULL
  staging: lustre: llite: eat -EEXIST on setting trusted.lov

Dmitry Eremin (1):
  staging: lustre: llite: add support set_acl method in inode operations

James Simmons (9):
  staging: lustre: llite: initialize xattr->xe_namelen
  staging: lustre: llite: fix invalid size test in ll_setstripe_ea()
  staging: lustre: llite: remove newline in fullname strings
  staging: lustre: llite: record in stats attempted removal of lma/link xattr
  staging: lustre: llite: cleanup posix acl xattr code
  staging: lustre: llite: use proper types in the xattr code
  staging: lustre: llite: cleanup xattr code comments
  staging: lustre: llite: style changes in xattr.c
  staging: lustre: llite: correct removexattr detection

John L. Hammond (3):
  staging: lustre: llite: handle xattr cache refill race
  staging: lustre: llite: use xattr_handler name for ACLs
  staging: lustre: llite: remove unused parameters from md_{get,set}xattr()

Niu Yawei (2):
  staging: lustre: llite: refactor lustre.lov xattr handling
  staging: lustre: llite: add simple comment about lustre.lov xattrs

Robin Humble (1):
  staging: lustre: llite: Remove filtering of seclabel xattr

Vitaly Fertman (3):
  staging: lustre: obd: create it_has_reply_body()
  staging: lustre: obd: change debug reporting in lmv_enqueue()
  staging: lustre: ldlm: xattr locks are lost on mdt

 drivers/staging/lustre/lustre/include/obd.h        |  20 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |  24 +--
 drivers/staging/lustre/lustre/llite/file.c         |  86 ++++++--
 .../staging/lustre/lustre/llite/llite_internal.h   |   4 +
 drivers/staging/lustre/lustre/llite/namei.c        |  10 +-
 drivers/staging/lustre/lustre/llite/xattr.c        | 231 ++++++++++++---------
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |  83 +++-----
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  12 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  36 ++--
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |   4 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  68 ++++--
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  34 +--
 12 files changed, 364 insertions(+), 248 deletions(-)

-- 
1.8.3.1
