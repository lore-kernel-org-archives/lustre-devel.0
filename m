Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A9835CCFA03
	for <lustre-devel@archiver.kernel.org>; Mon,  3 Nov 2025 19:52:27 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d0j0L2c3Vz1y1q;
	Mon, 03 Nov 2025 11:52:02 -0800 (PST)
Received: from mail-pl1-f177.google.com (mail-pl1-f177.google.com
 [209.85.214.177])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d0hzy3s20z1xrs
 for <lustre-devel@lists.lustre.org>; Mon, 03 Nov 2025 11:51:42 -0800 (PST)
Received: by mail-pl1-f177.google.com with SMTP id
 d9443c01a7336-29586626fbeso16013685ad.0
 for <lustre-devel@lists.lustre.org>; Mon, 03 Nov 2025 11:51:42 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1762199501; x=1762804301; darn=lists.lustre.org;
 h=to:references:message-id:cc:date:in-reply-to:from:subject
 :mime-version:content-transfer-encoding:from:to:cc:subject:date
 :message-id:reply-to;
 bh=LvspvX7bjLOu8lm/69QeRm+S2pRvK5XzXiKZavbgn68=;
 b=SBAQXESAu/mgY6xv3alWvnH1xhdej9SBxKDTF/Yj55QGQNWbTksBGIcYm8A6cdtGNu
 jpfqibEXck2aQly6a4sg12RuBGngCqj+Bn9pM20pOHoRvnR1EyX6WbYm+jXElU5pxfM1
 UiWqSsY0X5D+7ACHjaBlmwf6uMV38uq+qkq+TtU5fxilYhpyavkKMnYzj3klBJGXWAeT
 B9S6AghopryimWMHt3P10U0UG+23ieonPxhBDRQy7jowfbx8T70sFeTuMHsV2enGNKSM
 y++a1Se9H5Zelamwut9na8b950Alo+Fc7W1pwlh+fPaa/iHwFQqYKAPX7ff3ru018Jyk
 p6Cg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1762199501; x=1762804301;
 h=to:references:message-id:cc:date:in-reply-to:from:subject
 :mime-version:content-transfer-encoding:x-gm-message-state:from:to
 :cc:subject:date:message-id:reply-to;
 bh=LvspvX7bjLOu8lm/69QeRm+S2pRvK5XzXiKZavbgn68=;
 b=KBsb4Is2fhH6vyT2Nw334OU1MZUrtWnXyLaWwaq1n0eby9ZXfEHcW9h6Vi+j6l2z6r
 zMwHAQSUnRWm0vc60ChlpXh/pFanCHOT45XLYDZjfGNO6fpr5xJS8TUYmranTryWqJeo
 N1nkHqXo/aqlTG5svqdcwu6UQfdp4zwMcAhJxDk+QjXBzv1jMZk2gv92uQ0i7D8AI9rQ
 IQLf+wfvbVRJVipRzRWXXUHYdHvtOwFEaSHXb6sBJN7hroMhDvq6LtdPzi9Aq0XnTxLs
 T5tDJpScp7qBLplFICXgruMyEaQkKJmrKan+He2r+UBQqXiT0ueRN0wfEPc3PA5zwsaX
 7HzA==
X-Gm-Message-State: AOJu0Yw5plnCr2I4ROmKIwr7D3R3+u1H1A91U/pr4idMxg4JFMRGlriV
 NRi8hSRb+AyywwaMgHU9b1th8u8Uq66FCqLPumCeIL/ZKVdjxSYG00fS
