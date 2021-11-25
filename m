Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5C526C433EF
	for <lustre-devel@archiver.kernel.org>; Thu, 25 Nov 2021 01:25:37 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DC21F21EBCD;
	Wed, 24 Nov 2021 17:25:34 -0800 (PST)
Received: from mail-qk1-f182.google.com (mail-qk1-f182.google.com
 [209.85.222.182])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EDA04200485
 for <lustre-devel@lists.lustre.org>; Wed, 24 Nov 2021 17:25:32 -0800 (PST)
Received: by mail-qk1-f182.google.com with SMTP id t83so6953346qke.8
 for <lustre-devel@lists.lustre.org>; Wed, 24 Nov 2021 17:25:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=3MbbCcditwqDKWStyvUmWr4Ul5YnZdAeAWriSrFU3ZQ=;
 b=DZcKFGguq/vvogdelqNzFtIoAnVHJlXj286EpNSLgcGRgTXYCC8qV/KJQRTDhOeLf/
 P+CLk4BkwBKDYxQupkMme5eKZzNvg2wpytbIIFSUw+/JmhZW4J9cgr92vfkNRKiGzZNB
 bCpHum/9HGVyg3K4G0eLI0lRWg+VjpUtBZR06kab76pAM8X7HSf74sbCF8+KVi3Vd2PC
 uNSBP45y+yQB85s7bpyPyI0ZnlUaExxiE4OPLnxpZ1J1P4ClgEuxwYg6NZ37kYjUFJjp
 mdCo56dgzfVHkECNT+aKEXHhY4JamRSrEvwvSWHQG8ZiyDjzzwlfrMhZg7pNDJPrDjH7
 S5oQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=3MbbCcditwqDKWStyvUmWr4Ul5YnZdAeAWriSrFU3ZQ=;
 b=uXmp/sOHsyqOG2IOdtyIytFOCHSz74S4dcH+O4A34uz8SKaPOAM3wla2PzCOtwpZ8b
 z8hXsQIqEW4iUiNS22TcUDNevsA0yb9bYKD/flFnesFwOjlmcHdv8mthYkgF1/jR2gnO
 cH9CwzpqQUVvW1wkxjM/9CT14JfxkVeYsL7YYJkO/O4VZQRgkYDQRS1gk4XIOG6sI2od
 ucyCD10hQ6nGKiTgPDRJOq8jVl9L+gnj+mtOts5OxqfjFTRkMeRg7sWqRK3nDSwuk3zd
 kdu+J35LnR9/ukLrJPAQqQIr6Ly6foNWeIjU+lQyM5PrjXJaGWwBO2sMI417TtieguCC
 KWLQ==
X-Gm-Message-State: AOAM532SQWZOWZ5/hsyFE2l/ec3Dzz9IQbhzv7kY2XhAxRuvz2d/5rvt
 y0fCQER2IiUC6HX6ZsReq0zP0Pidgq0BSZPrnmQM61MJr26touZG
X-Google-Smtp-Source: ABdhPJyp9Ahy6bZ6HPMLM0F1+6HMqDKMdDBtj7kGvmm624oEZ058MHRzvp29LyLQwzcxM8WNvDcK1bKgs5+PWhJ/6B8=
X-Received: by 2002:a25:b70b:: with SMTP id t11mr2044177ybj.287.1637803532268; 
 Wed, 24 Nov 2021 17:25:32 -0800 (PST)
MIME-Version: 1.0
References: <CAKoKPbyin6b2CPT18YzEeY6JBRnWgmepS7B3ToSxsW_7nDmRqQ@mail.gmail.com>
 <B530F0D8-4446-452F-A513-32F42E8DFBA0@ddn.com>
