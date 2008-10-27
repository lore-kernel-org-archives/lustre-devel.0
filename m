From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Mon, 27 Oct 2008 16:02:34 -0700
Subject: [Lustre-devel] HSM comments
In-Reply-To: <4905F121.6000501@cea.fr>
References: <4905F121.6000501@cea.fr>
Message-ID: <4906488A.8030006@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Aurelien Degremont wrote:
> Hello all
>
> I'm sending this e-mail directly because for some unknown reasons, it 
> did not reach the mailing lists (either lustre-hsm-core-ext or 
> lustre-devel) last week.
>
> Find attached, 2 schemas presenting the various messages exchanged by 
> Lustre HSM components for copyin and copyout. Tell me if this is not 
> what you were expecting, I can fix them for tomorrow conf call. I 
> think I will add some other schemas also.
>
>
>
> Some points we did not discuss at last conf call:
>
> * File unlinks:
>
> - HSM object removal should be async.
Agreed, trigger should just be changelog unlink entry.
>
> - We should not link hsm object, even in v1. Could we manage hsm object
> deletion like ost object deletion and manage orphan in the same way?
Since the unlink event trigger is the changelog record, the policy 
engine should simply not cancel the changelog record until the HSM 
confirms the unlink.  
>
> - Presently, we could also leak hsm objects if the file is dirtied when
> being copied out. In this case, the file will be tagged dirtied, with no
> copyout_begin/complete flag. So the MDT will not request for HSM removal
> but their is something to delete there. Maybe the copyout mechanisms
> should be adapted.
How about we never clear the copyout_begin bit?  This is really for the 
coordinator's benefit so it knows a copyout is in progress on that file, 
but since we're having regular status updates to the coordinator from 
the agent, there's no real need for that bit.  So instead we have the 
bit "a_file_exists_in_hsm" aka hsm_exists.
But we don't even need that - the MDT does not "request for HSM 
removal", but instead the policy engine just watches the changelog for 
unlink events.  Ah, now I see the problem with using the changelog - 
this forces the policy engine to remember which files are on HSM, or 
accept an error return code, but in any case may result in much undue 
load on the HSM when deleting non-HSM'ed files.  So what do we do?  
Ignore the changelog and have the MDT directly signal the coordinator to 
do HSM unlinks?  That may be fine.  In that case, I think if we leak 
files after we tell the coordinator to delete them it is not much of a 
problem.

>
> * HSM dirty bit.
>
> - should be updated with laziness.
> - Is it possible to implement it like the lazy file size? That means,
> manage the dirty bit, per OST object, and lazily update it on the MDT?
Since file mtime/size is already updated this way, we can just use any 
attr change as the dirty indicator; we don't need an actual bit per 
object.  Any setattr should update MDT dirty bit, most setxattr should 
(not the hardlink/parent xattr however, maybe no XATTR_TRUSTED_PREFIX 
ones).  
>
> - Also, if, instead of setting hsm_dirty bit to 1 when the file is
> modified, can we do counter += 1 ? That way 'counter' could be use as
> 'light' file revision. You compare two versions of this variable, is 
> their differ, the file has been modified  (this is not
> intended to check 'counter_c1 < counter_c2' but just 'counter_c1 !=
> counter_c2', that way, you can have circular counters.) 
I have no objection, although I don't see the benefit right now.  E.g. 
how is that different than checking the mtime?
> - Could a policy test could be based on file path (not just filename and
> properties) ? This is a rule we presently used in our hsm tools. I do
> not see how have the filepath from the changelogs data ?
The changelog data has file and parent FID, if you want more path than 
this you can do a "lfs fid2path" to reconstruct the entire path name.  
Note however this returns only the "first" path of a hardlinked file.  
(Is this a limitation?  Do I need to fix fid2path?)
>
> - Could this flag be exposed to userspace via liblustreapi? Maybe this
> flag should be set on file creation also? Doing this, Policy Engines
> could use this flag to know easily if the file is udate to date in hsm
> or not.
Sounds good.
>
> * Policy Engine
>
> - It needs to:
> . read changelogs (mdt)
> . df (mdt/client)
> . lfs df (per ost) (mdt/client)
> . scan namespace (client)
> . lfs getstripe by fid (client)
> . stat file by fid (client)
>
> The only thing the engine will lack on a client is the changelogs. May
> be it could be a good idea to export the changelogs on some 'trusted
> clients' ?
I think it's sticky to impose certain priviledged clients, but maybe 
exporting to all clients isn't so bad.  Superuser privs on any client 
gives them access.  If anyone really hates this, we can add a tunable on 
the MDT to allow/disallow all client access.
> If not, we will be force to have MDT, client mount and policy engine on
> the same node or split the policy engine into two components (very bad
> idea to impose that on the engine). Potential overhead?
>
>
ok, client access to changelogs sounds like a reasonable requirement.  
[Note: this actually happens to solve a problem I haven't figured out 
yet, which is to limit access to only disk-committed changelog records.]
>
>
> ------------------------------------------------------------------------
>
>
#10 is "open reply", not "i/o reply", but a very nice diagram!  Can you 
add these to the wiki?
> ------------------------------------------------------------------------
>
