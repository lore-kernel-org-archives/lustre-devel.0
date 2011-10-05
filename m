From: wangdi <di.wang@whamcloud.com>
Date: Wed, 05 Oct 2011 12:44:01 -0700
Subject: [Lustre-devel] Wide striping
In-Reply-To: <73AED5C780AE05478241DB067651A92102378850@XYUS-EX22.xyus.xyratex.com>
References: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
	<4E8BA3EE.6060300@whamcloud.com>
	<73AED5C780AE05478241DB067651A92102378850@XYUS-EX22.xyus.xyratex.com>
Message-ID: <4E8CB381.40805@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 10/05/2011 09:06 AM, Nathan Rutman wrote:
>
>>
>>> Common
>>> Object ID
>>> The MDT
>>> tracks a special range of OST object ID?s (?wide stripe
>>> objectid? = WSO) that are used on all OSTs.  The MDT
>>> assigns the next available WSO to the file, and this
>>> objectid is used on all the OSTs.  The OSTs must never use
>>> these objects for regular striped files.  A special
>>> precreation group for these objects is probably necessary,
>>> as well as orphan cleanup (the MDT should purge "hole"
>>> objects that aren?t allocated from a particular OST). The
>>> MDT should track the last assigned WSO; this will be the
>>> starting point for new wide striped files after recovery. Objects 
>>> cannot be migrated
>>> from one OST to another, since this would result in
>>> out-of-order access. Similarly, stripes can
>>> never be added to holes.
>>> FID-on-OST
>>> Use a
>>> mapping of the MDT FID to uniquely determine an OST
>>> object.  The clients and MDT add in the OST number to the
>>> MDT FID (probably just reserve one sequence per OST).
>>>  (This allows the objects to potentially migrate to
>>> different OSTs).  The OSTs then internally must map the
>>> FID to a local object id.  Note this allows OST-local
>>> precreation pools, getting the MDT out of the
>>> precreate/orphan cleanup business and potentially
>>> improving create speeds, and also facilitates "create on
>>> write" semantics.  The FID can be assigned during the
>>> first access to OST object.
>>
>> I am not sure I follow your idea here. You mean the OST needs 
>> internally map MDT FID(added in OST number) to object id (or inode ino) ?
> yes.
>
>> So there are no real OST FID?
> I suppose -- this is just a mapping of the MDT fid to the local OST 
> object id, via a local lookup on the OST.  There would be something 
> like the OI to do this mapping.
>
>> But you also said "The FID can be
>> assigned during the first access to OST object.", Could you please
>> explain more here?
>
> Since the FID -> Objid mapping is performed locally, it doesn't need 
> to be assigned until the first write.  This is not integral to the 
> design, just a side effect.

Ah, you mean the object ID can be assigned during the first access, 
instead of FID? This is indeed an interesting idea, and do not need 
extra space. But this may add some limits of the future. (what if we 
decides to store some small file data in MDT directly?) And also it will 
add another difference between MDT and OST, probably it conflicts with 
the efforts of unifying MDT and OST?  I still prefer to have real OST 
FID, i.e. every object has its own identification in the cluster. Please 
correct me if I miss the point of your suggestion.

Thanks
Wangdi

>
>>
>>
>>> The big
>>> problem here is that FID>OBJID ( or better
>>> FID->inode id ) translation is absent from the OSTs
>>> today. See http://wiki.lustre.org/images/e/e9/SC09-FID-on-OST.pdf
>>> (what is the current state of this?)  There is also some
>>> work in this direction in the OST restructuring work
>>> (?Orion? WC branch, ORI-300(?), scheduled for Lustre 2.4).
>>>
>>>
>>> There's
>>> a few questions here, probably the first of which is "is it 
>>> worthwhile to
>>> spend effort on this, or is BZ4424 good enough?" Then there
>>> is the question of object identification, where FID-on-OST
>>> is more flexible, but also significantly more work (and
>>> risk). Also, I thought I understood from the EOFS Summit
>>> that WC also has a separate FID-on-OST project (separate
>>> from Orion that is) -- can someone tell me the state of
>>> that?
>>
>> FID-on-OST is actually part of DNE(dirtribute name space) phase I.  
>> It basically follows current fid client server infrastructure.
>>
>> 1. MDT is the fid client, which requests fid from the OST and 
>> allocates fids for the object during pre-creation.
>> 2. OST is the fid server, which will allocate the FIDs to MDTs and 
>> requests super fid sequence from fid control server (root MDT).
>> 3. Similar as MDT FID, there will be OI to map FID to object inside OST.
>
> To integrate with this, we would need to have a reserved sequence on 
> each OST that the MDT could assign FIDs from --
> the MDT would need to use the same Object ID on all OSTs.  For DNE, 
> there would need to be a reserved sequence per OST per MDT.
>
>
>>
>> The code will be release with DNE sometime next year.
>>
>> Thanks
>> WangDi
>>
>>
> ______________________________________________________________________
> This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
>
> Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
>
> Xyratex Technology Limited (03134912), Registered in England&  Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
>
> The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
> ______________________________________________________________________
>
>

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20111005/837cc869/attachment.htm>
