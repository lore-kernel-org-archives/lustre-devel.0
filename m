From: Mikhail Pershin <mike.tappro@gmail.com>
Date: Fri, 14 Jan 2011 22:14:37 +0300
Subject: [Lustre-devel] Setting attributes at open.
In-Reply-To: <alpine.LFD.2.00.1101141827450.5594@casper.infradead.org>
References: <alpine.LFD.2.00.1101141827450.5594@casper.infradead.org>
Message-ID: <op.vpbbqmjpcckvm4@garden>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

just quick idea. The mdd_open_sanity_check() is called under
mdd_write_lock():
>         mdd_write_lock(env, mdd_obj, MOR_TGT_CHILD);
> -        rc = mdd_open_sanity_check(env, mdd_obj, flags);
> +        rc = mdd_open_sanity_check(env, obj, ma, flags);

You've added mdd_attr_set(env, o, ma); in it causing deadlock it seems,
because it calls mdd_attr_set_internal_locked() which is taking the same
lock.


On Fri, 14 Jan 2011 21:48:24 +0300, James Simmons <jsimmons@infradead.org>
wrote:

>
> Hello!
>
> 	Lustre 1.8 had issues with mode setting which is in bug 24226 fix
> was fixed. Testing Lustre 2.X revealed the same problem. The correct
> behavior is when a file size is altered the SUID/SGID go away. This  
> occurs
> at the beginning of the file size change. Currently lustre does a
> attribute change after a file is closed which is incorrect. Another
> problem also surfaced. It seems there is a race possible where a client
> writes to a file, then client and mdt both die and the open transaction  
> is
> not committed, so the datain the file is updated, but suid is not  
> removed.
> 	So I made a attempt to alter the file attributes at the open time
> when the intent is to alter the file size. Just like the other
> md_object_operations I started to pass in the struct md_attr *ma for
> the opens to operate on it. mdd_open_sanity_check does detect the the
> condition I'm interested in but when I call mdd_attr_set the results hang
> the MDS. What is missing?
>
> diff --git a/lustre/cmm/cmm_object.c b/lustre/cmm/cmm_object.c
> index 5fdcf9a..c892661 100644
> --- a/lustre/cmm/cmm_object.c
> +++ b/lustre/cmm/cmm_object.c
> @@ -340,11 +340,11 @@ static int cml_ref_del(const struct lu_env *env,  
> struct md_object *mo,
>  }
> static int cml_open(const struct lu_env *env, struct md_object *mo,
> -                    int flags)
> +                    struct md_attr *ma, int flags)
>  {
>          int rc;
>          ENTRY;
> -        rc = mo_open(env, md_object_next(mo), flags);
> +        rc = mo_open(env, md_object_next(mo), ma, flags);
>          RETURN(rc);
>  }
> @@ -1093,7 +1093,7 @@ static int cmr_ref_del(const struct lu_env *env,  
> struct md_object *mo,
>  }
> static int cmr_open(const struct lu_env *env, struct md_object *mo,
> -                    int flags)
> +                    struct md_attr *ma, int flags)
>  {
>          return -EREMOTE;
>  }
> diff --git a/lustre/include/md_object.h b/lustre/include/md_object.h
> index 9a7e3ee..59012f3 100644
> --- a/lustre/include/md_object.h
> +++ b/lustre/include/md_object.h
> @@ -262,8 +262,8 @@ struct md_object_operations {
>                             struct md_object *obj,
>                             struct md_attr *ma);
> -        int (*moo_open)(const struct lu_env *env,
> -                        struct md_object *obj, int flag);
> +        int (*moo_open)(const struct lu_env *env, struct md_object *obj,
> +                        struct md_attr *ma, int flag);
>         int (*moo_close)(const struct lu_env *env, struct md_object *obj,
>                           struct md_attr *ma);
> @@ -679,10 +679,11 @@ static inline int mo_xattr_list(const struct  
> lu_env *env,
> static inline int mo_open(const struct lu_env *env,
>                            struct md_object *m,
> +                          struct md_attr *ma,
>                            int flags)
>  {
>          LASSERT(m->mo_ops->moo_open);
> -        return m->mo_ops->moo_open(env, m, flags);
> +        return m->mo_ops->moo_open(env, m, ma, flags);
>  }
> static inline int mo_close(const struct lu_env *env,
> diff --git a/lustre/mdd/mdd_device.c b/lustre/mdd/mdd_device.c
> index 0dbfbd4..16c457c 100644
> --- a/lustre/mdd/mdd_device.c
> +++ b/lustre/mdd/mdd_device.c
> @@ -527,7 +527,7 @@ static int dot_lustre_mdd_ref_del(const struct  
> lu_env *env,
>  }
> static int dot_lustre_mdd_open(const struct lu_env *env, struct  
> md_object *obj,
> -                               int flags)
> +                               struct md_attr *ma, int flags)
>  {
>          struct mdd_object *mdd_obj = md2mdd_obj(obj);
> @@ -779,7 +779,7 @@ static int obf_xattr_get(const struct lu_env *env,
>  }
> static int obf_mdd_open(const struct lu_env *env, struct md_object *obj,
> -                        int flags)
> +                        struct md_attr *ma, int flags)
>  {
>          struct mdd_object *mdd_obj = md2mdd_obj(obj);
> diff --git a/lustre/mdd/mdd_object.c b/lustre/mdd/mdd_object.c
> index 6209af9..f05cb4b 100644
> --- a/lustre/mdd/mdd_object.c
> +++ b/lustre/mdd/mdd_object.c
> @@ -1965,10 +1950,11 @@ int accmode(const struct lu_env *env, struct  
> lu_attr *la, int flags)
>          return res;
>  }
> -static int mdd_open_sanity_check(const struct lu_env *env,
> -                                 struct mdd_object *obj, int flag)
> +static int mdd_open_sanity_check(const struct lu_env *env, struct  
> md_object *o,
> +                                 struct md_attr *ma, int flag)
>  {
>          struct lu_attr *tmp_la = &mdd_env_info(env)->mti_la;
> +        struct mdd_object *obj = md2mdd_obj(o);
>          int mode, rc;
>          ENTRY;
> @@ -2006,6 +1992,22 @@ static int mdd_open_sanity_check(const struct  
> lu_env *env,
>                          RETURN(-EPERM);
>          }
> +        if (S_ISREG(tmp_la->la_mode) && (tmp_la->la_mode &  
> (S_ISGID|S_ISUID))) {
> +            LCONSOLE_INFO("mdd_open_sanity_check encountered  
> S_IS[G|U]ID\n");
> +            if (flag & (MDS_OPEN_TRUNC|MDS_OPEN_APPEND)) {
> +                ma->ma_attr_flags |= MDS_PERM_BYPASS;
> +                ma->ma_attr.la_mode &= ~(S_ISGID|S_ISUID);
> +                ma->ma_attr.la_valid = LA_MODE;
> +                LCONSOLE_INFO("ma->ma_attr.la_valid %llx\n",
> +                                ma->ma_attr.la_valid);
> +                rc = mdd_attr_set(env, o, ma);
> +                if (rc)
> +                        RETURN(rc);
> +            } else {
> +                RETURN(-EPERM);
> +            }
> +        }
> +
>  #if 0
>          /*
>           * Now, flag -- O_NOATIME does not be packed by client.
> @@ -2025,14 +2027,14 @@ static int mdd_open_sanity_check(const struct  
> lu_env *env,
>  }
> static int mdd_open(const struct lu_env *env, struct md_object *obj,
> -                    int flags)
> +                    struct md_attr *ma, int flags)
>  {
>          struct mdd_object *mdd_obj = md2mdd_obj(obj);
>          int rc = 0;
>         mdd_write_lock(env, mdd_obj, MOR_TGT_CHILD);
> -        rc = mdd_open_sanity_check(env, mdd_obj, flags);
> +        rc = mdd_open_sanity_check(env, obj, ma, flags);
>          if (rc == 0)
>                  mdd_obj->mod_count++;
> diff --git a/lustre/mdt/mdt_lib.c b/lustre/mdt/mdt_lib.c
> index 2a3b4a0..31fb9d0 100644
> --- a/lustre/mdt/mdt_lib.c
> +++ b/lustre/mdt/mdt_lib.c
> @@ -745,9 +745,6 @@ static __u64 mdt_attr_valid_xlate(__u64 in, struct  
> mdt_reint_record *rr,
>          if (in & MDS_OPEN_OWNEROVERRIDE)
>                  ma->ma_attr_flags |= MDS_OPEN_OWNEROVERRIDE;
> -        if (in & (ATTR_KILL_SUID|ATTR_KILL_SGID))
> -                ma->ma_attr_flags |= MDS_PERM_BYPASS;
> -
>          /*XXX need ATTR_RAW?*/
>          in &= ~(ATTR_MODE|ATTR_UID|ATTR_GID|ATTR_SIZE|ATTR_BLOCKS|
>                  ATTR_ATIME|ATTR_MTIME|ATTR_CTIME|ATTR_FROM_OPEN|
> diff --git a/lustre/mdt/mdt_open.c b/lustre/mdt/mdt_open.c
> index d581b82..2b221f9 100644
> --- a/lustre/mdt/mdt_open.c
> +++ b/lustre/mdt/mdt_open.c
> @@ -640,7 +640,7 @@ static int mdt_mfd_open(struct mdt_thread_info  
> *info, struct mdt_object *p,
>          if (rc)
>                  RETURN(rc);
> -        rc = mo_open(info->mti_env, mdt_object_child(o),
> +        rc = mo_open(info->mti_env, mdt_object_child(o), ma,
>                       created ? flags | MDS_OPEN_CREATED : flags);
>          if (rc)
>                  RETURN(rc);
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel


-- 
Mikhail Pershin,
Whamcloud Inc.
