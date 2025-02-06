Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 12CA0C02192
	for <lustre-devel@archiver.kernel.org>; Thu,  6 Feb 2025 01:20:46 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YpK6h2rFzz1xnx;
	Wed, 05 Feb 2025 17:20:44 -0800 (PST)
Received: from mail-lj1-f176.google.com (mail-lj1-f176.google.com
 [209.85.208.176])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YpK6f6jjCz1xh7
 for <lustre-devel@lists.lustre.org>; Wed, 05 Feb 2025 17:20:42 -0800 (PST)
Received: by mail-lj1-f176.google.com with SMTP id
 38308e7fff4ca-307c13298eeso4219971fa.0
 for <lustre-devel@lists.lustre.org>; Wed, 05 Feb 2025 17:20:42 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=linaro.org; s=google; t=1738804841; x=1739409641; darn=lists.lustre.org;
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=Hs2DB5QdekhEFBORw9lXSf+7IZTDplQbNWGsI5a8pBg=;
 b=ix/wk4Bom7erUgRvYlZEgB2GU2R8K5O0FE7nHbb85hIemUfAyN8loYL4D95Gs2kG9z
 I8xE7XuteEJxS/LkjCzQQF68B+Hp0gAmGck5BGt/TTHxTT23+Uk2xbWr++lVcDW6KF+t
 gBS3a9rdYcmTDkM+IFFGaiHTnaP8ri2fadZBGqkVznMCHN1g5l8ERdVYPJJ8TsKbhrcY
 ZJ7eEDxlp7ynoJvo42HdJWje5bDAy/IuCwT7I03VHvaduHYbxd0Xoj7Q4LEo1R9MiTqe
 BbK4GUHRinFDnghAJSJzFnQNTJND0Y/l0NaKpDnsBIavEWsbcBQj3ofENiU6+5N669L7
 pgCw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1738804841; x=1739409641;
 h=to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=Hs2DB5QdekhEFBORw9lXSf+7IZTDplQbNWGsI5a8pBg=;
 b=uoJ5cY6N1uu0+TPoRlur0gQIx1qKRdL7bggMCVfdj/AjQHQKc4HdOwK23sfwobwMhA
 M+lURdiZAA7PKPRuP/08cwj9UAtPH0VcVHCDh9sm/yBUu7WmtI6CP7mQwn+XUqYLbth8
 koHVK3+G3nLQfe/yzjP+BZgVrEJ9CsihJWI52bb8fG0Pr8EBhuFEU7ZVqaOQWJtsnTqt
 qyCDBDhfVPDjqExCOJVJUQhzFCUhSM80lxuP2gjrH4LMx6ok9zJzERMs5jZEKjKGMsGp
 U/gKrEcjDIBc0Dkth8V6U1ViNJ5G0J/7J0QZjhS2TeXXx9+aj5QUx1b3WXpbWI6s1/mt
 JQ/w==
X-Gm-Message-State: AOJu0YzyBSYzSQOwaRWf+c2irDa88jssgdTTfM7LQFx3ON8jfEt/7f1o
 knayTIlLU4zLI5LnZCcCRoPkad1BY4QxjeSpijNBzlODvuwGSmpTvurzuQzCXCllF4m2kXognzN
 MK5Q5lN9+/zqqanPDf8LNm2qE67wPS7H7oaNpusOP8k98cbcCmA==
X-Gm-Gg: ASbGncvfePeCPx2i6jYUH+xDxxihcT3/Z+xUsEhLG1IKC5VL4lL65Cd3U2w5xOMeWM8
 lCAnRjOB58jq9MkwZWzBBy47bhaCZ8D3pwC8j4xiVkeeWIThqvEbRFSNFZn0W+AWPxVE1m2U=
X-Google-Smtp-Source: AGHT+IHlu+HBVoW0JipPEi+pQ0h66T87zzR+ZEBPrzqs/xghiLbIN+AjZnHB7NzrF8SUEKCCdTE9qgHcUWuqORl95Rs=
X-Received: by 2002:a2e:a7ca:0:b0:302:2565:6fea with SMTP id
 38308e7fff4ca-307da51cb89mr4936601fa.3.1738804840594; Wed, 05 Feb 2025
 17:20:40 -0800 (PST)