X-Gm-Gg: ASbGnctod77xy60A2IC9rCNHukr+jkApuglF8MdiZokLkVFElxBnQOI4ylGwzr+95zL
 9U09dviFFbl8ZMgYXKQEjQ7goh9qUQU0H4UgsB5Gcc5VCQYJRIyZmpU0lTTojNgX9Wm96Uyf7V+
 TfWT3yQBd6aVy6nYMHm3dY6XXflaARBinPSyh4btTNGBLimGgU2I+DkxA4B9DmnuURJRah2S6PH
 CjOSLms4T/cqKaS9LTjbNz8uoF7HoCYSLmxLu9v+w1ei1hoNabE/OVvaJBukGKZZaW5bAwWJBsq
 P8J1AIAqCzRCdDQk05oXTkRKSncdRT7t2rhn1NgqOsCFqGDwuz/Dnj65AyupL9QVUpAAC/91ZUv
 D8xlCVv79lcZ7otOpEJjOZUoFc8+QhSfM5bMHlPNnJxhwxuohXPpEdzLxXxsgNdEPSiQXQ2B31G
 DSuuf58pExLs/rUMqAh9cMlZCgWcWmHQlbISqQt5jpPKGjwUDXPaNXc/tp3ZYpDD/kD5Y5vJtXc
 eW52Zw+UpA=
X-Google-Smtp-Source: AGHT+IGmH1ezC91s7rbU0OHC+twRe/vRQR0YN7zUaLTpTSUQLiB1aTjWI8bVJ1qk8e+21zxcZOsNfA==
X-Received: by 2002:a17:902:ec89:b0:274:5030:2906 with SMTP id
 d9443c01a7336-2951a51e93fmr198426055ad.46.1762199501203; 
 Mon, 03 Nov 2025 11:51:41 -0800 (PST)
Received: from smtpclient.apple ([2a00:79e1:2e01:1:b909:d38d:1dfa:b899])
 by smtp.gmail.com with ESMTPSA id
 d9443c01a7336-295269a8df3sm128439195ad.90.2025.11.03.11.51.40
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Mon, 03 Nov 2025 11:51:40 -0800 (PST)
Mime-Version: 1.0 (1.0)
In-Reply-To: <447DF6B0-8E35-400E-9AF2-784FCCAD4E28@ddn.com>
Date: Mon, 3 Nov 2025 11:51:29 -0800
Message-Id: <E75A8207-31D3-4B0A-997E-0B96CABC6FDC@gmail.com>
References: <447DF6B0-8E35-400E-9AF2-784FCCAD4E28@ddn.com>
To: Andreas Dilger <adilger@ddn.com>
X-Mailer: iPhone Mail (23A355)
Subject: Re: [lustre-devel] RFC: Spill device for Lustre OSD
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
From: Jinshan Xiong via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Jinshan Xiong <jinshan.xiong@gmail.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============5359721564606086800=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>


--===============5359721564606086800==
Content-Type: multipart/alternative; boundary=Apple-Mail-1D37317C-1ECD-459D-B3FB-FE98DD41B620
Content-Transfer-Encoding: 7bit


--Apple-Mail-1D37317C-1ECD-459D-B3FB-FE98DD41B620
Content-Type: text/plain;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable



> On Nov 2, 2025, at 21:50, Andreas Dilger <adilger@ddn.com> wrote:
>=20
> =EF=BB=BF On Nov 2, 2025, at 16:22, Jinshan Xiong <jinshan.xiong@gmail.com=
> wrote:
>> Hi folks,
>>=20
>> I came up with an idea to implement tiered storage for Lustre in a new
>> way. I'm sharing it here in order to get some feedback and decide if
>> it is worth pursuing. This is still in the early stage so it's just a
>> rough idea.
>>=20
>> Thanks,
>> Jinshan
>=20
> Jinshan,
> thanks for sending out this proposal.  As we discussed previously,
> I think it would be better for the long-term maintenance of Lustre if
> the spill device was also accessed via the Lustre OSD API instead
> of directly via the VFS, so that each of the OSDs implemented could
> be stacked on top of another (e.g. osd-memfs spilling to osd-ldiskfs
> on NVMe or HDD).

Yeah the major difference is that this spill device is not a fully functiona=
l OSD because we will support s3fs and gcsfuse, which means they won=E2=80=99=
t work with OFD on its own. We can discuss this further.

I created a PR at https://review.whamcloud.com/c/fs/lustre-release/+/62171 a=
nd we can discuss over there if it is easier.

