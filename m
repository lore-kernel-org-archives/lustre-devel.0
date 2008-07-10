From: Eric Mei <Eric.Mei@Sun.COM>
Date: Thu, 10 Jul 2008 10:45:16 -0600
Subject: [Lustre-devel] GSS cross-realm on MDT -> OST
In-Reply-To: <48751A75.1000102@psc.edu>
References: <C49A27F8.4E91%peter.braam@sun.com> <4874F47B.4010209@sun.com>
	<48751A75.1000102@psc.edu>
Message-ID: <48763C9C.4000003@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Benjamin Bennett wrote:
> Eric Mei wrote:
>> Peter Braam wrote:
>>>
>>>
>>> On 7/8/08 2:38 PM, "Benjamin Bennett" <ben@psc.edu> wrote:
>>>
>>>> Peter Braam wrote:
>>>>> Hmm. Perhaps there are implementation issues here that overshadow the
>>>>> architecture.
>>>>>
>>>>> To interact with MDS nodes that are part of one file system, the 
>>>>> MDS needs
>>>>> to be part of a realm.  The MDS performs authorization based on a 
>>>>> principal
>>>>> to MDS (i.e. Lustre) user/group database.   Within one Lustre file 
>>>>> system
>>>>> each MDS MUST HAVE the same user group database.  We will likely 
>>>>> want to
>>>>> place MDS's distributedly in the longer term future, so take clear 
>>>>> note of
>>>>> this: one Kerberos realm owns the entire MDS cluster for a file 
>>>>> system.
>>>> Could you explain more on why this requires a single realm and not just
>>>> consistent mappings across all MDSs?
>>>
>>> That MIGHT work ... But how would two domains guarantee consistent 
>>> updates
>>> to the databases?  However, the server - server trust across domains 
>>> we need
>>> is new to me (and I am not sure if/how it works).
>>
>> Practically it's doable, of course. But as Peter pointed out the user 
>> database must be the same across all MDSs within a Luster FS. If 2 
>> MDSs could share the user database, why bother putting them into 
>> different kerberos realms? So we assume all MDSs should be in a single 
>> realm. Does TeraGrid have different requirement?
> 
> TeraGrid has a central database of users which could be used to 
> consistently generate mappings.
> 
> The reason to bother putting MDSs in separate realms is that TeraGrid is 
> composed of distinct organizations.  We are trying to distribute a 
> filesystem across several organizations, not simply implement a 
> centralized fs accessed by several organizations.

I see, thanks for explanation. I think if the issue of server membership 
solved, there'll be no problem to do that as GSS/Kerberos's aspect.

>>>>> There can be multiple MDS clusters, i.e. Lustre file systems, in a 
>>>>> single
>>>>> realm, each serving their own file system.  Each Lustre file system 
>>>>> can have
>>>>> its own user/group database.  No restrictions here.
>>>> Well, that's the problem with multiple clusters in a single realm, lack
>>>> of restriction... ;-)
>>>
>>> Restrict yourself, not me or Lustre :)
>>>
>>>>> For a given file system the MDS nodes produce capabilities which 
>>>>> the OSS
>>>>> nodes use for authorization.   It is important that the MDS can maken
>>>>> authenticated RPC's to the OSS nodes in its file system and for 
>>>>> this we use
>>>>> Kerberos (this is not a "must have" - it could have been done with a
>>>>> different key sharing mechanism).
>>>> With multiple clusters in a single realm an MDS from any cluster could
>>>> authenticate and authorize as an MDS to an OSS in any cluster.
>>>
>>>
>>>
>>> Good point.  If so that should be a bug.
>>>
>>> ===> Eric Mei, what is the story here?
>>
>> Yes Ben is right, currently in a same realm any MDS could authenticate 
>> with any MDS and OSS. But afaics the problem is nothing to do with 
>> Kerberos. It's because currently Lustre have no config information 
>> about the server cluster membership, each server target have no idea 
>> what other targets are.
>>
>> So solve this, we can either place the configuration on each MDS/OST 
>> nodes - as Ben proposed in last mail; or probably better centrally 
>> managed by MGS, thus MDT/OST would be able to get uptodate server 
>> cluster information. Would it work?
> 
> Sounds like a good idea.  If I understand correctly...
>   A) An MDT/OST is explicitly given the MGS NID by a trusted entity 
> (administrator) during mkfs.
> 
>   B) The MGS principal name would be derived from its NID (assuming 
> lustre_mgs/mgsnode at REALM).  Realm is determined from the usual kerberos 
> dns -> realm mapping mechanism?
> 
>   C) MDT and OST (or just MDS, OSS) list retrieved via secured MGC -> 
> MGS connection.
> 
>   D) MDS and OSS principal names are derived from MDS and OSS NIDs. Same 
> realm determination as in B?

Well I guess you're talking about secure connection of MGC->MGS. Yes we 
have plan to add that in the near future.

As for the server membership control, I meant sysad need to teach MGS 
that a Lustre filesytem is comprised of what MDT/OSTs. And when a 
MDT/OST mounting, it can get the server list from MGS, thus it would 
know to prevent unwanted connection which pretend to be a MDT.

And I think the membership management better be working for both with or 
without Kerberos.

>>> The key (which is manually generated) should authenticate an instance 
>>> of an
>>> MDS, not a "cluster".   The only case where this might become 
>>> delicate is if
>>> one MDS node is the server for two file systems.
>>
>> GSS/Kerberos is for the a certain kind service on a node, we can tell 
>> it simply from the composition of Kerberos principal 
>> "service_name/hostname at REALM". As to Lustre, lustre_mds/hostname at REALM 
>> it's for MDS, not specific to MDT. So if two MDTs on a MDS serving two 
>> different file systems, GSS/Kerberos authentications are performed in 
>> the same way for them, further access control should be handled by 
>> each target (MDT/OST).
>>
>>>>  This would allow an MDS in one cluster to change the key used for
>>>> capabilities on the OSSs in another cluster, no?
>>>>
>>>>> ==> So the first issue you have to become clear about is how you 
>>>>> authorize
>>>>> an MDS to contact one of its OSS nodes, wherever these are place.
>>>> I've changed lsvcgssd on the OSSs to take an arbitrary number of '-M
>>>> lustre_mds/mdshost at REALM' and use this list to determine MDS
>>>> authorization.  Is there a way in which an OSS is already aware of its
>>>> appropriate MDSs?
>>>
>>> As you pointed out, we need that, and Eric Mei should help you get that.
>>
>> Yes that works, probably as temporary solution. As described above, 
>> currently OSS don't know that info. we may need a more complete 
>> centrally controlled server membership authentication, maybe 
>> independent of GSS/Kerberos.
> 
> If you're interested, the patch I have is at [1].

Thanks.

>>>>> Similarly the Kerberos connections are used by the clients to 
>>>>> connect to the
>>>>> OSS, but they are not used to authenticate anything (but optionally 
>>>>> the
>>>>> node), they are used merely to provide privacy and/or authenticity for
>>>>> transporting data between the client and the OSS nodes.  With 
>>>>> relatively
>>>>> little effort this could be done without Kerberos at all, on the 
>>>>> other hand,
>>>>> probably using Kerberos for this leads to a more easily understood
>>>>> architecture.
>>>>>
>>>>> So, to repeat,  the authorization uses capabilities, which 
>>>>> authenticate the
>>>>> requestor and contain authorization information, independent of a 
>>>>> server
>>>>> user/group database on the OSS.
>>>>>
>>>>> ==> The second issue you need to be clear about is how you 
>>>>> authenticate
>>>>> client NODES (NOT users) to OSS nodes.
>>>> Client nodes are issued lustre_root/host credentials from their local
>>>> realm.  This works just fine for Client -> OST since the only
>>>> [kerberos-related] authorization check is a "lustre_root" service part.
>>>
>>> Good.  Does it work across realms, because it seems we need that in any
>>> case?
>>
>> Yes, Ben had a patch to make it work.
> 
> The foreign lustre_root principals have to be mapped on the MDS to allow 
> mount.  What are your thoughts on authorizing [squashed] mount to all, 
> so as to not require mapping?

It was original assumption we made is that "remote realm" means 
"different user database". That's why remote realm user have to be 
remapped to a local user. It seems in TeraGrid case that's not true anymore.

The squashed mount, if I understand it correctly, it can be done by set 
a mapping entry in lustre/idmap.conf, to map "*@REALM" from NID "*" to a 
local user "U" - I don't remember the exact syntax though.

As for the user mapping part, I always feel not confident whether the 
current implementation is what people really want or not, and not fully 
tested, that's why I didn't put the UID mapping information on the 
public wiki. I believe you are the first one outside of Lustre Group to 
try that :) any opinions are very welcome, but decisions to change need 
to be made by Peter Braam.

>>> BTW, thank you for trying this all out in detail, that is very helpful.
>>> Perhaps Sheila could talk with you and Eric Mei and get a nice 
>>> writeup done
>>> for the manual.
> 
> np :-)
> 
> 
> --ben
> 
> [1] http://staff.psc.edu/ben/patches/lustre/lustre-explicit-mds-authz.patch

-- 
Eric
