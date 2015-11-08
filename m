From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Sun,  8 Nov 2015 14:46:44 +0530
Subject: [lustre-devel] [PATCH 0/2] Remove wrapper functions from workitem
Message-ID: <cover.1446974107.git.shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patchset removes unnecessary wrapper functions from the file workitem
and replace all their calls with the function that they wrap.
After applying this patch, code becomes cleaner.

Shivani Bhardwaj (2):
  staging: lustre: workitem: Remove cfs_wi_sched_lock wrapper
  staging: lustre: workitem: Remove cfs_wi_sched_unlock wrapper

 drivers/staging/lustre/lustre/libcfs/workitem.c | 48 ++++++++++---------------
 1 file changed, 18 insertions(+), 30 deletions(-)

-- 
2.1.0
