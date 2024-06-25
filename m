Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C3B8AC2BBCA
	for <lustre-devel@archiver.kernel.org>; Tue, 25 Jun 2024 11:38:53 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4W7jXB0rbQz1y78;
	Tue, 25 Jun 2024 04:38:50 -0700 (PDT)
Received: from mail-yb1-f173.google.com (mail-yb1-f173.google.com
 [209.85.219.173])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4W7jX770pcz1wgt
 for <lustre-devel@lists.lustre.org>; Tue, 25 Jun 2024 04:38:47 -0700 (PDT)
Received: by mail-yb1-f173.google.com with SMTP id
 3f1490d57ef6-dfac121b6a6so3927085276.0
 for <lustre-devel@lists.lustre.org>; Tue, 25 Jun 2024 04:38:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=charlotte.edu; s=google; t=1719315527; x=1719920327; darn=lists.lustre.org; 
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:from:to:cc:subject:date:message-id:reply-to;
 bh=rmbx2G4P8viijkbEPP/gxBQMArfazZaae8Iy1ad1vNw=;
 b=WyR5srJ/mkoAtoM+4ElcpSJdM78nmUhYSLmSjjzzemHv5+YN6/2np0MLpmxcfcP2hr
 tZMNtop6F1qrDDLNxpL6Rp06gnGa5ypAXVdFoXLzLg5TtueMA2QC0pyqCWBJU91JZIbM
 iX4Dt+5rGaUD9kWbxPA8NfB1OoSMdUEV82zTB1r8TVcjF6GGHBLDfTJpn5u7T24fAfz9
 RpvJrQW9rtZ3mPunlCXdgIJmLezYS9wvvLeBShm0nQSGFwS/LY/ZHpukKEbKm8+AI7f3
 Lj6JS2807Y9BrOs+nNSjVg7L+QIL7UeUJFGA52JlvQf8MAn1SXYcXUClOzw8KrfrCFPb
 Ro6A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1719315527; x=1719920327;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
 :reply-to;
 bh=rmbx2G4P8viijkbEPP/gxBQMArfazZaae8Iy1ad1vNw=;
 b=SPedx6UGLxT/KKaJD1VtauDPG/74a1pcddohKdKyOTby/H1aE269G9RxEJBt6DavdL
 Hnmy1Yf66LDncJfu4wlJlF1OTfJz2JSAFJdBHmeKOaaBmhRBD/CI4vPirjAP+exnNszo
 WtOJfTU/BXzwzv+Gqdf3OPgD2NGqsvyx0dux5bedQ2966UuVBiPos+yRLq4/2a22bkWz
 Z4kWWxtAhmzJFMJywrA+38ct0eWf/iA/GTFgfl5o1mH1kUD1T1thJU8OyfWmvWy2yZri
 E3RYQn2C3PByr/zyNxF72Q3jETRKS5ikC7xblbi00LMTG7PhtCZn40HY3I+oSHA8bzMo
 CqfA==
X-Gm-Message-State: AOJu0YwwfLJ9zXfr0iPmdZuUslpyClMM4eecYr/Ng3jENzLeDLmlGd+I
 wNQi/QcB2gBrHwWKvK40ibZpxUefEExboGVewuIJnnwnLDr06tu5TyBXj39TmepDTXISfT3LA9S
 BQ0yDFCQGLJaUcju8JtiizXPsU0BLj0P6UPHsk9gskddd4CKmA18=
X-Google-Smtp-Source: AGHT+IEJepa3xL0rl+XH6GgQRcnhmC+WDHGs6BTXU3LQEdEf0GaPvu1/gOuaXcBA28v/GYhtCOg2mHF36JdWaqzdWac=
X-Received: by 2002:a25:add5:0:b0:e03:2333:a6f0 with SMTP id
 3f1490d57ef6-e032333a7c6mr1076198276.10.1719315526768; Tue, 25 Jun 2024
 04:38:46 -0700 (PDT)
MIME-Version: 1.0
References: <CACyzrcS7iBzxmzUqLY7vo0gE_=D3v+33HZ_gGeYe6rgkv0YYOg@mail.gmail.com>
 <D862AC2B-4FFA-4F82-992F-246E24BF4C72@whamcloud.com>
