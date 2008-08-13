From: James Hughes <James.Hughes@Sun.COM>
Date: Wed, 13 Aug 2008 11:40:43 -0700
Subject: [Lustre-devel] Security issues
In-Reply-To: <C4C5F044.6C46%peter.braam@sun.com>
References: <C4C5F044.6C46%peter.braam@sun.com>
Message-ID: <1218652843.728.68.camel@JimsOSlap>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



On Mon, 2008-08-11 at 13:33 -0600, Peter Braam wrote:

> >> 
> >> You do need to sign it and encrypt it - for multiple purposes, to
> secure the
> >> wire transaction and for storage on the server.
> > 
> > Sorry I'm still a little confused. To be exactly clear, do you mean:
> In
> > the future we'll use NASD-style protocol to secure the bulk data's
> wire
> > transfer & storage on server; and for now we can simply leave the
> bulk
> > data unprotected?
> 
> No you need to be able to encrypt it.
> 
> I'm just stating that if you the current solution (which gives privacy
> using
> GSS between client and OSS iirc) is going to be changed, then please
> change
> it in the correct way to accommodate re-using checksums and re-using
> the
> encrypted data for storage.  Doing either of these things twice is
> pointless.

The NASD protocols do not allow for the encryption of the communications
and the stored information to be the same. The key management for
communications is well understood, but the key management for the stored
information as defined by NASD requires the encryption of the stored
information to be performed at the target. 


> Probably there should be options not to do so as part of the
> configuration.
> 
> Peter
> 
> 
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080813/88e59ca4/attachment.htm>
