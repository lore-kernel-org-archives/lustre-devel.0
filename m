From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 12:20:50 -0400
Subject: [lustre-devel] [PATCH 00/14] staging: lustre: llite: xattr related
	handling fixes
Message-ID: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This batch of patches resolves several issues with how lustre handles
xattrs. Some of the patches also resolve some style issues with the code.
The patch set is order dependent. These fixes resolve some of the test
failures that happen.

Bobi Jam (2):
  staging: lustre: llite: break up ll_setstripe_ea function
  staging: lustre: llite: return from ll_adjust_lum() if lump is NULL

Dmitry Eremin (1):
  staging: lustre: llite: add support set_acl method in inode operations

James Simmons (8):
  staging: lustre: llite: eat -EEXIST on setting trunsted.lov
  staging: lustre: llite: fix sparse variable length array warning
  staging: lustre: llite: fix invalid size test in ll_setstripe_ea()
  staging: lustre: llite: record in stats attempted removal of lma/link xattr
  staging: lustre: llite: cleanup posix acl xattr code
  staging: lustre: llite: use proper types in the xattr code
  staging: lustre: llite: cleanup xattr code comments
  staging: lustre: llite: style changes in xattr.c

Niu Yawei (2):
  staging: lustre: llite: refactor lustre.lov xattr handling
  staging: lustre: llite: add simple comment about lustre.lov xattrs

Robin Humble (1):
  staging: lustre: llite: Remove filtering of seclabel xattr

 drivers/staging/lustre/lustre/llite/file.c         |  58 ++++++
 .../staging/lustre/lustre/llite/llite_internal.h   |   4 +
 drivers/staging/lustre/lustre/llite/namei.c        |  10 +-
 drivers/staging/lustre/lustre/llite/xattr.c        | 222 ++++++++++++---------
 4 files changed, 196 insertions(+), 98 deletions(-)

-- 
1.8.3.1
