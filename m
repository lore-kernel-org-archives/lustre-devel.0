From: NeilBrown <neilb@suse.com>
Date: Wed, 14 Mar 2018 08:56:45 +1100
Subject: [lustre-devel] [PATCH] staging: lustre: use module_name() macro
 for debug printf
In-Reply-To: <20180313130425.3975930-1-arnd@arndb.de>
References: <20180313130425.3975930-1-arnd@arndb.de>
Message-ID: <87in9zd4gy.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Aliaksei Karaliou <akaraliou.dev@gmail.com>, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Tue, Mar 13 2018, Arnd Bergmann wrote:

> We now allow lustre to be built when CONFIG_MODULES is disabled,
> but that causes a build failure:
>
> In file included from drivers/staging/lustre/include/linux/libcfs/libcfs.h:42,
>                  from drivers/staging/lustre/lustre/obdclass/lu_object.c:44:
> drivers/staging/lustre/lustre/obdclass/lu_object.c: In function 'lu_context_key_degister':
> drivers/staging/lustre/lustre/obdclass/lu_object.c:1410:51: error: dereferencing pointer to incomplete type 'struct module'
>
> This particular case can be avoided by using the module_name()
> macro that was designed exactly to handle printing the name of
> a module in all configurations.

Learn something new every day :-)

Reviewed-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown

>
> Cc: NeilBrown <neilb@suse.com>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/staging/lustre/lustre/obdclass/lu_object.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> index 8ddf23b82a2c..3ae16e8501c2 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> @@ -1407,7 +1407,7 @@ void lu_context_key_degister(struct lu_context_key *key)
>  	while (atomic_read(&key->lct_used) > 1) {
>  		spin_unlock(&lu_keys_guard);
>  		CDEBUG(D_INFO, "%s: \"%s\" %p, %d\n",
> -		       __func__, key->lct_owner ? key->lct_owner->name : "",
> +		       __func__, module_name(key->lct_owner),
>  		       key, atomic_read(&key->lct_used));
>  		schedule();
>  		spin_lock(&lu_keys_guard);
> @@ -1547,7 +1547,7 @@ void lu_context_key_quiesce(struct lu_context_key *key)
>  			spin_unlock(&lu_keys_guard);
>  			CDEBUG(D_INFO, "%s: \"%s\" %p, %d (%d)\n",
>  			       __func__,
> -			       key->lct_owner ? key->lct_owner->name : "",
> +			       module_name(key->lct_owner),
>  			       key, atomic_read(&key->lct_used),
>  			atomic_read(&lu_key_initing_cnt));
>  			schedule();
> -- 
> 2.9.0
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180314/b129d153/attachment.sig>
