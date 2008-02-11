From: Andreas Dilger <adilger@sun.com>
Date: Mon, 11 Feb 2008 14:39:56 -0700
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <1202764303.6391.42.camel@localhost>
References: <47AB2FA7.10205@Sun.COM> <47AC7B75.30603@cea.fr>
	<20080211181850.GA6552@webber.adilger.int>
	<1202764303.6391.42.camel@localhost>
Message-ID: <20080211213956.GK3029@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 11, 2008  21:11 +0000, Ricardo Correia wrote:
> On Seg, 2008-02-11 at 11:18 -0700, Andreas Dilger wrote:
> 
> > On Feb 08, 2008  16:55 +0100, Aurelien Degremont wrote:
> > > But the touch could be problematic. Lustre gurus, is there another time 
> > > field we could use instead ? Should we add a 
> > > "last-modification-field-which-ignore-touch" ? Is this really a problem 
> > > is we use display a "touched" time ? In this case, we display what the 
> > > user set on the file, we suppose he did it in purpose.
> > 
> > (snip)
> > 
> > In ZFS I believe there is also a "last modified transaction group" (txg)
> > number stored with each dnode that could be used in a similar manner.
> 
> 
> Hmm.. I think ZFS only has zp_gen in the dnode/znode, which is the txg
> of the file creation. We also cannot use the txg birth time of the block
> where the dnode is stored because a metadnode block holds several
> dnodes.
> 
> I may be missing something here, but isn't the "ctime" the appropriate
> value to use here?

The problem with ctime (on Linux as well) is that it is possible for the
system clock to go backward, whether due to ntp, or because the hardware
clock is incorrect/reset, so it cannot be depended upon to be monotonically
increasing for the life of the lustre filesystem.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
