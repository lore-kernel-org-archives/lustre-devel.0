From: Nicolas Williams <Nicolas.Williams@Oracle.com>
Date: Wed, 20 Oct 2010 12:13:49 -0500
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <269E1A0D-2117-4ADC-BCDE-67A60EA9B974@oracle.com>
References: <D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>
	<AANLkTik53-vQLA9DTj858=San9fgMB+94i8eChvHomEK@mail.gmail.com>
	<EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>
	<4CBEA415.80307@gmail.com>
	<9C26CBA7-8DBD-4875-8E14-FB663B749096@oracle.com>
	<4CBEA8A9.9080802@gmail.com> <00d001cb705a$fd64cb80$f82e6280$@com>
	<90E83093-2655-4C70-ACEA-E75D7E8C5511@oracle.com>
	<4CBF1D00.9080402@psc.edu>
	<269E1A0D-2117-4ADC-BCDE-67A60EA9B974@oracle.com>
Message-ID: <20101020171348.GU1635@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Oct 20, 2010 at 11:00:53AM -0600, Andreas Dilger wrote:
> On 2010-10-20, at 10:46, Paul Nowoczynski <pauln@psc.edu> wrote:
> >> The name_to_handle() only needs to be called on a single node, and
> >> open_by_handle() is called on the other nodes. I agree that this
> >> doesn't avoid the full O(n) RPCs for the open itself  but at least
> >> it does avoid the full path traversal from every client and on the
> >> MDS (replacing it with an MPI broadcast of the handle).
> > 
> > excuse my ignorance, but why does open_by_handle() need to issue an
> > RPC?  If it's to obtain the layout, couldn't the layout be encoded
> > into the 'handle'?
> 
> In theory, yes. Practically, there is a size limit on the handle, and
> in large filesystems the layout is larger than this limit. 
> 
> Also, it depends on whether we want the MDS to have consistent
> behavior with the resulting open file descriptor or not.
> 
> I suppose in many cases it would be possible to fake out an open file
> on the client without telling the MDS, but then there will be strange
> problems in some cases (e.g. stat() of the file, errors on close,
> etc.) that would result since the MDS won't know anything about the
> other openers. Maybe that is acceptable, I don't know. 

Well, if we're going to add openg() (or whatever its name), we might as
well add variants of stat() that don't require getting the size when the
app doesn't need it, and forget about SOM, or forget about SOM when we
know that a file might be open by unknown clients (recover issues here).

Another possibility is that the handle encodes the current size, and
that to write past that size requires an RPC to establish open state,
but this ignores truncation.

Another possibility is to say that a handle is only good as long as the
original file descriptor remains open (recovery issues here), and that
client can tell the MDS that it will be sharing its handle with other
clients.  Or that client could tell the MDS what all the clients are
that will share that handle (recovery issues here too).

Some sort of additional RPC seems hard to avoid here, but maybe it could
be async for clients opening by handle.

Nico
-- 
