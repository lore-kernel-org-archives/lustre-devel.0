From: Benjamin Bennett <ben@psc.edu>
Date: Tue, 08 Jul 2008 14:41:39 -0400
Subject: [Lustre-devel] GSS cross-realm on MDT -> OST
In-Reply-To: <C499036B.4E46%peter.braam@sun.com>
References: <C499036B.4E46%peter.braam@sun.com>
Message-ID: <4873B4E3.2010609@psc.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam wrote:
> Yes, it will be very important that we can separate OST's/MDT's widely.
> 
> But placing them in different realms, I'm not sure about.  Can PSC explain
> what administrative model warrants that?  Why can a remote OST not be part
> of the realm of the MDS that controls it?

The OSTs will be distributed among several resource provider 
organizations, each with their own existing domain name space and 
kerberos realm.  There is also a centrally managed teragrid realm which 
could be used to provide cross-realm transit between the resource 
provider realms.  With this kerberos authentication infrastructure 
already in place the issue comes down to that of authorizing a principal 
as an MDS, the logic of which I believe should be reconsidered 
regardless of cross-realm issues.

Currently an OSS's authz of an MDS is inherent in the name of the 
principal (lustre_mds/host) so AFAICT one cannot safely run two distinct 
lustre clusters within a single kerberos realm.  Moreover, this makes 
the assumption that all kerberos admins are knowledgeable enough about 
lustre to only issue lustre_mds/host principals to entities that should 
have MDS privileges throughout the entire realm.  Please do correct me 
if I'm wrong here.


--ben

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 189 bytes
Desc: OpenPGP digital signature
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080708/a5cd273e/attachment.pgp>
