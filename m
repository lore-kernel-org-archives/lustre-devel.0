From: Brian J. Murrell <Brian.Murrell@Sun.COM>
Date: Fri, 10 Oct 2008 15:02:37 -0400
Subject: [Lustre-devel] proposal to increase seek in sgpdd_survey
In-Reply-To: <244CBACA73094649889DFE28A43F7B2E@ebpc>
References: <1222817771.26779.75.camel@pc.ilinx>
	<244CBACA73094649889DFE28A43F7B2E@ebpc>
Message-ID: <1223665357.11840.138.camel@brian-laptop>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, 2008-10-09 at 21:38 +0100, Eric Barton wrote:
> Brian, Andreas,
> 
> I'm cc-ing lustre-devel since this is of general interest.

Sounds good.

> 
> My comments inline...

Mine too, as always.  :-)

I just want to clarify, this idea is not mine.  I don't want to take
credit for something that is not actually mine.  The idea comes from a
bug filed by one of our support engineers, Kevin Van Maren.

> > -----Original Message-----
> > From: Brian.Murrell at Sun.COM [mailto:Brian.Murrell at Sun.COM] 
> ...
> > The proposal is to space out the regions to cover more of the drive.  So
> > for example, a 2 region test would write one region at 0% of the drive
> > and the second region at 50%.  A 4 region test would write at 0%, 25%,
> > 50% and 75%, etc.  Perhaps the inter-region spacing should be such that
> > the last byte of the last region is at the end of the disk to maximize
> > the seek penalty.  Perhaps not.
> 
> Indeed - this is how it should be done.

Just for clarification Eric...  Are you advocating num_gaps ==
num_regions or num_gaps == num_regions-1?  i.e. in a two region test
should the second region start at 50% of the disk or 100%-$region_size
so that the last byte of the second region is written to the last byte
of the disk?

It seems to me that the first option provides a more "middle of the
road" (which might correlate to real-world averages more closely)
average as it only incorporates a seek of half the disk whereas the
second option provides a more worst case performance result.

> This proposal _totally_ matches the original intent.  This feature of
> the current implementation is a bug.

Fair enough.  :-)

>   Mea maxima culpa...

:-)

b.
