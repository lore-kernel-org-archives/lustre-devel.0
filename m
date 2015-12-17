From: Shraddha <shraddha.6596@gmail.com>
Date: Fri, 18 Dec 2015 02:40:25 +0530
Subject: [lustre-devel] [PATCH 0/5] Staging: lustre: Code cleanups
Message-ID: <1450386630-5662-1-git-send-email-shraddha.6596@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shraddha Barke <shraddha.6596@gmail.com>

These patches remove unused code and declare functions as static

Shraddha Barke (5):
  Staging: lustre: obdclass: Declare cl_env_peek as static
  Staging: lustre: libcfs: Remove unused libcfs_debug_set_level
  Staging: lustre: osc: Declare as static
  Staging: lustre: osc: Declare osc_attr_set as static
  Staging: lustre: obdclass: Declare lu_site_hash_ops as static

 drivers/staging/lustre/lustre/libcfs/debug.c       |  7 -------
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  3 +--
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  2 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 10 +++++-----
 drivers/staging/lustre/lustre/osc/osc_object.c     |  4 ++--
 5 files changed, 9 insertions(+), 17 deletions(-)

-- 
2.1.4
