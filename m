From: NeilBrown <neilb@suse.com>
Date: Tue, 26 Jun 2018 10:34:57 +1000
Subject: [lustre-devel] [PATCH v3 23/26] staging: lustre: ptlrpc: use
 current CPU instead of hardcoded 0
In-Reply-To: <alpine.LFD.2.21.1806252350310.31196@casper.infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
 <1529875250-11531-24-git-send-email-jsimmons@infradead.org>
 <87a7rj8ub9.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806252350310.31196@casper.infradead.org>
Message-ID: <87vaa675ce.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jun 25 2018, James Simmons wrote:

>> > From: Dmitry Eremin <dmitry.eremin@intel.com>
>> >
>> > fix crash if CPU 0 disabled.
>> >
>> > Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
>> > WC-bug-id: https://jira.whamcloud.com/browse/LU-8710
>> > Reviewed-on: https://review.whamcloud.com/23305
>> > Reviewed-by: Doug Oucharek <dougso@me.com>
>> > Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
>> > Signed-off-by: James Simmons <jsimmons@infradead.org>
>> > ---
>> >  drivers/staging/lustre/lustre/ptlrpc/service.c | 11 ++++++-----
>> >  1 file changed, 6 insertions(+), 5 deletions(-)
>> >
>> > diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
>> > index 3fd8c74..8e74a45 100644
>> > --- a/drivers/staging/lustre/lustre/ptlrpc/service.c
>> > +++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
>> > @@ -421,7 +421,7 @@ static void ptlrpc_at_timer(struct timer_list *t)
>> >  		 * there are.
>> >  		 */
>> >  		/* weight is # of HTs */
>> > -		if (cpumask_weight(topology_sibling_cpumask(0)) > 1) {
>> > +		if (cpumask_weight(topology_sibling_cpumask(smp_processor_id())) > 1) {
>> 
>> This pops a warning for me:
>> [ 1877.516799] BUG: using smp_processor_id() in preemptible [00000000] code: mount.lustre/14077
>> 
>> I'll change it to disable preemption, both here and below.
>
> For .config I have:
>
> # CONFIG_PREEMPT_NONE is not set
> CONFIG_PREEMPT_VOLUNTARY=y
> # CONFIG_PREEMPT is not set
>
> What does yours look like? Strange no one has ever reported an error 
> before. Thanks for finding this!!!

I have
CONFIG_PREEMPT_RCU=y
CONFIG_PREEMPT_NOTIFIERS=y
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_DEBUG_PREEMPT=y
# CONFIG_PREEMPTIRQ_EVENTS is not set
# CONFIG_PREEMPT_TRACER is not set

CONFIG_PREEMPT=y helps find bugs - not just these but also some races.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180626/bb20ad16/attachment.sig>
