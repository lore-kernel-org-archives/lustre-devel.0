From: Canon, Richard Shane <canonrs@ornl.gov>
Date: Wed, 13 Feb 2008 15:35:02 -0500
Subject: [Lustre-devel] Global generic database
In-Reply-To: <47B335B6.5010703@sun.com>
References: <47B335B6.5010703@sun.com>
Message-ID: <537C6C0940C6C143AA46A88946B854170C1C9BB7@ORNLEXCHANGE.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



JC mentioned this when we were talking about the Space Manager component
in the HSM design.  The Space Manager would have some type of policy
language and the policies need to be stored some where.  Another use
case would be QoS policies when that starts to appear.

--Shane

-----Original Message-----
From: lustre-devel-bounces@lists.lustre.org
[mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Nathaniel
Rutman
Sent: Wednesday, February 13, 2008 1:24 PM
To: lustre-devel at lists.lustre.org; aurelien.degremont at cea.fr;
Eric.Barton at Sun.COM
Subject: [Lustre-devel] Global generic database

The design of various new features in Lustre call for global (filesystem

wide) databases, accessible from
clients or other servers:
A. pools - pool descriptions (pool #1 = OSTs 1-10,30-60), pool policies 
(all .jpg files to pool #1)
B. filesets - fileset policies (log creates on fileset #1 to feed "foo")
C. HSM - (aureleien - what was the use case here?)

We've already implemented at least 2 of these:
D. Fid Location Database - (is this done?)
E. configuration parameters - stored in MGS llogs

Rather than continue 1-off implementations, I think it's time we came up

with a consistent,
global, generic database mechanism for A-C as well as other future uses.
Needs to be:
1. Fast. We need to cache database entries locally, which also means 
having them under locks.
    a. local caching
    b. locks
2. Generic.  Store any kind of data, not limited to 8k page boundaries,
etc.
3. Transactional.  Power loss doesn't lead to inconsistent state.
4. Recoverable. Client changes are replayed if need be.
5. Remotely accessible, from a client or other servers.
_______________________________________________
Lustre-devel mailing list
Lustre-devel at lists.lustre.org
http://lists.lustre.org/mailman/listinfo/lustre-devel
