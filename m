From: Kit Westneat <kit.westneat@gmail.com>
Date: Tue, 18 Aug 2015 22:37:26 -0400
Subject: [lustre-devel] lctl conf_param vs set_param -P
In-Reply-To: <55D2229A.10506@llnl.gov>
References: <CAO3qy=GCE1fHkOk9Zn8HgdFpZy8FRb5S9y=6Wth8nHyReZWL9A@mail.gmail.com>
	<55D2229A.10506@llnl.gov>
Message-ID: <CA+F2jRe86ftnBo+Chkv=R5V7dW4cL4AgACD7aku5RrsmBbuLBw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>
> How much time?  In human terms, this should happen in very little time on
> a vm with llmount.sh created filesystem, should it not?


If it uses the same timeout as the other config locks, it will take between
5-10 seconds (5 + 0 to 5 random seconds). It's all done in the
mgc_requeue_thread function.

- Kit

On Mon, Aug 17, 2015 at 2:06 PM, Christopher J. Morrone <morrone2@llnl.gov>
wrote:

> On 08/17/2015 09:10 AM, Artem Blagodarenko wrote:
>
>> Hello,
>>
>>  >Can someone offer any insight on why the behavior appears to be
>>
> [cut]
>
>> After "set_param -P" applied, lock for "params" file is canceled that
>> initiate this log is acquired and "executed" by targets and clients.
>> This requires some time.
>>
>
> How much time?  In human terms, this should happen in very little time on
> a vm with llmount.sh created filesystem, should it not?
>
>  >Is it the intent of "set_param -P" that the specified changes only take
>> effect after components are restarted?  And if so, why?
>>
>> No, changes applied just after command executed, but some time
>> is required to cancel lock for params file.
>>
>
> Perhaps that is what is intended to happen, but is that working on master?
>
>  >How would a normal system administrator go about finding out what
>> settings are currently set permanently?
>>
>> Seme settings as "set_param" sets can be set using "set_param -P".
>> Finally all command that stored using "set_param" executed using "lctl
>> set_param" upcall on targets.
>>
>
> That was not the question.  I asked how a system administrator can get a
> listing of the parameters that have been permanently set.  It would appear
> that the only current method is to mount the underlying filesystem, locate
> the log file, and use llog_reader on it.  That is a software developer's
> interface, not an adequate interface for system administrators.
>
>  >And what about sites that use an MGS per filesystem, rather than a
>> single MGS for the entire site?  If one MGS says that the debug level
>> should be one value, and another says that the debug value should be
>> another value, is it entirely random which debug setting will appear on
>> any given node?
>>
>> Good example there we could use reserved field. Do you think this can
>> solve the issue? If so, we could extend "set_param -P" now.
>>
>
> I'm not so sure.  I have a feeling that really we need to consider and
> classify all of the configurables.
>
> Another use case:
>
> In WAN usage, two completely different organizations (two different
> universities, for instance) with separate security and administration
> policies may control different parts of the filesystem.  One organization
> runs the servers and some clients of its own.  A second organization runs
> clients that mount the first organization's servers over the internet.
>
> The second organization probably doesn't want the first organization to be
> setting _most_ of the settings that are available under lnet and lustre
> /proc trees.  But there are certainly some that are specific to the running
> of that filesystem that might be reasonable to pass to parts of the client
> that pertain to only that mount (keep in mind that the same client node may
> be mounting both local and remote lustre filesystems).
>
>  >We might want to just remove the conf_param deprecation message
>> altogether.  I think there is more than just a simple bug in the
>> "set_param -P" implementation.
>>
>> I believe we need move to "set_param -P". Yes, this require some scripts
>> to be changed, but fixing this now we get method with this benefits
>> instead of conf_param:
>>
>
> I would agree if there was no change other than than interface, but this
> also changes underlying semantics.  That concerns me since there seems to
> be little information about the design and not much in the way of vetting
> said design.
>
> Is there more design information out there to which you can point us?
>
> I belive we could solve found issues and move forward using "set_param -P"
>> I offered "set_param -P topic to last LAD, but unfortunately it was not
>> accepted. Lets' discuss this together. Moving conf_param discarding date
>> forward gives us some time for this.
>>
>
> This mailing list reaches a greater number of Lustre developers than LAD
> or LUG can ever reach (travel is expensive, email is cheap).  This list is
> very good place to work through design and implementation issues.
>
> Chris
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150818/b4186947/attachment.htm>
