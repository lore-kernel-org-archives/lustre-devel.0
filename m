From: NeilBrown <neilb@suse.com>
Date: Mon, 25 Jun 2018 11:54:38 +1000
Subject: [lustre-devel] [PATCH 0/8] staging: lustre: lnet: resolve time
 handling issues
In-Reply-To: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
References: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
Message-ID: <87fu1b8wbl.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jun 24 2018, James Simmons wrote:

> The migration of lustre to 64 bit time handling exposed various bugs
> which have lead to problems like routers no longer functioning with
> the upstream client. This is due to the complex handling of time by
> lustre with seconds time units and jiffies. Add in the fact that
> jiffies can vary from node to node and you can encounter corner
> case issues in a large node deployment. The solution to resolve this
> was to migrate as much as possible to time64_t when all you needed
> was seconds percision and ktime_t if better percision was required.
> With these changes it is reduced down to using jiffies only for
> schedule_timeout calls.
>
> James Simmons (8):
>   staging: lustre: lnet: simplify lnet_eq_wait_locked
>   staging: lustre: o2iblnd: use ktime_get_real_ns for ibn_incarnation
>   staging: lustre: ksocklnd: use ktime_get_real_ns for ksnn_incarnation
>   staging: lustre: ksocklnd: move remaining time handling to 64 bits
>   staging: lustre: lnet: use ktime_get_real_ns for cookie creation
>   staging: lustre: lnet: move ping and delay injection to time64_t
>   staging: lustre: ko2iblnd: remove remaining jiffy use
>   staging: lustre: selftest: fix time reporting

Lots of nice improvements in there - thanks.
I've applied all patches, though I made small changed to the first
as described separately.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180625/8baaf29f/attachment.sig>
