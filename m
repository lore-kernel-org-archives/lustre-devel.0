From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Sat, 4 Jul 2015 02:00:45 +0000
Subject: [lustre-devel] [PATCH] LU-3677 mdt: Set HSM dirty
 open-for-write file when evicted.
In-Reply-To: <D1BB1222.FB0C3%andreas.dilger@intel.com>
References: <20150702151848.GA26896@lusbld01.us.cray.com>
	<D1BB1222.FB0C3%andreas.dilger@intel.com>
Message-ID: <7010D276-D817-4A22-87FE-4997221EF5A1@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Jul 3, 2015, at 6:59 AM, Dilger, Andreas wrote:

> Hi Ben,
> for patches being submitted to the upstream kernel, they also need to be
> CC'd to the maintainers and lists of the "Linux Staging" project.  Since
> we're pretty new at taking outside patches for upstream, I'll let Oleg
> comment on whether he prefers to accumulate the patches himself and pass
> them upstream, or if you should CC the upstream maintainers/lists directly.

I think it's ok for people to send patches themselves.
> On 2015/07/02, 9:18 AM, "Ben Evans" <bevans@cray.com> wrote:
> 
>> LU-3677 mdt: Set HSM dirty open-for-write	file when	evicted.
> 
> For patches being pushed upstream, the "LU-3677" label should be removed
> from the subject line to a separate tag at the end after Reviewed-on:
> 
>    Intel-bug-ID: http://jira.hpdd.intel.com/browse/LU-3677

Additionally instead of the subsystem (mdt in this instance),
I typically expand that some more to something like:
staging/lustre/mdt (or jsut staging/lustre if there's no clear subsystem).

also note taht mdt is not really a subsystem in upstream kernel so typically
patches to it are skipped from being sent upstream or redone to only retain
relevant client-side bits.

>> Fix regression introduced by LU-1303 (5165cdd). Previously,
>> MDS_CLOSE_CLEANUP was used to detect file closing, due to eviction.
>> This flag is no more since 5165cdd.
> 
> The patch commit hash referenced here (5165cdd) is only relevant for
> the Lustre "master" branch, but do not make any sense for the kernel
> tree itself (where this patch is going), and the upstream maintainers
> don't like that.  Since the referenced patch was landed before the
> Lustre client code was pushed upstream, it probably doesn't make sense
> to reference this at all, and just update the commit comment like:
> 
>    Previously, MDS_CLOSE_CLEANUP was used to detect file closing
>    due to eviction.  This flag is not used anymore.
> 
>    Completely remove this symbol.
> 
>> Change-Id: I20e18103fe085672f499c956e831564e45bd5200
> 
> Upstream doesn't like the Change-Id, since it is confusing for other
> Gerrit instances if the patches are being imported.  This should be
> flagged if checkpatch.pl is run against the patch, which should be
> done for every patch going upstream, even if it was landed to master
> previously.
> 
>> Reviewed-on: http://review.whamcloud.com/7195
> 
> Reviewed-on: is OK.
> 
>> Tested-by: Hudson
>> Tested-by: Maloo <whamcloud.maloo@gmail.com>
> 
> Remove Tested-by: since those don't mean anything to upstream.
> 
>> Signed-off-by: Aurelien Degremont <aurelien.degremont@cea.fr>
>> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
>> Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
>> Reviewed-by: John L. Hammond <john.hammond@intel.com>
>> Reviewed-by: Fan Yong <fan.yong@intel.com>
>> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> 
> The Signed-off-by: and Reviewed-by: lines should stay.

Also your own Signed-off-by: line needs to appear here at the end.

> As you can see, the commit message and possibly the patch itself
> may be slightly different between master and upstream, but at least
> with the Reviewed-on: and Intel-bug-id: tags we can track the patches
> between the two.
> 
> There are similar labels needed when porting patches from upstream
> kernels into master.
> 
> Both of these cases are already described on the wiki page:
> https://wiki.hpdd.intel.com/display/PUB/Commit+Comments under the
> "Additional commit tags" section.
> 
> Cheers, Andreas
> 
>> ---
>> .../lustre/lustre/include/lustre/lustre_idl.h      |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
>> b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
>> index 4d72d6e..c039cbc 100644
>> --- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
>> +++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
>> @@ -2390,7 +2390,7 @@ enum mds_op_bias {
>> 	MDS_PERM_BYPASS		= 1 << 3,
>> 	MDS_SOM			= 1 << 4,
>> 	MDS_QUOTA_IGNORE	= 1 << 5,
>> -	MDS_CLOSE_CLEANUP	= 1 << 6,
>> +	/* Was MDS_CLOSE_CLEANUP	= (1 << 6), No more used */

I imagine you can also fix spelling/grammar as you go
(submitting symmetric patches to master).
This would likely be fixed in upstream by others creating further drift,
so probably a good idea to take it under control from the get go.

Thanks.

Bye,
    Oleg
