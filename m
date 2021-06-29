Return-Path: <SRS0=1qo3=LX=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 280C3C11F66
	for <lustre-devel@archiver.kernel.org>; Tue, 29 Jun 2021 13:04:10 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B924561DC0
	for <lustre-devel@archiver.kernel.org>; Tue, 29 Jun 2021 13:04:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B924561DC0
Authentication-Results: mail.kernel.org; dmarc=pass (p=none dis=none) header.from=lists.lustre.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D79F521CA5A;
	Tue, 29 Jun 2021 06:04:08 -0700 (PDT)
Received: from mail-ot1-f46.google.com (mail-ot1-f46.google.com
 [209.85.210.46])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BDE4F201110
 for <lustre-devel@lists.lustre.org>; Tue, 29 Jun 2021 06:04:06 -0700 (PDT)
Received: by mail-ot1-f46.google.com with SMTP id
 d21-20020a9d72d50000b02904604cda7e66so20792818otk.7
 for <lustre-devel@lists.lustre.org>; Tue, 29 Jun 2021 06:04:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=6B5+K0A9L1SQdvPix1uc+mhxM5/VX8A7SvAH8xY8940=;
 b=OkChRHNS4mdc/UeZxAttOZ9K+BHWi7tH15ma7zFl7odL/RYSsXTjkUXEqOtoDG9KvK
 QZ98m8z8Hn2sqfIraO0t13amCF3y5ADhvUaPl6nw5+3JAJUUSnn39iftIWS8xTqKqxYQ
 NDwAs16obpqgCPtNMVKuXGzteV7bGp3ek+Vf08baUIvTexplUJRFYaNL2EjP+T3Yyj3/
 NmYwp17fQipAVZsaDrokS/Ptuwpkw/ZA/kBaAOj7t70RaOkAlJvUVk9V3InFP8MCk+EJ
 BFTP4FH5nvXLWbkblu3XWq0QzxtqzCQAFQDoM6BG5amFmp9AhhvQZ3VsILbJyH5JhCIe
 Gejg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=6B5+K0A9L1SQdvPix1uc+mhxM5/VX8A7SvAH8xY8940=;
 b=M1QyOrHVbolWygWi4hIcu7Bzje3qNTovV9LdWWYf+VzLa9A0E7fH7DbEm6MMj4o1m8
 6achhkqGBc9ex6hEf9PZ0y0Rivum2smjkmgEoLZK4YPgrjZjJh9kSm0B7AEfeUwrWskp
 sPmVdQ/09ieeYU5JFpqVOI3Ph5umkLhNaq2EP7pVd/JKGo4W8hDg2T/IfUabbKdH4hbc
 I/CFq66gIIXabUVU53IKcocps9ky4McWb+5brfgejTrMSSLuEslYOFrgUVvRAlv+m2ua
 38CZIezpc7NCrn6Lg3hI6LPNXr7fuHgAyNCrbR213wmZOpYEniEMuRCvAtjZGsKIow1i
 cBmA==
X-Gm-Message-State: AOAM531v69+wDjpcZ+3diYCoceqEu+0Sl3X1t0zr2olFRBrv6Ymh/qPJ
 eHgFDpiNU4AqNsocy0fXEvfsFzgcm+gVUklZnliL
X-Google-Smtp-Source: ABdhPJw1jDTa+VEE8LShnNw1y5YAqC7eILxMtoiLnskhE20qMPtsDryEIIqZO5dbICJBpm42jen4GFHoZsrB5E+/JcQ=
X-Received: by 2002:a9d:554a:: with SMTP id h10mr4524283oti.177.1624971845040; 
 Tue, 29 Jun 2021 06:04:05 -0700 (PDT)
MIME-Version: 1.0
References: <CACzn6-U5HD_7UO5KSPO7p5O9n3JKm87jVVk5FJRS1x4W=TW_DA@mail.gmail.com>
 <846A7FB8-D265-4CCD-B61C-1D18A6FCA8FF@ddn.com>
 <CACzn6-WdPLPGhCmu8ZEJs21Fvogp8KiPfTAUP=c0Nrh22rLRTw@mail.gmail.com>
 <5C1FCECB-995B-47BA-9D98-DA00CAF42B3F@ddn.com>