>=20
> I haven't looked into the details, but the state machine for managing
> the spill device objects seems similar to FLR mirror files, and using
> the existing LOV EA layout on the OST objects would reduce the
> amount of dedicated tools that need to be developed to access such
> files.

That would be complex by exporting those information to Lustre stack because=
 we will have another entity that can initiate layout change from OST. Pleas=
e have a look at the design and we can discuss if that approach is reasonabl=
e.

>=20
> This seems similar to having the LOD layer split operations between
> a local OSD and a remote OSP, but it could split operations over
> two local OSD devices.
>=20
> The other thing of interest in the other direction is the log-structured
> writes to migrated files, which might be useful for FLR mirrored or
> EC files.  This would allow replaying partial overwrites of existing
> files into the other mirrors/EC at a later time.

Yes, by remembering this in the hot tier so that resync will be much less ex=
pensive.

>=20
>> # Spilling Device Proposal for Lustre OSD
>>=20
>> ## Introduction
>>=20
>> Spilling device is a private block device to an OSD in Lustre. It
>> allows an OSD to migrate infrequently accessed data objects to this
>> device. The key distinction between popular tiered storage is that it
>> only has a local view of the objects in a local OSD. Consequently, it
>> should make quick and accurate decisions based on the recent access
>> pattern. Only data objects can be spilled into the spilling device,
>> while metadata objects, such as OI namespace and last objid, remain in
>> the OSD permanently. This implies that the spilling device for OSD is
>> only applicable to OST OSDs. By design, the size of an OSD should be
>> sufficient to store the entire local workset, for instance, all the
>> data for an AI training job. A typical configuration would involve a
>> 1TB SSD OSD with 10TB of HDD as a spilling device.
>>=20
>> Generic Lustre utilities won=E2=80=99t be able to directly access spillin=
g
>> devices. For example, **lfs df** will only display the capacity of the
>> OSD device, while the capacity of the spilling device can be accessed
>> using specific options.
>=20
> It should be possible to pass an extra OS_STATE_STATFS flag to
> return the extra capacity of the spill device in statfs()/lfs df output.
>=20
>> OSDs will access spilling devices through VFS interfaces in the kernel
>> space. Therefore, the spilling device must be mountable into the
>> kernel namespace. Initially, only HDD is supported, and the
>> implementation can be extended to S3 and GCS using s3fs and gcsfuse
>> respectively in the future.
>>=20
>> ## Architecture
>>=20
>> When an OST object is spilled, it leaves a zero-lengthed stub object
>> with a special EA, called spill-ea, in the OSD. The spill-ea is used
>> to track the status of the object in the OSD and also store the
>> metadata of the spilled object in the spilling device.
>>=20
>> Status of the object:
>> - **MIGRATING**: The object data is being copied to the spilled object.
>> - **MIGRATED**: The object data exists in both the OSD and the
>> spilling device, and the contents are synchronized.
>> - **RELEASED**: The object data is only in the spilling device, and it
>> leaves a stub object in the OSD.
>> - **DIRTY**: The object is released, but it has been written to
>> afterward, so the OSD retains some up-to-date data.
>>=20
>> **Migrating**
>>=20
>> Migration involves copying data into the spilling device. A daemon
>> process in the OSD continuously scans candidates for migration. The
>> typical policy for migration is based on the last access time and size
>> of the objects. For instance, if an object hasn=E2=80=99t been accessed i=
n the
>> past day and its size exceeds 10MB, it will create an object in the
>> spilling device and copy its contents over.
>>=20
>> There=E2=80=99s no on-demand migration feature. If there=E2=80=99s no ava=
ilable space
>> while a large chunk of data is being written, the system will return
>> ENOSPC to the client. This simplifies the granting mechanism on the
>> OFD significantly. Another reason for this approach is that writing
>> performance is more predictable. Otherwise, the system might have to
>> wait for an object to be migrated on demand, leading to much higher
>> latency.
>>=20
>> **Releasing**
>>=20
>> Once the data is migrated, the daemon can release the object by
>> truncating it in the OSD and setting the spill-ea status to
>> **RELEASED**, atomically.
>>=20
>> Typically, an object is released only when the OSD=E2=80=99s available sp=
ace
>> becomes limited. This allows us to keep as much data as possible in
>> the OSD.
>>=20
>> **Restoring**
>>=20
>> Restoring involves copying data back to the OSD device. It=E2=80=99s trig=
gered
>> by reading from or writing to a released object and is managed by the
>> daemon, so it doesn=E2=80=99t interfere with the critical code path handl=
ing
>> read and write operations from the OFD.
>>=20
>> When restoring, the object data is first copied to a temporary file
>> (`O_TMPFILE`). Afterward, it=E2=80=99s renamed to switch the inode in OI a=
nd
>> reset the spill-ea status atomically.
>>=20
>> As mentioned earlier, the spilling device is operated with standard
>> VFS interfaces. Therefore, the OSD can directly read and write the
>> object in the spilling device. We tend to read a released file
>> directly in the first few reads. Writing is handled separately and
>> will be covered later.
>>=20
>> Maintaining a synchronized state between two systems is a challenge.
>> We=E2=80=99ll leverage llog extensively to achieve this.
>>=20
>> ## Operations Handling
>>=20
>> **write**
>>=20
>> If an object lacks a spill EA, it means there=E2=80=99s no spilled object=
 in
