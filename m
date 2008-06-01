From: Alex Zhuravlev <Alex.Zhuravlev@sun.com>
Date: Sun, 01 Jun 2008 20:54:14 +0400
Subject: [Lustre-devel] Commit on share
In-Reply-To: <20080531024524.GB2992@webber.adilger.int>
References: <C4620704.5499%peter.braam@sun.com> <op.ubxfheh9atmt0c@goga>
	<20080531024524.GB2992@webber.adilger.int>
Message-ID: <4842D436.9090005@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> I think the commit callbacks should be able to free this data, there
> should never be any such items on an object with di_transno > last_committed.
> Also, isn't it enough to store a single such item per object directly
> on the object?  Once we know there is ANY such conflict that is enough
> to invoke COS.  For per-object data this can be stored on 1.6 in the
> i_filterdata structure that we can attach onto every server inode.

we don't control inode's lifetime. in order to use i_filterdata we'd have
to pin inode. then we'd have to unpin inode. we can't do this from commit
callback as iput() may cause inode delete. so, we'd have to use special
thread - not that nice.

I believe originally hash table is a intermediate solution for 1.6 and 1.8.
in new server we do have own objects with all needed callbacks to control
data like i_filterdata.

thanks, Alex