In-Reply-To: <5C1FCECB-995B-47BA-9D98-DA00CAF42B3F@ddn.com>
Date: Tue, 29 Jun 2021 21:03:27 +0800
Message-ID: <CACzn6-UQBdna9jcT_s3RyDJC2OUmRDNdc9JxEC-YwjeSJbXgzg@mail.gmail.com>
To: Peter Jones <pjones@whamcloud.com>
Subject: Re: [lustre-devel] Lustre Arm64 Development and Release
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
From: Kevin Zhao via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Kevin Zhao <kevin.zhao@linaro.org>
Cc: Xinliang Liu <xinliang.liu@linaro.org>,
 "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============0255040633223553031=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============0255040633223553031==
Content-Type: multipart/alternative; boundary="00000000000098178805c5e73df4"

--00000000000098178805c5e73df4
Content-Type: text/plain; charset="UTF-8"

Hi Peter,

Thanks! We'll take a look at those tickets.

On Tue, 29 Jun 2021 at 20:47, Peter Jones <pjones@whamcloud.com> wrote:

> Kevin
>
>
>
> This would be a good starting point -
> https://jira.whamcloud.com/issues/?filter=15555
>
>
>
> Peter
>
>
>
> *From: *Kevin Zhao <kevin.zhao@linaro.org>
> *Date: *Tuesday, June 29, 2021 at 5:44 AM
> *To: *Peter Jones <pjones@whamcloud.com>
> *Cc: *"lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>,
> Xinliang Liu <xinliang.liu@linaro.org>
> *Subject: *Re: [lustre-devel] Lustre Arm64 Development and Release
>
>
>
> Hi Peter,
>
>
>
> That's great! We can help to follow and fix test failures. Could you point
> us some test failure links or logs? So that we can kick off our work and
> reproduce the failure in our local lab.
>
> Thanks!
>
>
>
> On Tue, 29 Jun 2021 at 20:41, Peter Jones <pjones@whamcloud.com> wrote:
>
> Hi Kevin
>
>
>
> Various people have asked this question over the last couple of years. We
> have machines that could be used for CI (Arm clients are being routinely
> tested) but the challenge has been to have someone follow through and work
> through test failures and take responsibility for vetting the tests in an
> ongoing basis.
>
>
>
> Peter
>
>
>
> *From: *lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of
> Kevin Zhao via lustre-devel <lustre-devel@lists.lustre.org>
> *Reply-To: *Kevin Zhao <kevin.zhao@linaro.org>
> *Date: *Tuesday, June 29, 2021 at 5:29 AM
> *To: *"lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
> *Cc: *Xinliang Liu <xinliang.liu@linaro.org>
> *Subject: *[lustre-devel] Lustre Arm64 Development and Release
>
>
>
> Hi Lustre,
>
>
>
> Greetings!
>
> I'm Kevin Zhao, and cc'ed Xinliang Liu, we are from Linaro. We are working
> on Arm64 storage enablement and Lustre is definitely on top of our list.
> We've received some requests from our members about Lustre support on
> Arm64.
>
>
>
> So I'm writing to ask the current status of Lustre on Arm64. I noticed
> that there are some pages recording Lustre build method on Arm64 as Link
> <https://wiki.whamcloud.com/pages/viewpage.action?pageId=154144662> and
> some Jira cards <https://jira.whamcloud.com/browse/LU-11200>. But I don't
> see official or experimental release on Arm64. So my question is:
>
> 1. if there some gap or effort needs to be done in order to offer arm64
> release? We are very interested and can help to work on that.
>
> 2. If there CI resources needs in order to achieve this? At Linaro we also
> have some machine resources to serve as the CI machines.
>
>
>
> Thanks a lot for your reply in advance and look forward to work with you
> in the community!
>
>
>
> --
>
> *Best Regards*
>
> *Kevin Zhao*
>
> Tech Lead, LDCG Cloud Infrastructure
>
> Linaro Vertical Technologies
>
> IRC(freenode): kevinz
>
> Slack(kubernetes.slack.com): kevinz
>
> kevin.zhao@linaro.org <elsie.wahlig@linaro.org> | Mobile/Direct/Wechat:
> +86 18818270915
>
>
>
>
>
>
> --
>
> *Best Regards*
>
> *Kevin Zhao*
>
> Tech Lead, LDCG Cloud Infrastructure
>
> Linaro Vertical Technologies
>
> IRC(freenode): kevinz
>
> Slack(kubernetes.slack.com): kevinz
>
> kevin.zhao@linaro.org <elsie.wahlig@linaro.org> | Mobile/Direct/Wechat:
> +86 18818270915
>
>
>


