From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 3 Aug 2018 00:01:18 +0000
Subject: [lustre-devel] [PATCH 11/31] lustre: lnet: Fix route hops print
In-Reply-To: <87o9elplht.fsf@notabene.neil.brown.name>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
 <1533003983-29311-12-git-send-email-jsimmons@infradead.org>
 <877elbrpxh.fsf@notabene.neil.brown.name>
 <3C0BF267DA2B2343B6A8D6013E6C43381AAE2A@LAX-EX-MB3.datadirect.datadirectnet.com>
 <87sh3zq634.fsf@notabene.neil.brown.name>
 <3C0BF267DA2B2343B6A8D6013E6C43381AAE41@LAX-EX-MB3.datadirect.datadirectnet.com>
 <878t5qrea2.fsf@notabene.neil.brown.name>
 <3C0BF267DA2B2343B6A8D6013E6C43381AAE75@LAX-EX-MB3.datadirect.datadirectnet.com>
 <87o9elplht.fsf@notabene.neil.brown.name>
Message-ID: <B2852889-F87E-4778-A930-917CD9EB69FF@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Aug 1, 2018, at 20:09, NeilBrown <neilb@suse.com> wrote:
> 
> 
> Once lustre and lnet are part of upstream Linux, what is the value of
> keeping any of it in the master repo?
> There would be be a need to keep it only to support old versions of
> Linux, which will hopefully be less and less over time.
> It might make sense to backport the upstream-linux code those particular
> versions where it is needed, and do all development work in upstream
> Linux, and just backport.

I think the main reason is that none of the distros (which is what our
customers use) will be running an upstream kernel for years after the
client and later the server have landed upsteam.  Also, since the
upstream kernel doesn't allow any kind of interoperability code,
backporting the upstream client to the older kernels will essentially
involve recreating all of the interop code that lives in the out-of-tree
client and server today, since there are a thousand small API changes
going into the kernel that affect the Lustre code.

I suspect there will be at least a couple of years of overlap, until
we start seeing the distro kernels including a version of Lustre, then
we can deprecate to out-of-tree code and only keep it maintained for
older kernels, as happens today for older Lustre releases.

Cheers, Andreas

> On Wed, Aug 01 2018, Amir Shehata wrote:
> 
>> Hi Neil,
>> 
>> Thanks for the explanation.
>> 
>> Speaking specifically for LNet, I'm not sure it's feasible to remove the code from master repo. As I mentioned LNet is a common piece between both the client and server sides. Both of them rely on it. And I believe LNet is also used by DVS, which is a cray developed layer, I'm not very familiar with it. So just deleting it from the master repo I don't think would work.
>> 
>> Over the past years, there has been discussions about making it a standalone module that can be pulled in as a dependency. This approach makes a bit more sense to me.
>> 
>> What are your thoughts on that?
>> 
>> thanks
>> amir
>> ________________________________________
>> From: NeilBrown [neilb at suse.com]
>> Sent: Tuesday, July 31, 2018 7:50 PM
>> To: Amir Shehata; James Simmons; Andreas Dilger; Oleg Drokin
>> Cc: Lustre Development List
>> Subject: RE: [PATCH 11/31] lustre: lnet: Fix route hops print
>> 
>> Hi Amir,
>> I think I'm happy to let this slide.  I don't like magic numbers, but
>> this one isn't important enough to justify the problems that might be
>> caused by changing it.
>> 
>> To answer your broader question:
>>> The code bases are already diverging significantly between the
>>> upstream client and the master repo, which makes porting features from
>>> master to upstream a difficult task. Do we have a strategy on how to
>>> deal with this?
>> 
>> The long term strategy is just to get the work done so that the client
>> code - and then all the kernel code - can be deleted from the master
>> repo and can live solely in Linux.  I know that is still quite a way
>> away.
>> 
>> Shorter term, there are no magic answers.  Yes it is difficult but it
>> is far from impossible.  My plan has always been to get the code that
>> is already in drivers/staging into a reasonable state, then start
>> forward-porting patches from master.  If other people do some of the
>> forward-porting, that just makes me happier.
>> If you think there is too much churn in my lustre tree, then just
>> provide patches based on some old commit - I'm quite happy to receive
>> patches based on fairly old code, and to do the final steps of
>> forward-porting/conflict resolution myself (I have lots of practice).
>> 
>> NeilBrown
>> 
>> 
>> On Wed, Aug 01 2018, Amir Shehata wrote:
>> 
>>> Hi Neil,
>>> 
>>> This issue actually came up because of LU-6060, which changed the behavior for LLNL. The behavior then was changed again by LU-6851: https://jira.whamcloud.com/browse/LU-6851 (if you'd like more background)
>>> 
>>> As a result of LU-6851 we were printing the unsigned value of -1. That's why we ended up printing it as -1, which is more bearable than just printing a large unsigned value.
>>> 
>>> I'm not disagreeing that it'll be better to print a clearer value, "unknown" does sound like it relays the correct meaning. However, I've sometimes run into issues where changing user facing interfaces caused  problems to user scripts. Would this be the case here, I'm not 100% sure. We can always make the change and then wait for tickets to be opened.
>>> 
>>> However, I think of more concern to me is that if we make changes like this to the upstreamed client, it's probably a good idea to also make them to the whamcloud repo as well, so as not to diverge the client and server (LNet is common between them). This particular case, might not be very significant, but other issues might come up that are of more significance.
>>> 
>>> The code bases are already diverging significantly between the upstream client and the master repo, which makes porting features from master to upstream a difficult task. Do we have a strategy on how to deal with this?
>>> 
>>> thanks
>>> amir
>>> ________________________________________
>>> From: NeilBrown [neilb at suse.com]
>>> Sent: Tuesday, July 31, 2018 5:32 PM
>>> To: Amir Shehata; James Simmons; Andreas Dilger; Oleg Drokin
>>> Cc: Lustre Development List
>>> Subject: RE: [PATCH 11/31] lustre: lnet: Fix route hops print
>>> 
>>> Hi Amir,
>>> thanks for the background.
>>> 
>>> I had to chuckle at "0 being the highest", though I know that this
>>> distortion is not something specific to lustre.
>>> 
>>> Your description seems to suggest that "-1" means "unknown" with an
>>> implication that the number of hops might be high, and best not to take
>>> the risk.
>>> 
>>> Your point about compatability with scripts has some validity, though
>>> it is annoying to have to support such ugly interfaces indefinitely.
>>> Are there really likely to be dependencies? lustre has only been
>>> printing -1 since Feb last year when this patch went upstream.
>>> That was presumably an abi change as it would have printed MAXINT-1
>>> previously.  Did that cause any problems?
>>> 
>>> Thanks,
>>> NeilBrown
>>> 
>>> 
>>> On Tue, Jul 31 2018, Amir Shehata wrote:
>>> 
>>>> The way hop and priority work in the code is they serve to select the preferred route. If you have multiple gateways leading to the same destination, you select the one with the highest priority (0 being the highest), followed by selecting the one with the least number of hops. If you don't specify hops, then it's actually treated as the least favoured if there are other routes with hops specified. If hops and priority are equivalent between routes, then you select the one with the most credits available, if that's equivalent you select in round robin.
>>>> 
>>>> In that sense hops and priority really serve the same purpose, select the preferred route. If it was up to me I would keep only one of them, but for historical reasons, both are kept.
>>>> 
>>>> Therefore, I'm not sure if "unlimited" actually relays the correct interpretation of that value. Note there could be user scripts out there that are already parsing the output. So by changing the -1 you could break the scripts. Also changing that will create an inconsistency between the server and client.
>>>> 
>>>> thanks
>>>> amir
>>>> ________________________________________
>>>> From: NeilBrown [neilb at suse.com]
>>>> Sent: Tuesday, July 31, 2018 3:38 PM
>>>> To: James Simmons; Andreas Dilger; Oleg Drokin
>>>> Cc: Lustre Development List; Amir Shehata; James Simmons
>>>> Subject: Re: [PATCH 11/31] lustre: lnet: Fix route hops print
>>>> 
>>>> On Mon, Jul 30 2018, James Simmons wrote:
>>>> 
>>>>> From: Amir Shehata <ashehata@whamcloud.com>
>>>>> 
>>>>> The default number of hops for  a route is -1. This is
>>>>> currently being printed as %u. Change that to %d to
>>>>> make it print out properly.
>>>> 
>>>> -1 hops???  I wish I could hop -1 times - it would be a good party
>>>> trick!!
>>>> 
>>>> What does -1 mean?  Unlimited (just a guess).  If so, could we print
>>>> "unlimited"??
>>>> 
>>>> I'm fine with having magic numbers in the code, but I don't like them to
>>>> leak out.
>>>> 
>>>> NeilBrown
>>>> 
>>>>> 
>>>>> Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
>>>>> WC-id: https://jira.whamcloud.com/browse/LU-9078
>>>>> Reviewed-on: https://review.whamcloud.com/25250
>>>>> Reviewed-by: Olaf Weber <olaf@sgi.com>
>>>>> Reviewed-by: Doug Oucharek <dougso@me.com>
>>>>> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
>>>>> Reviewed-by: Oleg Drokin <green@whamcloud.com>
>>>>> Signed-off-by: James Simmons <jsimmons@infradead.org>
>>>>> ---
>>>>> drivers/staging/lustre/lnet/lnet/router_proc.c | 2 +-
>>>>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>>>> 
>>>>> diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
>>>>> index 8856798..aa98ce5 100644
>>>>> --- a/drivers/staging/lustre/lnet/lnet/router_proc.c
>>>>> +++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
>>>>> @@ -218,7 +218,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
>>>>>                      int alive = lnet_is_route_alive(route);
>>>>> 
>>>>>                      s += snprintf(s, tmpstr + tmpsiz - s,
>>>>> -                                   "%-8s %4u %8u %7s %s\n",
>>>>> +                                   "%-8s %4d %8u %7s %s\n",
>>>>>                                    libcfs_net2str(net), hops,
>>>>>                                    priority,
>>>>>                                    alive ? "up" : "down",
>>>>> --
>>>>> 1.8.3.1

Cheers, Andreas
---
Andreas Dilger
CTO Whamcloud




-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 235 bytes
Desc: Message signed with OpenPGP
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180803/acf7cb6c/attachment.sig>
