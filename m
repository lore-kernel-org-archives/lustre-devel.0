Return-Path: <SRS0=ROYJ=G2=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,MIME_QP_LONG_LINE,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBE7CC433DB
	for <lustre-devel@archiver.kernel.org>; Sat, 23 Jan 2021 08:21:55 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4CBE1233EF
	for <lustre-devel@archiver.kernel.org>; Sat, 23 Jan 2021 08:21:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CBE1233EF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=dilger.ca
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7C75330BEE0;
	Sat, 23 Jan 2021 00:21:54 -0800 (PST)
Received: from mail-pg1-f169.google.com (mail-pg1-f169.google.com
 [209.85.215.169])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0F97721F86A
 for <lustre-devel@lists.lustre.org>; Sat, 23 Jan 2021 00:21:53 -0800 (PST)
Received: by mail-pg1-f169.google.com with SMTP id g15so5435124pgu.9
 for <lustre-devel@lists.lustre.org>; Sat, 23 Jan 2021 00:21:53 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=dilger-ca.20150623.gappssmtp.com; s=20150623;
 h=content-transfer-encoding:from:mime-version:date:subject:message-id
 :references:to;
 bh=qCpuBlbcfn0ZdCit3cn2OhJv0O3UoX0a7lk0/CVTGkM=;
 b=Q8v8JV3sBOUbW8S5SSUaXJ81QX6h8aijqfua5242MayDAI4jT04ZhxBYRNF2ypIEA4
 /0N62Y0tkq30A1rcFn8WbUASc9vEi8zPTIxWppgXBdxWPPqNv8vOeq0ltaJQRt3ZmV0o
 tqdNoAC1t9eyC5x5QQNPZBf+KzIY3/YRcXOjjpbvPIjpWSvYeH4yJXFnIymHoqXdZf1L
 OZQeQc49l9+FVyWW/l5StBXWGm/q8GCg7lDVtUVFUuYYUtAd+9HSkeRFleKPpNNd6lLV
 2b6Gid1Fo+kosnDD5zwdu//h4B50c6quRHkWSQchL7mv8Ac28VlzhDOcHKzP1K9miKU0
 inmQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:content-transfer-encoding:from:mime-version:date
 :subject:message-id:references:to;
 bh=qCpuBlbcfn0ZdCit3cn2OhJv0O3UoX0a7lk0/CVTGkM=;
 b=hJ3IHVaoOCWyDP0zjJMyAZTPEQk70ywikuPEdX46Rfol4Mck0XIo3fVYAzObYvOvmy
 AoEt0q7jy5ihz+s7mMxZoJLzUFCgEUZqT9hdtyAlZacY6xCIrn6yhTeY8ni3Ce4LAY6L
 +c98k72eQdGnS4oCoRNTv8HzfgV/GIxKttod0zxsypwwO4EyZYmv98mh5fq3MCcgyj+L
 Gwwho9TI1BxJsQJp7tz5CMIRd1kEtDe+SBYyFHyGUwZc25A7Z4ceCIi74Fw1RWa7WFYc
 k8q0cOvx8oxFKqVGsjjuYoZxxwdVWUwq2Q2Lqn7vIm3Ig/5XRvNtHV5ksj1DCzc/hONJ
 cnFw==
X-Gm-Message-State: AOAM533RCDsBk2CpRtw5cdYl8rNDM7EzTHQ2thYzo0fj5ur1dgXp/YDv
 gSNRzut6nHcUjh7DPhJt7dtmOkjnVU3OFqe/
X-Google-Smtp-Source: ABdhPJyVfoptdEXp0CwrPkJSvs148VE1UB2QaXJKPleZ/uRJbgLoEBHKT4dvaQ7Drt3eCc1IJaLcHg==
X-Received: by 2002:a63:1965:: with SMTP id 37mr8766885pgz.349.1611390112084; 
 Sat, 23 Jan 2021 00:21:52 -0800 (PST)
