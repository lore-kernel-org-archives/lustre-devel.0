From: NeilBrown <neilb@suse.com>
Date: Mon, 24 Sep 2018 16:58:29 +1000
Subject: [lustre-devel] [PATCH 00/34] Beginning of multi-rail support
 for drivers/staging/lustre
In-Reply-To: <alpine.LFD.2.21.1809102357470.29662@casper.infradead.org>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <alpine.LFD.2.21.1809102357470.29662@casper.infradead.org>
Message-ID: <87in2v4c16.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Sep 11 2018, James Simmons wrote:

>> The following series implements the first patch in the
>> multi-rail series:
>> Commit: 8cbb8cd3e771 ("LU-7734 lnet: Multi-Rail local NI split")
>> 
>> I split that commit up into 40 individual commits which can be found
>> at
>>   https://github.com/neilbrown/lustre/commits/multirail
>> though you need to scroll down a bit, as that contains all the
>> multi-rail series.
>> 
>> I then ported most of these patches to my mainline tree.
>> Some that I haven't included are:
>> - lnet: Move lnet_msg_alloc/free down a bit.
>>     lnet_msg_alloc/free don't exist any more
>> - lnet: lib-types: change some tabs to spaces
>> - lnet - assorted whitespace changes.
>> - lnet: change ni_last_alive from time64_t to long
>> - lnet: add lnet_net_state
>>     net_state is never used.
>> - lnet: remove 'static' from lnet_get_net_config()
>> 
>> I've also made a couple of minor changes to individual patches not
>> strictly related to porting (the net_prio field is never used, so I
>> never added it - I should have made that a separate patch).
>>
>> This series compiles, but doesn't work.  I get a NULL pointer
>> reference, then an assertion failure.  If I fix those, it hangs.
>> The NULL pointer ref and the failing assertion are gone with
>> later patches, so I hope the other problems are too.
>> 
>
> I have tried it and did a compare to what landed in the OpenSFS branch.
> I saw the failures in my testing and foudn the mistake in the 7th patch.
>
>> Some of these patches have very poor descriptions, such as "I have no
>> idea what this does".  If someone would like to explain - or maybe say
>> "Oh, we really shouldn't have done that", I'd be very happy to
>> receive that, and update the description or patch accordingly.
>
> When I ran checkpatch it really dislikes:
>
> This is part of
>     8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
>        LU-7734 lnet: Multi-Rail local NI split
>
> I don't recommend landing the above in the commit messsage as for the
> reason that a person outside of lustre will not know where to look for
> that git commit. Instead I recommend replacing it with:
>
> ------------------------------------------------------------------
> Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
> Reviewed-on: http://review.whamcloud.com/18274
> Reviewed-by: Doug Oucharek <dougso@me.com>
> Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
> Signed-off-by: NeilBrown <neilb@suse.com>

Thanks for the suggestion.  I don't like that approach exactly because
it seems to be a lie.  The specific patch was not reviewed by those
people, and there is useful information which is not included there.
I have changed to patches to include:

    This is part of
        Commit: 8cbb8cd3e771 ("LU-7734 lnet: Multi-Rail local NI split")
    from upstream lustre, where it is marked:
        Signed-off-by: Amir Shehata <amir.shehata@intel.com>
        WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
        Reviewed-on: http://review.whamcloud.com/18274
        Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
        Reviewed-by: Olaf Weber <olaf@sgi.com>

checkpatch is not happy with the indented tags, but checkpatch is a
servant, not the master.

I've made that change, moved this series to my 'lustre' branch, merged
in the latest -rc, and pushed it all out.

Now the post the rest of the 'MR' series, and then start looking at
Dynamic Discovery (756abb9cf00b9^..1c45d9051764)

Thanks,
NeilBrown