>> the spilling device. In such cases, the write operation proceeds
>> normally.
>>=20
>> If an object is in the **MIGRATING** or **MIGRATED** state, it writes
>> directly to the object and deletes the spill EA by writing llog.
>>=20
>> If an object is in the **RELEASED** state, it writes the data to the
>> object in log-structured format and sets its status to **DIRTY**.
>>=20
>> If an object is in the **DIRTY** state, it appends a new log entry to
>> the object. If the number of logs exceeds a predefined limit, it
>> triggers a restoration process.
>>=20
>> **read**
>>=20
>> If an object lacks a spill EA, it means there=E2=80=99s no spilled object=
 in
>> the spilling device. In such cases, the read operation proceeds
>> normally.
>>=20
>> If an object is in the **MIGRATING** or **MIGRATED**, it=E2=80=99s read d=
irectly.
>>=20
>> If an object is in the **DIRTY** state, it checks if the read range
>> overlaps with the entries in the log.
>>=20
>> If an object is in the **RELEASED** state, it reads the data directly
>> from the spilled object. If the number of reads to this object exceeds
>> a predefined limit, it initiates a restoration process and sets the
>> object=E2=80=99s status to **MIGRATED**.
>>=20
>> **truncate and unlink**
>>=20
>> If an object has a spill EA and is being truncated or deleted, it
>> writes an llog entry to ensure the spilled object is eventually
>> deleted.
>>=20
>> **migrate**
>>=20
>> Before initiating the migration of an object, it=E2=80=99s crucial to mak=
e the
>> spilled object a known state in order to prevent remote object
>> leakage. Therefore, it=E2=80=99s essential to set the spill EA first and t=
hen
>> create the spilled object after the transaction is committed. The
>> challenging aspect is that it's not possible to have any information
>> about the spilled object before its creation.
>>=20
>> We decided to store the object in a known path. For instance, object
>> paths like `<fsname>/OST<index>/<oid:0:2>/<oid:2:>` seem reasonable.
>> This also means that the OSD must own the spilling device entirely.
>> Having foreign objects would cause confusion.
>=20
> While my preference is that we use a regular OSD for the spill storage,
> I don't see why the exclusive access to this directory tree also needs
> exclusive use to the whole block device?  As long as the directory
> itself is not being modified by other applications then it should be OK?

That=E2=80=99s right. I just don=E2=80=99t want someone accidentally create a=
 conflicting file. Even though it=E2=80=99s unlikely. It=E2=80=99s easier to=
 just solely own it.

