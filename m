From: Jan Kara <jack@suse.cz>
Date: Wed, 29 Mar 2017 12:55:58 +0200
Subject: [lustre-devel] [PATCH 0/25 v2] fs: Convert all embedded bdis into
	separate ones
Message-ID: <20170329105623.18241-1-jack@suse.cz>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nilfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ecryptfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, codalist-/uMB558Y47wP4a1z8dhFYw@public.gmane.org, linux-block-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, osd-dev-yNzVSZO3znNg9hUCZPvPmw@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Petr Vandrovec <petr-vPk2MGR0e28uaRcfnNAh7A@public.gmane.org>, linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-btrfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

Hello,

this is the second revision of the patch series which converts all embedded
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

Changes since v1:
* Added some acks
* Added further FUSE cleanup patch
* Added removal of unused argument to bdi_register()
* Fixed up some compilation failures spotted by 0-day testing

								Honza