-- 
*Best Regards*

*Kevin Zhao*

Tech Lead, LDCG Cloud Infrastructure

Linaro Vertical Technologies

IRC(freenode): kevinz

Slack(kubernetes.slack.com): kevinz

kevin.zhao@linaro.org <elsie.wahlig@linaro.org> | Mobile/Direct/Wechat:
+86 18818270915

--00000000000098178805c5e73df4
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Peter,<div><br></div><div>Thanks! We&#39;ll take a look=
 at those tickets.</div></div><br><div class=3D"gmail_quote"><div dir=3D"lt=
r" class=3D"gmail_attr">On Tue, 29 Jun 2021 at 20:47, Peter Jones &lt;<a hr=
ef=3D"mailto:pjones@whamcloud.com">pjones@whamcloud.com</a>&gt; wrote:<br><=
/div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;bo=
rder-left:1px solid rgb(204,204,204);padding-left:1ex">





<div lang=3D"EN-CA">
<div class=3D"gmail-m_831508276939357730WordSection1">
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt">Kevin<=
u></u><u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt"><u></u=
>=C2=A0<u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt">This w=
ould be a good starting point -
<a href=3D"https://jira.whamcloud.com/issues/?filter=3D15555" target=3D"_bl=
ank">https://jira.whamcloud.com/issues/?filter=3D15555</a><u></u><u></u></s=
pan></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt"><u></u=
>=C2=A0<u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt">Peter<=
u></u><u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt"><u></u=
>=C2=A0<u></u></span></p>
<div style=3D"border-right:none;border-bottom:none;border-left:none;border-=
top:1pt solid rgb(181,196,223);padding:3pt 0cm 0cm">
<p class=3D"MsoNormal"><b><span style=3D"font-size:12pt;color:black">From: =
</span></b><span style=3D"font-size:12pt;color:black">Kevin Zhao &lt;<a hre=
f=3D"mailto:kevin.zhao@linaro.org" target=3D"_blank">kevin.zhao@linaro.org<=
/a>&gt;<br>
<b>Date: </b>Tuesday, June 29, 2021 at 5:44 AM<br>
<b>To: </b>Peter Jones &lt;<a href=3D"mailto:pjones@whamcloud.com" target=
=3D"_blank">pjones@whamcloud.com</a>&gt;<br>
<b>Cc: </b>&quot;<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D=
"_blank">lustre-devel@lists.lustre.org</a>&quot; &lt;<a href=3D"mailto:lust=
re-devel@lists.lustre.org" target=3D"_blank">lustre-devel@lists.lustre.org<=
/a>&gt;, Xinliang Liu &lt;<a href=3D"mailto:xinliang.liu@linaro.org" target=
=3D"_blank">xinliang.liu@linaro.org</a>&gt;<br>
<b>Subject: </b>Re: [lustre-devel] Lustre Arm64 Development and Release<u><=
/u><u></u></span></p>
</div>
<div>
<p class=3D"MsoNormal"><u></u>=C2=A0<u></u></p>
</div>
<div>
<p class=3D"MsoNormal">Hi Peter,<u></u><u></u></p>
<div>
<p class=3D"MsoNormal"><u></u>=C2=A0<u></u></p>
</div>
<div>
<p class=3D"MsoNormal">That&#39;s great! We can help to follow and fix test=
 failures. Could you point us some test failure links or logs? So that we c=
