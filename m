From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Wed, 27 Feb 2008 17:51:04 +0100
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <47C34358.6050806@sun.com>
References: <47AAE307.9040305@cea.fr> <47BD980F.50201@cea.fr>
	<47C34358.6050806@sun.com>
Message-ID: <47C594F8.20409@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Peter J Braam a ?crit :
>> Coordinator:
>>
>> This element will manage migration externally (HSM) and internally of 
>> Lustre (space balancing?). Is the current API acceptable (specific 
>> calls for external migration, and other ones for internal migration)?
> I would like to see a parameter indicating what agent will be used and 
> keep all other parameters the same.

Agreed.

>>  The best way could have been to have generic call for migration, but 
>> we must also have generic objects to describe the migration sources 
>> and destinations and those are not simples.
> For migration to and from external sources, Lustre must already manage 
> this data in an extended attribute (e.g. to describe the file on tape to 
> which a Lustre file was migrated).  This data is opaque to Lustre and 
> can be passed as a blob.
>> It seems, to support Lustre internal migration, you have planned to 
>> implement specific Agents which will reside on OST.
> To avoid many complications involving locks, we decided that even the 
> agents used for internal migrations will layer on the file system.  The 
> Lustre file system will be mounted on the OST's and it will use the 
> "LOLND" to transport the data efficiently between the OST process and 
> the client file system cache.  In the internal case source and 
> destination lie in Lustre in the HSM case only one of them.
> 
> As a result I believe these two cases are closer together than you may 
> think, and should be one "type".


If we unify the API, we must have a way to request some data movement like:

copy elemA in placeP
copy elemA,stored in placeP bak into Lustre
copy elemA into placeC
move elemB into elemB


The elem could be unified using Lustre FID, but the places could be an 
external storage, or a precise OST. If we want a unify API, the API call 
should manipulate a generic object which could describe a Lustre storage 
element (ost) or a external storage (hsm,...)

ie:
   struct storage_place {
     ...
   }
   copy(fid,storage_place*)
   move(fid,storage_place*)

and their is some specific cases to handle. The other possibity:

   ext_copyout(fid, external storage)
   ext_copyin(fid, external object)
   int_copy(fid, fid, ost)
   int_move(fid, fid, ost)

I think this one, even if the design is not the most beautiful one, if 
the easiest one.

Instead you want to create some new generic objects to manipulate lustre 
object data and generic storage areas, the second case is the best one IMO.


-- 
Aurelien Degremont
CEA
