From: Alex Zhuravlev <Alex.Zhuravlev@sun.com>
Date: Mon, 02 Jun 2008 12:42:01 +0400
Subject: [Lustre-devel] Commit on share
In-Reply-To: <C4620704.5499%peter.braam@sun.com>
References: <C4620704.5499%peter.braam@sun.com>
Message-ID: <4843B259.40106@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

there was an idea to control recovery postponing replies.
can we use this idea for COS? instead of immediate sync
we execute request, but put reply on a special queue. then
reply is sent from the queue when all previous transno
are committed (for COS w/o VBR). if there is no requests to
be handled, but reply queue isn't empty server does sync.
for VBR, the rule is a bit more complex - we'll have to track
dependency on per-object basis.

thanks, Alex


Peter Braam wrote:
> This HLD is definitely not ready at all.  It is very short, lacks 
> interaction diagrams and the arguments made are not sufficiently detailed.
> 
>     * the second sentence is not right.  Commit should happen before
>       un-committed data coming from a client is shared with a 2nd client.
>     * Is COS dependent on VBR ? no it is not, and can equally apply to
>       normal recovery
>     * Section 3.2 is wrong: the recovery process will not fail with gaps
>       in the sequence when there is VBR.  It only fails if there are
>       gaps in the versions, and this is rare.
>     * 3.3 parallel creations in one directory are protected with
>       different, independent lock resources.  Isn?t that sufficient to
>       allow parallel operations with COS?
>     * 3.6 provide a detailed explanation please
>     * GC thread is wrong mechanism this is what we have commit callbacks
>       for
>     * Why not use the DLM, then we can simply keep the client waiting ?
>       the mechanism already exists for repack; I am not convinced at all
>       by the reasoning that rep-ack is so different ? no real facts are
>       quoted
>     * It is left completely without explanation how the hash table
>       (which I think we don?t need/want) is used
> 
> 
> Regards,
> 
> Peter
> 
> 
> ------------------------------------------------------------------------
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
