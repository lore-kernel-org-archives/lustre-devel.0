From: Ming Lei <tom.leiming@gmail.com>
Date: Tue,  5 Apr 2016 19:56:45 +0800
Subject: [lustre-devel] [PATCH 00/27] block: cleanup direct access on
	.bi_vcnt & .bi_io_vec
Message-ID: <1459857443-20611-1-git-send-email-tom.leiming@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jens Axboe <axboe@fb.com>, linux-kernel@vger.kernel.org
Cc: linux-block@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Boaz Harrosh <boaz@plexistor.com>, Ming Lei <tom.leiming@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <andreas.dilger@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:STAGING SUBSYSTEM" <devel@driverdev.osuosl.org>, "open list:DEVICE-MAPPER LVM" <dm-devel@redhat.com>, "open list:DRBD DRIVER" <drbd-dev@lists.linbit.com>, Frank Zago <fzago@cray.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hannes Reinecke <hare@suse.de>, James Simmons <jsimmons@infradead.org>, Jan Kara <jack@suse.cz>, Jarod Wilson <jarod@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Joe Perches <joe@perches.com>, "John L. Hammond" <john.hammond@intel.com>, Julia Lawall <Julia.Lawall@lip6.fr>, Keith Busch <keith.busch@intel.com>, Kent Overstreet <kent.overstreet@gmail.com>, linux-bcache@vger.kernel

Hi Guys,

It is always not a good practice to access bio->bi_vcnt and
bio->bi_io_vec from drivers directly. Also this kind of direct
access will cause trouble when converting to multipage bvecs.

The 1st patch introduces the following 4 bio helpers which can be
used inside drivers for avoiding direct access to .bi_vcnt and .bi_io_vec.

	bio_pages()
	bio_is_full()
	bio_get_base_vec()
	bio_set_vec_table()

Both bio_pages() and bio_is_full() can be easy to convert to
multipage bvecs.

For bio_get_base_vec() and bio_set_vec_table(), they are often used
during initializing a new bio or in case of single bvec bio. With the
two new helpers, it becomes quite easy to audit access to .bi_io_vec
and .bi_vcnt.

Most of the other patches use the 4 helpers to clean up most of direct
access to .bi_vcnt and .bi_io_vec from drivers, except for MD and btrfs,
which two subsystems will be done in the future. 

Also bio_add_page() is used in floppy, dm-crypt and fs/logfs to
avoiding direct access to .bi_vcnt & .bi_io_vec.

Thanks,
Ming

Ming Lei (27):
  block: bio: introduce 4 helpers for cleanup
  block: drbd: use bio_get_base_vec() to retrieve the 1st bvec
  block: drbd: remove impossible failure handling
  block: loop: use bio_get_base_vec() to retrive bvec table
  block: pktcdvd: use bio_get_base_vec() to retrive bvec table
  block: floppy: use bio_set_vec_table()
  block: floppy: use bio_add_page()
  staging: lustre: avoid to use bio->bi_vcnt directly
  target: use bio_is_full()
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
 drivers/md/bcache/super.c                   |  28 +++++---
 drivers/md/bcache/writeback.c               |   4 +-
 drivers/md/dm-bufio.c                       |   3 +-
 drivers/md/dm-crypt.c                       |   8 +--
 drivers/md/dm-io.c                          |   7 +-
 drivers/md/dm.c                             |   3 +-
 drivers/staging/lustre/lustre/llite/lloop.c |   9 +--
 drivers/target/target_core_pscsi.c          |   2 +-
 fs/logfs/dev_bdev.c                         | 107 +++++++++++-----------------
 include/linux/bio.h                         |  28 ++++++++
 kernel/power/swap.c                         |  10 ++-
 mm/page_io.c                                |  18 ++++-
 21 files changed, 156 insertions(+), 129 deletions(-)

-- 
1.9.1
