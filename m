From: quentin.bouget at cea.fr <quentin.bouget@cea.fr>
Date: Tue, 1 Sep 2020 11:33:37 +0200
Subject: [lustre-devel] Error checking for llapi_hsm_action_progress().
In-Reply-To: <87mu2aqpnp.fsf@notabene.neil.brown.name>
References: <87pn77qx60.fsf@notabene.neil.brown.name>
 <2659fe05-9cd7-afd3-e1ce-c1726129e354@cea.fr>
 <87mu2aqpnp.fsf@notabene.neil.brown.name>
Message-ID: <3df93cf2-1a94-f7bf-e073-29bf0c8c985a@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 01/09/2020 02:58, NeilBrown wrote:
> On Mon, Aug 31 2020, quentin.bouget at cea.fr wrote:
>> On 31/08/2020 06:03, NeilBrown wrote:
>>> I tried removing that check, but there is a test (hsm_test 108)
>>> which checks for repeating identical intervals.
>> test108 handles a "growing" extent (offset=0, length=1, 2, 3, ...).
> test108_progress() in llapi_hsm_test.c sets:
> 		he.offset = 0;
> 		he.length = length;
> where 'length' is 1000.  It reports progress for this extent 1000 times.
> Then complains if the total progress isn't 1000.

My bad, I read that wrong. You are right.

>> test112 handles acknowledging non-overlapping extents twice each.
> Yep.  10 non-overlapping extents, then sends the same 10 again.
>
>> I wrote a test to check what happens if you acknowledge overlapping extents:
>>
>>    * (offset=0, length=256)
>>    * (offset=128, length=256)
>>
>> And surely enough mdt_cdt_get_work_done() returns "512" rather than the
>> expected "384" (ie. 128 + 256).
>>
>> Even worse, when acknowledging a "shrinking" extent (offset=0, length=N,
>> N - 1, N - 2, ...), only the last value is kept in store.
> Does that even mean anything?  It seems to be saying "I've done N amount
> of work" and then "Sorry, I lied, I've only done N-1"...

I think it could happen if a copytool spreads HSM actions to multiple 
workers, one of the worker stalls, its work is resubmitted to another 
worker, and both of them acknowledge extents with different lengths.

But yes, this is at best a weird/bad corner case.

> But I'm surprised at your result that only the last is kept.  Reading
> the code strongly suggests that it would report the sum of all these
> regions.  N^2/2 if you continued to  N-N.

That was me being wrong again. It behaves just like you say.

> How do you perform these tests?  Is there a command-line tool, or would
> I need to write some code?

I copied test112 in llapi_hsm_test.c and edited the code (and read the 
error message wrong =/).

>> From this, I think that exact duplicates are not really ignored, 
>> rather, intervals that share the same starting point overwrite one 
>> another, until only the last one remains. Bug or feature? I don't 
>> really know.
>>
>>
>>> I want to clean up this code as I'm converting all users of the lustre
>>> interval-tree to use the upstream-linux interval tree code.  What should
>>> I do?
>> How does the upstream-linux interval tree compares to Lustre's?
> The interesting difference is that the lustre interval-tree refuses to
> store exact duplicates (same start, same end), while the Linux
> interval-tree will accept any new interval.
> I think this made some sense for the first user for interval-trees in
> lustre, which was LDLM extent locking, but some other users need to
> jump through hoops to handle duplicates correctly.
>
> For hsm_update_work(), it just tries to store the interval it was given
> and if that fails, it say "oh well, too bad".

Yes, there is a comment saying : "it can happen if ct sends 2 times the 
same progress".

 From "git blame", this seems to be coming from one of the earliest HSM 
commits, so I don't know if this was ever useful in practice or just an 
instance of defensive programming.

>> If their behaviours match, there should not be any issue (so far as the
>> current behaviour can be considered issue-free).
> Certainly I could preserve exactly the same behaviour, but I find it
> hard to write code that doesn't make any sense.
> If I *were* to keep exactly the same behaviour as current, I wouldn't use
> an interval tree, as (if I understand it correctly), the intervals
> aren't really relevant.  It just stores discrete "start+length"
> pairs and rejects duplicates.  I'd probably use an rhashtable for that.

Assuming duplicated extents, but otherwise non-overlapping, I agree.

Ideally, there would be a standard data structure that automatically 
merges overlapping/contiguous extents.
But I don't know any, and I don't think it is worth coding one from scratch.

>> Otherwise, I think it would be OK to just assume sending overlapping
>> extents is a programming error and the server does not need to protect
>> itself against it.
>> In terms of security, this isn't very good, but the problem already
>> exists, and copytools are supposedly trusted binaries run as root.
>> You could then remove test108 as it is itself a programming error,
>> test112 as well, and maybe others.
>>
>> Just to be sure, you could open a new issue on Jira, and let others rule
>> how much of a bug/feature the whole thing is.
> I guess the key question here is: who are those "others" ??
> Jira has a "Component/s" field, but it seems to be fixed at "None".
> How would I ensure that the Jira issue got to the right people?

There is a "label" field that can take "HSM" as a value.

Other than that, I agree with Ben that removing the feature would be the 
easiest way to fix all this.
I am just worried that someone somewhere uses it. For example, I can 
imagine a monitoring script that polls the coordinator's active request 
procfile to detect stalled HSM actions.

I'll check with our admins, but I don't think we use it at CEA. Maybe if 
Cray & DDN confirm that they don't know anyone using it, it will be 
enough to remove the code, like Ben suggests. Or maybe we axe the 
feature and wait to see if anyone complains.

 From the repos linked by Aur?lien, every copytool seems to mind the 
constraint of not sending overlapping extents (not even duplicates). I 
also have access to the sources of a different copytool that uses 
llapi_hsm_action_progress() as a heartbeat (offset=0, length=0).

Sorry about the earlier mistakes.

Have a good day,
Quentin

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200901/2ddc421a/attachment-0001.html>