Btw, the design will lead to an implementation that a single gcs bucket is u=
sed by all OSDs in a Lustre instance.

>=20
>> **restore**
>>=20
>> Restoration will use a temporary file, which is essentially a file
>> created under an orphan directory. Once the copy from spilled object
>> is complete, it will also deal the write log entries in the original
>> object. If everything is done, it will rename the temporary file and
>> the corresponding OI file, and append a log entry to delete the
>> spilled object, all in a local transaction.
>>=20
>> ## Implementation
>>=20
>> OSD APIs are well-maintained and provide dedicated APIs for object
>> manipulation and body operations to interact with object content.
>> Spill device configuration  will be stored in the configuration log so
>> that the OSD will know if it has spilling device in the device
>> initialization.
>>=20
>> If a spill device exists for an OSD, the object and body operations
>> will be redirected to a new set of OSD APIs. These APIs essentially
>> check for the existence of a spill EA before proceeding with any
>> operations. If local objects are used, the original OSD APIs will
>> still be invoked.
>>=20
>> A new set of Lustre utilities will be developed to display information
>> about spill devices.
>>=20
>> ## Conclusion
>>=20
>> This solution gives a possible solution trying to address the
>> painpoints of prevalent tiered storage using mirroring, where a
>> full-flavoured policy engine has to run on dedicated clients, and
>> deliver better performance than block-level cache with dmcache, where
>> recovery time is lengthy if the cache size is huge.
>=20
> Cheers, Andreas
> =E2=80=94
> Andreas Dilger
> Lustre Principal Architect
> Whamcloud/DDN
>=20
>=20
>=20
>=20

--Apple-Mail-1D37317C-1ECD-459D-B3FB-FE98DD41B620
Content-Type: text/html;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable

<html class=3D"apple-mail-supports-explicit-dark-mode"><head><meta http-equi=
v=3D"content-type" content=3D"text/html; charset=3Dutf-8"></head><body dir=3D=
"auto"><div dir=3D"ltr"></div><div dir=3D"ltr"><br></div><div dir=3D"ltr"><b=
r><blockquote type=3D"cite">On Nov 2, 2025, at 21:50, Andreas Dilger &lt;adi=
lger@ddn.com&gt; wrote:<br><br></blockquote></div><blockquote type=3D"cite">=
<div dir=3D"ltr">=EF=BB=BF

<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dutf-8">


On Nov 2, 2025, at 16:22, Jinshan Xiong &lt;jinshan.xiong@gmail.com&gt; wrot=
e:
<div>
<blockquote type=3D"cite">
<div>
<div>Hi folks,<br>
<br>
I came up with an idea to implement tiered storage for Lustre in a new<br>
way. I'm sharing it here in order to get some feedback and decide if<br>
it is worth pursuing. This is still in the early stage so it's just a<br>
rough idea.<br>
<br>
Thanks,<br>
Jinshan<br>
</div>
</div>
</blockquote>
<div><br>
</div>
Jinshan,</div>
<div>thanks for sending out this proposal. &nbsp;As we discussed previously,=
</div>
<div>I think it would be better for the long-term maintenance of Lustre if</=
div>
<div>the spill device was also accessed via the Lustre OSD API instead</div>=

<div>of directly via the VFS, so that each of the OSDs implemented could</di=
v>
<div>be stacked on top of another (e.g. osd-memfs spilling to osd-ldiskfs</d=
iv>
<div>on NVMe or HDD).</div></div></blockquote><div><br></div><div>Yeah the m=
ajor difference is that this spill device is not a fully functional OSD beca=
use we will support s3fs and gcsfuse, which means they won=E2=80=99t work wi=
th OFD on its own. We can discuss this further.</div><div><br></div><div>I c=
reated a PR at&nbsp;<a href=3D"https://review.whamcloud.com/c/fs/lustre-rele=
ase/+/62171" style=3D"font-family: &quot;Times New Roman&quot;; -webkit-text=
-stroke-color: rgb(0, 0, 238);">https://review.whamcloud.com/c/fs/lustre-rel=
ease/+/62171</a>&nbsp;and we can discuss over there if it is easier.</div><b=
r><blockquote type=3D"cite"><div dir=3D"ltr">
<div><br>
</div>
<div>I haven't looked into the details, but the state machine for managing</=
div>
<div>the spill device objects seems similar to FLR mirror files, and using</=
div>
<div>the existing LOV EA layout on the OST objects would reduce the</div>
<div>amount of dedicated tools that need to be developed to access such</div=
>
<div>files.</div></div></blockquote><div><br></div><div>That would be comple=
x by exporting those information to Lustre stack because we will have anothe=
r entity that can initiate layout change from OST. Please have a look at the=
 design and we can discuss if that approach is reasonable.</div><br><blockqu=
