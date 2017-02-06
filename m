From: Jan Kara <jack@suse.cz>
Date: Mon, 6 Feb 2017 10:24:15 +0100
Subject: [lustre-devel] [PATCH] mm: Avoid returning VM_FAULT_RETRY from
 ->page_mkwrite handlers
In-Reply-To: <20170203152054.6ee9f8a920e6d0ac8a93d2b9@linux-foundation.org>
References: <20170203150729.15863-1-jack@suse.cz>
	<20170203152054.6ee9f8a920e6d0ac8a93d2b9@linux-foundation.org>
Message-ID: <20170206092415.GD4004@quack2.suse.cz>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lustre-devel@lists.lustre.org, cluster-devel@redhat.com

On Fri 03-02-17 15:20:54, Andrew Morton wrote:
> On Fri,  3 Feb 2017 16:07:29 +0100 Jan Kara <jack@suse.cz> wrote:
> 
> > Some ->page_mkwrite handlers may return VM_FAULT_RETRY as its return
> > code (GFS2 or Lustre can definitely do this). However VM_FAULT_RETRY
> > from ->page_mkwrite is completely unhandled by the mm code and results
> > in locking and writeably mapping the page which definitely is not what
> > the caller wanted. Fix Lustre and block_page_mkwrite_ret() used by other
> > filesystems (notably GFS2) to return VM_FAULT_NOPAGE instead which
> > results in bailing out from the fault code, the CPU then retries the
> > access, and we fault again effectively doing what the handler wanted.
> 
> I'm not getting any sense of the urgency of this fix.  The bug *sounds*
> bad?  Which kernel versions need fixing?

So I did more analysis of GFS2 and Lustre behavior. AFAICS GFS2 returns
EAGAIN only for truncated page, when we then return with VM_FAULT_RETRY,
do_page_mkwrite() locks the page, sees it is truncated and bails out
properly thus silently fixes up the problem. The Lustre bug looks like it
could actually result in some real problems and the bug is there since the
initial commit in which Lustre was added in 3.11 (d7e09d0397e84).

So overall the issue doesn't look like too serious currently but it is
certainly a serious bug waiting to happen.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
