From: Andreas Dilger <adilger@sun.com>
Date: Fri, 25 Jul 2008 15:41:09 -0400
Subject: [Lustre-devel] statahead feature
In-Reply-To: <1216978676.16594.104.camel@bear.shadowland>
References: <4888573F.4010506@sun.com> <488957EC.1040701@sun.com>
	<4889597A.6060109@sun.com> <1216978676.16594.104.camel@bear.shadowland>
Message-ID: <20080725194109.GV5346@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 25, 2008  12:37 +0300, Alexey Lyashkov wrote:
> On Fri, 2008-07-25 at 08:41 +0400, Alex Zhuravlev wrote:
> > > Another optimization (maybe) to be considered is that whether it is 
> > > necessary to start one statahead thread
> > > for each "ls -l" operation or not? As said by Nikita, maybe we can use a 
> > > single thread for all the statahead.
> > 
> > I'm not sure we need any statahead thread at all. what's wrong with issuing
> > number of async RPCs from ll_getattr_it()? this way user's application
> > drives statahead directly: each time stat(2) is called you tune statahead
> > window and send few more RPCs again -- like data read-ahead does.

I think it is very useful to consider these "lockless MDT getattr" RPCs
as "glimpse" requests.  That idea has served us very well on OST attributes,
and I think the same would true with MDT attributes.  We should always
send these getattr requests with a special flag (is a "getattr intent"
enough, or do we need a different flag).

We should ideally make this DLM RPC work the same way for both OST glimpses
and MDT glimpses - client can optionally be granted a lock if inode has not
been changed recently, but only the attributes returned if the lock is busy.

> not need any statahead thread.
> as alex say:
> if we have UPDATE lock to parent - we can create valid dentry without
> lookup and add new locked inode to him.
> ---
> this looks easy to implement - call ll_readdir with i_mutex held and
> pass custom fill callback.

One problem with this idea is that we cannot do the callbacks in the
context of the ptlrpcd thread - see bug 15927.

> in callback we allocate new dentry + empty locked inode (or attach new
> dentry to inode if we have only update lock /ll_find_alias/ ?? ), also
> submit async getattr rpc into ptlrpcd if need.
> rpc completion callback set md_lock to inode and unlock inode.
> also ll_getattr_it should call wait_on_inode for be sure statahead is
> finished.

IMHO it would also be useful to start the OST glimpse in the callback as
soon as the MDT "glimpse" is returned.  Without a change like this we
are limited to <= 2x speedup for statahead until size-on-MDS is done.
That is because we are hiding the MDT RPC latency, but still have to wait
for the parallel OST RPC latency, so:

speedup = (old time / new time) = (MDT RPC + max(OST RPC)) / max(OST RPC)

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
