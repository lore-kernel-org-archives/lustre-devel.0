From: Patrick Farrell <paf@cray.com>
Date: Tue, 22 May 2018 23:01:07 +0000
Subject: [lustre-devel] Regression with delayed_work in sec_gc
In-Reply-To: <874lizz6lq.fsf@notabene.neil.brown.name>
References: <alpine.LFD.2.21.1805151609430.28403@casper.infradead.org>
 <87sh6s5zjy.fsf@notabene.neil.brown.name>
 <E4BBDF07-0165-4306-9846-382D2D0A9C3D@ddn.com>
 <87r2m5ztsr.fsf@notabene.neil.brown.name>
 <79108C6E-9FC1-44E8-9B3A-AB7FE3A4C5DE@intel.com>,
 <874lizz6lq.fsf@notabene.neil.brown.name>
Message-ID: <BN3PR1101MB120293F9E3AA076CA0B339CECB940@BN3PR1101MB1202.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Neil, Andreas,

A few thoughts I?d be curious to see one or both of you speak to.

1. Supporting multiple kernels has historically been important because Lustre is integrated in to various different HPC setups and they value being able to move distribution versions and Lustre versions independently.  Cray, for example, is less interested in upstream than we might be in part BECAUSE we use SLES as the base for our HPC distro and have a need for very recent versions of Lustre.  Long term, how would we square the desire to use enterprise distros and new versions of Lustre?

2. The Lustre server code remains out of tree.  Until it?s in, it?s difficult for me to see development getting fully invested in upstream, since a key component - which is normally distributed as a unified whole, at least for source - is out of tree.  Thoughts on that?

3. This is perhaps not so much a question for either of you, but it?s one I?m curious about anyway.  What?s the route out of staging and what happens after?  Provided we keep cleanliness high and duplication of existing functionality minimal, will the community accept a ton of feature drops?  If we have to dribble in existing features slowly, people will remain reluctant to use the upstream version for as long as that goes on.

Perhaps Greg?s suggestion of going temporarily out of tree, cleaning up, and coming back with everything would be better?  That?s radical, I know, but...

- Patrick
________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
Sent: Tuesday, May 22, 2018 5:08 PM
To: Dilger, Andreas
Cc: Lustre Developement
Subject: Re: [lustre-devel] Regression with delayed_work in sec_gc

On Tue, May 22 2018, Dilger, Andreas wrote:

