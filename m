From: DEGREMONT Aurelien <aurelien.degremont@cea.fr>
Date: Tue, 28 Oct 2008 16:42:09 +0100
Subject: [Lustre-devel] HSM comments
In-Reply-To: <4906488A.8030006@sun.com>
References: <4905F121.6000501@cea.fr> <4906488A.8030006@sun.com>
Message-ID: <490732D1.8060103@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathaniel Rutman a ?crit :
>> - HSM object removal should be async.
> Agreed, trigger should just be changelog unlink entry.
I'm not sure Lustre need the policy engine for managing the hsm removals.
It could triggers them automatically (like the copy-in mechanisms) when 
the file is deleted in Lustre.
Lustre could still live for a long moment without the PolicyEngine/Space 
Manager, we could imagine this for several hours.

>> - We should not link hsm object, even in v1. Could we manage hsm object
>> deletion like ost object deletion and manage orphan in the same way?
> Since the unlink event trigger is the changelog record, the policy 
> engine should simply not cancel the changelog record until the HSM 
> confirms the unlink.
For the moment, the PolicyEngine has no way to know the copytool has 
successfully deleted the file.
> How about we never clear the copyout_begin bit?  This is really for 
> the coordinator's benefit so it knows a copyout is in progress on that 
> file, but since we're having regular status updates to the coordinator 
> from the agent, there's no real need for that bit.  So instead we have 
> the bit "a_file_exists_in_hsm" aka hsm_exists.
> But we don't even need that - the MDT does not "request for HSM 
> removal", but instead the policy engine just watches the changelog for 
> unlink events.  Ah, now I see the problem with using the changelog - 
> this forces the policy engine to remember which files are on HSM, or 
> accept an error return code, but in any case may result in much undue 
> load on the HSM when deleting non-HSM'ed files.  So what do we do?  
> Ignore the changelog and have the MDT directly signal the coordinator 
> to do HSM unlinks?  That may be fine.  In that case, I think if we 
> leak files after we tell the coordinator to delete them it is not much 
> of a problem.
If we store in a llog the hsm objects that need to be removed and only 
delete them when copytool says it's fine, we will not leak files and if 
coordinator crashes, the copyin and removal requests will be resent 
automatically. The PolicyEngine will also re-send copy-out requests.
>> * HSM dirty bit.
>>
>> - should be updated with laziness.
>> - Is it possible to implement it like the lazy file size? That means,
>> manage the dirty bit, per OST object, and lazily update it on the MDT?
>
> Since file mtime/size is already updated this way, we can just use any 
> attr change as the dirty indicator; we don't need an actual bit per 
> object.  
Dirty means data were changed, not metadata.

>> - Also, if, instead of setting hsm_dirty bit to 1 when the file is
>> modified, can we do counter += 1 ? That way 'counter' could be use as
>> 'light' file revision. You compare two versions of this variable, is 
>> their differ, the file has been modified  (this is not
>> intended to check 'counter_c1 < counter_c2' but just 'counter_c1 !=
>> counter_c2', that way, you can have circular counters.) 
> I have no objection, although I don't see the benefit right now.  E.g. 
> how is that different than checking the mtime?
mtime could not be trust. mtime is a user exposed value that could be 
changed by user as he likes it.

$ touch -t 200101010000 foo
$ ls -l foo
-rw-r--r-- 1 degremont user 0 Jan  1  2001 foo

> The changelog data has file and parent FID, if you want more path than 
> this you can do a "lfs fid2path" to reconstruct the entire path name.  
> Note however this returns only the "first" path of a hardlinked file.  
> (Is this a limitation?  Do I need to fix fid2path?)
Ok this is fine, enough for our needs.

> #10 is "open reply", not "i/o reply", but a very nice diagram!  Can 
> you add these to the wiki?
>
Thanks. Done.


Aur?lien
