From: David Dillow <dillowda@ornl.gov>
Date: Tue, 04 Oct 2011 17:16:23 -0400
Subject: [Lustre-devel] Wide striping
In-Reply-To: <73AED5C780AE05478241DB067651A92102378846@XYUS-EX22.xyus.xyratex.com>
References: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
	<1317687469.23023.3.camel@obelisk.thedillows.org>
	<73AED5C780AE05478241DB067651A92102378846@XYUS-EX22.xyus.xyratex.com>
Message-ID: <1317762984.16569.18.camel@lap75545.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 2011-10-04 at 10:44 -0700, Nathan Rutman wrote:
> On Oct 3, 2011, at 5:17 PM, David Dillow wrote:
> 
> > On Mon, 2011-10-03 at 13:15 -0700, Nathan Rutman wrote:
> > 
> >> Some OST?s may be down at file creation time, or new OSTs added later;
> >> hence there will likely be holes in the bitmap (but relatively few).
> >> Start index will still be used, but stripe order will be strictly
> >> round-robin (we will wrap around).  In other words, the stripe
> >> sequence will always be in linear OST order, starting from
> >> start_index, maybe skipping some holes, wrapping around to
> >> start_index-1.
> > 
> > It didn't occur to me when spoke at EOFS, but you'd need to store the
> > number of OSTs in the system when the mapping was created if you allow
> > it to wrap around -- otherwise, adding OSTs later would cause existing
> > files to loose track of the objects after the wrap point.
> 
> That's done inherently in the bitmap, where everything beyond the
> current number of OSTs is marked as a hole. (So actually, there will
> typically be one giant hole at the end of every bitmap, and then maybe
> some singeltons for deactivated OSTs.)

Perhaps I'm misunderstanding something, then.

I understood you to say that we would have a linear OST order that
starts from the start_index. So bitmap position 0 would be start_index,
position 1 would be start_index + 1, and so on. If those bits are on,
then there is a object for this file on those OSTs.

Am I on the same page so far?

Now, above you mention wrapping around to start_index - 1; I take this
to mean that at some point, we'd say bitmap position N is no longer OST
start_index + N, but would be OST 0. Bitmap position N + 1 would be OST
1, etc. This scheme may allow for a more compact bitmap when our file
consists of OSTs at the extreme ends of the ones available, but you have
to store the maximum OST number when creating the file to avoid having
the bitmap wrap point shift when you add new OSTs.

Or perhaps I just misunderstood what you meant by wrapping? Did you mean
bitmap position 0 is always OST 0, and the OST indicated by start_index
will hold the first object, and each set bit in turn indicates the next
OST/object, and if we run out of bits in the bitmap before we hit
stripe_count, we'll start checking again at bitmap position/OST 0?
-- 
Dave Dillow
National Center for Computational Science
Oak Ridge National Laboratory
(865) 241-6602 office
