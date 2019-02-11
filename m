From: NeilBrown <neilb@suse.com>
Date: Mon, 11 Feb 2019 11:34:55 +1100
Subject: [lustre-devel] [PATCH 07/21] lustre: use list_first_entry() in
 lnet/klnds subdirectory.
In-Reply-To: <1F487FF7-BF02-4FD7-9026-51CBD34610FE@whamcloud.com>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781297.10620.13452862524706335326.stgit@noble.brown>
 <1F487FF7-BF02-4FD7-9026-51CBD34610FE@whamcloud.com>
Message-ID: <87sgwvgo28.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Feb 08 2019, Andreas Dilger wrote:

> On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
>> 
>> Convert
>>  list_entry(foo->next .....)
>> to
>>  list_first_entry(foo, ....)
>> 
>> in 'lnet/klnds
>> 
>> In several cases the call is combined with a list_empty() test and
>> list_first_entry_or_null() is used
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> 
>> @@ -1853,8 +1855,9 @@ static void kiblnd_destroy_pool_list(struct list_head *head)
>> {
>> 	struct kib_pool *pool;
>> 
>> -	while (!list_empty(head)) {
>> -		pool = list_entry(head->next, struct kib_pool, po_list);
>> +	while ((pool = list_first_entry_or_null(head,
>> +						struct kib_pool,
>> +						po_list)) != NULL) {
>> 		list_del(&pool->po_list);
>> 
>> 		LASSERT(pool->po_owner);
>> @@ -1869,7 +1872,7 @@ static void kiblnd_fail_poolset(struct kib_poolset *ps, struct list_head *zombie
>> 
>> 	spin_lock(&ps->ps_lock);
>> 	while (!list_empty(&ps->ps_pool_list)) {
>> -		struct kib_pool *po = list_entry(ps->ps_pool_list.next,
>> +		struct kib_pool *po = list_first_entry(&ps->ps_pool_list,
>> 					    struct kib_pool, po_list);
>> 		po->po_failed = 1;
>> 		list_del(&po->po_list);
>
> Why not use the same style as elsewhere in the code:
>
> 	while ((po = list_first_entry_or_null(&ps->ps_pool_list,
> 					      struct kib_pool,
> 					      po_list)) != NULL) {
>

No good reason - just fatigue probably.  I could automate most of
finding these, but automating the fixing of them didn't quite seem
worth the effort.  Maybe I should play with coccinelle...

I've merged:

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index df6b1b134709..d67a197e718d 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1867,13 +1867,15 @@ static void kiblnd_destroy_pool_list(struct list_head *head)
 
 static void kiblnd_fail_poolset(struct kib_poolset *ps, struct list_head *zombies)
 {
+	struct kib_pool *po;
+
 	if (!ps->ps_net) /* initialized? */
 		return;
 
 	spin_lock(&ps->ps_lock);
-	while (!list_empty(&ps->ps_pool_list)) {
-		struct kib_pool *po = list_first_entry(&ps->ps_pool_list,
-					    struct kib_pool, po_list);
+	while ((po = list_first_entry_or_null(&ps->ps_pool_list,
+					      struct kib_pool,
+					      po_list)) == NULL) {
 		po->po_failed = 1;
 		list_del(&po->po_list);
 		if (!po->po_allocated)

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190211/bc4f596b/attachment.sig>