Received: from [192.168.10.175] (S01061cabc081bf83.cg.shawcable.net.
 [70.77.221.9])
 by smtp.gmail.com with ESMTPSA id l12sm11020119pjq.7.2021.01.23.00.21.51
 for <lustre-devel@lists.lustre.org>
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Sat, 23 Jan 2021 00:21:51 -0800 (PST)
From: Andreas Dilger <adilger@dilger.ca>
Mime-Version: 1.0 (1.0)
Date: Sat, 23 Jan 2021 00:21:50 -0800
Message-Id: <D7EB3901-2693-4F06-9827-EF3F04595521@dilger.ca>
References: <20210122151536.7982-2-s.hauer@pengutronix.de>
To: Lustre Development List <lustre-devel@lists.lustre.org>
X-Mailer: iPhone Mail (18B92)
Subject: [lustre-devel] Fwd: [PATCH 1/8] quota: Allow to pass mount path to
 quotactl
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============7057999662320647493=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>


--===============7057999662320647493==
Content-Type: multipart/alternative; boundary=Apple-Mail-0FCFF05D-544C-416C-BEB2-6069ED9717EB
Content-Transfer-Encoding: 7bit


--Apple-Mail-0FCFF05D-544C-416C-BEB2-6069ED9717EB
Content-Type: text/plain;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable

FYI, I noticed this new patch submitted upstream.

If it gets included upstream, there is a patch forward to allow the
standard quota tools to query Lustre quota data.=20

Cheers, Andreas

Begin forwarded message:

> From: Sascha Hauer <s.hauer@pengutronix.de>
> Date: January 22, 2021 at 07:17:45 PST
> To: linux-fsdevel@vger.kernel.org
> Cc: Richard Weinberger <richard@nod.at>, linux-mtd@lists.infradead.org, ke=
rnel@pengutronix.de, Jan Kara <jack@suse.com>, Sascha Hauer <s.hauer@pengutr=
onix.de>
> Subject: [PATCH 1/8] quota: Allow to pass mount path to quotactl
>=20
> =EF=BB=BFThis patch introduces the Q_PATH flag to the quotactl cmd argumen=
t.
> When given, the path given in the special argument to quotactl will
> be the mount path where the filesystem is mounted, instead of a path
> to the block device.
> This is necessary for filesystems which do not have a block device as
> backing store. Particularly this is done for upcoming UBIFS support.
>=20
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
> ---
> fs/quota/quota.c           | 66 ++++++++++++++++++++++++++++----------
> include/uapi/linux/quota.h |  1 +
> 2 files changed, 50 insertions(+), 17 deletions(-)
>=20
> diff --git a/fs/quota/quota.c b/fs/quota/quota.c
> index 6d16b2be5ac4..f653b27a9a4e 100644
> --- a/fs/quota/quota.c
> +++ b/fs/quota/quota.c
> @@ -17,6 +17,7 @@
> #include <linux/capability.h>
> #include <linux/quotaops.h>
> #include <linux/types.h>
> +#include <linux/mount.h>
> #include <linux/writeback.h>
> #include <linux/nospec.h>
> #include "compat.h"
> @@ -859,25 +860,10 @@ static bool quotactl_cmd_onoff(int cmd)
>         (cmd =3D=3D Q_XQUOTAON) || (cmd =3D=3D Q_XQUOTAOFF);
> }
>=20
> -/*
> - * look up a superblock on which quota ops will be performed
> - * - use the name of a block device to find the superblock thereon
> - */
> -static struct super_block *quotactl_block(const char __user *special, int=
 cmd)
> +static struct super_block *quotactl_sb(dev_t dev, int cmd)
> {
> -#ifdef CONFIG_BLOCK
>    struct super_block *sb;
> -    struct filename *tmp =3D getname(special);
>    bool excl =3D false, thawed =3D false;
> -    int error;
> -    dev_t dev;
> -
> -    if (IS_ERR(tmp))
> -        return ERR_CAST(tmp);
> -    error =3D lookup_bdev(tmp->name, &dev);
> -    putname(tmp);
> -    if (error)
> -        return ERR_PTR(error);
>=20
>    if (quotactl_cmd_onoff(cmd)) {
>        excl =3D true;
> @@ -901,12 +887,50 @@ static struct super_block *quotactl_block(const char=
 __user *special, int cmd)
>        goto retry;
>    }
>    return sb;
> +}
> +
> +/*
> + * look up a superblock on which quota ops will be performed
> + * - use the name of a block device to find the superblock thereon
> + */
> +static struct super_block *quotactl_block(const char __user *special, int=
 cmd)
