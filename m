From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Mon, 11 Feb 2008 21:11:43 +0000
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <20080211181850.GA6552@webber.adilger.int>
References: <47AB2FA7.10205@Sun.COM> <47AC7B75.30603@cea.fr>
	<20080211181850.GA6552@webber.adilger.int>
Message-ID: <1202764303.6391.42.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

On Seg, 2008-02-11 at 11:18 -0700, Andreas Dilger wrote:

> On Feb 08, 2008  16:55 +0100, Aurelien Degremont wrote:
> > But the touch could be problematic. Lustre gurus, is there another time 
> > field we could use instead ? Should we add a 
> > "last-modification-field-which-ignore-touch" ? Is this really a problem 
> > is we use display a "touched" time ? In this case, we display what the 
> > user set on the file, we suppose he did it in purpose.
> 
> (snip)
> 
> In ZFS I believe there is also a "last modified transaction group" (txg)
> number stored with each dnode that could be used in a similar manner.


Hmm.. I think ZFS only has zp_gen in the dnode/znode, which is the txg
of the file creation. We also cannot use the txg birth time of the block
where the dnode is stored because a metadnode block holds several
dnodes.

I may be missing something here, but isn't the "ctime" the appropriate
value to use here?

Regards,
Ricardo

--

Ricardo Manuel Correia
Lustre Engineering

Sun Microsystems, Inc.
Portugal
Phone +351.214134023 / x58723
Mobile +351.912590825
Email Ricardo.M.Correia at Sun.COM
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080211/03b52971/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080211/03b52971/attachment.gif>
