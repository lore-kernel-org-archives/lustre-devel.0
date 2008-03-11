From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 11 Mar 2008 11:00:13 -0700
Subject: [Lustre-devel] Metadata Write Back Cache - review
In-Reply-To: <18390.43888.833221.303657@gargle.gargle.HOWL>
Message-ID: <C3FC16BD.2BE1%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I wanted to ask one more question.  The MDS multithreading is being
mentioned below with an indication that version recovery will take care of
this.  

But is version recovery really replacing ordinary recovery? Otherwise this
argument is not correct.  Iirc version recovery has slightly different
semantics.

- Peter -


On 3/11/08 8:55 AM, "Nikita Danilov" <Nikita.Danilov@Sun.COM> wrote:

> [I am duplicating this to lustre-rabbit-team at sun.com, because
> lustre-devel at lists.lustre.org black-holed my previous attempt to
> distribute this.]
> 
> Peter Braam writes:
>> Hi -
> 
> Hello,
> 
> here is an update of HLD. Not all review points are addressed so far,
> but I think it makes sense to release earlier.
> 
>> 
>> I did a quick review of the HLD for the write back cache (which is
>> in-progress).  Here is the current state and my comments, also attached is
>> the HLD itself for convenience.
> 
> Q1. perceived benefits---lower latency, particularly on a wide area
>     networks.
> 
> Added.
> 
> Q2. order definitions alphabetically.
> 
> Done.
> 
> Q3. define file system object.
> 
> Done.
> 
> Q4. define epoch.
> 
> Done.
> 
> Q5. QAS is what?
> 
> Addressed.
> 
> Q6. add a requirement that "grants prevent unexpected ENOSPC
>     conditions".
> 
> Recorded as "resource leasing" requirement.
> 
> Q7. add a requirement that recovery will lead to well defined results.
> 
> Recorded in "correctness" requirement.
> 
> Q8. incompleteness of functional specification.
> 
> In progress.
> 
> Q9. local sequentiality---for security should this include all preceding
>     operations on any ancestors in the namespace as well?
> 
> Added "Security" sub-section in functional specification that addresses
> additional ordering constraints for reintegration, not necessary for
> basic file system consistency.
> 
> There is a nice symmetry:
> 
>     - together with any operation R relaxing permissions on a directory,
>     an epoch has to include any operation that is a descendant of R (in
>     a subtree order) and that was made earlier than R in the client
>     global time;
> 
>     - together with any operation R an epoch has to include any
>     operation that is an ascendant of R, that tightens permissions, and
>     that was made later than R.
> 
> Q10. Doesn't writing out data independently also introduce a security
>      hole?
> 
> I think the simplest way to address this is to extend meta-data name space
> tree to include data. Specifically, to every regular file (which is a leaf
> node in the meta-data tree) graft "children" representing its stripe
> sub-objects, and to every stripe sub-object graft children representing cached
> data pages. Extension of reintegration ordering constraints to this tree
> closes security holes for data. Added to "5.4 Data consistency".
> 
> Q11. To avoid ongoing negative lookups, how do you transfer full
> directory content to the client? (use case: "make bzImage").
> 
> "Local lookups" sub-section added.
> 
> Q12. Versioning is very important. How are versions handled, how is a
> partial reintegration completed? (the client needs to know the versions
> to which the previous reintegration was applied perhaps?)
> 
> I would very much like to keep all details of recovery encapsulated in
> the Epochs documentation. WBC design is already large and is going to be
> much larger; separation of as much material as possible is the only way
> I see to keep it manageable.
> 
> Speaking of versions, yes, I agree that every epoch has to be equipped
> with a vector in versions for all objects updated by it.
> 
> Q13. What is changed in llite module, or are all changes below it?
> 
> Described in sub-section 6.2 of Logic specification. New functionality
> is to be implemented below llite, but changes in the latter (and in
> other layers too), are necessary to get rid of assumptions about
> synchronous processing of meta-data RPCs.
> 
> Q14. This solution needs to work well on clients with many many CPUs and
> eliminate disadvantages of a single threaded client.
> 
> Described in "7.2 Scalability": per-object logs with per-log locks should
> improve scalability. On the other hand, with the current recovery mechanism we
> are still limited to the maximum of 1 rpc in flight for meta-data; version
> recovery should fix this.
> 
> Q15. All exported API's must be added to HLD in the functional
> specification.
> 
> In progress.
> 
> Q16. Detailed recovery descriptions must be added; epochs is not the
> only use case probably (e.g. networking can fail and come back).
> 
> In progress.
> 
> Q17. If you run out of memory locally, do you push out the changelog?
> 
> Added.
> 
> Q18. Note that there are many server interactions that do not require
> writeout, such as a lookup or getting more fid sequences.
> 
> Clarify in 4.4.
> 
>> 
>> This is mostly on track, but it is a very big project with many angles.
>> 
>> - Peter -
> 
> Nikita.