> +{
> +#ifdef CONFIG_BLOCK
> +    struct filename *tmp =3D getname(special);
> +    int error;
> +    dev_t dev;
>=20
> +    if (IS_ERR(tmp))
> +        return ERR_CAST(tmp);
> +    error =3D lookup_bdev(tmp->name, &dev);
> +    putname(tmp);
> +    if (error)
> +        return ERR_PTR(error);
> +
> +    return quotactl_sb(dev, cmd);
> #else
>    return ERR_PTR(-ENODEV);
> #endif
> }
>=20
> +static struct super_block *quotactl_path(const char __user *special, int c=
md)
> +{
> +    struct super_block *sb;
> +    struct path path;
> +    int error;
> +
> +    error =3D user_path_at(AT_FDCWD, special, LOOKUP_FOLLOW | LOOKUP_AUTO=
MOUNT,
> +               &path);
> +    if (error)
> +        return ERR_PTR(error);
> +
> +    sb =3D quotactl_sb(path.mnt->mnt_sb->s_dev, cmd);
> +
> +    path_put(&path);
> +
> +    return sb;
> +}
> +
> /*
>  * This is the system call interface. This communicates with
>  * the user-level programs. Currently this only supports diskquota
> @@ -920,6 +944,7 @@ SYSCALL_DEFINE4(quotactl, unsigned int, cmd, const cha=
r __user *, special,
>    struct super_block *sb =3D NULL;
>    struct path path, *pathp =3D NULL;
>    int ret;
> +    bool q_path;
>=20
>    cmds =3D cmd >> SUBCMDSHIFT;
>    type =3D cmd & SUBCMDMASK;
> @@ -927,6 +952,9 @@ SYSCALL_DEFINE4(quotactl, unsigned int, cmd, const cha=
r __user *, special,
>    if (type >=3D MAXQUOTAS)
>        return -EINVAL;
>=20
> +    q_path =3D cmds & Q_PATH;
> +    cmds &=3D ~Q_PATH;
> +
>    /*
>     * As a special case Q_SYNC can be called without a specific device.
>     * It will iterate all superblocks that have quota enabled and call
> @@ -951,7 +979,11 @@ SYSCALL_DEFINE4(quotactl, unsigned int, cmd, const ch=
ar __user *, special,
>            pathp =3D &path;
>    }
>=20
> -    sb =3D quotactl_block(special, cmds);
> +    if (q_path)
> +        sb =3D quotactl_path(special, cmds);
> +    else
> +        sb =3D quotactl_block(special, cmds);
> +
>    if (IS_ERR(sb)) {
>        ret =3D PTR_ERR(sb);
>        goto out;
> diff --git a/include/uapi/linux/quota.h b/include/uapi/linux/quota.h
> index f17c9636a859..e1787c0df601 100644
> --- a/include/uapi/linux/quota.h
> +++ b/include/uapi/linux/quota.h
> @@ -71,6 +71,7 @@
> #define Q_GETQUOTA 0x800007    /* get user quota structure */
> #define Q_SETQUOTA 0x800008    /* set user quota structure */
> #define Q_GETNEXTQUOTA 0x800009    /* get disk limits and usage >=3D ID */=

> +#define Q_PATH     0x400000    /* quotactl special arg contains mount pat=
h */
>=20
> /* Quota format type IDs */
> #define    QFMT_VFS_OLD 1
> --=20
> 2.20.1
>=20

--Apple-Mail-0FCFF05D-544C-416C-BEB2-6069ED9717EB
Content-Type: text/html;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable

<html><head><meta http-equiv=3D"content-type" content=3D"text/html; charset=3D=
utf-8"></head><body dir=3D"auto">FYI, I noticed this new patch submitted ups=
tream.<div><br></div><div>If it gets included upstream, there is a patch for=
ward to allow the<div>standard quota tools to query Lustre quota data.&nbsp;=
<br><br><div dir=3D"ltr">Cheers, Andreas</div><div dir=3D"ltr"><br>Begin for=
warded message:<br><br></div><blockquote type=3D"cite"><div dir=3D"ltr"><b>From:=
</b> Sascha Hauer &lt;s.hauer@pengutronix.de&gt;<br><b>Date:</b> January 22,=
 2021 at 07:17:45 PST<br><b>To:</b> linux-fsdevel@vger.kernel.org<br><b>Cc:<=
/b> Richard Weinberger &lt;richard@nod.at&gt;, linux-mtd@lists.infradead.org=
, kernel@pengutronix.de, Jan Kara &lt;jack@suse.com&gt;, Sascha Hauer &lt;s.=
hauer@pengutronix.de&gt;<br><b>Subject:</b> <b>[PATCH 1/8] quota: Allow to p=
ass mount path to quotactl</b><br><br></div></blockquote><blockquote type=3D=
"cite"><div dir=3D"ltr">=EF=BB=BF<span>This patch introduces the Q_PATH flag=
 to the quotactl cmd argument.</span><br><span>When given, the path given in=
 the special argument to quotactl will</span><br><span>be the mount path whe=
re the filesystem is mounted, instead of a path</span><br><span>to the block=
 device.</span><br><span>This is necessary for filesystems which do not have=
 a block device as</span><br><span>backing store. Particularly this is done f=