ote type=3D"cite"><div dir=3D"ltr">
<div><br>
</div>
<div>This seems similar to having the LOD layer split operations between</di=
v>
<div>a local OSD and a remote OSP, but it could split operations over</div>
<div>two local OSD devices.</div>
<div><br>
</div>
<div>The other thing of interest in the other direction is the log-structure=
d</div>
<div>writes to migrated files, which might be useful for FLR mirrored or</di=
v>
<div>EC files. &nbsp;This would allow replaying partial overwrites of existi=
ng</div>
<div>files into the other mirrors/EC at a later time.</div></div></blockquot=
e><div><br></div><div>Yes, by remembering this in the hot tier so that resyn=
c will be much less expensive.</div><br><blockquote type=3D"cite"><div dir=3D=
"ltr">
<div><br>
<blockquote type=3D"cite">
<div>
<div># Spilling Device Proposal for Lustre OSD<br>
<br>
## Introduction<br>
<br>
Spilling device is a private block device to an OSD in Lustre. It<br>
allows an OSD to migrate infrequently accessed data objects to this<br>
device. The key distinction between popular tiered storage is that it<br>
only has a local view of the objects in a local OSD. Consequently, it<br>
should make quick and accurate decisions based on the recent access<br>
pattern. Only data objects can be spilled into the spilling device,<br>
while metadata objects, such as OI namespace and last objid, remain in<br>
the OSD permanently. This implies that the spilling device for OSD is<br>
only applicable to OST OSDs. By design, the size of an OSD should be<br>
sufficient to store the entire local workset, for instance, all the<br>
data for an AI training job. A typical configuration would involve a<br>
1TB SSD OSD with 10TB of HDD as a spilling device.<br>
<br>
Generic Lustre utilities won=E2=80=99t be able to directly access spilling<b=
r>
devices. For example, **lfs df** will only display the capacity of the<br>
OSD device, while the capacity of the spilling device can be accessed<br>
using specific options.<br>
</div>
</div>
</blockquote>
<div><br>
</div>
It should be possible to pass an extra OS_STATE_STATFS flag to</div>
<div>return the extra capacity of the spill device in statfs()/lfs df output=
.</div>
<div><br>
<blockquote type=3D"cite">
<div>
<div>OSDs will access spilling devices through VFS interfaces in the kernel<=
br>
space. Therefore, the spilling device must be mountable into the<br>
kernel namespace. Initially, only HDD is supported, and the<br>
implementation can be extended to S3 and GCS using s3fs and gcsfuse<br>
respectively in the future.<br>
<br>
## Architecture<br>
<br>
When an OST object is spilled, it leaves a zero-lengthed stub object<br>
with a special EA, called spill-ea, in the OSD. The spill-ea is used<br>
to track the status of the object in the OSD and also store the<br>
metadata of the spilled object in the spilling device.<br>
<br>
Status of the object:<br>
- **MIGRATING**: The object data is being copied to the spilled object.<br>
- **MIGRATED**: The object data exists in both the OSD and the<br>
spilling device, and the contents are synchronized.<br>
- **RELEASED**: The object data is only in the spilling device, and it<br>
leaves a stub object in the OSD.<br>
- **DIRTY**: The object is released, but it has been written to<br>
afterward, so the OSD retains some up-to-date data.<br>
<br>
**Migrating**<br>
<br>
Migration involves copying data into the spilling device. A daemon<br>
process in the OSD continuously scans candidates for migration. The<br>
typical policy for migration is based on the last access time and size<br>
of the objects. For instance, if an object hasn=E2=80=99t been accessed in t=
he<br>
past day and its size exceeds 10MB, it will create an object in the<br>
spilling device and copy its contents over.<br>
<br>
There=E2=80=99s no on-demand migration feature. If there=E2=80=99s no availa=
ble space<br>
while a large chunk of data is being written, the system will return<br>
ENOSPC to the client. This simplifies the granting mechanism on the<br>
OFD significantly. Another reason for this approach is that writing<br>
performance is more predictable. Otherwise, the system might have to<br>
wait for an object to be migrated on demand, leading to much higher<br>
latency.<br>
<br>
**Releasing**<br>
<br>
Once the data is migrated, the daemon can release the object by<br>
truncating it in the OSD and setting the spill-ea status to<br>
**RELEASED**, atomically.<br>
<br>
Typically, an object is released only when the OSD=E2=80=99s available space=
<br>
becomes limited. This allows us to keep as much data as possible in<br>
the OSD.<br>
<br>
**Restoring**<br>
<br>
Restoring involves copying data back to the OSD device. It=E2=80=99s trigger=
ed<br>
by reading from or writing to a released object and is managed by the<br>
daemon, so it doesn=E2=80=99t interfere with the critical code path handling=
<br>
read and write operations from the OFD.<br>
<br>
When restoring, the object data is first copied to a temporary file<br>
(`O_TMPFILE`). Afterward, it=E2=80=99s renamed to switch the inode in OI and=
<br>
reset the spill-ea status atomically.<br>
<br>
As mentioned earlier, the spilling device is operated with standard<br>
VFS interfaces. Therefore, the OSD can directly read and write the<br>
object in the spilling device. We tend to read a released file<br>
directly in the first few reads. Writing is handled separately and<br>
will be covered later.<br>
<br>
Maintaining a synchronized state between two systems is a challenge.<br>
We=E2=80=99ll leverage llog extensively to achieve this.<br>
<br>
## Operations Handling<br>
<br>
**write**<br>
<br>
If an object lacks a spill EA, it means there=E2=80=99s no spilled object in=
<br>
the spilling device. In such cases, the write operation proceeds<br>
normally.<br>
<br>
If an object is in the **MIGRATING** or **MIGRATED** state, it writes<br>
directly to the object and deletes the spill EA by writing llog.<br>
<br>
If an object is in the **RELEASED** state, it writes the data to the<br>
object in log-structured format and sets its status to **DIRTY**.<br>
<br>
If an object is in the **DIRTY** state, it appends a new log entry to<br>
the object. If the number of logs exceeds a predefined limit, it<br>
triggers a restoration process.<br>
<br>
**read**<br>
<br>
If an object lacks a spill EA, it means there=E2=80=99s no spilled object in=
<br>
the spilling device. In such cases, the read operation proceeds<br>
normally.<br>
<br>
If an object is in the **MIGRATING** or **MIGRATED**, it=E2=80=99s read dire=
ctly.<br>
<br>
If an object is in the **DIRTY** state, it checks if the read range<br>
overlaps with the entries in the log.<br>
<br>
If an object is in the **RELEASED** state, it reads the data directly<br>
from the spilled object. If the number of reads to this object exceeds<br>
a predefined limit, it initiates a restoration process and sets the<br>
object=E2=80=99s status to **MIGRATED**.<br>
<br>
**truncate and unlink**<br>
<br>
If an object has a spill EA and is being truncated or deleted, it<br>
writes an llog entry to ensure the spilled object is eventually<br>
deleted.<br>
<br>
**migrate**<br>
<br>
Before initiating the migration of an object, it=E2=80=99s crucial to make t=
he<br>
spilled object a known state in order to prevent remote object<br>
leakage. Therefore, it=E2=80=99s essential to set the spill EA first and the=
n<br>
create the spilled object after the transaction is committed. The<br>
challenging aspect is that it's not possible to have any information<br>
about the spilled object before its creation.<br>
<br>
We decided to store the object in a known path. For instance, object<br>
paths like `&lt;fsname&gt;/OST&lt;index&gt;/&lt;oid:0:2&gt;/&lt;oid:2:&gt;` s=
eem reasonable.<br>
This also means that the OSD must own the spilling device entirely.<br>
Having foreign objects would cause confusion.<br>
</div>
</div>
</blockquote>
<div><br>
</div>
<div>While my preference is that we use a regular OSD for the spill storage,=
</div>
I don't see why the exclusive access to this directory tree also needs</div>=

