From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 22 May 2019 22:07:43 +0000
Subject: [lustre-devel] [PATCH v2 07/29] lustre: obd: collect all
 resource releasing for obj_type.
In-Reply-To: <alpine.LFD.2.21.1905221918410.26312@casper.infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
 <1558356671-29599-8-git-send-email-jsimmons@infradead.org>
 <alpine.LFD.2.21.1905221918410.26312@casper.infradead.org>
Message-ID: <4617C98C-31F0-4773-97F3-54B2BCAF1E7A@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On May 22, 2019, at 12:51, James Simmons <jsimmons@infradead.org> wrote:
> 
> 
>>> int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
>>> @@ -181,10 +163,17 @@ int class_register_type(struct obd_ops *dt_ops, 
>> struct md_ops *md_ops,
>>> 		return -EEXIST;
>>> 	}
>>> 
>>> -	rc = -ENOMEM;
>>> 	type = kzalloc(sizeof(*type), GFP_NOFS);
>>> 	if (!type)
>>> -		return rc;
>>> +		return -ENOMEM;
>>> +
>>> +	type->typ_kobj.kset = lustre_kset;
>>> +	rc = kobject_init_and_add(&type->typ_kobj, &class_ktype,
>>> +				  &lustre_kset->kobj, "%s", name);
>> 
>> I don't know that I would actually cause a problem, but I don't like
>> "add"ing and object (above) before fully initializing it (below).  So
>> I've kept the split from my version where kobject_init() happens early
>> and kobject_add() happens later.
>> I've included the other changes that you made.
>> 
>> Thanks,
>> NeilBrown
> 
> The reason I did it that way was to handle the server case down the road.
> So for the case when both client and server are on the same node, and yes
> people do such setups for testing this is important.
> 
> Consider the case we have both the lov and lod layer on a single node. 
> Both layers attempt to create "lov" obd_type. When the lov module loads 
> first then a complete obd_type is created. Once lod loads then it just 
> uses real lov obd_type and creates the needed symlinks.

We've had the "lov->lod" symlinks on servers since Lustre 2.4 or so (when
osd-zfs was first added).  We could just remove this compatibility, so
long as the test scripts were updated to always use "lod" on the server
and "lov" on the client (previously they shared the same "lov" code module
so the path was the same).  We don't need test script interop going back
further than that, so this should be OK.

Cheers, Andreas

> You end up with
> 
> ls -al /sys/fs/lustre/lov/
> total 0
> drwxr-xr-x  2 root root 0 May 22 14:27 .
> drwxr-xr-x 14 root root 0 May 22 14:27 ..
> lrwxrwxrwx  1 root root 0 May 22 14:27 lustre-MDT0000-mdtlov -> 
> ../lod/lustre-MDT0000-mdtlov
> lrwxrwxrwx  1 root root 0 May 22 14:27 lustre-MDT0002-mdtlov -> 
> ../lod/lustre-MDT0002-mdtlov
> 
> Plus the real lov obd devices.
> 
> Now if lod loads first then the lod module creates a "lov" obd_type
> using class_create_symlink() but is not fully initialized nor does
> it need to be. If the client lov module is present and it loads then
> it takes the "lov" obd_type create by the lod and finishes initializing
> it.
> 
> Looking at the final code and added in server case:
> 
>        type = class_search_type(name);
>        if (type) {
>                kobject_put(&type->typ_kobj);
> 		if (strcmp(name, LUSTRE_LOV_NAME) == 0 ||
>                    strcmp(name, LUSTRE_OSC_NAME) == 0)
>                        goto dir_exist;
> 		CDEBUG(D_IOCTL, "Type %s already registered\n", name);
>                return -EEXIST;
>        }
> 
>        type = kzalloc(sizeof(*type), GFP_NOFS);
>        if (!type)
>                return rc;
> 
>        type->typ_kobj.kset = lustre_kset;
>        kobject_init(&type->typ_kobj, &class_ktype);
> 
>        type->typ_dt_ops = dt_ops;  /* lov obd_type is never set to the 
> 				     * correct values if lod created it.
> 				     */
>        type->typ_md_ops = md_ops;
> 
>        rc = kobject_add(&type->typ_kobj, &lustre_kset->kobj, "%s", name);
>        if (rc)
>                goto failed;
> 
>        type->typ_debugfs_entry = debugfs_create_dir(type->typ_name,
>                                                     debugfs_lustre_root);
> dir_exit:
> 
> Now if this needed for the later module handling patches I guess we could
> do:
> 
> 	if (strcmp(name, LUSTRE_LOV_NAME) == 0 ||
>            strcmp(name, LUSTRE_OSC_NAME) == 0) {
> 		type->typ_dt_ops = dt_ops;
> 		type->typ_md_ops = md_ops;
> 		goto dir_exist;
> 	}
> 
> Is that the case?
> 
> 

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud
