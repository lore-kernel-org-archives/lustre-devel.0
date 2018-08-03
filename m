From: NeilBrown <neilb@suse.com>
Date: Fri, 03 Aug 2018 11:58:12 +1000
Subject: [lustre-devel] [PATCH 11/31] lustre: lnet: Fix route hops print
In-Reply-To: <B2852889-F87E-4778-A930-917CD9EB69FF@whamcloud.com>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
 <1533003983-29311-12-git-send-email-jsimmons@infradead.org>
 <877elbrpxh.fsf@notabene.neil.brown.name>
 <3C0BF267DA2B2343B6A8D6013E6C43381AAE2A@LAX-EX-MB3.datadirect.datadirectnet.com>
 <87sh3zq634.fsf@notabene.neil.brown.name>
 <3C0BF267DA2B2343B6A8D6013E6C43381AAE41@LAX-EX-MB3.datadirect.datadirectnet.com>
 <878t5qrea2.fsf@notabene.neil.brown.name>
 <3C0BF267DA2B2343B6A8D6013E6C43381AAE75@LAX-EX-MB3.datadirect.datadirectnet.com>
 <87o9elplht.fsf@notabene.neil.brown.name>
 <B2852889-F87E-4778-A930-917CD9EB69FF@whamcloud.com>
Message-ID: <87a7q4p5xn.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Aug 03 2018, Andreas Dilger wrote:

> On Aug 1, 2018, at 20:09, NeilBrown <neilb@suse.com> wrote:
>> 
>> 
>> Once lustre and lnet are part of upstream Linux, what is the value of
>> keeping any of it in the master repo?
>> There would be be a need to keep it only to support old versions of
>> Linux, which will hopefully be less and less over time.
>> It might make sense to backport the upstream-linux code those particular
>> versions where it is needed, and do all development work in upstream
>> Linux, and just backport.
>
> I think the main reason is that none of the distros (which is what our
> customers use) will be running an upstream kernel for years after the
> client and later the server have landed upsteam.  Also, since the
> upstream kernel doesn't allow any kind of interoperability code,
> backporting the upstream client to the older kernels will essentially
> involve recreating all of the interop code that lives in the out-of-tree
> client and server today, since there are a thousand small API changes
> going into the kernel that affect the Lustre code.
>
> I suspect there will be at least a couple of years of overlap, until
> we start seeing the distro kernels including a version of Lustre, then
> we can deprecate to out-of-tree code and only keep it maintained for
> older kernels, as happens today for older Lustre releases.

Yes, there will be overlap.  It would be worth some effort to minimize
that if we can.
Once we have something credible in mainline, I'd like to encourage
vendors to take a back-port of that, at least for their next SP.
Hopefully we can then do development against mainline, and backport that
to whatever still needs to be supported by out-of-tree code.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180803/2f9475c5/attachment.sig>
