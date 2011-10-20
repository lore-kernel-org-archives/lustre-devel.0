From: Alex Kulyavtsev <aik@fnal.gov>
Date: Thu, 20 Oct 2011 11:24:53 -0500
Subject: [Lustre-devel] Wide striping
In-Reply-To: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
References: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
Message-ID: <3EDC1D49-4A97-4F3A-A9DE-BE2C976665E4@fnal.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Oct 3, 2011, at 3:15 PM, Nathan Rutman wrote:

> ... snip...
> We have been thinking about a different wide-striping method that  
> doesn't have these problems. The basic idea is to create a new  
> stripe type that encodes the list of OSTs compactly, and then using  
> the same (or a calculable) object identifier (or FID) on all these  
> OSTs.
>
>
> Our version of widestriping does not involve increasing the EA size  
> at all, but instead utilizes a new stripe pattern.  (This will not  
> be understandable by older Lustre versions, which will generate an  
> error locally, or potentially we can convert into the BZ-4424 form  
> if the layout fits in that format). A bitmap will identify which  
> OSTs hold a stripe of this file. The bitmap should probably fit into  
> current ext4 EA size limit, giving us ~32k stripes.
>
> Some OST?s may be down at file creation time, or new OSTs added  
> later; hence there will likely be holes in the bitmap (but  
> relatively few).

1) There will be holes when OST pools used: if the file can be written  
only to the set of OST from specific OST POOL and if by the virtue of  
configuration OSTs in the  pool do not represent continuous set then  
there will be holes in OST bit map even if all OSTs are online.

2) "relatively few holes [in bitmap]" - did you consider compressing  
bitmap? Like BBC or WAH described at en.wikipedia.org/wiki/ 
Bitmap_index#Compression ? Reportedly you can do bitwise operations  
without decompression. This way you can go up in number of stripes  
(well, 32k is big number). But it may help control RPC size - you may  
represent wide striping with few integers effectively representing  
continuous blocks and OST holes, the size of the descriptor is the  
function of # of blocks and holes and to the less extent function of  
number of stripes.
More:
It is possible to have two bitmaps:
0000000111111111000000111111 - one describing general "blocks" of OST  
= ((beg1,end1),(beg2,end2))
0000000000000010100100100000 - other describing "corrections" - drop  
two OST, add two OST ; here 4 bits, compressed to X bytes
0000000111111101100100011111 - OST map, computed on client as bitwise  
XOR to uncompressed maps (1) and (2)
Each of two maps is compressed for transfer, thus shall not take much  
space.

3) If metadata file format going to be changed, is it right time to  
reserve descriptors to have few replicas of the file data?

In such case we need to have number of replicas, and layout descriptor  
for each replica. Each replica may have different number of stripes,  
thus you can have widely striped file replica on SAS disks (or in  
flash) and replicate it to slower disk storage with one or "few"  
stripes for further tape archival.
  I assume after initial writes file has more or less "stable"  
content. Replicas can be on different media type, like flash/ SAS/  
SATA, fast / cheap disks, effectively Hierarchical Storage.
I'm thinking about "lazy" replication as you implemented to replicate  
data to another file system but in this case replication is within the  
same lustre file system. Client became aware of multiple replicas and  
can chose  what file replica to use (e.g when some OSTs down). It  
eliminates OST as single point of failure.

Alex.

> ______________________________________________________________________
> This email may contain privileged or confidential information, which  
> should only be used for the purpose for which it was sent by  
> Xyratex. No further rights or licenses are granted to use such  
> information. If you are not the intended recipient of this message,  
> please notify the sender by return and delete it. You may not use,  
> copy, disclose or rely on the information contained in it.
>
> Internet email is susceptible to data corruption, interception and  
> unauthorised amendment for which Xyratex does not accept liability.  
> While we have taken reasonable precautions to ensure that this email  
> is free of viruses, Xyratex does not accept liability for the  
> presence of any computer viruses in this email, nor for any losses  
> caused as a result of viruses.
>
> Xyratex Technology Limited (03134912), Registered in England &  
> Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
>
> The Xyratex group of companies also includes, Xyratex Ltd,  
> registered in Bermuda, Xyratex International Inc, registered in  
> California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia,  
> Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic  
> of China and Xyratex Japan Limited registered in Japan.
> ______________________________________________________________________
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20111020/a01ee1d3/attachment.htm>
