From: Jan Kara <jack@suse.cz>
Date: Wed, 12 Apr 2017 12:24:24 +0200
Subject: [lustre-devel] [PATCH 0/25 v3] fs: Convert all embedded bdis into
	separate ones
Message-ID: <20170412102449.16901-1-jack@suse.cz>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jens Axboe <axboe@kernel.dk>
Cc: codalist@TELEMANN.coda.cs.cmu.edu, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org, Jan Kara <jack@suse.cz>, linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org, linux-block@vger.kernel.org, linux-mtd@lists.infradead.org, osd-dev@open-osd.org, linux-fsdevel@vger.kernel.org, v9fs-developer@lists.sourceforge.net, ceph-devel@vger.kernel.org, Petr Vandrovec <petr@vandrovec.name>, linux-afs@lists.infradead.org, linux-btrfs@vger.kernel.org, lustre-devel@lists.lustre.org

Hello,

this is the third revision of the patch series which converts all embedded
occurences of struct backing_dev_info to use standalone dynamically allocated
structures. This makes bdi handling unified across all bdi users and generally
removes some boilerplate code from filesystems setting up their own bdi. It
also allows us to remove some code from generic bdi implementation.

The patches were only compile-tested for most filesystems (I've tested
mounting only for NFS & btrfs) so fs maintainers please have a look whether
the changes look sound to you.

This series is based on top of bdi fixes that were merged into linux-block
git tree into for-next branch. I have pushed out the result as a branch to

git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs.git bdi

Since all patches got reviewed by Christoph, can you please pick them up Jens?
Thanks!

Changes since v2:
* Added Reviewed-by tags from Christoph

Changes since v1:
* Added some acks
* Added further FUSE cleanup patch
* Added removal of unused argument to bdi_register()
* Fixed up some compilation failures spotted by 0-day testing

								Honza
