From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 28 Feb 2008 21:30:45 -0700
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <47C594F8.20409@cea.fr>
Message-ID: <C3ECD885.117D%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The discussion below about the API's is a standard element of data
abstraction taught in advanced programming courses  (see e.g. Abelson et.
al. Structure and Interpretation of Computer Programs (SICP)).

From this one concludes that the coordinator and agents will use abstract
data types and call abstract methods that accommodate multiple:
- source and destination descriptors for the data
- data movers implementing the methods to move data

If you proceed along the lines you outline you will get a big matrix of
movers and data types to keep track of.  If you follow my approach you will
encapsulate things much more cleanly.

Think in terms of virtual classes data movers acting on source and
destination objects.

- peter -



On 2/27/08 9:51 AM, "Aurelien Degremont" <aurelien.degremont@cea.fr> wrote:

> 
> Peter J Braam a ?crit :
>>> Coordinator:
>>> 
>>> This element will manage migration externally (HSM) and internally of
>>> Lustre (space balancing?). Is the current API acceptable (specific
>>> calls for external migration, and other ones for internal migration)?
>> I would like to see a parameter indicating what agent will be used and
>> keep all other parameters the same.
> 
> Agreed.
> 
>>>  The best way could have been to have generic call for migration, but
>>> we must also have generic objects to describe the migration sources
>>> and destinations and those are not simples.
>> For migration to and from external sources, Lustre must already manage
>> this data in an extended attribute (e.g. to describe the file on tape to
>> which a Lustre file was migrated).  This data is opaque to Lustre and
>> can be passed as a blob.
>>> It seems, to support Lustre internal migration, you have planned to
>>> implement specific Agents which will reside on OST.
>> To avoid many complications involving locks, we decided that even the
>> agents used for internal migrations will layer on the file system.  The
>> Lustre file system will be mounted on the OST's and it will use the
>> "LOLND" to transport the data efficiently between the OST process and
>> the client file system cache.  In the internal case source and
>> destination lie in Lustre in the HSM case only one of them.
>> 
>> As a result I believe these two cases are closer together than you may
>> think, and should be one "type".
> 
> 
> If we unify the API, we must have a way to request some data movement like:
> 
> copy elemA in placeP
> copy elemA,stored in placeP bak into Lustre
> copy elemA into placeC
> move elemB into elemB
> 
> 
> The elem could be unified using Lustre FID, but the places could be an
> external storage, or a precise OST. If we want a unify API, the API call
> should manipulate a generic object which could describe a Lustre storage
> element (ost) or a external storage (hsm,...)
> 
> ie:
>    struct storage_place {
>      ...
>    }
>    copy(fid,storage_place*)
>    move(fid,storage_place*)
> 
> and their is some specific cases to handle. The other possibity:
> 
>    ext_copyout(fid, external storage)
>    ext_copyin(fid, external object)
>    int_copy(fid, fid, ost)
>    int_move(fid, fid, ost)
> 
> I think this one, even if the design is not the most beautiful one, if
> the easiest one.
> 
> Instead you want to create some new generic objects to manipulate lustre
> object data and generic storage areas, the second case is the best one IMO.
> 
