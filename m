From: Nathan Rutman <Nathan_Rutman@xyratex.com>
Date: Thu, 6 Oct 2011 12:09:26 -0700
Subject: [Lustre-devel] Wide striping
In-Reply-To: <4684D08A-A823-47CD-8C02-22A92AEE6112@whamcloud.com>
References: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
	<1317687469.23023.3.camel@obelisk.thedillows.org>
	<73AED5C780AE05478241DB067651A92102378846@XYUS-EX22.xyus.xyratex.com>
	<1317762984.16569.18.camel@lap75545.ornl.gov>
	<73AED5C780AE05478241DB067651A9210237884F@XYUS-EX22.xyus.xyratex.com>
	<1317828832.27894.8.camel@lap75545.ornl.gov>
	<4684D08A-A823-47CD-8C02-22A92AEE6112@whamcloud.com>
Message-ID: <73AED5C780AE05478241DB067651A92102378866@XYUS-EX22.xyus.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Oct 5, 2011, at 6:51 PM, Andreas Dilger wrote:

> On 2011-10-05, at 9:33 AM, David Dillow <dillowda@ornl.gov> wrote:
>> On Wed, 2011-10-05 at 11:06 -0400, Nathan Rutman wrote:
>>> Sorry if I'm being unclear.
>>> 
>>> start_index is just an offset into the bitmap.  That's the OST where the first 
>>> stripe will be.  Next stripe will be on the next OST index (unless a hole). 
>>> When we get to the big hole at the end of the used OSTs, these OST index 
>>> locations are all skipped (since they are holes), and the next stripe will 
>>> be at OST index 0, then 1, etc, up to start_index-1 (again, unless holes).
>> 
>> Ok, so bitmap position 0 is always OST 0; thanks for clearing up my
>> misunderstanding.
> 
> But this means that the table always needs to be as large as the maximum OST number. If the bitmap started at the starting OST index it would only need to be as large as the number of stripes. 
Yes, the table is as large as the maximum possible OST number.  32,000 stripes fit in a bitmap in the current (non-extended) EA size.  If you started at the starting OST index, you would need to record the last OST number also.  Either way I don't see as a problem.

> 
> That said, the limitation if not being able to migrate objects with this layout is a major one. The ability to so online object migration is just arriving with the layout lock (from HSM), so I expect this to be useful to many users. 
Well, that's why we added the complication of embedding the OST index into the object FIDs that the clients would ask for. Then you could migrate that object to a new OST - but really only for exceptional cases.  General migration for e.g. space rebalancing would result in a bunch of additional overhead to figure out where all the stripes moved to.  So I agree - this is a weakness of the bitmap design, which really implies a fixed ordering. =
______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
