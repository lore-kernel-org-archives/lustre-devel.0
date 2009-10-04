From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Sun, 4 Oct 2009 12:11:18 -0500
Subject: [Lustre-devel] Needed: insight on obd_set_info_async()
In-Reply-To: <20091004073427.GN3789@webber.adilger.int>
References: <20091002220611.GU887@Sun.COM>
	<20091004073427.GN3789@webber.adilger.int>
Message-ID: <20091004171118.GV887@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Oct 04, 2009 at 01:34:27AM -0600, Andreas Dilger wrote:
> On Oct 02, 2009  17:06 -0500, Nicolas Williams wrote:
> > I'm trying to find out which uses of obd_set_info_async() involve values
> > that come from a PTLRPC message buffer, and which ones don't.  It would
> > help to know what obd_set_info_async() is for...  It seems it's a
> > glorified ioctl()...
> 
> Sort of, yes, though I would characterize it more like a "get/set system
> xattr".  It can get/set key,value pairs on a local or remote node.  The
> "async" part means that the caller is the one in charge of handling waiting
> for completion of the operation.  This is important when doing an operation
> that may involve many OSTs, since we want the RPCs to happen in parallel
> instead of in series.

But does it always go over the wire?  Is it always executed with a 'val'
that came off the wire?

> > I'm tempted to augment it to always take a struct ptlrpc_request *req
> > argument, so that req == NULL || val == NULL, and when req != NULL the
> > value will be obtained using req_capsule_*_get().  Between that and
> > enhancements to req_capsule_extend() and what not we might be able to
> > ensure that 'val' is always swabbed by capsule code.
> 
> I can't comment on the HEAD capsule code, maybe someone else can...

That's OK, I can take care of the capsule conversion for this function.
But I need to understand it and the contexts when it's called a bit
better.

Nico
-- 
