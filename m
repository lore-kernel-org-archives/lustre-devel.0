From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 09 Jul 2008 08:31:52 -0600
Subject: [Lustre-devel] GSS cross-realm on MDT -> OST
In-Reply-To: <4873D03D.5060002@psc.edu>
Message-ID: <C49A27F8.4E91%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 7/8/08 2:38 PM, "Benjamin Bennett" <ben@psc.edu> wrote:

> Peter Braam wrote:
>> Hmm. Perhaps there are implementation issues here that overshadow the
>> architecture.
>> 
>> To interact with MDS nodes that are part of one file system, the MDS needs
>> to be part of a realm.  The MDS performs authorization based on a principal
>> to MDS (i.e. Lustre) user/group database.   Within one Lustre file system
>> each MDS MUST HAVE the same user group database.  We will likely want to
>> place MDS's distributedly in the longer term future, so take clear note of
>> this: one Kerberos realm owns the entire MDS cluster for a file system.
> 
> Could you explain more on why this requires a single realm and not just
> consistent mappings across all MDSs?

That MIGHT work ... But how would two domains guarantee consistent updates
to the databases?  However, the server - server trust across domains we need
is new to me (and I am not sure if/how it works).

> 
>> There can be multiple MDS clusters, i.e. Lustre file systems, in a single
>> realm, each serving their own file system.  Each Lustre file system can have
>> its own user/group database.  No restrictions here.
> 
> Well, that's the problem with multiple clusters in a single realm, lack
> of restriction... ;-)

Restrict yourself, not me or Lustre :)

> 
>> For a given file system the MDS nodes produce capabilities which the OSS
>> nodes use for authorization.   It is important that the MDS can maken
>> authenticated RPC's to the OSS nodes in its file system and for this we use
>> Kerberos (this is not a "must have" - it could have been done with a
>> different key sharing mechanism).
> 
> With multiple clusters in a single realm an MDS from any cluster could
> authenticate and authorize as an MDS to an OSS in any cluster.



Good point.  If so that should be a bug.

===> Eric Mei, what is the story here?

The key (which is manually generated) should authenticate an instance of an
MDS, not a "cluster".   The only case where this might become delicate is if
one MDS node is the server for two file systems.

>  This 
> would allow an MDS in one cluster to change the key used for
> capabilities on the OSSs in another cluster, no?
> 
>> ==> So the first issue you have to become clear about is how you authorize
>> an MDS to contact one of its OSS nodes, wherever these are place.
> 
> I've changed lsvcgssd on the OSSs to take an arbitrary number of '-M
> lustre_mds/mdshost at REALM' and use this list to determine MDS
> authorization.  Is there a way in which an OSS is already aware of its
> appropriate MDSs?

As you pointed out, we need that, and Eric Mei should help you get that.

> 
>> Similarly the Kerberos connections are used by the clients to connect to the
>> OSS, but they are not used to authenticate anything (but optionally the
>> node), they are used merely to provide privacy and/or authenticity for
>> transporting data between the client and the OSS nodes.  With relatively
>> little effort this could be done without Kerberos at all, on the other hand,
>> probably using Kerberos for this leads to a more easily understood
>> architecture.
>> 
>> So, to repeat,  the authorization uses capabilities, which authenticate the
>> requestor and contain authorization information, independent of a server
>> user/group database on the OSS.
>> 
>> ==> The second issue you need to be clear about is how you authenticate
>> client NODES (NOT users) to OSS nodes.
> 
> Client nodes are issued lustre_root/host credentials from their local
> realm.  This works just fine for Client -> OST since the only
> [kerberos-related] authorization check is a "lustre_root" service part.

Good.  Does it work across realms, because it seems we need that in any
case?

BTW, thank you for trying this all out in detail, that is very helpful.
Perhaps Sheila could talk with you and Eric Mei and get a nice writeup done
for the manual.

Regards

peter


> 
>> Peter
> 
> --ben
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