an kick off our work and reproduce the failure in our local lab.<u></u><u><=
/u></p>
</div>
<div>
<p class=3D"MsoNormal">Thanks!<u></u><u></u></p>
</div>
</div>
<p class=3D"MsoNormal"><u></u>=C2=A0<u></u></p>
<div>
<div>
<p class=3D"MsoNormal">On Tue, 29 Jun 2021 at 20:41, Peter Jones &lt;<a hre=
f=3D"mailto:pjones@whamcloud.com" target=3D"_blank">pjones@whamcloud.com</a=
>&gt; wrote:<u></u><u></u></p>
</div>
<blockquote style=3D"border-top:none;border-right:none;border-bottom:none;b=
order-left:1pt solid rgb(204,204,204);padding:0cm 0cm 0cm 6pt;margin-left:4=
.8pt;margin-right:0cm">
<div>
<div>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt">Hi Kev=
in</span><u></u><u></u></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt">=C2=A0=
</span><u></u><u></u></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt">Variou=
s people have asked this question over the last couple of years. We have ma=
chines that could be used for CI (Arm clients are being
 routinely tested) but the challenge has been to have someone follow throug=
h and work through test failures and take responsibility for vetting the te=
sts in an ongoing basis.</span><u></u><u></u></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt">=C2=A0=
</span><u></u><u></u></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt">Peter<=
/span><u></u><u></u></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt">=C2=A0=
</span><u></u><u></u></p>
<div style=3D"border-right:none;border-bottom:none;border-left:none;border-=
top:1pt solid rgb(181,196,223);padding:3pt 0cm 0cm">
<p class=3D"MsoNormal"><b><span style=3D"font-size:12pt;color:black">From:
</span></b><span style=3D"font-size:12pt;color:black">lustre-devel &lt;<a h=
ref=3D"mailto:lustre-devel-bounces@lists.lustre.org" target=3D"_blank">lust=
re-devel-bounces@lists.lustre.org</a>&gt; on behalf of Kevin Zhao via lustr=
e-devel &lt;<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_bla=
nk">lustre-devel@lists.lustre.org</a>&gt;<br>
<b>Reply-To: </b>Kevin Zhao &lt;<a href=3D"mailto:kevin.zhao@linaro.org" ta=
rget=3D"_blank">kevin.zhao@linaro.org</a>&gt;<br>
<b>Date: </b>Tuesday, June 29, 2021 at 5:29 AM<br>
<b>To: </b>&quot;<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D=
"_blank">lustre-devel@lists.lustre.org</a>&quot; &lt;<a href=3D"mailto:lust=
re-devel@lists.lustre.org" target=3D"_blank">lustre-devel@lists.lustre.org<=
/a>&gt;<br>
<b>Cc: </b>Xinliang Liu &lt;<a href=3D"mailto:xinliang.liu@linaro.org" targ=
et=3D"_blank">xinliang.liu@linaro.org</a>&gt;<br>
<b>Subject: </b>[lustre-devel] Lustre Arm64 Development and Release</span><=
u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal">=C2=A0<u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal">Hi Lustre,<u></u><u></u></p>
<div>
<p class=3D"MsoNormal">=C2=A0<u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal">Greetings!<u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal">I&#39;m Kevin Zhao, and cc&#39;ed Xinliang Liu, we a=
re from Linaro. We are working on Arm64 storage enablement and Lustre is de=
finitely on top of our list. We&#39;ve received some requests
 from our members about Lustre support on Arm64.=C2=A0<u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal">=C2=A0<u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal">So I&#39;m writing to ask the current status of Lust=
re on Arm64. I noticed that there are some pages recording Lustre build met=
hod on Arm64 as
<a href=3D"https://wiki.whamcloud.com/pages/viewpage.action?pageId=3D154144=
662" target=3D"_blank">
Link</a> and some <a href=3D"https://jira.whamcloud.com/browse/LU-11200" ta=
rget=3D"_blank">
Jira cards</a>. But I don&#39;t see official or experimental=C2=A0release o=
n Arm64. So my question is:<u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal">1. if there some gap or effort needs to be done in o=
rder to offer arm64 release? We are very interested and can help to work on=
 that.<u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal">2. If there CI resources needs in order to achieve t=
his? At Linaro we also have some machine resources to serve as the CI machi=
nes.<u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal">=C2=A0<u></u><u></u></p>
</div>
<div>
<p class=3D"MsoNormal">Thanks a lot for your reply in=C2=A0advance and look=
 forward to work with you in the community!<br clear=3D"all">
