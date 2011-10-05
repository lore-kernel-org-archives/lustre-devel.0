From: Nathan Rutman <Nathan_Rutman@xyratex.com>
Date: Wed, 5 Oct 2011 11:18:57 -0700
Subject: [Lustre-devel] Wide striping
In-Reply-To: <54C22AB8-783C-4B23-9CC9-B70C72CA1150@xyratex.com>
References: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
	<4E8BA3EE.6060300@whamcloud.com>
	<54C22AB8-783C-4B23-9CC9-B70C72CA1150@xyratex.com>
Message-ID: <73AED5C780AE05478241DB067651A92102378851@XYUS-EX22.xyus.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Oct 5, 2011, at 2:28 AM, Alexey Lyashkov wrote:

> Hi All,
>> 
>> FID-on-OST is actually part of DNE(dirtribute name space) phase I.  It basically follows current fid client server infrastructure.
>> 
>> 1. MDT is the fid client, which requests fid from the OST and allocates fids for the object during pre-creation. 
>> 2. OST is the fid server, which will allocate the FIDs to MDTs and requests super fid sequence from fid control server (root MDT).
>> 3. Similar as MDT FID, there will be OI to map FID to object inside OST.
>> 
>> The code will be release with DNE sometime next year.
>> 
> I think we not need a special FID's for OST object, except we want to migrate one object via different data containers over cluster.
> I think it's not a priority for now.
> So we can simplify a FID management for OST now.
> Each data object may identified via pair {OST_INDEX / OST_UUID, MDT_FID}.
> In that case OST not need allocate any FID's, and MDT can reuse current reallocation scheme.
> in fact we not need a assign a FID for OST object in file creation time (aka creating LSM), but we need a guaranteed free OST object exist when client tried to make access to that object.
> in that case OST can preallocate some pool and report that size to MDT,
> MDT know it's uses some objects from that pool, but not know which object id assigned to file. 
> to avoid OST confusion client send a MDT FID to OST when need access to OST object.
> OST look to OI database and check - is that FID assigned to something or not.
> if assigned - IO will return a inode, otherwise OST need to grab any free object from a pool and assign to that FID.
> that's all.
> 
> orphan cleanup not need to be changed in that case - MDT send a last allocated objid, and OST will kill a unallocated objects and return last index to the MDT.
> open-unlink case need to be changed to put a fid in LLOG record and OST need to be changed to handle FID as object index.
> 

What Shadow is saying here (correct me if I'm wrong) is that full-blown FIDs on OSTs are really needed; just a way to map the MDT fid to to the local object id.
(The other general class of solution being to reserve a specific range of common ost object id's, and do no mapping.)  Both of these are significantly less
complicated than the DNE FID-on-OST description.

As I was hinting at before, perhaps there's not a very strong case to be made for doing anything other than using the "just make it bigger" solution of BZ4424.
I was trying to gauge the interest of the community in an intermediate solution.=
______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