>
> This gives the reviewer a URL link for both the JIRA ticket that usually
> contains details not in the commit message as well as the gerrit URL
> for the original patch. This way if a future bug is found a comparison
> can be done against the original patch. 
>  
> The policy for the Lustre project is to perserve authorship for patches
> when porting to other branches, upstream or LTS.
>
>> These will all appear in my lustre-testing branch, but won't migrate
>> to 'lustre' until I, at least, have enough other patches that I can
>> get a successful test run.
>> 
>> Review and comments always welcome.
>> 
>> Thanks,
>> NeilBrown
>> 
>> 
>> ---
>> 
>> Amir Shehata (1):
>>       Completely re-write lnet_parse_networks().
>> 
>> NeilBrown (33):
>>       struct lnet_ni - reformat comments.
>>       lnet: Create struct lnet_net
>>       lnet: struct lnet_ni: move ni_lnd to lnet_net
>>       lnet: embed lnd_tunables in lnet_ni
>>       lnet: begin separating "networks" from "network interfaces".
>>       lnet: store separate xmit/recv net-interface in each message.
>>       lnet: change lnet_peer to reference the net, rather than ni.
>>       lnet: add cpt to lnet_match_info.
>>       lnet: add list of cpts to lnet_net.
>>       lnet: add ni arg to lnet_cpt_of_nid()
>>       lnet: pass tun to lnet_startup_lndni, instead of full conf
>>       lnet: split lnet_startup_lndni
>>       lnet: reverse order of lnet_startup_lnd{net,ni}
>>       lnet: rename lnet_find_net_locked to lnet_find_rnet_locked
>>       lnet: extend zombie handling to nets and nis
>>       lnet: lnet_shutdown_lndnets - remove some cleanup code.
>>       lnet: move lnet_shutdown_lndnets down to after first use
>>       lnet: add ni_state
>>       lnet: simplify lnet_islocalnet()
>>       lnet: discard ni_cpt_list
>>       lnet: add net_ni_added
>>       lnet: don't take reference in lnet_XX2ni_locked()
>>       lnet: don't need lock to test ln_shutdown.
>>       lnet: don't take lock over lnet_net_unique()
>>       lnet: swap 'then' and 'else' branches in lnet_startup_lndnet
>>       lnet: only valid lnd_type when net_id is unique.
>>       lnet: make it possible to add a new interface to a network
>>       lnet: add checks to ensure network interface names are unique.
>>       lnet: track tunables in lnet_startup_lndnet()
>>       lnet: fix typo
>>       lnet: lnet_dyn_add_ni: fix ping_info count
>>       lnet: lnet_dyn_del_ni: fix ping_info count
>>       lnet: introduce use_tcp_bonding mod param
>> 
>> 
>>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |   31 -
>>  .../staging/lustre/include/linux/lnet/lib-types.h  |  142 ++-
>>  .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |   18 
>>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   10 
>>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    6 
>>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   12 
>>  .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |   74 +-
>>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   25 -
>>  drivers/staging/lustre/lnet/lnet/acceptor.c        |    8 
>>  drivers/staging/lustre/lnet/lnet/api-ni.c          |  939 +++++++++++++-------
>>  drivers/staging/lustre/lnet/lnet/config.c          |  688 +++++++++++----
>>  drivers/staging/lustre/lnet/lnet/lib-move.c        |  132 ++-
>>  drivers/staging/lustre/lnet/lnet/lib-ptl.c         |    6 
>>  drivers/staging/lustre/lnet/lnet/lo.c              |    2 
>>  drivers/staging/lustre/lnet/lnet/net_fault.c       |    3 
>>  drivers/staging/lustre/lnet/lnet/peer.c            |   31 -
>>  drivers/staging/lustre/lnet/lnet/router.c          |   51 +
>>  drivers/staging/lustre/lnet/lnet/router_proc.c     |   24 -
>>  drivers/staging/lustre/lnet/selftest/brw_test.c    |    2 
>>  drivers/staging/lustre/lnet/selftest/framework.c   |    3 
>>  drivers/staging/lustre/lnet/selftest/selftest.h    |    2 
>>  21 files changed, 1507 insertions(+), 702 deletions(-)
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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180924/ce3ab1c5/attachment.sig>
