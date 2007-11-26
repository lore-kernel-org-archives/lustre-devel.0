From: Brian J. Murrell <Brian.Murrell@Sun.COM>
Date: Mon, 26 Nov 2007 12:55:48 -0500
Subject: [Lustre-devel] parallelism across oss or ost?
In-Reply-To: <200711261703.lAQH369U028247@cmf.nrl.navy.mil>
References: <200711261703.lAQH369U028247@cmf.nrl.navy.mil>
Message-ID: <1196099748.31044.4.camel@pc.ilinx>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, 2007-11-26 at 12:03 -0500, chas williams - CONTRACTOR wrote:
> if i have a single oss with multiple ost's do i get any parallelism
> when striping across the ost's?

If the hardware can handle it.  i.e. as long as the bandwidth between
the clients and the OSS is capable and as long as the bandwidth and/or
connect paths to the disk can handle it.

We have many installations with >1 OST/OSS simply because usually, the
bandwidth of a single disk is much less than the next slowest component
in and out of a single OSS.

>   i.e. would a client form multiple
> connections on whatever transport between the itself the oss?

If you are asking what I think you are, yes.  Maybe not as literally as
you are asking, but logically, yes.  A client will utilize multiple OSTs
in an OSS, in parallel if the file access patterns dictate such.

b.
