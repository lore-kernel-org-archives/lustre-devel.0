From: NeilBrown <neilb@suse.com>
Date: Thu, 21 Jun 2018 12:54:58 +1000
Subject: [lustre-devel] [PATCH 00/24] lustre - more cleanups including
 module reduction.
In-Reply-To: <alpine.LFD.2.21.1806210239190.3886@casper.infradead.org>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <alpine.LFD.2.21.1806210239190.3886@casper.infradead.org>
Message-ID: <87r2l0df25.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 21 2018, James Simmons wrote:

>> Here are a bunch more cleanups that will appear in my lustre-testing
>> tree shortly.
>> 
>> The interesting stuff is some enhancements to kbuild to let us
>> build modules from multiple directories.
>> I've used that to clean up the build of ptlrpc+ldlm and to
>> merge libcfs and lnet into the one module - I've left the lnds
>> separate.
>
> That looks pretty good. It doesn't apply to the stable lustre tree but I
> did try it out on lustre-testing. The module building does seem to 
> function well. Only thing not clear is if do a
>
> make SUBDIRS=drivers/staging/lustre/lustre/lmv modules

Why would you do that?  SUBDIRS= is for building external modules.
What are you trying to achieve?

>
> do lmv.a and the other *.a files get relinked int lustre.ko ?

It isn't "lmv.a", it is ".../lustre/lmv/mod.a".

>  
>> I've haven't progressed further in lustre because I'm not sure which -
>> if any - modules are also used by the server.
>> I'd rather shared code was in a separate module to client-only.
>>
>> Which parts of lustre/lustre/* are also used by server?
>
> Basically all the client code is reused on the server except for llite.
> The reason is each server type MDS, MGS, or OSS is treated as a client
> to each other. So in affect the server code is a middle layer level on
> top of the client code.
>
>> After that, it is all fairly simple cleanups.
>> 
>> I plan to submit the kbuild stuff upstream next week.
>> 
>> Thanks,
>> NeilBrown
>> 
>> ---
>> 
>> NeilBrown (24):
>>       kbuild: detect directories in components of a module.
>>       kbuild: treat a directory listed in a composite object as foo/mod.a
>>       kbuild: support building of per-directory mod.a
>>       kbuild: disable KBUILD_MODNAME when building for mod.a
>>       kbuild: Add documentation for modobj-m
>>       lustre: build ldlm in the ldlm directory.
>>       lustre: merge libcfs module into lnet.
>
> This seems to work when I tried the lustre-testing tree. I did see 
> regression to related to this work in that tree.
>
>>       lustre: use truncate_inode_page in place of truncate_complete_page
>>       lustre: don't use spare bits in iattr.ia_valid
>>       lustre: remove lustre_patchless_compat.h
>>       lustre: discard current_n*groups macros.
>>       lustre: discard LTIME_S macro
>>       lustre: discard NO_QUOTA and QUOTA_OK
>>       lustre: discard ext2* bit operations
>>       lustre: centralize TIMES_SET_FLAGS
>>       lustre: remove redefinition of module_init().
>>       lustre: remove lustre_compat.h
>
> The first two patches of the above seem to break things. The first one was 
> pointed out so I avoid issues in my testing by changing the patch to just
> move truncate_inode_page() to lustre_mdc.h for now. The next patch does 
> break things.

Can you be specific about what things (or just one thing) that the next
patch breaks?  I haven't seen anything in my testing.
The only problem I've seen is that kvmalloc(GFP_NOFS) has been changed to
silently become kmalloc(GFP_NOFS) so there are memory allocation
problems.

>
>>       lustre/lnet: move tracefile locking from linux-tracefile.c to tracefile.c
>>       lustre: open code cfs_trace_max_debug_mb() into cfs_trace_set_debug_mb()
>>       lustre: move tcd locking across to tracefile.c
>>       lustre: move remainder of linux-tracefile.c to tracefile.c
>>       lustre: fold cfs_tracefile_*_arch into their only callers.
>>       lustre: renamed CFS_TCD_TYPE_MAX to CFS_TCD_TYPE_CNT
>>       lustre: discard TCD_MAX_TYPES
>
> I see breakage in this code as well.

Specifically??...

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180621/ed188aeb/attachment.sig>
