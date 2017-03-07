From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 7 Mar 2017 10:20:56 +0000
Subject: [lustre-devel] [PATCH 5/5] staging: lustre: osc_page.c: Use
 list_for_each_entry_safe
In-Reply-To: <alpine.LFD.2.20.1703061512070.30144@casper.infradead.org>
References: <1488733610-22289-1-git-send-email-singhalsimran0@gmail.com>
	<1488733610-22289-6-git-send-email-singhalsimran0@gmail.com>
	<alpine.LFD.2.20.1703061512070.30144@casper.infradead.org>
Message-ID: <64A47B25-17B2-4ED8-9066-6796E97768A0@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: simran singhal <singhalsimran0@gmail.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, Greg KH <gregkh@linuxfoundation.org>, lustre-devel <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, LKML <linux-kernel@vger.kernel.org>, "outreachy-kernel@googlegroups.com" <outreachy-kernel@googlegroups.com>

On Mar 6, 2017, at 08:20, James Simmons <jsimmons@infradead.org> wrote:
> 
>> 
>> Doubly linked lists which are  iterated  using list_empty
>> and list_entry macros have been replaced with list_for_each_entry_safe
>> macro.
>> This makes the iteration simpler and more readable.
>> 
>> This patch replaces the while loop containing list_empty and list_entry
>> with list_for_each_entry_safe.
>> 
>> This was done with Coccinelle.
>> 
>> @@
>> expression E1;
>> identifier I1, I2;
>> type T;
>> iterator name list_for_each_entry_safe;
>> @@
>> 
>> T *I1;
>> + T *tmp;
>> ...
>> - while (list_empty(&E1) == 0)
>> + list_for_each_entry_safe (I1, tmp, &E1, I2)
>> {
>> ...when != T *I1;
>> - I1 = list_entry(E1.next, T, I2);
>> ...
>> }
>> 
>> Signed-off-by: simran singhal <singhalsimran0@gmail.com>
> 
> NAK!!!!!!
> 
> This change was reverted in commit 
> 
> cd15dd6ef4ea11df87f717b8b1b83aaa738ec8af
> 
> Doing these while (list_empty(..)) to list_for_entry...
> are not simple changes and have broken things in lustre
> before. Unless you really understand the state machine of
> the lustre code I don't recommend these kinds of change
> for lustre.

It may be useful to add a comment to these cases where the while() loop cannot be
replaced by list_for_each_entry_safe() (with details of why that is the case) to
avoid such optimization attempts again in the future.

Cheers, Andreas

> 
>> ---
>> drivers/staging/lustre/lustre/osc/osc_page.c | 11 ++++-------
>> 1 file changed, 4 insertions(+), 7 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
>> index ed8a0dc..e8b974f 100644
>> --- a/drivers/staging/lustre/lustre/osc/osc_page.c
>> +++ b/drivers/staging/lustre/lustre/osc/osc_page.c
>> @@ -542,6 +542,7 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
>> 	struct cl_object *clobj = NULL;
>> 	struct cl_page **pvec;
>> 	struct osc_page *opg;
>> +	struct osc_page *tmp;
>> 	int maxscan = 0;
>> 	long count = 0;
>> 	int index = 0;
>> @@ -572,7 +573,7 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
>> 	if (force)
>> 		cli->cl_lru_reclaim++;
>> 	maxscan = min(target << 1, atomic_long_read(&cli->cl_lru_in_list));
>> -	while (!list_empty(&cli->cl_lru_list)) {
>> +	list_for_each_entry_safe(opg, tmp, &cli->cl_lru_list, ops_lru) {
>> 		struct cl_page *page;
>> 		bool will_free = false;
>> 
>> @@ -582,8 +583,6 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
>> 		if (--maxscan < 0)
>> 			break;
>> 
>> -		opg = list_entry(cli->cl_lru_list.next, struct osc_page,
>> -				 ops_lru);
>> 		page = opg->ops_cl.cpl_page;
>> 		if (lru_page_busy(cli, page)) {
>> 			list_move_tail(&opg->ops_lru, &cli->cl_lru_list);
>> @@ -1043,6 +1042,7 @@ unsigned long osc_cache_shrink_scan(struct shrinker *sk,
>> {
>> 	struct client_obd *stop_anchor = NULL;
>> 	struct client_obd *cli;
>> +	struct client_obd *tmp;
>> 	struct lu_env *env;
>> 	long shrank = 0;
>> 	u16 refcheck;
>> @@ -1059,10 +1059,7 @@ unsigned long osc_cache_shrink_scan(struct shrinker *sk,
>> 		return SHRINK_STOP;
>> 
>> 	spin_lock(&osc_shrink_lock);
>> -	while (!list_empty(&osc_shrink_list)) {
>> -		cli = list_entry(osc_shrink_list.next, struct client_obd,
>> -				 cl_shrink_list);
>> -
>> +	list_for_each_entry_safe(cli, tmp, &osc_shrink_list, cl_shrink_list) {
>> 		if (!stop_anchor)
>> 			stop_anchor = cli;
>> 		else if (cli == stop_anchor)
>> -- 
>> 2.7.4

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
