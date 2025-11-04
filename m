Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D86A4CCF9E3
	for <lustre-devel@archiver.kernel.org>; Tue,  4 Nov 2025 17:54:58 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1GJK1jVVz20fJ;
	Tue, 04 Nov 2025 09:52:49 -0800 (PST)
Received: from mail-oa1-f49.google.com (mail-oa1-f49.google.com
 [209.85.160.49])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1GHk6tZkz20dp
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 09:52:18 -0800 (PST)
Received: by mail-oa1-f49.google.com with SMTP id
 586e51a60fabf-3c9c379af8aso50780fac.1
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 09:52:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=google.com; s=20230601; t=1762278716; x=1762883516; darn=lists.lustre.org;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:from:to:cc:subject:date:message-id:reply-to;
 bh=6U19zaqPjuqAryR3Q/BjAB2YbhsL1a/lB6/p5D07l/o=;
 b=VPfV1Ef5MD9MMHQn+31XD79lTjQB8NrhZXMVgp8ttM4vYK+oxaJU7jOlT5oXZZWPH/
 Lup1pkEP0ocaoatd0ZYay8Hc5Gewe6u8cqIfjAOgFn5P/AYP/ONZsV/nyzYcJxKm2tV9
 5KWSQBtW5/sP27WOGX1lfBQATLbpUNGyYm+lPybJiq/VFZTh7xppilEua2/FQTWtUW4X
 yL+sFr/CxT46OKlITqS8fX4wUA4vtInVcEJKQCKpRsTna79ARzjBjawW52FfS5P3WM+b
 e8Ojvl2d9H5QX2wbMcxYo2ny9EW470PVCD8UwmcEsMAs5qvlEpo2hIeQmlKxDz/BstTI
 /Deg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1762278716; x=1762883516;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
 :reply-to;
 bh=6U19zaqPjuqAryR3Q/BjAB2YbhsL1a/lB6/p5D07l/o=;
 b=VdgjlE8YoCtekL0gkKB5UZBscnVnFuRTeq5qhbDOb3c4m4hP8rkE1NaIUO0KT6Dz5i
 J7ydHXMPwGtnS4OJ1vFG0+fyJ2GITj1zBLjoAc3p4m8f7EEkE+75f2+90FlyNwuxiXQ5
 LiJTx4r3tQs7coiag7aGsLp1ILMbMa7bFBXgnOL9OgjH+PnW97b0LJECdonF0YVqq9TZ
 t2HWXCEJkUc/qtbB+sCtAX0hnfYGUFJ4WC3grcuuzxO5jzKXw6+wgxbo4295hrhW3egr
 SOiZlKqnc5qXIudU5yfkpk4Eru7Q+9lsW1oI3paEkPFjM+3wQHYgJLz8Necr6MnnWft8
 aLyg==
X-Forwarded-Encrypted: i=1;
 AJvYcCWy5Uyl6E3se7cqzjNJbsBHzuSXr7bmZpbXk1Xz5SFQhVqdeqZi0xZ1iN+heyf9+epvWsZgfRnM1t9FqS0=@lists.lustre.org
X-Gm-Message-State: AOJu0Yy66MCoxfOEZ8wWDAIldL40TnyYTV5NGdPnMVmom4yr25zjdxi1
 fBvtaK3sO9Mwlx/XoOz8bixnPCzeSS5IgGAq0JKILoqs8j/9OlCL7c+dJLwl+UVZTOPyz0yQbjY
 a7u8loT+HLi/v3Qm+kpq1x1psrIS7TNXSDbVkDHMM
X-Gm-Gg: ASbGnctc3NUF9E0wzOEmGEONSykknBsiXKaTqcm1CJNzEirHoCbZ28NVlky7IsgwPOd
 qovSzIoad/oaxMMbMVjKDFtA6NGIty3kTU7F6d3HsJ4/J/G3fpg4KJ6tkdre1wPzbBk8KQcdABH
 NE3SnBYO5FKnxaxkfRv5TF1+i2lpyEC2DT7b7Jghx0U52xYzvGYzKmlImlicPIPM78aiL4epTyq
 /5bF+SJqqNcfC+Ti0gsKYEBo0ThfkfzfWrBNx3TnxRtPtwn/0AaLliCGSBCXeo5AKbR9VF6hICQ
 gfA5TemN+KIYTMK5hNaYlSsedM+L
