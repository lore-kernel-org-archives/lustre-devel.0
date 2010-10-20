From: Nicolas Williams <Nicolas.Williams@oracle.com>
Date: Wed, 20 Oct 2010 12:29:57 -0500
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <4CBF2483.7030805@gmail.com>
References: <4CBEA415.80307@gmail.com>
	<9C26CBA7-8DBD-4875-8E14-FB663B749096@oracle.com>
	<4CBEA8A9.9080802@gmail.com> <00d001cb705a$fd64cb80$f82e6280$@com>
	<4CBF01DA.3090505@psc.edu> <4CBF094A.9020302@gmail.com>
	<4CBF1C42.1090109@psc.edu> <4CBF1D82.60508@gmail.com>
	<4CBF22DE.9080204@psc.edu> <4CBF2483.7030805@gmail.com>
Message-ID: <20101020172956.GV1635@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Oct 20, 2010 at 09:18:59PM +0400, bzzz.tomas at gmail.com wrote:
> On 10/20/10 9:11 PM, Paul Nowoczynski wrote:
> > I could be wrong but my guess is that the network congestion caused by
> > this communication pattern is a more serious problem. The mds should be
> > able to easily service lookup rpc's since only the first few necessitate
> > a read I/O from the disk.
> 
> but then the network should be able to deal with storm of
> <max RPC in-flight> * <# clients> to read/write data?
> 
> or it's a specific switch being the bottleneck to specific node?
> 
> because if it isn't network, but MDS being a real bottleneck,
> then proxy might be a solution like Eric said above. not sure
> is this important in your case, but this would allow to use
> existing apps.

MDSes are typically CPU bound, so that's likely the issue.  The problem
though is that the MDS does need to track open file state for SOM and
for dealing with unlinks.  The semantics of open-by-handle might be such
that unlinks of files opened by handle can cause the file to disappear
and syscalls on FDs opened by handle could then return EBADF or EIO or
some new error code.  But open-by-handle semantics don't allow for that,
then the MDS needs to track open file state, and it's hard to see how to
avoid RPCs to the MDS to establish that state (the original client could
tell the MDS about all the clients that will open-by-handle, but this
seems unlikely to perform so much better than N smaller RPCs as to
justify it, and the open-by-handle API suddenly gets much more complex).

Nico
-- 
