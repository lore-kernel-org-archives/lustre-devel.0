From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 08 Jul 2008 13:39:35 -0600
Subject: [Lustre-devel] GSS cross-realm on MDT -> OST
In-Reply-To: <4873B4E3.2010609@psc.edu>
Message-ID: <C4991E97.4E5B%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hmm. Perhaps there are implementation issues here that overshadow the
architecture.

To interact with MDS nodes that are part of one file system, the MDS needs
to be part of a realm.  The MDS performs authorization based on a principal
to MDS (i.e. Lustre) user/group database.   Within one Lustre file system
each MDS MUST HAVE the same user group database.  We will likely want to
place MDS's distributedly in the longer term future, so take clear note of
this: one Kerberos realm owns the entire MDS cluster for a file system.

There can be multiple MDS clusters, i.e. Lustre file systems, in a single
realm, each serving their own file system.  Each Lustre file system can have
its own user/group database.  No restrictions here.

For a given file system the MDS nodes produce capabilities which the OSS
nodes use for authorization.   It is important that the MDS can maken
authenticated RPC's to the OSS nodes in its file system and for this we use
Kerberos (this is not a "must have" - it could have been done with a
different key sharing mechanism).

==> So the first issue you have to become clear about is how you authorize
an MDS to contact one of its OSS nodes, wherever these are place.

Similarly the Kerberos connections are used by the clients to connect to the
OSS, but they are not used to authenticate anything (but optionally the
node), they are used merely to provide privacy and/or authenticity for
transporting data between the client and the OSS nodes.  With relatively
little effort this could be done without Kerberos at all, on the other hand,
probably using Kerberos for this leads to a more easily understood
architecture.

So, to repeat,  the authorization uses capabilities, which authenticate the
requestor and contain authorization information, independent of a server
user/group database on the OSS.

==> The second issue you need to be clear about is how you authenticate
client NODES (NOT users) to OSS nodes.

Peter




On 7/8/08 12:41 PM, "Benjamin Bennett" <ben@psc.edu> wrote:

> Peter Braam wrote:
>> Yes, it will be very important that we can separate OST's/MDT's widely.
>> 
>> But placing them in different realms, I'm not sure about.  Can PSC explain
>> what administrative model warrants that?  Why can a remote OST not be part
>> of the realm of the MDS that controls it?
> 
> The OSTs will be distributed among several resource provider
> organizations, each with their own existing domain name space and
> kerberos realm.  There is also a centrally managed teragrid realm which
> could be used to provide cross-realm transit between the resource
> provider realms.  With this kerberos authentication infrastructure
> already in place the issue comes down to that of authorizing a principal
> as an MDS, the logic of which I believe should be reconsidered
> regardless of cross-realm issues.
> 
> Currently an OSS's authz of an MDS is inherent in the name of the
> principal (lustre_mds/host) so AFAICT one cannot safely run two distinct
> lustre clusters within a single kerberos realm.  Moreover, this makes
> the assumption that all kerberos admins are knowledgeable enough about
> lustre to only issue lustre_mds/host principals to entities that should
> have MDS privileges throughout the entire realm.  Please do correct me
> if I'm wrong here.
> 
> 
> --ben
> 