In-Reply-To: <D862AC2B-4FFA-4F82-992F-246E24BF4C72@whamcloud.com>
Date: Tue, 25 Jun 2024 07:38:34 -0400
Message-ID: <CACyzrcSdiKfskxN_AViRAUU1YKTsYpEFLaRVfOyb8GYpTm=GHQ@mail.gmail.com>
To: Andreas Dilger <adilger@whamcloud.com>
Cc: lustre-devel <lustre-devel@lists.lustre.org>
Subject: Re: [lustre-devel] [EXTERNAL] Re: Inquiry Regarding Checksum
 Support for Lustre Extended Attributes
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
From: Saisha Kamat via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Saisha Kamat <skamat1@charlotte.edu>
Content-Type: multipart/mixed; boundary="===============6887558290089066181=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============6887558290089066181==
Content-Type: multipart/alternative; boundary="0000000000003b82d4061bb557f5"

--0000000000003b82d4061bb557f5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello,

Thank you for your previous response.

I have a question regarding the integration of ext4 metadata checksumming
with Lustre. Specifically, I am interested in enabling metadata check
summing on a Lustre file system backed by ldiskfs.
For context, I have a Lustre filesystem on /dev/sda, which is formatted as
ldiskfs (MDS). I used the command *tune2fs -O metadata_csum /dev/sda *to
enable metadata checksumming. However, after enabling this feature, I am
unable to mount the Lustre filesystem (MDS node).
Could you please advise if there is a way to enable metadata check summing
on the underlying ext4 filesystem and successfully mount the Lustre MDS or
OSS nodes on the same device? Are there specific steps or configurations
required to achieve this?

Thank you for your assistance and time.

Thanks and regards,
Saisha

On Wed, Jun 12, 2024 at 6:27=E2=80=AFPM Andreas Dilger <adilger@whamcloud.c=
om>
wrote:

> [*Caution*: Email from External Sender. Do not click or open links or
> attachments unless you know this sender.]
>   On Jun 12, 2024, at 12:35, Saisha Kamat via lustre-devel <
> lustre-devel@lists.lustre.org> wrote:
>
>
> Hello,
>
> I hope this email finds you well.
>
> My name is Saisha, and I am currently pursuing my Ph.D. at UNC-Charlotte,
> with a focus on research related to the Lustre File System. As part of my
> project, I am exploring the possibility of utilizing checksums to verify
> Lustre extended attributes.
>
> My understanding is that the ext4 file system supports checksums for
> extended attributes (xattrs). However, I am interested in whether this
> functionality extends to Lustre as well.
>
>
> Yes, the ext4 (and ZFS) xattr values have checksums.  No, the xattr
> checksums are neither managed or verified by Lustre, and only come into
> effect when they are passed on to the backing filesystem.  Conceivably, i=
t
> would be possible to have a checksum (e.g. crc32c) for the xattr values i=
n
> the MDS_GETXATTR and MDS_SETXATTR RPCs, if this is something you are
> interested to contribute.
>
> This could probably be done by overloading one of the 32-bit fields in th=
e
> mdt_body for getxattr, and one in mdt_rec_reint for setxattr, but there i=
s
> also "opportunistic" xattr prefetching done in the lookup RPC, so that
> would need to be covered as well.
>
> Also, the checksum would also need to be kept with the xattrs in cache an=
d
> verified on access, otherwise they could become corrupted in memory after
> the RPC processing had completed.
>
> Finally, there is no interface to specify or verify the xattr checksum in
> the syscall interface, so there can be no guarantee that the data supplie=
d
> in the setxattr is correct, or remains correct after supplied to getxattr=
,
> but the window there is very small.
>
> Cheers, Andreas
>
> I would greatly appreciate it if you could provide some insights or direc=
t
> me to relevant documentation on this matter. Any information or guidance
> you can offer would be invaluable to my research.
>
> Thank you very much for your time and assistance.
>
> Thanks and Regards,
> Saisha
> _______________________________________________
> lustre-devel mailing list
> lustre-devel@lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
>
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Principal Architect
> Whamcloud
>
>
>
>
>
>
>
>

--0000000000003b82d4061bb557f5
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hello,<br><br>Thank you for your previous response.<br><br=
>I have a question regarding the integration of ext4 metadata checksumming =
with Lustre. Specifically, I am interested in enabling metadata check summi=
ng on a Lustre file system backed by ldiskfs.<br>For context, I have a Lust=
re filesystem on /dev/sda, which is formatted as ldiskfs (MDS). I used the =
command <b><i>tune2fs -O metadata_csum /dev/sda </i></b>to enable metadata =
checksumming. However, after enabling this feature, I am unable to mount th=
e Lustre filesystem (MDS node).<div>Could you please advise if there is a w=
ay to enable metadata check summing on the underlying ext4 filesystem and s=
uccessfully mount the Lustre MDS or OSS nodes on the same device? Are there=
 specific steps or configurations required to achieve this?<br><br>Thank yo=
