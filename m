From: NeilBrown <neilb@suse.com>
Date: Fri, 17 Aug 2018 16:52:04 +1000
Subject: [lustre-devel] [PATCH 27/38] lustre: obd: resolve config log
 sysfs issues
In-Reply-To: <1534475441-15543-28-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
 <1534475441-15543-28-git-send-email-jsimmons@infradead.org>
Message-ID: <87va89qycr.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Aug 16 2018, James Simmons wrote:

> This resolves long standing issues with modifying sysfs settings
> on multiple nodes simultaneously by running a single command on
> the backend MGS server. Their are two ways to change the settings,
> LCFG_PARAM and LCFG_SET_PARAM. For the LCFG_PARAM case we create
> a new function class_modify_config() that grabs the attributes
> from the passed in kobject. We can use those attributes to
> modify the sysfs settings. If we can't find the attribute then
> send a uevent to let userland resolve the change. For the
> LCFG_SET_PARAM case we handle two class of settings. The function
> class_set_global() was modifiy to handle the top lustre sysfs
> files since they are not searchable with kset_find_obj.
> If we can find a kobject with kset_find_obj then we can send
> a uevent so userland change manage the change.
>
..

> +EXPORT_SYMBOL(class_modify_config);
> +

Unfortunately EXPORTed symbols are global - there is no namespace
control.
So it is good practice to choose names that are not overly generic.
I would be nice of all exported symbols from lustre started with
"lustre_".  Having "lnet_" as well is OK.  This isn't necessarily a
strict requirement.
But "class_" looks particularly bad.
I'm not saying you have to change this now, but it is something that we
really need to clean up.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180817/e05f3135/attachment.sig>