<u></u><u></u></p>
<div>
<p class=3D"MsoNormal">=C2=A0<u></u><u></u></p>
</div>
<p class=3D"MsoNormal">--
<u></u><u></u></p>
<div>
<div>
<div>
<div>
<div>
<div>
<div>
<p class=3D"MsoNormal"><b>Best Regards</b><u></u><u></u></p>
<div>
<div>
<div>
<div style=3D"margin-top:6pt">
<div>
<div>
<div>
<div>
<p class=3D"MsoNormal"><b><span style=3D"font-family:Helvetica;color:rgb(56=
,118,29)">Kevin Zhao</span></b><u></u><u></u></p>
<p class=3D"MsoNormal"><span style=3D"font-family:Helvetica;color:rgb(117,1=
23,128)">Tech Lead, LDCG Cloud Infrastructure</span><u></u><u></u></p>
<p class=3D"MsoNormal"><span style=3D"font-family:Helvetica;color:rgb(117,1=
23,128)">Linaro Vertical Technologies</span><u></u><u></u></p>
<p class=3D"MsoNormal"><span style=3D"font-family:Helvetica;color:rgb(117,1=
23,128)">IRC(freenode): kevinz</span><u></u><u></u></p>
<p class=3D"MsoNormal"><span style=3D"font-family:Helvetica;color:rgb(136,1=
36,136)">Slack(</span><span style=3D"font-family:Helvetica;color:rgb(117,12=
3,128)"><a href=3D"http://kubernetes.slack.com" target=3D"_blank">kubernete=
s.slack.com</a>)</span><span style=3D"font-family:Helvetica;color:rgb(136,1=
36,136)">:
 kevinz</span><u></u><u></u></p>
<p class=3D"MsoNormal"><span style=3D"font-family:Helvetica;color:rgb(117,1=
23,128)"><a href=3D"mailto:elsie.wahlig@linaro.org" target=3D"_blank">kevin=
.zhao@linaro.org</a>=C2=A0| Mobile/Direct/Wechat:=C2=A0 +86 18818270915=C2=
=A0</span><u></u><u></u></p>
<div>
<p class=3D"MsoNormal"><span style=3D"font-size:13.5pt;font-family:Helvetic=
a;color:rgb(136,136,136)">=C2=A0</span><u></u><u></u></p>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</blockquote>
</div>
<p class=3D"MsoNormal"><br clear=3D"all">
<u></u><u></u></p>
<div>
<p class=3D"MsoNormal"><u></u>=C2=A0<u></u></p>
</div>
<p class=3D"MsoNormal">-- <u></u><u></u></p>
<div>
<div>
<div>
<div>
<div>
<div>
<div>
<p class=3D"MsoNormal"><b>Best Regards</b><u></u><u></u></p>
<div>
<div>
<div>
<div style=3D"margin-top:6pt">
<div>
<div>
<div>
<div>
<p class=3D"MsoNormal"><b><span style=3D"font-family:Helvetica;color:rgb(56=
,118,29)">Kevin Zhao</span></b><span style=3D"font-size:13.5pt;font-family:=
Helvetica;color:rgb(136,136,136)"><u></u><u></u></span></p>
<p class=3D"MsoNormal"><span style=3D"font-family:Helvetica;color:rgb(117,1=
23,128)">Tech Lead, LDCG Cloud Infrastructure</span><span style=3D"font-siz=
e:13.5pt;font-family:Helvetica;color:rgb(136,136,136)"><u></u><u></u></span=
></p>
<p class=3D"MsoNormal"><span style=3D"font-family:Helvetica;color:rgb(117,1=
23,128)">Linaro Vertical Technologies</span><span style=3D"font-size:13.5pt=
;font-family:Helvetica;color:rgb(136,136,136)"><u></u><u></u></span></p>
<p class=3D"MsoNormal"><span style=3D"font-family:Helvetica;color:rgb(117,1=
23,128)">IRC(freenode): kevinz</span><span style=3D"font-size:13.5pt;font-f=
amily:Helvetica;color:rgb(136,136,136)"><u></u><u></u></span></p>
<p class=3D"MsoNormal"><span style=3D"font-family:Helvetica;color:rgb(136,1=
36,136)">Slack(</span><span style=3D"font-family:Helvetica;color:rgb(117,12=
3,128)"><a href=3D"http://kubernetes.slack.com" target=3D"_blank">kubernete=
s.slack.com</a>)</span><span style=3D"font-family:Helvetica;color:rgb(136,1=
36,136)">:
 kevinz</span><u></u><u></u></p>