MIME-Version: 1.0
From: Kevin Zhao <kevin.zhao@linaro.org>
Date: Thu, 6 Feb 2025 09:20:29 +0800
X-Gm-Features: AWEUYZn4xbqfO1z7caoQTWC4LgdVjtqNbszKyIoDsTu_A_bu8HwTy2WmBddJXSg
Message-ID: <CACzn6-W5LWNNUu_zXFgFBHccqCSWgCGxHKouYicD81_LSCszdg@mail.gmail.com>
To: "lustre-devel@lists.lustre.org lustre-devel"
 <lustre-devel@lists.lustre.org>
Subject: [lustre-devel] unsubscribe
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
Content-Type: multipart/mixed; boundary="===============1972894695731545849=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============1972894695731545849==
Content-Type: multipart/alternative; boundary="000000000000db9c5a062d6f0c57"

--000000000000db9c5a062d6f0c57
Content-Type: text/plain; charset="UTF-8"

-- 
*Best Regards*

*Kevin Zhao*

Tech Lead, Linaro Data Center Group

Linaro Ecosystem Engineering

Slack(cloud-native.slack.com)

kevin.zhao@linaro.org | Mobile/Direct/Wechat:  +86 18818270915

--000000000000db9c5a062d6f0c57
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><br clear=3D"all"></div><div><br></div><span class=3D=
"gmail_signature_prefix">-- </span><br><div dir=3D"ltr" class=3D"gmail_sign=
ature" data-smartmail=3D"gmail_signature"><div dir=3D"ltr"><div dir=3D"ltr"=
><div dir=3D"ltr"><div dir=3D"ltr"><b>Best Regards</b><div><div style=3D"ma=
rgin:0px;padding:0px 0px 20px;width:1262px"><div style=3D"margin:8px 0px 0p=
x;padding:0px"><div dir=3D"ltr"><font><div dir=3D"ltr"><div dir=3D"ltr"><p =
class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto,Robo=
toDraft,Helvetica,Arial,sans-serif;font-size:medium"><b><span style=3D"font=
-size:11pt"><font color=3D"#38761d">Kevin Zhao</font></span></b></p><p clas=
s=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDr=
aft,Helvetica,Arial,sans-serif;font-size:medium"><font color=3D"#757b80"><s=
pan style=3D"font-size:14.6667px">Tech Lead, Linaro Data Center Group</span=
></font></p><p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-fam=
ily:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"><font c=
olor=3D"#757b80"><span style=3D"font-size:14.6667px">Linaro Ecosystem Engin=
eering</span></font></p><p class=3D"MsoNormal"><font color=3D"#757b80"><fon=
t color=3D"#888888" face=3D"Roboto, RobotoDraft, Helvetica, Arial, sans-ser=
if"><span style=3D"font-size:14.6667px">Slack(</span></font><font face=3D"R=
oboto, RobotoDraft, Helvetica, Arial, sans-serif"><span style=3D"font-size:=
14.6667px"><a href=3D"http://cloud-native.slack.com" target=3D"_blank">clou=
d-native.slack.com</a>)</span></font></font></p><p class=3D"MsoNormal" styl=
e=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial,=
sans-serif;font-size:medium"><font color=3D"#757b80"><span style=3D"font-si=
ze:14.6667px"><a href=3D"mailto:kevin.zhao@linaro.org" target=3D"_blank"><s=
pan>kevin.zhao@linaro.org</span></a>=C2=A0| Mobile/Direct/Wechat:=C2=A0 +86=
 18818270915</span></font><span style=3D"color:rgb(117,123,128);font-size:1=
1pt">=C2=A0</span><br></p><div style=3D"color:rgb(136,136,136);font-family:=
Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"><span style=
=3D"color:rgb(117,123,128);font-size:11pt"><img src=3D"https://ci3.googleus=
ercontent.com/mail-sig/AIorK4wc4TZ48IdDiJLbNdlQwblxliEGCLVTT3hP2H_ZygmvrR14=
MUBNPvReiaamhbY-528GfwvH-y-V6gky" width=3D"96" height=3D"16"><br></span></d=
iv></div></div></font></div><div style=3D"font-family:Roboto,RobotoDraft,He=
lvetica,Arial,sans-serif;font-size:medium"></div></div><div style=3D"font-f=
amily:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"></div=
></div></div></div></div></div></div></div></div>

--000000000000db9c5a062d6f0c57--

--===============1972894695731545849==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============1972894695731545849==--
