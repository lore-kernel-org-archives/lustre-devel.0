From: NeilBrown <neilb@suse.com>
Date: Thu, 28 Feb 2019 11:39:19 +1100
Subject: [lustre-devel] [PATCH 28/37] lustre: remove scope and source
 from class_incref and class_decref.
In-Reply-To: <F37CEB24-A519-47AF-8C22-9FD627A7D7CC@whamcloud.com>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494637.24125.716197573687357279.stgit@noble.brown>
 <F37CEB24-A519-47AF-8C22-9FD627A7D7CC@whamcloud.com>
Message-ID: <875zt4u4p4.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Feb 27 2019, Andreas Dilger wrote:

> On Feb 18, 2019, at 17:09, NeilBrown <neilb@suse.com> wrote:
>> 
>> These arguments are no longer used, so we can discard them.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>
> Well, they are no longer used, because you've removed the users.

yes......
'source' isn't used since I removed lu_ref.
'scope' is used, as you say, in a CDEBUG() message.

I'll wait until there is more input on the lu_ref stuff before doing
anything more about these.  I won't push them for now.

Thanks,
NeilBrown


>
>> -struct obd_device *class_incref(struct obd_device *obd,
>> -				const char *scope, const void *source)
>> +struct obd_device *class_incref(struct obd_device *obd)
>> {
>> 	atomic_inc(&obd->obd_refcount);
>> 	CDEBUG(D_INFO, "incref %s (%p) now %d\n", obd->obd_name, obd,
>> @@ -528,12 +527,12 @@ struct obd_device *class_incref(struct obd_device *obd,
>> }
>> EXPORT_SYMBOL(class_incref);
>> 
>> -void class_decref(struct obd_device *obd, const char *scope, const void *source)
>> +void class_decref(struct obd_device *obd)
>> {
>> 	int last;
>> 
>> -	CDEBUG(D_INFO, "Decref %s (%p) now %d - %s\n", obd->obd_name, obd,
>> -	       atomic_read(&obd->obd_refcount), scope);
>> +	CDEBUG(D_INFO, "Decref %s (%p) now %d\n", obd->obd_name, obd,
>> +	       atomic_read(&obd->obd_refcount));
>
> In particular, the scope (object type) is printed, which allows debugging the
> generic incref/decref of these objects (similar to class_get_export() and
> class_put_export() as mentioned in my other email).  If we at least can keep
> the scope and source, then these generic refcount functions could still be used
> for debugging.
>
> Cheers, Andreas
> ---
> Andreas Dilger
> Principal Lustre Architect
> Whamcloud
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190228/cbc73a10/attachment-0001.sig>
