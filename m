From: Jan Kara <jack@suse.cz>
Date: Fri, 3 Feb 2017 16:46:40 +0100
Subject: [lustre-devel] [PATCH] mm: Avoid returning VM_FAULT_RETRY from
 ->page_mkwrite handlers
In-Reply-To: <20170203151356.GB2267@bombadil.infradead.org>
References: <20170203150729.15863-1-jack@suse.cz>
	<20170203151356.GB2267@bombadil.infradead.org>
Message-ID: <20170203154640.GA25586@quack2.suse.cz>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, lustre-devel@lists.lustre.org, cluster-devel@redhat.com

On Fri 03-02-17 07:13:59, Matthew Wilcox wrote:
> On Fri, Feb 03, 2017 at 04:07:29PM +0100, Jan Kara wrote:
> > Some ->page_mkwrite handlers may return VM_FAULT_RETRY as its return
> > code (GFS2 or Lustre can definitely do this). However VM_FAULT_RETRY
> > from ->page_mkwrite is completely unhandled by the mm code and results
> > in locking and writeably mapping the page which definitely is not what
> > the caller wanted. Fix Lustre and block_page_mkwrite_ret() used by other
> > filesystems (notably GFS2) to return VM_FAULT_NOPAGE instead which
> > results in bailing out from the fault code, the CPU then retries the
> > access, and we fault again effectively doing what the handler wanted.
> 
> Reading this commit message makes me wonder if this is the best fix.
> It would seem logical that if I want the fault to be retried that I should
> return VM_FAULT_RETRY, not VM_FAULT_NOPAGE.  Why don't we have the MM
> treat VM_FAULT_RETRY the same way that it treats VM_FAULT_NOPAGE and give
> driver / filesystem writers one fewer way to shoot themselves in the foot?

VM_FAULT_RETRY is special, it may be used only if FAULT_FLAG_ALLOW_RETRY
was set in page fault flags and it means - we have dropped mmap_sem, we
loaded page needed to satisfy the fault and now we need to try again (have
a look at __lock_page_or_retry()). I have my reservations about this
interface but it works...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
