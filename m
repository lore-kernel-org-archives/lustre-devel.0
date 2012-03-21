From: Nathan Rutman <Nathan_Rutman@xyratex.com>
Date: Wed, 21 Mar 2012 11:29:19 -0700
Subject: [Lustre-devel] [wc-discuss] Re: [Twg] Lustre and cross-platform
	portability
In-Reply-To: <097F86FD722A2445B248BC51CC5DB88D1702BC@xchmbbal504.ds.susq.com>
References: <201203151845.q2FIjcXV029439@hedwig.cmf.nrl.navy.mil>
	<C481511A-14DB-4032-9071-82AF5974E263@whamcloud.com>
	<4F624851.6030707@iu.edu> <4F6311CB.8040506@diamond.ac.uk>
	<097F86FD722A2445B248BC51CC5DB88D1702BC@xchmbbal504.ds.susq.com>
Message-ID: <73AED5C780AE05478241DB067651A92102F108DF@XYUS-EX22.xyus.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Mar 16, 2012, at 8:06 AM, Todd, Allen wrote:

> 
> On Friday, March 16, 2012 6:11 AM, Gregory Matthews wrote:
>> why bother having a windows client if you lose the performance? We have
>> windows based detectors and proprietary windows based analysis software
>> that would definitely benefit from higher performance access to lustre
>> file systems but replacing existing CIFS servers for no gain seems a bit
>> pointless.

1. Re-exporting Lustre via CIFS or NFS isn't scalable to very large numbers of Windows clients
2. Re-exporting Lustre via CIFS or NFS can have coherency problems when multiple re-exporters are involved
3. Wide-striped file access would likely have greater performance on a native client than via a re-exported single pipe, for some value of "wide".

> 
>> From the perspective of my firm, the benefit of a windows lustre client (native or fuse-based), even one that performs at 10% or 20% of the linux client, is the improved scalability that it offers.  Our current solution uses 4 samba gateways per hundred windows servers to achieve acceptable bandwidth, but that bandwidth can be cut to an unacceptable trickle if a large wave of native linux clients simultaneously accesses the filesystem.
> 
> We have repeatedly asked our Microsoft HPC contacts to intervene to either fund a native windows client or to get oracle to release the existing one, since scalable storage is a big hole in the Microsoft HPC toolkit.  Obviously, nothing has come out of that.  It seems Microsoft is banking on pNFS, eventually working in this space.
> 
> Allen Todd
> 
> 
> 
> 
> ________________________________
> 
> IMPORTANT: The information contained in this email and/or its attachments is confidential. If you are not the intended recipient, please notify the sender immediately by reply and immediately delete this message and all its attachments. Any review, use, reproduction, disclosure or dissemination of this message or any attachment by an unintended recipient is strictly prohibited. Neither this message nor any attachment is intended as or should be construed as an offer, solicitation or recommendation to buy or sell any security or other financial instrument. Neither the sender, his or her employer nor any of their respective affiliates makes any warranties as to the completeness or accuracy of any of the information contained herein or that this message or any of its attachments is free of viruses.
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