or upcoming UBIFS support.</span><br><span></span><br><span>Signed-off-by: S=
ascha Hauer &lt;s.hauer@pengutronix.de&gt;</span><br><span>---</span><br><sp=
an> fs/quota/quota.c &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;| 66 ++++++++++++++++++++++++++++----------</span><br><span> include/ua=
pi/linux/quota.h | &nbsp;1 +</span><br><span> 2 files changed, 50 insertions=
(+), 17 deletions(-)</span><br><span></span><br><span>diff --git a/fs/quota/=
quota.c b/fs/quota/quota.c</span><br><span>index 6d16b2be5ac4..f653b27a9a4e 1=
00644</span><br><span>--- a/fs/quota/quota.c</span><br><span>+++ b/fs/quota/=
quota.c</span><br><span>@@ -17,6 +17,7 @@</span><br><span> #include &lt;linu=
x/capability.h&gt;</span><br><span> #include &lt;linux/quotaops.h&gt;</span>=
<br><span> #include &lt;linux/types.h&gt;</span><br><span>+#include &lt;linu=
x/mount.h&gt;</span><br><span> #include &lt;linux/writeback.h&gt;</span><br>=
<span> #include &lt;linux/nospec.h&gt;</span><br><span> #include "compat.h"<=
/span><br><span>@@ -859,25 +860,10 @@ static bool quotactl_cmd_onoff(int cmd=
)</span><br><span>  &nbsp; &nbsp; &nbsp; &nbsp; (cmd =3D=3D Q_XQUOTAON) || (=
cmd =3D=3D Q_XQUOTAOFF);</span><br><span> }</span><br><span></span><br><span=
>-/*</span><br><span>- * look up a superblock on which quota ops will be per=
formed</span><br><span>- * - use the name of a block device to find the supe=
rblock thereon</span><br><span>- */</span><br><span>-static struct super_blo=
ck *quotactl_block(const char __user *special, int cmd)</span><br><span>+sta=
tic struct super_block *quotactl_sb(dev_t dev, int cmd)</span><br><span> {</=
span><br><span>-#ifdef CONFIG_BLOCK</span><br><span>  &nbsp; &nbsp;struct su=
per_block *sb;</span><br><span>- &nbsp; &nbsp;struct filename *tmp =3D getna=
me(special);</span><br><span>  &nbsp; &nbsp;bool excl =3D false, thawed =3D f=
alse;</span><br><span>- &nbsp; &nbsp;int error;</span><br><span>- &nbsp; &nb=
sp;dev_t dev;</span><br><span>-</span><br><span>- &nbsp; &nbsp;if (IS_ERR(tm=
p))</span><br><span>- &nbsp; &nbsp; &nbsp; &nbsp;return ERR_CAST(tmp);</span=
><br><span>- &nbsp; &nbsp;error =3D lookup_bdev(tmp-&gt;name, &amp;dev);</sp=
an><br><span>- &nbsp; &nbsp;putname(tmp);</span><br><span>- &nbsp; &nbsp;if (=
error)</span><br><span>- &nbsp; &nbsp; &nbsp; &nbsp;return ERR_PTR(error);</=
span><br><span></span><br><span>  &nbsp; &nbsp;if (quotactl_cmd_onoff(cmd)) {=
</span><br><span>  &nbsp; &nbsp; &nbsp; &nbsp;excl =3D true;</span><br><span=
>@@ -901,12 +887,50 @@ static struct super_block *quotactl_block(const char _=
_user *special, int cmd)</span><br><span>  &nbsp; &nbsp; &nbsp; &nbsp;goto r=
etry;</span><br><span>  &nbsp; &nbsp;}</span><br><span>  &nbsp; &nbsp;return=
 sb;</span><br><span>+}</span><br><span>+</span><br><span>+/*</span><br><spa=
n>+ * look up a superblock on which quota ops will be performed</span><br><s=
pan>+ * - use the name of a block device to find the superblock thereon</spa=
n><br><span>+ */</span><br><span>+static struct super_block *quotactl_block(=
const char __user *special, int cmd)</span><br><span>+{</span><br><span>+#if=
def CONFIG_BLOCK</span><br><span>+ &nbsp; &nbsp;struct filename *tmp =3D get=
name(special);</span><br><span>+ &nbsp; &nbsp;int error;</span><br><span>+ &=
nbsp; &nbsp;dev_t dev;</span><br><span></span><br><span>+ &nbsp; &nbsp;if (I=
S_ERR(tmp))</span><br><span>+ &nbsp; &nbsp; &nbsp; &nbsp;return ERR_CAST(tmp=
);</span><br><span>+ &nbsp; &nbsp;error =3D lookup_bdev(tmp-&gt;name, &amp;d=
ev);</span><br><span>+ &nbsp; &nbsp;putname(tmp);</span><br><span>+ &nbsp; &=
nbsp;if (error)</span><br><span>+ &nbsp; &nbsp; &nbsp; &nbsp;return ERR_PTR(=
error);</span><br><span>+</span><br><span>+ &nbsp; &nbsp;return quotactl_sb(=
dev, cmd);</span><br><span> #else</span><br><span>  &nbsp; &nbsp;return ERR_=
PTR(-ENODEV);</span><br><span> #endif</span><br><span> }</span><br><span></s=
pan><br><span>+static struct super_block *quotactl_path(const char __user *s=
pecial, int cmd)</span><br><span>+{</span><br><span>+ &nbsp; &nbsp;struct su=
per_block *sb;</span><br><span>+ &nbsp; &nbsp;struct path path;</span><br><s=
pan>+ &nbsp; &nbsp;int error;</span><br><span>+</span><br><span>+ &nbsp; &nb=
sp;error =3D user_path_at(AT_FDCWD, special, LOOKUP_FOLLOW | LOOKUP_AUTOMOUN=
T,</span><br><span>+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&=
amp;path);</span><br><span>+ &nbsp; &nbsp;if (error)</span><br><span>+ &nbsp=
; &nbsp; &nbsp; &nbsp;return ERR_PTR(error);</span><br><span>+</span><br><sp=
an>+ &nbsp; &nbsp;sb =3D quotactl_sb(path.mnt-&gt;mnt_sb-&gt;s_dev, cmd);</s=
pan><br><span>+</span><br><span>+ &nbsp; &nbsp;path_put(&amp;path);</span><b=
r><span>+</span><br><span>+ &nbsp; &nbsp;return sb;</span><br><span>+}</span=
><br><span>+</span><br><span> /*</span><br><span> &nbsp;* This is the system=
 call interface. This communicates with</span><br><span> &nbsp;* the user-le=
vel programs. Currently this only supports diskquota</span><br><span>@@ -920=
,6 +944,7 @@ SYSCALL_DEFINE4(quotactl, unsigned int, cmd, const char __user *=
, special,</span><br><span>  &nbsp; &nbsp;struct super_block *sb =3D NULL;</=
span><br><span>  &nbsp; &nbsp;struct path path, *pathp =3D NULL;</span><br><=
span>  &nbsp; &nbsp;int ret;</span><br><span>+ &nbsp; &nbsp;bool q_path;</sp=
an><br><span></span><br><span>  &nbsp; &nbsp;cmds =3D cmd &gt;&gt; SUBCMDSHI=
FT;</span><br><span>  &nbsp; &nbsp;type =3D cmd &amp; SUBCMDMASK;</span><br>=
<span>@@ -927,6 +952,9 @@ SYSCALL_DEFINE4(quotactl, unsigned int, cmd, const=
 char __user *, special,</span><br><span>  &nbsp; &nbsp;if (type &gt;=3D MAX=
QUOTAS)</span><br><span>  &nbsp; &nbsp; &nbsp; &nbsp;return -EINVAL;</span><=
br><span></span><br><span>+ &nbsp; &nbsp;q_path =3D cmds &amp; Q_PATH;</span=
><br><span>+ &nbsp; &nbsp;cmds &amp;=3D ~Q_PATH;</span><br><span>+</span><br=
><span>  &nbsp; &nbsp;/*</span><br><span>  &nbsp; &nbsp; * As a special case=
 Q_SYNC can be called without a specific device.</span><br><span>  &nbsp; &n=
bsp; * It will iterate all superblocks that have quota enabled and call</spa=
n><br><span>@@ -951,7 +979,11 @@ SYSCALL_DEFINE4(quotactl, unsigned int, cmd=
, const char __user *, special,</span><br><span>  &nbsp; &nbsp; &nbsp; &nbsp=
; &nbsp; &nbsp;pathp =3D &amp;path;</span><br><span>  &nbsp; &nbsp;}</span><=
br><span></span><br><span>- &nbsp; &nbsp;sb =3D quotactl_block(special, cmds=
);</span><br><span>+ &nbsp; &nbsp;if (q_path)</span><br><span>+ &nbsp; &nbsp=
; &nbsp; &nbsp;sb =3D quotactl_path(special, cmds);</span><br><span>+ &nbsp;=
 &nbsp;else</span><br><span>+ &nbsp; &nbsp; &nbsp; &nbsp;sb =3D quotactl_blo=
ck(special, cmds);</span><br><span>+</span><br><span>  &nbsp; &nbsp;if (IS_E=
RR(sb)) {</span><br><span>  &nbsp; &nbsp; &nbsp; &nbsp;ret =3D PTR_ERR(sb);<=
/span><br><span>  &nbsp; &nbsp; &nbsp; &nbsp;goto out;</span><br><span>diff -=
-git a/include/uapi/linux/quota.h b/include/uapi/linux/quota.h</span><br><sp=
an>index f17c9636a859..e1787c0df601 100644</span><br><span>--- a/include/uap=
i/linux/quota.h</span><br><span>+++ b/include/uapi/linux/quota.h</span><br><=
span>@@ -71,6 +71,7 @@</span><br><span> #define Q_GETQUOTA 0x800007 &nbsp; &=
nbsp;/* get user quota structure */</span><br><span> #define Q_SETQUOTA 0x80=
0008 &nbsp; &nbsp;/* set user quota structure */</span><br><span> #define Q_=
GETNEXTQUOTA 0x800009 &nbsp; &nbsp;/* get disk limits and usage &gt;=3D ID *=
/</span><br><span>+#define Q_PATH &nbsp;&nbsp;&nbsp;&nbsp;0x400000 &nbsp; &n=
bsp;/* quotactl special arg contains mount path */</span><br><span></span><b=
r><span> /* Quota format type IDs */</span><br><span> #define &nbsp; &nbsp;Q=
FMT_VFS_OLD 1</span><br><span>-- </span><br><span>2.20.1</span><br><span></s=
pan><br></div></blockquote></div></div></body></html>=

--Apple-Mail-0FCFF05D-544C-416C-BEB2-6069ED9717EB--

--===============7057999662320647493==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7057999662320647493==--
