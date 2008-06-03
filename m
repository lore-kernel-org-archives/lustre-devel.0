From: Alex Zhuravlev <Alex.Zhuravlev@sun.com>
Date: Tue, 03 Jun 2008 22:56:57 +0400
Subject: [Lustre-devel] Commit on share
In-Reply-To: <20080603184151.GA2961@webber.adilger.int>
References: <C4620704.5499%peter.braam@sun.com> <op.ubxfheh9atmt0c@goga>
	<20080531024524.GB2992@webber.adilger.int> <op.ub15vdu9atmt0c@goga>
	<20080603184151.GA2961@webber.adilger.int>
Message-ID: <484593F9.4050306@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> Well, in 1.6/1.8 the layering isn't so strict, and in HEAD the problem
> goes away because of per-object data/locking.  I also don't think Alex's
> worry about the i_filterdata lifetime is warranted.  If the inode is
> being evicted from cache, then it surely must have been written to disk,
> so there is no need to cache the last-modified data at all as COS is
> not needed anymore.

we can't destroy dependency data until object is committed, right?
but JBD doesn't work with inodes, it works with buffers only. IOW,
inode can be evicted from the cache while correspondent buffer is
still to be flushed?

thanks, Alex
