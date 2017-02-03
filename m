From: Jan Kara <jack@suse.cz>
Date: Fri, 3 Feb 2017 14:50:42 +0100
Subject: [lustre-devel] [PATCH 04/24] fs: Provide infrastructure for
 dynamic BDIs in filesystems
In-Reply-To: <20170202192827.GF6550@localhost.localdomain>
References: <20170202173422.3240-1-jack@suse.cz>
	<20170202173422.3240-5-jack@suse.cz>
	<20170202192827.GF6550@localhost.localdomain>
Message-ID: <20170203135042.GB5844@quack2.suse.cz>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Liu Bo <bo.li.liu@oracle.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-block@vger.kernel.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, Petr Vandrovec <petr@vandrovec.name>, linux-nilfs@vger.kernel.org, cluster-devel@redhat.com, osd-dev@open-osd.org, codalist@TELEMANN.coda.cs.cmu.edu, linux-afs@lists.infradead.org, ecryptfs@vger.kernel.org, linux-cifs@vger.kernel.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, v9fs-developer@lists.sourceforge.net, lustre-devel@lists.lustre.org

On Thu 02-02-17 11:28:27, Liu Bo wrote:
> Hi,
> 
> On Thu, Feb 02, 2017 at 06:34:02PM +0100, Jan Kara wrote:
> > Provide helper functions for setting up dynamically allocated
> > backing_dev_info structures for filesystems and cleaning them up on
> > superblock destruction.
> 
> Just one concern, will this cause problems for multiple superblock cases
> like nfs with nosharecache?

Can you ellaborate a bit? I've looked for a while what nfs with
nosharecache does but I didn't see how it would influence anything with
bdis...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
