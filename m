From: Ming Lei <tom.leiming@gmail.com>
Date: Thu, 14 Apr 2016 20:02:18 +0800
Subject: [lustre-devel] [PATCH v1 00/27] block: cleanup direct access to
	.bi_vcnt & .bi_io_vec
Message-ID: <1460635375-28282-1-git-send-email-tom.leiming@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jens Axboe <axboe-b10kYP2dOMg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Mike Snitzer <snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>, Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>, Oleg Drokin <green-SOTZviwpzew/JUsKyNonYw@public.gmane.org>, Keith Busch <keith.busch-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "open list:MEMORY MANAGEMENT" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, "open list:DEVICE-MAPPER  LVM" <dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "open list:TARGET SUBSYSTEM" <target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Miklos Szeredi <mszeredi-AlSwsSmVLrQ@public.gmane.org>, "open list:DRBD DRIVER" <drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>, "open list:STAGING SUBSYSTEM" <devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org>, "open list:TARGET SUBSYSTEM" <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Minchan Kim <minchan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Jarod Wilson <jarod-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Swee Hua Law <sweehua81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Kent Overstreet <kent.overstreet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "open list:HIBERNATION aka Software Suspend,
	aka swsusp" <linux-pm-u79uwXL29TaqPxH82wqD4g@public.gmane.org>

Hi Guys,

It is always not a good practice to access bio->bi_vcnt and
bio->bi_io_vec from drivers directly. Also this kind of direct
access will cause trouble when converting to multipage bvecs
because currently drivers may suppose one bvec always include
one page, and use the two fields to figure out how to handle
pages.

Even the actual meaning of the two fields arn't change from
block subsystem's view, but it may change from driver or fs's
view, so this patchset takes a conservative approach to cleanup
direct access to the two fields for avoiding regressions.

The 1st patch introduces the following 3 bio helpers which can be
used inside drivers for avoiding direct access to .bi_vcnt and .bi_io_vec.

        bio_pages()
        bio_get_base_vec()
        bio_set_vec_table()

bio_pages() can be easy to convert to multipage bvecs.

For bio_get_base_vec() and bio_set_vec_table(), they are often used
during initializing a new bio or in case of single bvec bio. With the
two new helpers, it becomes quite easy to audit access to .bi_io_vec
and .bi_vcnt.

Most of the other patches use the 3 helpers to clean up most of direct
access to .bi_vcnt and .bi_io_vec from drivers, except for MD and btrfs,
which two subsystems will be handled with different way in future.

For btrfs, its direct access to .bi_vcnt & .bi_io_vec need to be cleanuped
and audited that there isn't issue once converting to multipage bvecs.

For raid(md), given its usage is quite complicated, we can just
not enable multipage bvecs for raid queue until all its usage
are cleaned up and audited. So it won't be a blocker for multipage
bvecs.

Also bio_add_page() is used in floppy, dm-crypt and fs/logfs to
avoiding direct access to .bi_vcnt & .bi_io_vec.

The patchset can be found in the following tree:

https://github.com/ming1/linux/tree/v4.6-rc-block-next-mpbvecs-cleanup.v1

V1:
	- add Reviewed-by
	- remove bio_is_full() helper because target can find it
	via the return value of bio_add_pc_page() (9/27)
	- add comment on another two uses of bio_get_base_vec() (16/27)
	- rebased on latest for-next branch of block tree

Ming Lei (27):
  block: bio: introduce 3 helpers for cleanup
  block: drbd: use bio_get_base_vec() to retrieve the 1st bvec
  block: drbd: remove impossible failure handling
  block: loop: use bio_get_base_vec() to retrive bvec table
  block: pktcdvd: use bio_get_base_vec() to retrive bvec table
  block: floppy: use bio_set_vec_table()
  block: floppy: use bio_add_page()
  staging: lustre: avoid to use bio->bi_vcnt directly
  target: avoid to access .bi_vcnt directly
  bcache: debug: avoid to access .bi_io_vec directly
  bcache: io.c: use bio_set_vec_table
  bcache: journal.c: use bio_set_vec_table()
  bcache: movinggc: use bio_set_vec_table()
  bcache: writeback: use bio_set_vec_table()
  bcache: super: use bio_set_vec_table()
  bcache: super: use bio_get_base_vec
  dm: crypt: use bio_add_page()
  dm: dm-io.c: use bio_get_base_vec()
  dm: dm.c: replace 'bio->bi_vcnt == 1' with !bio_multiple_segments
  dm: dm-bufio.c: use bio_set_vec_table()
  fs: logfs: use bio_set_vec_table()
  fs: logfs: convert to bio_add_page() in sync_request()
  fs: logfs: use bio_add_page() in __bdev_writeseg()
  fs: logfs: use bio_add_page() in do_erase()
  fs: logfs: remove unnecesary check
  kernel/power/swap.c: use bio_get_base_vec()
  mm: page_io.c: use bio_get_base_vec()

 drivers/block/drbd/drbd_bitmap.c            |   4 +-
 drivers/block/drbd/drbd_receiver.c          |  14 +---
 drivers/block/floppy.c                      |   9 +--
 drivers/block/loop.c                        |   5 +-
 drivers/block/pktcdvd.c                     |   3 +-
 drivers/md/bcache/debug.c                   |  11 ++-
 drivers/md/bcache/io.c                      |   3 +-
 drivers/md/bcache/journal.c                 |   3 +-
 drivers/md/bcache/movinggc.c                |   6 +-
 drivers/md/bcache/super.c                   |  33 ++++++---
 drivers/md/bcache/writeback.c               |   4 +-
 drivers/md/dm-bufio.c                       |   3 +-
 drivers/md/dm-crypt.c                       |   8 +--
 drivers/md/dm-io.c                          |   7 +-
 drivers/md/dm.c                             |   3 +-
 drivers/staging/lustre/lustre/llite/lloop.c |   9 +--
 drivers/target/target_core_pscsi.c          |   8 +--
 fs/logfs/dev_bdev.c                         | 107 +++++++++++-----------------
 include/linux/bio.h                         |  21 ++++++
 kernel/power/swap.c                         |  10 ++-
 mm/page_io.c                                |  18 ++++-
 21 files changed, 155 insertions(+), 134 deletions(-)

Thanks,
Ming
-- 
1.9.1
