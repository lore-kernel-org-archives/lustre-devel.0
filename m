Return-Path: <SRS0=5M43=MW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77B69C4338F
	for <lustre-devel@archiver.kernel.org>; Fri, 30 Jul 2021 03:49:11 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DCB5D60F94
	for <lustre-devel@archiver.kernel.org>; Fri, 30 Jul 2021 03:49:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org DCB5D60F94
Authentication-Results: mail.kernel.org; dmarc=pass (p=none dis=none) header.from=lists.lustre.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7EE9030AD45;
	Thu, 29 Jul 2021 20:49:08 -0700 (PDT)
Received: from mail-yb1-f172.google.com (mail-yb1-f172.google.com
 [209.85.219.172])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 85560307A48
 for <lustre-devel@lists.lustre.org>; Thu, 29 Jul 2021 20:49:06 -0700 (PDT)
Received: by mail-yb1-f172.google.com with SMTP id p145so12626868ybg.6
 for <lustre-devel@lists.lustre.org>; Thu, 29 Jul 2021 20:49:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=xBsOLdZl2m1OMdAr4C+vEadslGJhfLjkoTaMrHf9xoU=;
 b=Q5r9f/Z/sJco+s3H4IPI6rPPjpG4CWp4+Ct9IBMXFB8Msbdg2Jsz23Lp5LqDqF/Tqd
 ZMQxXvl7c6rhCWrEW20iFXAQNg/zZ6H6zCyzYFGvagJ7X12qpVN/6Mk2E16Gsd4e1cPA
 4WdQSY/brFm5Sj8HccSEzljwf/mOfhb23Oe81xppJ/ZjnlJ+hQOWMv685AmFLtcNdmJn
 iboB/DkgmRSP22jU1rQz/BF2VC79h0JDZguRw9Lb/2TnGV+psfbX2GJMEg+TUO88Dn7t
 15ZyxTNYagoEwKmXRex7gxO3BgAAm+vFHqtRrZ9ij+PFRd4Ri3N0fNZZ7ZPEXYmgSbZP
 XzVg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=xBsOLdZl2m1OMdAr4C+vEadslGJhfLjkoTaMrHf9xoU=;
 b=D5MJi+vkDIFMekNbEVHaQuKQ+7lrM/uLHdE+C4DCAjk8sDRFYbpUTXpg4ZksCRrSzw
 ej3dobgLAQZ+xeM/2LUFHuOnYuOf/IQGkyWaEIU0pnuqW+I8wmuJiO7ItVDvC9lmC8ey
 6V9Af3FRHtAc3v/uJ5e1GGXEKVz7pm5nZIVoRDT2bnKSKrjyDKiy88fEuvHPnjHQahxt
 JXrTH9tNf/GoWHcrpVWljBhqCQaaHayVQCgEMsPyB0nRsFA9Qad9R/VOmycjCDwSq/2y
 GvP9GZYf6gRNi6PE0wUBNEVYAsjYwQp+McuXFaRfKu9eu8khp96DyPAh7mFNCayLTVRJ
 4nrw==
X-Gm-Message-State: AOAM531IA64advxX43JMBwRXjfJGC7OJ9s56WDLPEZTofggoxUkCTrRK
 wkcXed9thZN8QaFziTlwlCi1iZHNRbUYeP+V1l6kdA==
X-Google-Smtp-Source: ABdhPJxCHIFDtQrfLd4unpeYLTzMetDBcp40YKYgiiE424VW2sEGpIicNNyDUWdujX20atzMYiLIghn4bkzTtcTCMQk=
X-Received: by 2002:a25:5d5:: with SMTP id 204mr573291ybf.24.1627616944278;
 Thu, 29 Jul 2021 20:49:04 -0700 (PDT)
MIME-Version: 1.0
References: <CACzn6-U5HD_7UO5KSPO7p5O9n3JKm87jVVk5FJRS1x4W=TW_DA@mail.gmail.com>
 <846A7FB8-D265-4CCD-B61C-1D18A6FCA8FF@ddn.com>
 <CACzn6-WdPLPGhCmu8ZEJs21Fvogp8KiPfTAUP=c0Nrh22rLRTw@mail.gmail.com>
 <5C1FCECB-995B-47BA-9D98-DA00CAF42B3F@ddn.com>
In-Reply-To: <5C1FCECB-995B-47BA-9D98-DA00CAF42B3F@ddn.com>
Date: Fri, 30 Jul 2021 11:48:27 +0800
Message-ID: <CAKoKPbx_4oZ=gcv6bCB7GyxQ7zsnTSE9SL3+BgQjyH-+4jK1zg@mail.gmail.com>
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
From: Xinliang Liu via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Xinliang Liu <xinliang.liu@linaro.org>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============8137756965303299893=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============8137756965303299893==
Content-Type: multipart/alternative; boundary="000000000000cb62fb05c84f1916"

--000000000000cb62fb05c84f1916
Content-Type: text/plain; charset="UTF-8"

Hi Peter and Lustre team,

On Tue, 29 Jun 2021 at 20:47, Peter Jones <pjones@whamcloud.com> wrote:

> Kevin
>
>
>
> This would be a good starting point -
> https://jira.whamcloud.com/issues/?filter=15555
>

Recently, we've set up all-in-one and multi-node CentOS8 aarch64 Lustre
test environments which include both server and client.
And we've done some basic file read/write manual tests and verified the
first bug #LU-10073 of the filter bug list, it's very exciting that no
issues were found on aarch64 CentOS8.

We will continue to verify other bugs on the filter list. But we currently
are very interested in the goal of arm64 release. So that users can
directly download aarch64 release from Lustre web site without building by
themself. And we eager to know more details about the aarch64 release:
1) Any schedule timeline or plan for aarch64 release?
2) If there is no now, how to make it happen?
3) What are things we need to offer aarch64 releases? Or what resources are
missing?
We are looking forward to your reply. And will continue to contribute more
to the Lustre community. Thanks.

Xinliang


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

--000000000000cb62fb05c84f1916
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hi Peter and Lustre team,</div><br><div class=3D"gmai=
l_quote"><div dir=3D"ltr" class=3D"gmail_attr">On Tue, 29 Jun 2021 at 20:47=
, Peter Jones &lt;<a href=3D"mailto:pjones@whamcloud.com">pjones@whamcloud.=
com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"marg=
in:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1e=
x">





<div lang=3D"EN-CA">
<div class=3D"gmail-m_2435674323767192568WordSection1">
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt">Kevin<=
u></u><u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt"><u></u=
>=C2=A0<u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:14pt">This w=
ould be a good starting point -
<a href=3D"https://jira.whamcloud.com/issues/?filter=3D15555" target=3D"_bl=
ank">https://jira.whamcloud.com/issues/?filter=3D15555</a></span></p></div>=
</div></blockquote><div><br></div><div>Recently, we&#39;ve set up all-in-on=
e and multi-node CentOS8 aarch64 Lustre test environments which include bot=
h server and client. <br>And we&#39;ve done some basic file read/write manu=
al tests and verified the first bug #LU-10073 of the filter bug list, it&#3=
9;s very exciting that no issues were found on aarch64 CentOS8.<br>=C2=A0<b=
r>We will continue to verify other bugs on the filter list. But we currentl=
y are very interested in the goal of arm64 release. So that users can direc=
tly download aarch64 release from Lustre web site without building by thems=
elf. And we eager to know more details about the aarch64 release:</div><div=
>1) Any schedule timeline or plan for aarch64 release?<br>2) If there is no=
 now, how to make it happen? <br>3) What are things we need to offer aarch6=
4 releases? Or what resources are missing? <br>We are looking forward to yo=
ur reply. And will continue to contribute more to the Lustre community. Tha=
nks.<br></div><div><br></div><div>Xinliang</div><div>=C2=A0</div><blockquot=
e class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px s=
olid rgb(204,204,204);padding-left:1ex"><div lang=3D"EN-CA"><div class=3D"g=
mail-m_2435674323767192568WordSection1"><p class=3D"MsoNormal"><span lang=
=3D"EN-US" style=3D"font-size:14pt"><u></u><u></u></span></p>
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

</blockquote></div></div>

--000000000000cb62fb05c84f1916--

--===============8137756965303299893==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============8137756965303299893==--
