From: Jan Kara <jack@suse.cz>
Date: Thu, 9 Feb 2017 13:12:12 +0100
Subject: [lustre-devel] [PATCH 04/24] fs: Provide infrastructure for
 dynamic	BDIs in filesystems
In-Reply-To: <C01BF300-AD67-4A3E-810F-AAB2EEB90B97@intel.com>
References: <20170202173422.3240-1-jack@suse.cz>
	<20170202173422.3240-5-jack@suse.cz>
	<C01BF300-AD67-4A3E-810F-AAB2EEB90B97@intel.com>
Message-ID: <20170209121212.GD16825@quack2.suse.cz>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: "linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-nilfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nilfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, "ecryptfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <ecryptfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "codalist-/uMB558Y47wP4a1z8dhFYw@public.gmane.org" <codalist-/uMB558Y47wP4a1z8dhFYw@public.gmane.org>, "linux-block-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-block-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, "osd-dev-yNzVSZO3znNg9hUCZPvPmw@public.gmane.org" <osd-dev-yNzVSZO3znNg9hUCZPvPmw@public.gmane.org>, "linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, "ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Petr Vandrovec <petr-vPk2MGR0e28uaRcfnNAh7A@public.gmane.org>, "linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-afs-IAPFreCvJWM7uuMidbF8XcXa4x6EXUF0@public.gmane.org>

> > @@ -1249,6 +1254,50 @@ mount_fs(struct file_system_type *type, int flags, const char *name, void *data)
> > }
> > 
> > /*
> > + * Setup private BDI for given superblock. I gets automatically cleaned up
> 
> (typo) s/I/It/
> 
> Looks fine otherwise.

Thanks, fixed.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
