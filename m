From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 8 Feb 2019 01:10:43 +0000
Subject: [lustre-devel] [PATCH 10/21] lustre: obdclass: use
 cl_object_for_each where appropriate
In-Reply-To: <154949781310.10620.8883358407999258821.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781310.10620.8883358407999258821.stgit@noble.brown>
Message-ID: <D0699499-2DE2-4430-94B6-81FE876793A2@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
> 
> There are various places which have a list_for_each_entry()
> where cl_object_for_each (or .._reverse) is more appropriate.
> 
> Several of these re-use the 'obj' function parameter as a loop
> iterator, which is a little confusing.
> 
> Change these to use cl_object_for_each{_reverse}, and where needed,
> introduce a new iterator variable 'o'.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> drivers/staging/lustre/lustre/lov/lov_page.c       |    3 -
> drivers/staging/lustre/lustre/obdclass/cl_lock.c   |    3 -
> drivers/staging/lustre/lustre/obdclass/cl_object.c |   82 +++++++++-----------
> drivers/staging/lustre/lustre/obdclass/cl_page.c   |   11 +--
> 4 files changed, 44 insertions(+), 55 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
> index f724b2d62df1..d71a680660da 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
> @@ -190,16 +190,15 @@ EXPORT_SYMBOL(cl_object_attr_unlock);
> int cl_object_attr_get(const struct lu_env *env, struct cl_object *obj,
> 		       struct cl_attr *attr)
> {
> -	struct lu_object_header *top;
> +	struct cl_object *o;
> 	int result;
> 
> 	assert_spin_locked(cl_object_attr_guard(obj));
> 
> -	top = obj->co_lu.lo_header;
> 	result = 0;

May as well move the "result = 0" initialization to the declaration for
all of these?  Another 5 fewer lines of code under your belt.

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
