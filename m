From: Nathan Rutman <Nathan_Rutman@xyratex.com>
Date: Wed, 5 Oct 2011 08:06:15 -0700
Subject: [Lustre-devel] Wide striping
In-Reply-To: <1317762984.16569.18.camel@lap75545.ornl.gov>
References: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
	<1317687469.23023.3.camel@obelisk.thedillows.org>
	<73AED5C780AE05478241DB067651A92102378846@XYUS-EX22.xyus.xyratex.com>
	<1317762984.16569.18.camel@lap75545.ornl.gov>
Message-ID: <73AED5C780AE05478241DB067651A9210237884F@XYUS-EX22.xyus.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Oct 4, 2011, at 2:16 PM, David Dillow wrote:

> On Tue, 2011-10-04 at 10:44 -0700, Nathan Rutman wrote:
>> On Oct 3, 2011, at 5:17 PM, David Dillow wrote:
>> 
>>> On Mon, 2011-10-03 at 13:15 -0700, Nathan Rutman wrote:
>>> 
>>>> Some OST?s may be down at file creation time, or new OSTs added later;
>>>> hence there will likely be holes in the bitmap (but relatively few).
>>>> Start index will still be used, but stripe order will be strictly
>>>> round-robin (we will wrap around).  In other words, the stripe
>>>> sequence will always be in linear OST order, starting from
>>>> start_index, maybe skipping some holes, wrapping around to
>>>> start_index-1.
>>> 
>>> It didn't occur to me when spoke at EOFS, but you'd need to store the
>>> number of OSTs in the system when the mapping was created if you allow
>>> it to wrap around -- otherwise, adding OSTs later would cause existing
>>> files to loose track of the objects after the wrap point.
>> 
>> That's done inherently in the bitmap, where everything beyond the
>> current number of OSTs is marked as a hole. (So actually, there will
>> typically be one giant hole at the end of every bitmap, and then maybe
>> some singeltons for deactivated OSTs.)
> 
> Perhaps I'm misunderstanding something, then.
> 
> I understood you to say that we would have a linear OST order that
> starts from the start_index. So bitmap position 0 would be start_index,
> position 1 would be start_index + 1, and so on. If those bits are on,
> then there is a object for this file on those OSTs.

Sorry if I'm being unclear.

start_index is just an offset into the bitmap.  That's the OST where the first 
stripe will be.  Next stripe will be on the next OST index (unless a hole). 
When we get to the big hole at the end of the used OSTs, these OST index 
locations are all skipped (since they are holes), and the next stripe will 
be at OST index 0, then 1, etc, up to start_index-1 (again, unless holes).



> 
> Am I on the same page so far?
> 
> Now, above you mention wrapping around to start_index - 1; I take this
> to mean that at some point, we'd say bitmap position N is no longer OST
> start_index + N, but would be OST 0. Bitmap position N + 1 would be OST
> 1, etc. This scheme may allow for a more compact bitmap when our file
> consists of OSTs at the extreme ends of the ones available, but you have
> to store the maximum OST number when creating the file to avoid having
> the bitmap wrap point shift when you add new OSTs.
> 
> Or perhaps I just misunderstood what you meant by wrapping? Did you mean
> bitmap position 0 is always OST 0, and the OST indicated by start_index
> will hold the first object, and each set bit in turn indicates the next
> OST/object, and if we run out of bits in the bitmap before we hit
> stripe_count, we'll start checking again at bitmap position/OST 0?
> -- 
> Dave Dillow
> National Center for Computational Science
> Oak Ridge National Laboratory
> (865) 241-6602 office
> 
> 
______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
