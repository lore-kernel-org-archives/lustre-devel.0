From: NeilBrown <neilb@suse.com>
Date: Wed, 24 Apr 2019 12:17:26 +1000
Subject: [lustre-devel] [PATCH 1/4] lustre: stop using deprecated wrappers.
In-Reply-To: <155607223991.16863.3231709121984405156.stgit@noble.brown>
References: <155607223991.16863.3231709121984405156.stgit@noble.brown>
Message-ID: <155607224614.16863.4989845798565604514.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

ib_sg_dma_address(), ib_sg_dma_len(), and get_ds()
were simple wrappers that are no longer provided, so
replace them with the code they were wrapping.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    4 ++--
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 852ada838a1c..3f28c5b7d74e 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -951,13 +951,13 @@ static inline void kiblnd_dma_unmap_sg(struct ib_device *dev,
 static inline u64 kiblnd_sg_dma_address(struct ib_device *dev,
 					  struct scatterlist *sg)
 {
-	return ib_sg_dma_address(dev, sg);
+	return sg_dma_address(sg);
 }
 
 static inline unsigned int kiblnd_sg_dma_len(struct ib_device *dev,
 					     struct scatterlist *sg)
 {
-	return ib_sg_dma_len(dev, sg);
+	return sg_dma_len(sg);
 }
 
 /* XXX We use KIBLND_CONN_PARAM(e) as writable buffer, it's not strictly */
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 45da892cf276..d634e2281c58 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -829,7 +829,7 @@ int cfs_tracefile_dump_all_pages(char *filename)
 		goto close;
 	}
 	__oldfs = get_fs();
-	set_fs(get_ds());
+	set_fs(KERNEL_DS);
 
 	/* ok, for now, just write the pages.  in the future we'll be building
 	 * iobufs with the pages and calling generic_direct_IO