> On May 20, 2018, at 19:22, NeilBrown <neilb@suse.com> wrote:
>>
>> On Thu, May 17 2018, Sebastien Buisson wrote:
>>
>>>> Le 16 mai 2018 ? 00:22, NeilBrown <neilb@suse.com> a ?crit :
>>>>
>>>> On Tue, May 15 2018, James Simmons wrote:
>>>>
>>>>> Dmitry has backported your upstream commit
>>>>>
>>>>> be3c64da248b1ada2bbcfc3855f07536d8087acb ( ptlrpc: use workqueue for
>>>>> pinger)
>>>>>
>>>>> and Sebastien tried out the change which can be seen at
>>>>> https://review.whamcloud.com/#/c/31724. Sebastien is having issues with
>>>>> unloading osc, mdc, ost or mdt kernel modules. He writes that he activated
>>>>> Kerberos for my file system, did some IOs, then tried to unmount the
>>>>> client and the  targets. Unfortunately, on some occasions, while
>>>>> unmounting, the mdc module for instance has extra references (as shown by
>>>>> 'lsmod'), and cannot be unloaded. After a while, the extra references are
>>>>> dropped, and the  module can be unloaded. It also happens on occasions on
>>>>> server side, for the mdt or ost modules. I tried destroy_workqueue but
>>>>> that made things worst :-( Do you know what is going on?
>>>>
>>>> My guess is that ptlrpc_pinger_main() is looping, so
>>>> cancel_delayed_work_sync() is waiting an unusually long time for it.
>>>> This patch might fix the problem - it certainly makes the usage
>>>> of "this_ping" closer to the original code.
>>>>
>>>> Thanks,
>>>> NeilBrown
>>>>
>>>> diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
>>>> index 89eef8ec7df4..131b201541e8 100644
>>>> --- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
>>>> +++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
>>>> @@ -222,12 +222,13 @@ static DECLARE_DELAYED_WORK(ping_work, ptlrpc_pinger_main);
>>>>
>>>> static void ptlrpc_pinger_main(struct work_struct *ws)
>>>> {
>>>> -  unsigned long this_ping = jiffies;
>>>>     long time_to_next_wake;
>>>>     struct timeout_item *item;
>>>>     struct obd_import *imp;
>>>>
>>>>     do {
>>>> +          unsigned long this_ping = jiffies;
>>>> +
>>>>             mutex_lock(&pinger_mutex);
>>>>             list_for_each_entry(item, &timeout_list, ti_chain) {
>>>>                     item->ti_cb(item, item->ti_cb_data);
>>>
>>> Still same problem when testing "ptlrpc: use delayed_work in sec_gc" with patch "ptlrpc: use workqueue for pinger" and modification as suggested above. Kernel module ptlrpc_gss holds extra references, and cannot be unloaded.
>>>
>>> However, patch "ptlrpc: use workqueue for pinger" alone does not have the issue.
>>
>> Thanks for the clear explanation - helps a lot.  I see the problem - I think.
>>
>> When (e.g.) ctx_release_kr() is called as part of shutting down a security
>> context, it calls sptlrpc_gc_add_ctx() which signals the gc-thread to
>> re-run.
>> None of this code is in mainline (why isn't the GSS code in
>> mainline????)
>
> We are in the un-enviable position that we can't really land new Lustre
> features into the staging tree, but we can't get out of the staging tree
> without a lot of code changes.

I don't see this as a problem.  "code changes" and "new fetures" are
largely independent.  There certainly are grey areas, but then the rules
aren't inflexible.  If something feature-like is needed to achieve clean
code, I doubt anyone would object.

I also don't see how your observation explains the lack of gss code in
the staging tree.
I've found
Commit: b78560200d41 ("staging: lustre: ptlrpc: gss: delete unused code")
and am wondering why all the sec*.c code didn't disappear at the same
time.
I guess I'll put 'gss' on my list of things to "fix".

>
> It isn't clear to me why Lustre has such a high bar to cross to get out
> of staging, compared to other filesystems that were added in the past.

I don't see the bar as being all that high, but then I haven't seen any
battles that you might have already fought that seem to show a high bar.

In my mind there are two issues: code quality and maintainership
quality.
Lustre was (is) out-of-tree for a long time with little or no apparent
interesting in going mainline, so that results in a fairly low score for
maintainership.  Maintainership means working in and with the community.
While lustre was out-of-tree it developed lot of useful functionality
which was also independently (and differently) developed in mainline
linux.  This makes the code look worse than it is - because it seems to
be unnecessarily different.
Lustre also previously supported multiple kernels, so it had (has)
abstraction layers which are now just technical debt.
So it is coming from a fairly low starting point.  I think it is
reasonable for the Linux community to want to be able to see lustre clearly
rising above all that past, clearing the debt with interest (you might
say).
This is all quite achievable - it just takes time and effort (and skill
- I think we have that among us).
I've been given time by SUSE to work on this and I can clear a lot of
the technical debt.  The more we work together, the easier it will be.
James has been a great help and I think momentum is building.
The community side needs key people to stop thinking of "us vs them" and
start thinking of lustre as part of the Linux community.  Don't talk
about "upstream has accepted this" or "upstream have rejected that", but
get on board with "we've landed this upstream" or "we are working to
find the best solution for that".
It might help to start using the mailing list more, rather than
depending on whamcloud.  The work-flow is different, but is quite
workable, and shows a willingness to be part of the broader community.


> It's not like Lustre is going away any time soon, unlike some no-name
> ethernet card driver, and we could still continue to improve the Lustre
> code if we could move out of staging, but it could be done in a more
> sustainable manner where we also land feature patches and try to bring
> the kernel and master code closer together over time.

I think we should do one thing at a time.
Firstly, focus on getting out of staging.  Freeze the current feature
set and get all existing features into an acceptable form.
Secondly, add all the fixes and features from master-code into Linux.
If you also want to move fixes from Linux into master, that's up to you.

Thanks,
NeilBrown
