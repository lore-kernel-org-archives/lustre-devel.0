From: Nicolas Williams <Nicolas.Williams@oracle.com>
Date: Wed, 20 Oct 2010 12:01:24 -0500
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <4CBF1D00.9080402@psc.edu>
References: <AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>
	<D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>
	<AANLkTik53-vQLA9DTj858=San9fgMB+94i8eChvHomEK@mail.gmail.com>
	<EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>
	<4CBEA415.80307@gmail.com>
	<9C26CBA7-8DBD-4875-8E14-FB663B749096@oracle.com>
	<4CBEA8A9.9080802@gmail.com> <00d001cb705a$fd64cb80$f82e6280$@com>
	<90E83093-2655-4C70-ACEA-E75D7E8C5511@oracle.com>
	<4CBF1D00.9080402@psc.edu>
Message-ID: <20101020170124.GT1635@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Oct 20, 2010 at 12:46:56PM -0400, Paul Nowoczynski wrote:
> 
> > The name_to_handle() only needs to be called on a single node, and 
> > open_by_handle() is called on the other nodes. I agree that this 
> > doesn't avoid the full O(n) RPCs for the open itself  but at least it 
> > does avoid the full path traversal from every client and on the 
> > MDS (replacing it with an MPI broadcast of the handle).
> Andreas,
> excuse my ignorance, but why does open_by_handle() need to issue an 
> RPC?  If it's to obtain the layout, couldn't the layout be encoded into 
> the 'handle'?

If you don't mind having a huge handle, then yes, we could skip
additional RPCs.

A handle would have to consist of a {MGS address, FID, layout, access
type, capability}, or so.
