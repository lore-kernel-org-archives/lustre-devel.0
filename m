From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Wed, 11 Jun 2008 18:21:27 +0400
Subject: [Lustre-devel] Commit on share
In-Reply-To: <C4620704.5499%peter.braam@sun.com>
References: <C4620704.5499%peter.braam@sun.com>
Message-ID: <200806111821.27616.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

On 27 May 2008 14:44:18 Peter Braam wrote:
> This HLD is definitely not ready at all.  It is very short, lacks
> interaction diagrams and the arguments made are not sufficiently
> detailed.

is the following definition of dependent operation more clear?

Operation B depends on operation A if:

1. A and B modify the same object
2. B modifies the object after A (LDLM serializes object access) 
3. A isn't committed yet
4. A and B are issued by different clients

> * the second sentence is not right.  Commit should happen before
> un-committed data coming from a client is shared with a 2nd client.
> * Is COS dependent on VBR ? no it is not, and can equally apply to
> normal recovery
> * Section 3.2 is wrong: the recovery process will not fail with gaps
> in the sequence when there is VBR.  It only fails if there are gaps
> in the versions, and this is rare.
> * 3.3 parallel creations in one directory are protected with
> different, independent lock resources.  Isn?t that sufficient to
> allow parallel operations with COS?

The objects in the definition of dependent operation can be those parts 
of the directory identified by hash.

> * 3.6 provide a detailed explanation please
> * GC thread is wrong mechanism this is what we have commit callbacks
> for * Why not use the DLM, then we can simply keep the client waiting
> ? the mechanism already exists for repack;

CoS is just an improved version of rep-ack, using persistent storage 
instead of client replay queue?

> I am not convinced at all 
> by the reasoning that rep-ack is so different ? no real facts are
> quoted * It is left completely without explanation how the hash table
> (which I think we don?t need/want) is used
>
> Regards,
>
> Peter

Thanks,
-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
