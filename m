From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Mon, 5 Oct 2009 14:00:54 -0500
Subject: [Lustre-devel] Needed: insight on obd_set_info_async()
In-Reply-To: <20091005171532.GV3789@webber.adilger.int>
References: <20091002220611.GU887@Sun.COM>
	<20091004073427.GN3789@webber.adilger.int>
	<20091004171118.GV887@Sun.COM>
	<20091005171532.GV3789@webber.adilger.int>
Message-ID: <20091005190053.GD887@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Oct 05, 2009 at 11:15:32AM -0600, Andreas Dilger wrote:
> On Oct 04, 2009  12:11 -0500, Nicolas Williams wrote:
> > But does it always go over the wire?  Is it always executed with a 'val'
> > that came off the wire?
> 
> No, getinfo/setinfo also operate locally in many places.  The caller isn't
> supposed to know at what lower layer the request will be processed.
> 
> In that regard, the early design goal of the Lustre stack was that it
> has a single API throughout the stack and is transparent whether the
> operations are happening on a local or remote node, but I wasn't at all
> involved in the 2.0 development and that goal has fallen by the wayside.

Thanks.  This helps.  Also, it seems, from what I can tell, that 'val'
is expected to be in local byte order, which also helps.

I've figured out what to do.  There's only a handful of PTLRPCs that
devolve into calls to obd_set_info_async() with 'val's taken from an RPC
buffer, and at each of those places there's a call to ptlrpc_req_need_swab()
and swabbing code.  Each such RPC handler will change the req's format
to one that properly models the 'val', so that it gets swabbed properly
(this was my original plan, but I wasn't sure if obd_set_info_async()
might be doing additional swabbing below, and now it's clear that it
does not).

I'll make sure to check every call to KEY_IS() as well.

Nico
-- 