X-Google-Smtp-Source: AGHT+IEqLAZui7CFTY/F4Jc4k1OGDJnb6AhlCBwGo2VLTmszHXXReiFGVeYBgoOPmox+xFOW8u7UJyQSUBvOppRZjpo=
X-Received: by 2002:a05:6871:ac0a:b0:3d2:7f44:c161 with SMTP id
 586e51a60fabf-3e189e95f84mr228232fac.13.1762278716046; Tue, 04 Nov 2025
 09:51:56 -0800 (PST)
MIME-Version: 1.0
References: <e2c69a503e80f3ba59d69f093bc8df519cdd7f66.camel@whamcloud.com>
 <BFDDAAED-BA9A-44DB-BCD0-B3B84E652FE7@gmail.com>
 <c6c016567a02f857303eedb9a4af6b5831c2c818.camel@whamcloud.com>
 <CAEp8vpiZ8iKRbjy8GYKdXFjsycW=a48baOXxUnSP7uE+Xf5cYw@mail.gmail.com>
 <e31f82d56f034cb325ae29a08280122711078a97.camel@whamcloud.com>
 <54DC145F-B965-4B04-8B03-473A845892F6@ddn.com>
In-Reply-To: <54DC145F-B965-4B04-8B03-473A845892F6@ddn.com>
Date: Tue, 4 Nov 2025 09:51:44 -0800
X-Gm-Features: AWmQ_bmdQ_Ieqt5czHocIv4OrcF9uEjagw-BRXVnXf03ogVT_l1DWvA8cIlCDz8
Message-ID: <CAEp8vpjcGobjG-vrHihY3mPB7Lq7a2Hv+-FSPJUVY6R2_w+h_A@mail.gmail.com>
To: Andreas Dilger <adilger@ddn.com>
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
Reply-To: Jinshan Xiong <jinshanx@google.com>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============2101585686254843481=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============2101585686254843481==
Content-Type: multipart/alternative; boundary="000000000000de642b0642c87c23"

--000000000000de642b0642c87c23
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 4, 2025 at 8:37=E2=80=AFAM Andreas Dilger <adilger@ddn.com> wro=
te:

> On Nov 3, 2025, at 18:58, Oleg Drokin via lustre-devel <
> lustre-devel@lists.lustre.org> wrote:
>
>
> On Mon, 2025-11-03 at 16:33 -0800, Jinshan Xiong wrote:
>
> I guess users won't have 1PB OSTs, will they?
>
>
> There probably are already? NASA has a known 0.5P OST configuration:
>
> https://www.nas.nasa.gov/hecc/support/kb/lustre-progressive-file-layout-(=
pfl)-with-ssd-and-hdd-pools_680.html#:~:text=3DThe%20available%20SSD%20spac=
e%20in%20each%20filesystem,decimal%20(far%20right)%20labels%20of%20each%20O=
ST
>
>
> In order to maximize rebuild performance for declustered parity RAID,
> there are OSTs in production with 90x20TB HDDs =3D 1.4 PB today,
> and requests to have even larger OSTs.  We've done a bunch of work
> to improve huge ldiskfs OST performance, including the hybrid OST
> patches like https://review.whamcloud.com/51625 ("LU-16750 ldiskfs:
> optimize metadata allocation for hybrid LUNs"), but there could still
> be further improvements in supporting such large OSTs.
>

Since they are already HDDs, this feature won't apply because it makes no
sense for them.

For SSDs, cloud users prefer to spread them across multiple servers to
fully utilize disk bandwidth. Bandwidth is likely the first priority. Once
that's solved, they want larger capacity so they don't have to load new
worksets each time.



>
> Cheers, Andreas
> =E2=80=94
> Andreas Dilger
> Lustre Principal Architect
> Whamcloud/DDN
>
>
>
>
>

--000000000000de642b0642c87c23
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><br><div class=3D"gmail_quote g=
mail_quote_container"><div dir=3D"ltr" class=3D"gmail_attr">On Tue, Nov 4, =
2025 at 8:37=E2=80=AFAM Andreas Dilger &lt;<a href=3D"mailto:adilger@ddn.co=
m">adilger@ddn.com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote=
" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);=
padding-left:1ex">



<div>
On Nov 3, 2025, at 18:58, Oleg Drokin via lustre-devel &lt;<a href=3D"mailt=
o:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-devel@lists.lustr=
e.org</a>&gt; wrote:<br>
<div>
<blockquote type=3D"cite"><br>
<div><span style=3D"font-family:Helvetica;font-size:14px;font-style:normal;=
font-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:s=
tart;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0p=
x;text-decoration:none;float:none;display:inline">On
 Mon, 2025-11-03 at 16:33 -0800, Jinshan Xiong wrote:</span><br style=3D"fo=