<div>exclusive use to the whole block device? &nbsp;As long as the directory=
</div>
<div>itself is not being modified by other applications then it should be OK=
?</div></div></blockquote><div><br></div>That=E2=80=99s right. I just don=E2=
=80=99t want someone accidentally create a conflicting file. Even though it=E2=
=80=99s unlikely. It=E2=80=99s easier to just solely own it.<div><br></div><=
div>Btw, the design will lead to an implementation that a single gcs bucket i=
s used by all OSDs in a Lustre instance.<br><div><br><blockquote type=3D"cit=
e"><div dir=3D"ltr">
<div><br>
<blockquote type=3D"cite">
<div>
<div>**restore**<br>
<br>
Restoration will use a temporary file, which is essentially a file<br>
created under an orphan directory. Once the copy from spilled object<br>
is complete, it will also deal the write log entries in the original<br>
object. If everything is done, it will rename the temporary file and<br>
the corresponding OI file, and append a log entry to delete the<br>
spilled object, all in a local transaction.<br>
<br>
## Implementation<br>
<br>
OSD APIs are well-maintained and provide dedicated APIs for object<br>
manipulation and body operations to interact with object content.<br>
Spill device configuration &nbsp;will be stored in the configuration log so<=
br>
that the OSD will know if it has spilling device in the device<br>
initialization.<br>
<br>
If a spill device exists for an OSD, the object and body operations<br>
will be redirected to a new set of OSD APIs. These APIs essentially<br>
check for the existence of a spill EA before proceeding with any<br>
operations. If local objects are used, the original OSD APIs will<br>
still be invoked.<br>
<br>
A new set of Lustre utilities will be developed to display information<br>
about spill devices.<br>
<br>
## Conclusion<br>
<br>
This solution gives a possible solution trying to address the<br>
painpoints of prevalent tiered storage using mirroring, where a<br>
full-flavoured policy engine has to run on dedicated clients, and<br>
deliver better performance than block-level cache with dmcache, where<br>
recovery time is lengthy if the cache size is huge.<br>
</div>
</div>
</blockquote>
</div>
<br>
<div>
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); l=
etter-spacing: normal; text-align: start; text-indent: 0px; text-transform: n=
one; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px;=
 text-decoration: none; overflow-wrap: break-word; -webkit-nbsp-mode: space;=
 line-break: after-white-space;">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); l=
etter-spacing: normal; text-align: start; text-indent: 0px; text-transform: n=
one; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: 0px;=
 text-decoration: none; overflow-wrap: break-word; -webkit-nbsp-mode: space;=
 line-break: after-white-space;">
<div>Cheers, Andreas</div>
<div>=E2=80=94</div>
<div>Andreas Dilger</div>
<div>Lustre Principal Architect</div>
<div>Whamcloud/DDN</div>
</div>
<br class=3D"Apple-interchange-newline">
</div>
<br class=3D"Apple-interchange-newline">
<br class=3D"Apple-interchange-newline">
</div>
<br>


</div></blockquote></div></div></body></html>=

--Apple-Mail-1D37317C-1ECD-459D-B3FB-FE98DD41B620--

--===============5359721564606086800==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============5359721564606086800==--
