From: Peter Braam <Peter.Braam@Sun.COM>
Date: Sat, 07 Jun 2008 08:00:40 -0600
Subject: [Lustre-devel] some thoughts on COS
In-Reply-To: <4847DBAF.5020001@sun.com>
Message-ID: <C46FF0A8.591A%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Somehow making this work seems very attractive.  I really think that
clarifying the definitions further might reveal a solution.

Peter


On 6/5/08 5:27 AM, "Alex Zhuravlev" <Alex.Zhuravlev@Sun.COM> wrote:

> Hi,
> 
> I think it could be great if we can use LDLM for COS. at the very first view
> it looks possible:
> 1) each server lock is tagged with client unique id (uuid/export addr/etc)
> 2) mds registers own blocking AST function
> 3) locks to be used rep-ack's aren't released upon ACK, only upon commit
> 4) whenever conflict is observed by LDLM at enqueue time, MDS's blocking AST
>     function is called and depending on whetner conflicting locks are taken on
>     behalf same or different clients, the function issues sync causing commit
>     and old lock to be released later
> 
> but one use case isn't that obvious. it's OK when first lock L1 was from
> client
> C1 with PW mode and new lock is also from C1/PW. but then we have a situation
> with same client, but locks are PW then PR:
> 1) we wouldn't want to sync just because client does mkdir a; touch a
> 2) thus we have to grant PR lock (so, first problem - sometimes PW and PR
> doesn't
>     conflict?)
> 3) if we cancel PW to grant PR, then we'd have to make this PR conflicting
> with
>     any PR coming from different client?
> 4) changing PR to PW in order to inherit state? (client side doesn't expect
> such
>     locks_
> 
> all of this doesn't sound like a good solution, IMHO. at least it'd require
> serious
> changes in LDLM while we're talking about 1.6/1.8 ... so we need another way.
> 
> probably we could re-use VBR as each inode change goes with new persistent
> version
> and version is numerically equal to transno, comparing inode's version with
> last
> committed transno we can learn whether the inode is committed?
> 
> next problem is to learn source of change, i.e. client. in the worst case all
> changes
> are from different clients, thus every change means sync. but if we *cache*
> source
> information we probably can avoid majority of syncs. IOW, we don't need to
> track
> source all the time, it should be enough if we have this information most of
> time.
> so, storing it in in-core inode is good enough probably. following this way we
> don't
> need to care about inode's lifetime.
> 
> thanks, Alex
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
