From: NeilBrown <neilb@suse.com>
Date: Wed, 16 May 2018 08:46:51 +1000
Subject: [lustre-devel] RFC: [PATCH 0/6] lustre: Improve locking in
 lu_object.s
In-Reply-To: <alpine.LFD.2.21.1805151622540.28403@casper.infradead.org>
References: <152599874625.19824.11344372150811845854.stgit@noble>
 <alpine.LFD.2.21.1805151622540.28403@casper.infradead.org>
Message-ID: <87po1w5yg4.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, May 15 2018, James Simmons wrote:

>> This is a followup to the patches that James recently posted
>> which addressed some locking issues in lu_object.c.
>> I said at the time that I thought the locking could be
>> improved further.  Here is the result of that thought.
>> 
>> The lu_keys_guard lock is now gone, replaced by a spin lock, an rwsem,
>> and some lockless code.
>> The lu_context_exit() function, which appears to have been a
>> performance problem at one point, is now completely lockless.
>> 
>> This is an RFC at this stage: I haven't included Greg on the email and
>> don't expect this to go upstream without some review - and maybe even
>> some testing.
>
> So I managed to mostly port it to the Intel branch. For testing on RHEL7
> I had to add:
>
> #ifndef smp_store_mb
> #define smp_store_mb(var, value)       set_mb(var, value)
> #endif
>
> #ifndef wake_up_var
> #define wake_up_var(atom)              wake_up_atomic_t(atom)
> #endif
>
> I'm still working out how to support wait_var_event on older kernels.

When wait_var_event() is used to wait for an atomic_t to be zero, like
I did, it is exactly wait_on_atomic_t().

> Another than that I have it ported so people will look at it. DDN was

Thanks for that!

> very interested in this but they wouldn't work with the upstream client 
> :-( Any suggestions to help speed up the process.

Cloning?
The looming monster in my mind is the tracing stuff - not that lustre
tracing is a monster, but that converting it to use upstream interfaces
will be a big task.  One of the difficulties I'll have there is
understanding the requirements.  I've collected various snippets of that
so it should be manageable, but I'm still putting it off :-)

Thanks,
NeilBrown

>
>>       staging: lustre: make key_set_version an atomic_t
>>       staging: lustre: use an rwsem instead of lu_key_initing_cnt.
>>       staging: lustre: remove locking from lu_context_exit()
>>       staging: lustre: use wait_event_var() in lu_context_key_degister()
>>       staging: lustre: remove lock from key register/degister
>>       staging: lustre: rename lu_keys_guard to lu_context_remembered_guard
>> 
>> 
>>  drivers/staging/lustre/lustre/include/lu_object.h  |    1 
>>  drivers/staging/lustre/lustre/obdclass/lu_object.c |  187 ++++++++------------
>>  2 files changed, 78 insertions(+), 110 deletions(-)
>> 
>> --
>> Signature
>> 
>> 
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180516/97e1bc47/attachment.sig>
