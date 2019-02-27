From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 27 Feb 2019 06:52:17 +0000
Subject: [lustre-devel] [PATCH 28/37] lustre: remove scope and source
 from class_incref and class_decref.
In-Reply-To: <155053494637.24125.716197573687357279.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494637.24125.716197573687357279.stgit@noble.brown>
Message-ID: <F37CEB24-A519-47AF-8C22-9FD627A7D7CC@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 18, 2019, at 17:09, NeilBrown <neilb@suse.com> wrote:
> 
> These arguments are no longer used, so we can discard them.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Well, they are no longer used, because you've removed the users.

> -struct obd_device *class_incref(struct obd_device *obd,
> -				const char *scope, const void *source)
> +struct obd_device *class_incref(struct obd_device *obd)
> {
> 	atomic_inc(&obd->obd_refcount);
> 	CDEBUG(D_INFO, "incref %s (%p) now %d\n", obd->obd_name, obd,
> @@ -528,12 +527,12 @@ struct obd_device *class_incref(struct obd_device *obd,
> }
> EXPORT_SYMBOL(class_incref);
> 
> -void class_decref(struct obd_device *obd, const char *scope, const void *source)
> +void class_decref(struct obd_device *obd)
> {
> 	int last;
> 
> -	CDEBUG(D_INFO, "Decref %s (%p) now %d - %s\n", obd->obd_name, obd,
> -	       atomic_read(&obd->obd_refcount), scope);
> +	CDEBUG(D_INFO, "Decref %s (%p) now %d\n", obd->obd_name, obd,
> +	       atomic_read(&obd->obd_refcount));

In particular, the scope (object type) is printed, which allows debugging the
generic incref/decref of these objects (similar to class_get_export() and
class_put_export() as mentioned in my other email).  If we at least can keep
the scope and source, then these generic refcount functions could still be used
for debugging.

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