u for your assistance and time.=C2=A0</div><div><br>Thanks and=C2=A0regards=
,</div><div>Saisha</div></div><br><div class=3D"gmail_quote"><div dir=3D"lt=
r" class=3D"gmail_attr">On Wed, Jun 12, 2024 at 6:27=E2=80=AFPM Andreas Dil=
ger &lt;<a href=3D"mailto:adilger@whamcloud.com">adilger@whamcloud.com</a>&=
gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0=
px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">



<div style=3D"overflow-wrap: break-word;">[<strong><font color=3D"red">Caut=
ion</font></strong>: Email from External Sender. Do not click or open links=
 or attachments unless you know this sender.]<br><span>=C2=A0</span>
On Jun 12, 2024, at 12:35, Saisha Kamat via lustre-devel &lt;<a href=3D"mai=
lto:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-devel@lists.lus=
tre.org</a>&gt; wrote:<br>
<div>
<blockquote type=3D"cite"><br>
<div>
<div dir=3D"ltr">Hello,<br>
<br>
I hope this email finds you well.<br>
<br>
My name is Saisha, and I am currently pursuing my Ph.D. at UNC-Charlotte, w=
ith a focus on research related to the Lustre File System. As part of my pr=
oject, I am exploring the possibility of utilizing checksums to verify Lust=
re extended attributes.<br>
<br>
My understanding is that the ext4 file system supports checksums for extend=
ed attributes (xattrs). However, I am interested in whether this functional=
ity extends to Lustre as well.<br>
</div>
</div>
</blockquote>
<div><br>
</div>
Yes, the ext4 (and ZFS) xattr values have checksums.=C2=A0 No, the xattr ch=
ecksums are neither managed or verified by Lustre, and only come into effec=
t when they are passed on to the backing filesystem.=C2=A0 Conceivably, it =
would be possible to have a checksum (e.g.
 crc32c) for the xattr values in the MDS_GETXATTR and MDS_SETXATTR RPCs, if=
 this is something you are interested to contribute.</div>
<div><br>
</div>
<div>This could probably be done by overloading one of the 32-bit fields in=
 the mdt_body for getxattr, and one in mdt_rec_reint for setxattr, but ther=
e is also &quot;opportunistic&quot; xattr prefetching done in the lookup RP=
C, so that would need to be covered as well.</div>
<div><br>
</div>
<div>Also, the checksum would also need to be kept with the xattrs in cache=
 and verified on access, otherwise they could become corrupted in memory af=
ter the RPC processing had completed.</div>
<div><br>
</div>
<div>Finally, there is no interface to specify or verify the xattr checksum=
 in the syscall interface, so there can be no guarantee that the data suppl=
ied in the setxattr is correct, or remains correct after supplied to getxat=
tr, but the window there is very
 small.</div>
<div><br>
</div>
<div>Cheers, Andreas</div>
<div><br>
<blockquote type=3D"cite">
<div>
<div dir=3D"ltr">I would greatly appreciate it if you could provide some in=
sights or direct me to relevant documentation on this matter. Any informati=
on or guidance you can offer would be invaluable to my research.<br>
<br>
Thank you very much for your time and assistance.
<div><br>
</div>
<div>Thanks and Regards,</div>
<div>Saisha</div>
</div>
_______________________________________________<br>
lustre-devel mailing list<br>
<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-d=
evel@lists.lustre.org</a><br>
<a href=3D"http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org" ta=
rget=3D"_blank">http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.or=
g</a><br>
</div>
</blockquote>
</div>
<br>
<div>
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div>Cheers, Andreas</div>
<div>--</div>
<div>Andreas Dilger</div>
<div>Lustre=C2=A0Principal Architect</div>
<div>Whamcloud</div>
<div><br>
</div>
<div><br>
</div>
<div><br>
</div>
</div>
</div>
</div>
</div>
</div>
<br>
</div>
<br>
<br>
</div>
<br>
</div>

</blockquote></div>

--0000000000003b82d4061bb557f5--

--===============6887558290089066181==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6887558290089066181==--