In-Reply-To: <B530F0D8-4446-452F-A513-32F42E8DFBA0@ddn.com>
Date: Thu, 25 Nov 2021 09:24:56 +0800
Message-ID: <CAKoKPby7n-LGxs6Z_2Uzd9BuPymZDy+3FBqRMGDvVN32qn8OnA@mail.gmail.com>
To: Peter Jones <pjones@whamcloud.com>
Subject: Re: [lustre-devel] Arm client is not in CI?
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
From: Xinliang Liu via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Xinliang Liu <xinliang.liu@linaro.org>
Cc: "cloud-dev-request@op-lists.linaro.org"
 <cloud-dev-request@op-lists.linaro.org>,
 "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============7455216055659840185=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7455216055659840185==
Content-Type: multipart/alternative; boundary="000000000000c0cc3d05d192d9f6"

--000000000000c0cc3d05d192d9f6
Content-Type: text/plain; charset="UTF-8"

OK, thanks Peter.

On Wed, 24 Nov 2021 at 21:22, Peter Jones <pjones@whamcloud.com> wrote:

> I suspect that this is a temporary suspension relating to the lab
> relocation. Try again in a week or two.
>
>
>
> *arch | String or Array*
>
> Sets the architecture for the specified node type
>
> Valid values: x86_64, ppc64, aarch64 (architecture must have been built
> for patch)
>
>
>
>
>
> *From: *lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of
> Xinliang Liu via lustre-devel <lustre-devel@lists.lustre.org>
> *Reply-To: *Xinliang Liu <xinliang.liu@linaro.org>
> *Date: *Wednesday, November 24, 2021 at 1:45 AM
> *To: *"lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
> *Cc: *"cloud-dev-request@op-lists.linaro.org" <
> cloud-dev-request@op-lists.linaro.org>
> *Subject: *[lustre-devel] Arm client is not in CI?
>
>
>
> Hi,
>
> Recently, I find that Test-Parameters "clientarch=aarch64 " is not
> supported in CI yet.
>
> Any reason why arm client is removed? I have some patches which address
> arm client or server failed test cases to be landed.
>
>
>
> Here is the CI comment that says "clientarch=aarch64" is not supported:
>
> Which is copied from https://review.whamcloud.com/#/c/40758/
>
> ''
>
> Patch Set 15:
>
> Build 84492 (patch #15) will not be tested because: Unsupported build
> configurations were specified in the Test-Parameters:
>
> Test-Parameters line #1:
> - client: el8.3 - aarch64 - inkernel | lustre-reviews #84492
> Test-Parameters line #2:
> - client: el8.3 - aarch64 - inkernel | lustre-reviews #84492
> Test-Parameters line #3:
> - client: el8.3 - aarch64 - inkernel | lustre-reviews #84492
>
> Supported build configurations for lustre-reviews #84492:
> Clients
> - el7.8 - x86_64 - inkernel
> - el7.9 - x86_64 - inkernel
> - el8.3 - x86_64 - inkernel
> - el8.4 - x86_64 - inkernel
> - sles12sp5 - x86_64 - inkernel
> - sles15sp2 - x86_64 - inkernel
> - sles15sp3 - x86_64 - inkernel
> - ubuntu1804 - x86_64 - inkernel
> - ubuntu2004 - x86_64 - inkernel
> Servers
> - el7.8 - x86_64 - inkernel
> - el7.9 - x86_64 - inkernel
> - el8.3 - x86_64 - inkernel
> - el8.4 - x86_64 - inkernel
>
> "
>
>
>
> Thanks,
>
> Xinliang
>

--000000000000c0cc3d05d192d9f6
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">OK, thanks Peter.=C2=A0<br></div><br><div class=3D"gmail_q=
uote"><div dir=3D"ltr" class=3D"gmail_attr">On Wed, 24 Nov 2021 at 21:22, P=
eter Jones &lt;<a href=3D"mailto:pjones@whamcloud.com">pjones@whamcloud.com=
</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:=
0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">





<div lang=3D"EN-CA">
<div class=3D"gmail-m_-1266896689549948523WordSection1">
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt">I susp=
ect that this is a temporary suspension relating to the lab relocation. Try=
 again in a week or two.<u></u><u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt"><u></u=
>=C2=A0<u></u></span></p>
<p class=3D"MsoNormal" style=3D"background:rgb(247,247,247)"><b><span style=
=3D"font-size:10.5pt;font-family:&quot;Segoe UI&quot;;color:rgb(51,51,51)">=
arch | String or Array</span></b><span style=3D"font-size:10.5pt;font-famil=
y:&quot;Segoe UI&quot;;color:rgb(51,51,51)"><u></u><u></u></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:10.5pt;font-family:&quot;Se=
goe UI&quot;;color:rgb(51,51,51)">Sets the architecture for the specified n=
ode type<u></u><u></u></span></p>
<p class=3D"MsoNormal" style=3D"margin-top:7.5pt"><span style=3D"font-size:=
10.5pt;font-family:&quot;Segoe UI&quot;;color:rgb(51,51,51)">Valid values: =
x86_64, ppc64, aarch64 (architecture must have been built for patch)<u></u>=
<u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt"><u></u=
>=C2=A0<u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt"><u></u=
>=C2=A0<u></u></span></p>
<div style=3D"border-right:none;border-bottom:none;border-left:none;border-=
top:1pt solid rgb(181,196,223);padding:3pt 0cm 0cm">
<p class=3D"MsoNormal"><b><span style=3D"font-size:12pt;color:black">From: =
</span></b><span style=3D"font-size:12pt;color:black">lustre-devel &lt;<a h=
ref=3D"mailto:lustre-devel-bounces@lists.lustre.org" target=3D"_blank">lust=
re-devel-bounces@lists.lustre.org</a>&gt; on behalf of Xinliang Liu via lus=
tre-devel &lt;<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_b=
lank">lustre-devel@lists.lustre.org</a>&gt;<br>
<b>Reply-To: </b>Xinliang Liu &lt;<a href=3D"mailto:xinliang.liu@linaro.org=
" target=3D"_blank">xinliang.liu@linaro.org</a>&gt;<br>
<b>Date: </b>Wednesday, November 24, 2021 at 1:45 AM<br>
<b>To: </b>&quot;<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D=
"_blank">lustre-devel@lists.lustre.org</a>&quot; &lt;<a href=3D"mailto:lust=
re-devel@lists.lustre.org" target=3D"_blank">lustre-devel@lists.lustre.org<=
/a>&gt;<br>
<b>Cc: </b>&quot;<a href=3D"mailto:cloud-dev-request@op-lists.linaro.org" t=
arget=3D"_blank">cloud-dev-request@op-lists.linaro.org</a>&quot; &lt;<a hre=
f=3D"mailto:cloud-dev-request@op-lists.linaro.org" target=3D"_blank">cloud-=
dev-request@op-lists.linaro.org</a>&gt;<br>
<b>Subject: </b>[lustre-devel] Arm client is not in CI?<u></u><u></u></span=
></p>
</div>
<div>
<p class=3D"MsoNormal"><u></u>=C2=A0<u></u></p>
</div>
<div>
<p class=3D"MsoNormal">Hi,=C2=A0<u></u><u></u></p>
<div>
<p class=3D"MsoNormal">Recently, I find that Test-Parameters &quot;clientar=
ch=3Daarch64 &quot; is not supported in CI yet.=C2=A0<u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal">Any reason why arm client is removed? I have some pa=
tches which address arm client or server failed test cases to be landed.<u>=
</u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal"><u></u>=C2=A0<u></u></p>
</div>
<div>
<p class=3D"MsoNormal">Here is the CI comment that says &quot;clientarch=3D=
aarch64&quot; is not supported:<u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal">Which is copied from=C2=A0<a href=3D"https://review.=
whamcloud.com/#/c/40758/" target=3D"_blank">https://review.whamcloud.com/#/=
c/40758/</a><u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal">&#39;&#39;<u></u><u></u></p>
</div>
<div>
<p style=3D"white-space:pre-wrap"><span style=3D"font-family:Arial,sans-ser=
if;color:rgb(53,53,53)">Patch Set 15:<u></u><u></u></span></p>
<p style=3D"white-space:pre-wrap"><span style=3D"font-family:Arial,sans-ser=
if;color:rgb(53,53,53)">Build 84492 (patch #15) will not be tested because:=
 Unsupported build configurations were specified in the Test-Parameters:<u>=
</u><u></u></span></p>
<p style=3D"white-space:pre-wrap"><span style=3D"font-family:Monaco;color:r=
gb(53,53,53)">Test-Parameters line #1:</span><span style=3D"font-family:Ari=
al,sans-serif;color:rgb(53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- client: el8=
.3 - aarch64 - inkernel | lustre-reviews #84492</span><span style=3D"font-f=
amily:Arial,sans-serif;color:rgb(53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">Test-Paramete=
rs line #2:</span><span style=3D"font-family:Arial,sans-serif;color:rgb(53,=
53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- client: el8=
.3 - aarch64 - inkernel | lustre-reviews #84492</span><span style=3D"font-f=
amily:Arial,sans-serif;color:rgb(53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">Test-Paramete=
rs line #3:</span><span style=3D"font-family:Arial,sans-serif;color:rgb(53,=
53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- client: el8=
.3 - aarch64 - inkernel | lustre-reviews #84492</span><span style=3D"font-f=
amily:Arial,sans-serif;color:rgb(53,53,53)"><u></u><u></u></span></p>
<p style=3D"white-space:pre-wrap"><span style=3D"font-family:Monaco;color:r=
gb(53,53,53)">Supported build configurations for lustre-reviews #84492:</sp=
an><span style=3D"font-family:Arial,sans-serif;color:rgb(53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">Clients</span=
><span style=3D"font-family:Arial,sans-serif;color:rgb(53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- el7.8 - x86=
_64 - inkernel</span><span style=3D"font-family:Arial,sans-serif;color:rgb(=
53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- el7.9 - x86=
_64 - inkernel</span><span style=3D"font-family:Arial,sans-serif;color:rgb(=
53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- el8.3 - x86=
_64 - inkernel</span><span style=3D"font-family:Arial,sans-serif;color:rgb(=
53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- el8.4 - x86=
_64 - inkernel</span><span style=3D"font-family:Arial,sans-serif;color:rgb(=
53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- sles12sp5 -=
 x86_64 - inkernel</span><span style=3D"font-family:Arial,sans-serif;color:=
rgb(53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- sles15sp2 -=
 x86_64 - inkernel</span><span style=3D"font-family:Arial,sans-serif;color:=
rgb(53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- sles15sp3 -=
 x86_64 - inkernel</span><span style=3D"font-family:Arial,sans-serif;color:=
rgb(53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- ubuntu1804 =
- x86_64 - inkernel</span><span style=3D"font-family:Arial,sans-serif;color=
:rgb(53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- ubuntu2004 =
- x86_64 - inkernel</span><span style=3D"font-family:Arial,sans-serif;color=
:rgb(53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">Servers</span=
><span style=3D"font-family:Arial,sans-serif;color:rgb(53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- el7.8 - x86=
_64 - inkernel</span><span style=3D"font-family:Arial,sans-serif;color:rgb(=
53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- el7.9 - x86=
_64 - inkernel</span><span style=3D"font-family:Arial,sans-serif;color:rgb(=
53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- el8.3 - x86=
_64 - inkernel</span><span style=3D"font-family:Arial,sans-serif;color:rgb(=
53,53,53)"><br>
</span><span style=3D"font-family:Monaco;color:rgb(53,53,53)">- el8.4 - x86=
_64 - inkernel</span><span style=3D"font-family:Arial,sans-serif;color:rgb(=
53,53,53)"><u></u><u></u></span></p>
</div>
<div>
<p class=3D"MsoNormal">&quot;<u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal"><u></u>=C2=A0<u></u></p>
</div>
<div>
<p class=3D"MsoNormal">Thanks,<u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal">Xinliang<u></u><u></u></p>
</div>
</div>
</div>
</div>

</blockquote></div>

--000000000000c0cc3d05d192d9f6--

--===============7455216055659840185==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7455216055659840185==--
