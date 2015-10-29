From: James Simmons <jsimmons@infradead.org>
Date: Thu, 29 Oct 2015 17:35:16 -0400
Subject: [lustre-devel] [PATCH 0/6] staging: lustre: second series for
	libcfs hash code cleanup
Message-ID: <1446154522-12929-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

This patch covers more style cleanup series for the libcfs
hash code. Mostly removal of white spaces and resolving the
checkpath issues in libcfs_hash.h.

James Simmons (6):
  staging: lustre: remove white space in libcfs_hash.h
  staging: lustre: remove obsolete comment in libcfs_hash.h
  staging: lustre: move linux hash.h header to start of libcfs_hash.h
  staging: lustre: fix remaining checkpatch issues for libcfs_hash.h
  staging: lustre: remove white space in hash.c
  staging: lustre: place linux header first in hash.c

 .../lustre/include/linux/libcfs/libcfs_hash.h      |  170 +++++-----
 drivers/staging/lustre/lustre/libcfs/hash.c        |  344 ++++++++++----------
 2 files changed, 266 insertions(+), 248 deletions(-)
