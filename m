Return-Path: <SRS0=1qo3=LX=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: **
X-Spam-Status: No, score=2.4 required=3.0 tests=BAYES_40,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02D8DC11F66
	for <lustre-devel@archiver.kernel.org>; Tue, 29 Jun 2021 12:29:54 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7F18761D92
	for <lustre-devel@archiver.kernel.org>; Tue, 29 Jun 2021 12:29:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F18761D92
Authentication-Results: mail.kernel.org; dmarc=pass (p=none dis=none) header.from=lists.lustre.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 29108201363;
	Tue, 29 Jun 2021 05:29:53 -0700 (PDT)
Received: from mail-oi1-f174.google.com (mail-oi1-f174.google.com
 [209.85.167.174])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 48472200D71
 for <lustre-devel@lists.lustre.org>; Tue, 29 Jun 2021 05:29:51 -0700 (PDT)
Received: by mail-oi1-f174.google.com with SMTP id s17so26149783oij.0
 for <lustre-devel@lists.lustre.org>; Tue, 29 Jun 2021 05:29:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:from:date:message-id:subject:to:cc;
 bh=JdoZHZMKdi5sMG9+ngje0ihDqs+svt0F6BUsZ7AdSBE=;
 b=ZBPeTs0JIATWqL0+TSJUCFfhmT7BaZ8lqjjvm9saGFTDfPqQ3FmYCflYL5DUHNCIrw
 ePFr7N1+06alFjxDK5hM0w4XBe0WD43NE+W0mmMT468R65Yu9NA/Sk/3i6SqbjKCE4Lz
 kmWtBY9Bk/PQl7ioJUCcVAqVAS/2gQtWHKP+O/EmmP2+NPZ4YsbcoC5W55dsWEh9Xodh
 LQnwjyJEFt+f0bhf/yyAQbYEzMyq4qfd1nVs/963FfG+uBrbBAZGWHnZEevos8DK9y+s
 lagJq4v6cpAttFN4lchX+txdutA480XJ7U3BHNSrievqaR+veflpkfAKooBrHg7u+8RO
 TX9Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
 bh=JdoZHZMKdi5sMG9+ngje0ihDqs+svt0F6BUsZ7AdSBE=;
 b=cAPgpjI8HbjH81zxzyN6zAmQRrnmiRFL+4IQRI0JpO1g1fWgYTy4HtsCgs3GWopZGg
 fBq2/mzj6xs4nyTI4PqLoHMdaSo3+Ssump6MsUX7oOO9PD8f6MVVmbpqvs4tS39EtMXq
 RYd6Anufe2hPHjasYsk+wm6bIW94Lrathwl/HxSGC0OiCy2XDNEyks9TXEBNkRTVKeaj
 jvrrYjf3YYLcD5ZN0lgOMqclxDW7i/RGQLSbeAZ65prxBB1PkzgTDlAXW0vHeP8YemVQ
 tM1IkcDGKtw8j1bumkT1OEAm7Em08N6gQWOAh9WfQMWQt0rH9RzJKTK06iDrsRvBGUq1
 6KXA==
X-Gm-Message-State: AOAM530RW52tWDLryPhgDZ83T/K8ME3NW7TzmBZDRKhWtPjQVCB6m4tO
 lIlWEDpwPal1gclqAMjfwLJCT67Rn5Nnw/w+mTlh7w8WFw==
X-Google-Smtp-Source: ABdhPJzOziBHbWUWRL+teoS4OhtZxnsrQhV5myDk7y2FN1azzRUeeP9vtgQGiSjrNJ1YHhdFbLkmZHjQNbxQoCjO8Ok=
X-Received: by 2002:aca:3285:: with SMTP id
 y127mr21253780oiy.115.1624969790357; 
 Tue, 29 Jun 2021 05:29:50 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 29 Jun 2021 20:29:13 +0800
Message-ID: <CACzn6-U5HD_7UO5KSPO7p5O9n3JKm87jVVk5FJRS1x4W=TW_DA@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] Lustre Arm64 Development and Release
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
Cc: Xinliang Liu <xinliang.liu@linaro.org>
Content-Type: multipart/mixed; boundary="===============7791479850439061018=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7791479850439061018==
Content-Type: multipart/alternative; boundary="00000000000020156405c5e6c34d"

--00000000000020156405c5e6c34d
Content-Type: text/plain; charset="UTF-8"

Hi Lustre,

Greetings!
I'm Kevin Zhao, and cc'ed Xinliang Liu, we are from Linaro. We are working
on Arm64 storage enablement and Lustre is definitely on top of our list.
We've received some requests from our members about Lustre support on
Arm64.

So I'm writing to ask the current status of Lustre on Arm64. I noticed that
there are some pages recording Lustre build method on Arm64 as Link
<https://wiki.whamcloud.com/pages/viewpage.action?pageId=154144662> and
some Jira cards <https://jira.whamcloud.com/browse/LU-11200>. But I don't
see official or experimental release on Arm64. So my question is:
1. if there some gap or effort needs to be done in order to offer arm64
release? We are very interested and can help to work on that.
2. If there CI resources needs in order to achieve this? At Linaro we also
have some machine resources to serve as the CI machines.

