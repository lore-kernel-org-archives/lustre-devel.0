From: Alex Kulyavtsev <aik@fnal.gov>
Date: Thu, 20 Oct 2011 15:15:06 -0500
Subject: [Lustre-devel] Wide striping
In-Reply-To: <73AED5C780AE05478241DB067651A921023788CF@XYUS-EX22.xyus.xyratex.com>
References: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
	<3EDC1D49-4A97-4F3A-A9DE-BE2C976665E4@fnal.gov>
	<AC496A61-5807-4E46-B7D9-0717E363F0BD@whamcloud.com>
	<73AED5C780AE05478241DB067651A921023788CF@XYUS-EX22.xyus.xyratex.com>
Message-ID: <4091F461-E2B7-413A-BEEB-D0460B72E5E1@fnal.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Oct 20, 2011, at 2:08 PM, Nathan Rutman wrote:

>
> On Oct 20, 2011, at 11:45 AM, Andreas Dilger wrote:
>
>> On 2011-10-20, at 10:24 AM, Alex Kulyavtsev wrote:
>>> On Oct 3, 2011, at 3:15 PM, Nathan Rutman wrote:
>>>> We have been thinking about a different wide-striping method that  
>>>> doesn't have these problems. The basic idea is to create a new  
>>>> stripe type that encodes the list of OSTs compactly, and then  
>>>> using the same (or a calculable) object identifier (or FID) on  
>>>> all these OSTs.
>>>>
>>>
>>> 1) There will be holes when OST pools used: if the file can be  
>>> written only to the set of OST from specific OST POOL and if by  
>>> the virtue of configuration OSTs in the  pool do not represent  
>>> continuous set then there will be holes in OST bit map even if all  
>>> OSTs are online.
>>
>> Since the membership in a pool can change after a file is allocated,
>> there cannot be anything in the layout that depends on the current
>> membership of the pool.  In this regard, the layout of a file that
>> is allocated in the pool should be identical to a non-pool file, with
>> the exception that it saves the pool name in which the file was  
>> created.
>> That allows future operations (migration, replication, etc) to take  
>> the
>> originally requested pool of the user into account.
> Yes, exactly like current striping works -- pool name is recorded,  
> but is only informational: actual striping is explicitly recorded.
Sorry for not being clear, I agree the file is laid out at creation  
time.
I'm just trying to make a point pool configuration is the other source  
of holes in bitmap in addition to OSTs down.

Suppose user purchased eight OST each year for three years, and  
allocated four OSTs to pool1, four to pool2.
OST numbering get mixed and  OSTs are assigned as follows:
1111 0000   1111 0000   1111 0000 - pool1
0000 1111   0000 1111   0000 1111 - pool2

All OSTs are up, and file was striped across all OSTs in pool1. Thus  
the file layout is like
1111 0000   1111 0000  1111 0000
The file has holes in OST layout because of pool configuration.

>
>>
>>> 2) "relatively few holes [in bitmap]" - did you consider  
>>> compressing bitmap? Like BBC or WAH described at en.wikipedia.org/ 
>>> wiki/Bitmap_index#Compression ? Reportedly you can do bitwise  
>>> operations without decompression. This way you can go up in number  
>>> of stripes (well, 32k is big number). But it may help control RPC  
>>> size - you may represent wide striping with few integers  
>>> effectively representing continuous blocks and OST holes, the size  
>>> of the descriptor is the function of # of blocks and holes and to  
>>> the less extent function of number of stripes.
>>
>> I think that having some kind of bitmap compression seems reasonable,
>> and extends the number of stripes that can be fit into a single  
>> layout
>> for most cases.  Originally I was thinking that in addition to saving
>> the starting index of the bitmap, we could also save the index at  
>> which
>> the bitmap wraps back to 0 (i.e. bit N = (start_idx + N) % wrap_idx),
>> but if there is bitmap compression then the run of zeroes between the
>> starting index and the (lower) ending index could be stored  
>> efficiently
>> as well.
>
> I don't think there's any point of compressing this.  32,000 stripes  
> fit in the old EA limit, and there's going to be plenty of other  
> limits hit before
> we start using 32,000 OSTs.  And even then, we can use the larger EA  
> size.   So perhaps we turn the question around and ask, "how many  
> stripes do you want to support"?
Frankly, we do not use wide striping at this point and 32k is a "large  
number."
Having said that, if you have flash OST on each compute node and/or  
have replication and can use local disk on compute node for  
opportunistic storage ("local file replica"), the number of OSTs is  
O(compute nodes) in the cluster and that can be "large number" too.

Best regards, Alex.

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20111020/eff8fe41/attachment.htm>