nt-family:Helvetica;font-size:14px;font-style:normal;font-variant-caps:norm=
al;font-weight:400;letter-spacing:normal;text-align:start;text-indent:0px;t=
ext-transform:none;white-space:normal;word-spacing:0px;text-decoration:none=
">
<blockquote type=3D"cite" style=3D"font-family:Helvetica;font-size:14px;fon=
t-style:normal;font-variant-caps:normal;font-weight:400;letter-spacing:norm=
al;text-align:start;text-indent:0px;text-transform:none;white-space:normal;=
word-spacing:0px;text-decoration:none">
I guess users won&#39;t have 1PB OSTs, will they?<br>
</blockquote>
<br style=3D"font-family:Helvetica;font-size:14px;font-style:normal;font-va=
riant-caps:normal;font-weight:400;letter-spacing:normal;text-align:start;te=
xt-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;text-=
decoration:none">
<span style=3D"font-family:Helvetica;font-size:14px;font-style:normal;font-=
variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:start;=
text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;tex=
t-decoration:none;float:none;display:inline">There
 probably are already? NASA has a known 0.5P OST configuration:</span><br s=
tyle=3D"font-family:Helvetica;font-size:14px;font-style:normal;font-variant=
-caps:normal;font-weight:400;letter-spacing:normal;text-align:start;text-in=
dent:0px;text-transform:none;white-space:normal;word-spacing:0px;text-decor=
ation:none">
<a href=3D"https://www.nas.nasa.gov/hecc/support/kb/lustre-progressive-file=
-layout-(pfl)-with-ssd-and-hdd-pools_680.html#:~:text=3DThe%20available%20S=
SD%20space%20in%20each%20filesystem,decimal%20(far%20right)%20labels%20of%2=
0each%20OST" style=3D"font-family:Helvetica;font-size:14px;font-style:norma=
l;font-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align=
:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing:=
0px" target=3D"_blank">https://www.nas.nasa.gov/hecc/support/kb/lustre-prog=
ressive-file-layout-(pfl)-with-ssd-and-hdd-pools_680.html#:~:text=3DThe%20a=
vailable%20SSD%20space%20in%20each%20filesystem,decimal%20(far%20right)%20l=
abels%20of%20each%20OST</a><br style=3D"font-family:Helvetica;font-size:14p=
x;font-style:normal;font-variant-caps:normal;font-weight:400;letter-spacing=
:normal;text-align:start;text-indent:0px;text-transform:none;white-space:no=
rmal;word-spacing:0px;text-decoration:none">
</div>
</blockquote>
</div>
<div><br>
</div>
In order to maximize rebuild performance for declustered parity RAID,
<div>there are OSTs in production with 90x20TB HDDs =3D 1.4 PB today,</div>
<div>and requests to have even larger OSTs.=C2=A0 We&#39;ve done a bunch of=
 work</div>
<div>to improve huge ldiskfs OST performance, including the hybrid OST</div=
>
<div>patches like=C2=A0<a href=3D"https://review.whamcloud.com/51625" targe=
t=3D"_blank">https://review.whamcloud.com/51625</a>=C2=A0(&quot;LU-16750 ld=
iskfs:</div>
<div>optimize metadata allocation for hybrid LUNs&quot;), but there could s=
till</div>
<div>be further improvements in supporting such large OSTs.<br></div></div>=
</blockquote><div><br></div><div>Since they are already HDDs, this feature =
won&#39;t apply because it makes no sense for them.</div><div><br></div><di=
v>For SSDs, cloud users prefer to spread them across multiple servers to fu=
lly utilize disk bandwidth. Bandwidth is likely the first priority. Once th=
at&#39;s solved, they want larger capacity so they don&#39;t have to load n=
ew worksets each time.=C2=A0</div><div><br></div><div>=C2=A0</div><blockquo=
te class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px =
solid rgb(204,204,204);padding-left:1ex"><div><div>
<div><br>
<div>
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div>Cheers, Andreas</div>
<div>=E2=80=94</div>
<div>Andreas Dilger</div>
<div>Lustre Principal Architect</div>
<div>Whamcloud/DDN</div>
</div>
<br>
</div>
<br>
<br>
</div>
<br>
</div>
</div>
</div>

</blockquote></div></div>

--000000000000de642b0642c87c23--

--===============2101585686254843481==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============2101585686254843481==--