Thanks a lot for your reply in advance and look forward to work with you in
the community!

-- 
*Best Regards*

*Kevin Zhao*

Tech Lead, LDCG Cloud Infrastructure

Linaro Vertical Technologies

IRC(freenode): kevinz

Slack(kubernetes.slack.com): kevinz

kevin.zhao@linaro.org <elsie.wahlig@linaro.org> | Mobile/Direct/Wechat:
+86 18818270915

--00000000000020156405c5e6c34d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Lustre,<div><br></div><div>Greetings!</div><div>I&#39;m=
 Kevin Zhao, and cc&#39;ed Xinliang Liu, we are from Linaro. We are working=
 on Arm64 storage enablement and Lustre is definitely on top of our list. W=
e&#39;ve received some requests from our members about Lustre support on Ar=
m64.=C2=A0</div><div><br></div><div>So I&#39;m writing to ask the current s=
tatus of Lustre on Arm64. I noticed that there are some pages recording Lus=
tre build method on Arm64 as <a href=3D"https://wiki.whamcloud.com/pages/vi=
ewpage.action?pageId=3D154144662">Link</a> and some <a href=3D"https://jira=
.whamcloud.com/browse/LU-11200">Jira cards</a>. But I don&#39;t see officia=
l or experimental=C2=A0release on Arm64. So my question is:</div><div>1. if=
 there some gap or effort needs to be done in order to offer arm64 release?=
 We are very interested and can help to work on that.</div><div>2. If there=
 CI resources needs in order to achieve this? At Linaro we also have some m=
achine resources to serve as the CI machines.</div><div><br></div><div>Than=
ks a lot for your reply in=C2=A0advance and look forward to work with you i=
n the community!<br clear=3D"all"><div><br></div>-- <br><div dir=3D"ltr" cl=
ass=3D"gmail_signature" data-smartmail=3D"gmail_signature"><div dir=3D"ltr"=
><div><div dir=3D"ltr"><div><div dir=3D"ltr"><div dir=3D"ltr"><b>Best Regar=
ds</b><div><div style=3D"margin:0px;padding:0px 0px 20px;width:1262px"><div=
><div style=3D"margin:8px 0px 0px;padding:0px"><div><div dir=3D"ltr"><font>=
<div dir=3D"ltr"><div dir=3D"ltr"><p class=3D"MsoNormal" style=3D"color:rgb=
(136,136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;fon=
t-size:medium"><b><span style=3D"font-size:11pt"><font color=3D"#38761d">Ke=
vin Zhao</font></span></b></p><p class=3D"MsoNormal" style=3D"color:rgb(136=
,136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-si=
ze:medium"><font color=3D"#757b80"><span style=3D"font-size:14.6667px">Tech=
 Lead, LDCG Cloud Infrastructure</span></font></p><p class=3D"MsoNormal" st=
yle=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica,Aria=
l,sans-serif;font-size:medium"><font color=3D"#757b80"><span style=3D"font-=
size:14.6667px">Linaro Vertical Technologies</span></font></p><p class=3D"M=
soNormal" style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,He=
lvetica,Arial,sans-serif;font-size:medium"><font color=3D"#757b80"><span st=
yle=3D"font-size:14.6667px">IRC(freenode): kevinz</span></font></p><p class=
=3D"MsoNormal"><font color=3D"#757b80"><font color=3D"#888888" face=3D"Robo=
to, RobotoDraft, Helvetica, Arial, sans-serif"><span style=3D"font-size:14.=
6667px">Slack(</span></font><font face=3D"Roboto, RobotoDraft, Helvetica, A=
rial, sans-serif"><span style=3D"font-size:14.6667px"><a href=3D"http://kub=
ernetes.slack.com" target=3D"_blank">kubernetes.slack.com</a>)</span></font=
><font color=3D"#888888" face=3D"Roboto, RobotoDraft, Helvetica, Arial, san=
s-serif"><span style=3D"font-size:14.6667px">: kevinz</span></font></font><=
/p><p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Robot=
o,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"><font color=3D"#=
757b80"><span style=3D"font-size:14.6667px"><a href=3D"mailto:elsie.wahlig@=
linaro.org" target=3D"_blank"><span>kevin.zhao@linaro.org</span></a>=C2=A0|=
 Mobile/Direct/Wechat:=C2=A0 +86 18818270915</span></font><span style=3D"co=
lor:rgb(117,123,128);font-size:11pt">=C2=A0</span><br></p><div style=3D"col=
or:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-ser=
if;font-size:medium"><span style=3D"color:rgb(117,123,128);font-size:11pt">=
<br></span></div></div></div></font></div><div style=3D"font-family:Roboto,=
RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"></div></div></div>=
<div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;fon=
t-size:medium"></div></div></div></div></div></div></div></div></div></div>=
</div></div></div>

--00000000000020156405c5e6c34d--

--===============7791479850439061018==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7791479850439061018==--
