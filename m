From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Nov 2015 12:22:06 -0500
Subject: [lustre-devel] [PATCH v2 0/7] staging: lustre: second series for
	libcfs hash code cleanup
Message-ID: <1446484933-23571-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch covers more style cleanup series for the libcfs
hash code. Mostly removal of white spaces and resolving the
checkpath issues in libcfs_hash.h.

James Simmons (7):
  staging: lustre: remove white space in libcfs_hash.h
  staging: lustre: remove obsolete comment in libcfs_hash.h
  staging: lustre: move linux hash.h header to start of libcfs_hash.h
  staging: lustre: use proper comment blocks for libcfs_hash.h
  staging: lustre: handle NULL comparisons correctly for libcfs_hash.h
  staging: lustre: remove white space in hash.c
  staging: lustre: place linux header first in hash.c

 .../lustre/include/linux/libcfs/libcfs_hash.h      |  170 +++++-----
 drivers/staging/lustre/lustre/libcfs/hash.c        |  344 ++++++++++----------
 2 files changed, 266 insertions(+), 248 deletions(-)
