From: Nathan Rutman <Nathan_Rutman@xyratex.com>
Date: Tue, 4 Oct 2011 10:44:34 -0700
Subject: [Lustre-devel] Wide striping
In-Reply-To: <1317687469.23023.3.camel@obelisk.thedillows.org>
References: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
	<1317687469.23023.3.camel@obelisk.thedillows.org>
Message-ID: <73AED5C780AE05478241DB067651A92102378846@XYUS-EX22.xyus.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Oct 3, 2011, at 5:17 PM, David Dillow wrote:

> On Mon, 2011-10-03 at 13:15 -0700, Nathan Rutman wrote:
> 
>> Some OST?s may be down at file creation time, or new OSTs added later;
>> hence there will likely be holes in the bitmap (but relatively few).
>> Start index will still be used, but stripe order will be strictly
>> round-robin (we will wrap around).  In other words, the stripe
>> sequence will always be in linear OST order, starting from
>> start_index, maybe skipping some holes, wrapping around to
>> start_index-1.
> 
> It didn't occur to me when spoke at EOFS, but you'd need to store the
> number of OSTs in the system when the mapping was created if you allow
> it to wrap around -- otherwise, adding OSTs later would cause existing
> files to loose track of the objects after the wrap point.

That's done inherently in the bitmap, where everything beyond the current number of OSTs is marked as a hole.
(So actually, there will typically be one giant hole at the end of every bitmap, and then maybe some singeltons for deactivated
OSTs.)

> 
> -- 
> Dave Dillow
> National Center for Computational Science
> Oak Ridge National Laboratory
> (865) 241-6602 office
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