<p class=3D"MsoNormal"><span style=3D"font-family:Helvetica;color:rgb(117,1=
23,128)"><a href=3D"mailto:elsie.wahlig@linaro.org" target=3D"_blank">kevin=
.zhao@linaro.org</a>=C2=A0| Mobile/Direct/Wechat:=C2=A0 +86 18818270915=C2=
=A0</span><span style=3D"font-size:13.5pt;font-family:Helvetica;color:rgb(1=
36,136,136)"><u></u><u></u></span></p>
<div>
<p class=3D"MsoNormal"><span style=3D"font-size:13.5pt;font-family:Helvetic=
a;color:rgb(136,136,136)"><u></u>=C2=A0<u></u></span></p>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>

</blockquote></div><br clear=3D"all"><div><br></div>-- <br><div dir=3D"ltr"=
 class=3D"gmail_signature"><div dir=3D"ltr"><div><div dir=3D"ltr"><div><div=
 dir=3D"ltr"><div dir=3D"ltr"><b>Best Regards</b><div><div style=3D"margin:=
0px;padding:0px 0px 20px;width:1262px"><div><div style=3D"margin:8px 0px 0p=
x;padding:0px"><div><div dir=3D"ltr"><font><div dir=3D"ltr"><div dir=3D"ltr=
"><p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto=
,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"><b><span style=3D=
"font-size:11pt"><font color=3D"#38761d">Kevin Zhao</font></span></b></p><p=
 class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto,Rob=
otoDraft,Helvetica,Arial,sans-serif;font-size:medium"><font color=3D"#757b8=
0"><span style=3D"font-size:14.6667px">Tech Lead, LDCG Cloud Infrastructure=
</span></font></p><p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);fo=
nt-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"><=
font color=3D"#757b80"><span style=3D"font-size:14.6667px">Linaro Vertical =
Technologies</span></font></p><p class=3D"MsoNormal" style=3D"color:rgb(136=
,136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-si=
ze:medium"><font color=3D"#757b80"><span style=3D"font-size:14.6667px">IRC(=
freenode): kevinz</span></font></p><p class=3D"MsoNormal"><font color=3D"#7=
57b80"><font color=3D"#888888" face=3D"Roboto, RobotoDraft, Helvetica, Aria=
l, sans-serif"><span style=3D"font-size:14.6667px">Slack(</span></font><fon=
t face=3D"Roboto, RobotoDraft, Helvetica, Arial, sans-serif"><span style=3D=
"font-size:14.6667px"><a href=3D"http://kubernetes.slack.com" target=3D"_bl=
ank">kubernetes.slack.com</a>)</span></font><font color=3D"#888888" face=3D=
"Roboto, RobotoDraft, Helvetica, Arial, sans-serif"><span style=3D"font-siz=
e:14.6667px">: kevinz</span></font></font></p><p class=3D"MsoNormal" style=
=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial,s=
ans-serif;font-size:medium"><font color=3D"#757b80"><span style=3D"font-siz=
e:14.6667px"><a href=3D"mailto:elsie.wahlig@linaro.org" target=3D"_blank"><=
span>kevin.zhao@linaro.org</span></a>=C2=A0| Mobile/Direct/Wechat:=C2=A0 +8=
6 18818270915</span></font><span style=3D"color:rgb(117,123,128);font-size:=
11pt">=C2=A0</span><br></p><div style=3D"color:rgb(136,136,136);font-family=
:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"><span styl=
e=3D"color:rgb(117,123,128);font-size:11pt"><br></span></div></div></div></=
font></div><div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,san=
s-serif;font-size:medium"></div></div></div><div style=3D"font-family:Robot=
o,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"></div></div></di=
v></div></div></div></div></div></div></div></div>

--00000000000098178805c5e73df4--

--===============0255040633223553031==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0255040633223553031==--
