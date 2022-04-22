Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6B12AC433F5
	for <lustre-devel@archiver.kernel.org>; Fri, 22 Apr 2022 07:24:05 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E04E142A515;
	Fri, 22 Apr 2022 00:24:04 -0700 (PDT)
Received: from mail-oo1-f47.google.com (mail-oo1-f47.google.com
 [209.85.161.47])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1964D42A4A8
 for <lustre-devel@lists.lustre.org>; Fri, 22 Apr 2022 00:24:03 -0700 (PDT)
Received: by mail-oo1-f47.google.com with SMTP id
 e7-20020a4aaac7000000b00330e3ddfd4bso1258279oon.8
 for <lustre-devel@lists.lustre.org>; Fri, 22 Apr 2022 00:24:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:from:date:message-id:subject:to:cc;
 bh=1ZflQiRPOr8hO+cKkWcBvOG8HcPv4hOv8Omjomy4lnM=;
 b=sSK8/cRsW0KVfFpd1QzRoTXmUyESafY4ZxAVVg6VfDPbhu1vk4LNoaIPUAokcUO53B
 3Nppk49aOLmjMFrtEVwdjAx73qoK1gNwFlmqUYaTXGvkMX0t9vnTNiFsYkZOLH2WKW1a
 ztG1aMK4y2I2BBbfCTUmRqKWch4N/dF2pf/lV+6Zi4leoEz9erbcRQjoZRKKAUNbjXJs
 3avZz69ybQYUFSoHbH/FvQMDoGoQ9qB+Owg/q7pyIPbHbmkLQ11DFJuzZt11SjoMoT1P
 hpSCifeF6QDL8DWdsauDcjoLADf5LoMVyMjiuUZxOUGkuayx1ZRSBZ332xEcZ4T7Y4Ew
 JuyQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112;
 h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
 bh=1ZflQiRPOr8hO+cKkWcBvOG8HcPv4hOv8Omjomy4lnM=;
 b=WV0asBbW02H1D+fJG9pOOmRSpPJgeEbCtnRYLRei4pRPBZ//lv5seEXpCOQV9z3D6Y
 8f6i7FdLvfsjxFZaTOjQd6mkEfoR5KFh1bc00kuxX2qdbL1OmO8yRJQ9KZpSLbRe1QH9
 AvoJkZ+DYtE+zQFnr4WYWgeNLWIIMhy9+KDVQ2plSxZB/6kQkk6n7R5WNcLuVdYTDEo3
 78uidX93aRJPP5+XWrpol8ZDXrQUWVybN1vozZdVsvkPsBbiJZfs0yJTmgEO78L3CCx+
 8zayU2G4frVKmZUsYAyN7LsQ3nro1LHAupW71tLGJpzylBpnRccQ0malehz9zuIjEGFy
 JURg==
X-Gm-Message-State: AOAM530xR+E2CsM3oEBQ8KeV+6FDTqwzeUxjb0CRn3b9Pmp56T+7y3sa
 5RPaYbDz4fU8knHy1tb5rrrH+EqRpu+fKnsvSDXvnnuMVE02
X-Google-Smtp-Source: ABdhPJzVDDN1exHGDU25mFqSnQKAB6Aa8fgzN/+VsEV0mJ42y8wTEK2VTkfGnGertejzLMN+daOdFtEvPnDIA+H2eEU=
X-Received: by 2002:a4a:4ec2:0:b0:331:7bb3:a61b with SMTP id
 r185-20020a4a4ec2000000b003317bb3a61bmr1109996ooa.13.1650612242206; Fri, 22
 Apr 2022 00:24:02 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 22 Apr 2022 15:23:50 +0800
Message-ID: <CACzn6-XNRn5DwANNghgEgUjOosJ1=PTzJ0TOfd0VtbVYmoZ8Mw@mail.gmail.com>
To: "lustre-devel@lists.lustre.org lustre-devel"
 <lustre-devel@lists.lustre.org>
Subject: [lustre-devel] The Progress of Arm64 External Tester and Builder
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
Cc: Li Xi <lixi@ddn.com>, Jian Yu <jiyu@whamcloud.com>
Content-Type: multipart/mixed; boundary="===============1701319320134079993=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============1701319320134079993==
Content-Type: multipart/alternative; boundary="0000000000005be75505dd391ca6"

--0000000000005be75505dd391ca6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Lustre,

Xinliang and I are from Linaro, and we=E2=80=99ve worked on Lustre on the A=
rm64 for
several months. Now we=E2=80=99ve enabled the external Arm64 builder and te=
st.

The external arm64 CI architecture is like below:

We=E2=80=99ve set up an external Jenkins to handle this. Currently, it is o=
n an
self-setup jenkins  <http://213.146.155.72:8080/>

Now we have:

   -

   Lustre Build Job
   <http://213.146.155.72:8080/job/project-lustre-build-release-master/>:
   watch gerrit change and build Lustre packages, then move them to a self
   setup Yum repo. Now due to easy test, we just run it once every to grab =
the
   latest version. Will move to on-trigger after we get more machines.
   -

   Lustre test job
   <http://213.146.155.72:8080/job/project-lustre-periodical-test/>:
   Jenkins pipeline. Using Terraform to provision arm64 vms in an OpenStack
   cluster. And then configure the test vms and run. Currently we just test
   sanity test suites. Usually cost 4-5 hours for the whole jobs.

TODO:

   -

   Test: Cover more tests suites, needs to provision more machines for this=
.
   -

   Move to Linaro Jenkins: https://ci.linaro.org  after the test becomes
   stable.
   -

   Build more Arm64 Release and publish for experiment use.


*And 2 things below need the community=E2=80=99s confirmation and help*:

   -

   We don=E2=80=99t have Maloo DB account or token, so currently we can not=
 post
   the data to Maloo DB for the upstream developers to see the test
   consequence.
   -

   We have now built and maintained a yum repository for Lustre and
   e2fsprogs at http://213.146.155.48/repo/. We plan to share the tested
   Arm64 RPMs in case anyone wants to try Lustre on Arm quickly, can we put
   them into the Lustre official repo
   https://downloads.whamcloud.com/public/lustre/ as an experimental releas=
e?
   Or if we can=E2=80=99t, another proposal, is it possible for the communi=
ty to
   have an entry in the https://www.lustre.org/download/ point to the
   external Arm64 yum repo?


Thanks in advance and look forward to hearing from you soon. Really
appreciate the help from Lustre upstream during the last several months for
Lustre on Arm64 bugfix and test.

--=20
*Best Regards*

*Kevin Zhao*

Tech Lead, LDCG Cloud Infrastructure

Linaro Vertical Technologies

IRC(freenode): kevinz

Slack(kubernetes.slack.com): kevinz

kevin.zhao@linaro.org | Mobile/Direct/Wechat:  +86 18818270915

--0000000000005be75505dd391ca6
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><span id=3D"gmail-docs-internal-guid-bf78b256-7fff-fed1-32=
e6-5692649117fe"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;ma=
rgin-bottom:0pt"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(=
0,0,0);background-color:transparent;font-variant-numeric:normal;font-varian=
t-east-asian:normal;vertical-align:baseline;white-space:pre-wrap">Hi Lustre=
,</span></p><br><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;mar=
gin-bottom:0pt"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0=
,0,0);background-color:transparent;font-variant-numeric:normal;font-variant=
-east-asian:normal;vertical-align:baseline;white-space:pre-wrap">Xinliang a=
nd I are from Linaro, and we=E2=80=99ve worked on Lustre on the Arm64 for s=
everal months. Now we=E2=80=99ve enabled the external Arm64 builder and tes=
t.</span></p><br><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;ma=
rgin-bottom:0pt"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(=
0,0,0);background-color:transparent;font-variant-numeric:normal;font-varian=
t-east-asian:normal;vertical-align:baseline;white-space:pre-wrap">The exter=
nal arm64 CI architecture is like below:</span></p><p dir=3D"ltr" style=3D"=
line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size=
:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent;font-=
variant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseli=
ne;white-space:pre-wrap"><span style=3D"border:none;display:inline-block;ov=
erflow:hidden;width:652px;height:367px"><img src=3D"https://lh5.googleuserc=
ontent.com/rq2aUSmGeWYT0UNjeljCVRjzwbrmwy1z3ciMwoBT0smgkZQ5g9LKPJEk75ZAdgXL=
b1CqOoo0v5qMA2Wsw1jUyPK0Anm1hbLxP543XWxikD95cwpa9v9tbBQW6WLc-q-ShbQNSnA" wi=
dth=3D"652" height=3D"367" style=3D"margin-left: 0px; margin-top: 0px;"></s=
pan></span></p><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;marg=
in-bottom:0pt"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,=
0,0);background-color:transparent;font-variant-numeric:normal;font-variant-=
east-asian:normal;vertical-align:baseline;white-space:pre-wrap">We=E2=80=99=
ve set up an external Jenkins to handle this. Currently, it is on </span><a=
 href=3D"http://213.146.155.72:8080/" style=3D"text-decoration-line:none"><=
span style=3D"font-size:11pt;font-family:Arial;background-color:transparent=
;font-variant-numeric:normal;font-variant-east-asian:normal;text-decoration=
-line:underline;vertical-align:baseline;white-space:pre-wrap">an self-setup=
 jenkins=C2=A0</span></a></p><p dir=3D"ltr" style=3D"line-height:1.38;margi=
n-top:0pt;margin-bottom:0pt"><span style=3D"font-size:11pt;font-family:Aria=
l;color:rgb(0,0,0);background-color:transparent;font-variant-numeric:normal=
;font-variant-east-asian:normal;vertical-align:baseline;white-space:pre-wra=
p">Now we have:</span></p><ul style=3D"margin-top:0px;margin-bottom:0px"><l=
i dir=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font-family:Aria=
l;color:rgb(0,0,0);background-color:transparent;font-variant-numeric:normal=
;font-variant-east-asian:normal;vertical-align:baseline;white-space:pre"><p=
 dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" ro=
le=3D"presentation"><a href=3D"http://213.146.155.72:8080/job/project-lustr=
e-build-release-master/" style=3D"text-decoration-line:none"><span style=3D=
"font-size:11pt;background-color:transparent;font-variant-numeric:normal;fo=
nt-variant-east-asian:normal;text-decoration-line:underline;vertical-align:=
baseline;white-space:pre-wrap">Lustre Build Job</span></a><span style=3D"fo=
nt-size:11pt;background-color:transparent;font-variant-numeric:normal;font-=
variant-east-asian:normal;vertical-align:baseline;white-space:pre-wrap">: w=
atch gerrit change and build Lustre packages, then move them to a self setu=
p Yum repo. Now due to easy test, we just run it once every to grab the lat=
est version. Will move to on-trigger after we get more machines.</span></p>=
</li><li dir=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font-fami=
ly:Arial;color:rgb(0,0,0);background-color:transparent;font-variant-numeric=
:normal;font-variant-east-asian:normal;vertical-align:baseline;white-space:=
pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:=
0pt" role=3D"presentation"><a href=3D"http://213.146.155.72:8080/job/projec=
t-lustre-periodical-test/" style=3D"text-decoration-line:none"><span style=
=3D"font-size:11pt;background-color:transparent;font-variant-numeric:normal=
;font-variant-east-asian:normal;text-decoration-line:underline;vertical-ali=
gn:baseline;white-space:pre-wrap">Lustre test job</span></a><span style=3D"=
font-size:11pt;background-color:transparent;font-variant-numeric:normal;fon=
t-variant-east-asian:normal;vertical-align:baseline;white-space:pre-wrap">:=
 Jenkins pipeline. Using Terraform to provision arm64 vms in an OpenStack c=
luster. And then configure the test vms and run. Currently we just test san=
ity test suites. Usually cost 4-5 hours for the whole jobs.</span></p></li>=
</ul><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:=
0pt"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);backg=
round-color:transparent;font-variant-numeric:normal;font-variant-east-asian=
:normal;vertical-align:baseline;white-space:pre-wrap">TODO:</span></p><ul s=
tyle=3D"margin-top:0px;margin-bottom:0px"><li dir=3D"ltr" style=3D"list-sty=
le-type:disc;font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-c=
olor:transparent;font-variant-numeric:normal;font-variant-east-asian:normal=
;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-heig=
ht:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span style=
=3D"font-size:11pt;background-color:transparent;font-variant-numeric:normal=
;font-variant-east-asian:normal;vertical-align:baseline;white-space:pre-wra=
p">Test: Cover more tests suites, needs to provision more machines for this=
.</span></p></li><li dir=3D"ltr" style=3D"list-style-type:disc;font-size:11=
pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent;font-var=
iant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;=
white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;ma=
rgin-bottom:0pt" role=3D"presentation"><span style=3D"font-size:11pt;backgr=
ound-color:transparent;font-variant-numeric:normal;font-variant-east-asian:=
normal;vertical-align:baseline;white-space:pre-wrap">Move to Linaro Jenkins=
: </span><a href=3D"https://ci.linaro.org" style=3D"text-decoration-line:no=
ne"><span style=3D"font-size:11pt;background-color:transparent;font-variant=
-numeric:normal;font-variant-east-asian:normal;text-decoration-line:underli=
ne;vertical-align:baseline;white-space:pre-wrap">https://ci.linaro.org</spa=
n></a><span style=3D"font-size:11pt;background-color:transparent;font-varia=
nt-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;wh=
ite-space:pre-wrap">=C2=A0 after the test becomes stable.</span></p></li><l=
i dir=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font-family:Aria=
l;color:rgb(0,0,0);background-color:transparent;font-variant-numeric:normal=
;font-variant-east-asian:normal;vertical-align:baseline;white-space:pre"><p=
 dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" ro=
le=3D"presentation"><span style=3D"font-size:11pt;background-color:transpar=
ent;font-variant-numeric:normal;font-variant-east-asian:normal;vertical-ali=
gn:baseline;white-space:pre-wrap">Build more Arm64 Release and publish for =
experiment use.</span></p></li></ul><br><p dir=3D"ltr" style=3D"line-height=
:1.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size:11pt;font-=
family:Arial;color:rgb(0,0,0);background-color:transparent;font-variant-num=
eric:normal;font-variant-east-asian:normal;vertical-align:baseline;white-sp=
ace:pre-wrap"><b>And 2 things below need the community=E2=80=99s confirmati=
on and help</b>:=C2=A0</span></p><ul style=3D"margin-top:0px;margin-bottom:=
0px"><li dir=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font-fami=
ly:Arial;color:rgb(0,0,0);background-color:transparent;font-variant-numeric=
:normal;font-variant-east-asian:normal;vertical-align:baseline;white-space:=
pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:=
0pt" role=3D"presentation"><span style=3D"font-size:11pt;background-color:t=
ransparent;font-variant-numeric:normal;font-variant-east-asian:normal;verti=
cal-align:baseline;white-space:pre-wrap">We don=E2=80=99t have Maloo DB acc=
ount or token, so currently we can not post the data to Maloo DB for the up=
stream developers to see the test consequence.</span></p></li><li dir=3D"lt=
r" style=3D"list-style-type:disc;font-size:11pt;font-family:Arial;color:rgb=
(0,0,0);background-color:transparent;font-variant-numeric:normal;font-varia=
nt-east-asian:normal;vertical-align:baseline;white-space:pre"><p dir=3D"ltr=
" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"prese=
ntation"><span style=3D"font-size:11pt;background-color:transparent;font-va=
riant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline=
;white-space:pre-wrap">We have now built and maintained a yum repository fo=
r Lustre and e2fsprogs at </span><a href=3D"http://213.146.155.48/repo/" st=
yle=3D"text-decoration-line:none"><span style=3D"font-size:11pt;background-=
color:transparent;font-variant-numeric:normal;font-variant-east-asian:norma=
l;text-decoration-line:underline;vertical-align:baseline;white-space:pre-wr=
ap">http://213.146.155.48/repo/</span></a><span style=3D"font-size:11pt;bac=
kground-color:transparent;font-variant-numeric:normal;font-variant-east-asi=
an:normal;vertical-align:baseline;white-space:pre-wrap">. We plan to share =
the tested Arm64 RPMs in case anyone wants to try Lustre on Arm quickly, </=
span><span style=3D"font-size:11pt;background-color:transparent;font-weight=
:700;font-variant-numeric:normal;font-variant-east-asian:normal;vertical-al=
ign:baseline;white-space:pre-wrap">can we put them into the Lustre official=
 repo</span><span style=3D"font-size:11pt;background-color:transparent;font=
-variant-numeric:normal;font-variant-east-asian:normal;vertical-align:basel=
ine;white-space:pre-wrap"> </span><a href=3D"https://downloads.whamcloud.co=
m/public/lustre/" style=3D"text-decoration-line:none"><span style=3D"font-s=
ize:11pt;background-color:transparent;font-variant-numeric:normal;font-vari=
ant-east-asian:normal;text-decoration-line:underline;vertical-align:baselin=
e;white-space:pre-wrap">https://downloads.whamcloud.com/public/lustre/</spa=
n></a><span style=3D"font-size:11pt;background-color:transparent;font-varia=
nt-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;wh=
ite-space:pre-wrap"> </span><span style=3D"font-size:11pt;background-color:=
transparent;font-weight:700;font-variant-numeric:normal;font-variant-east-a=
sian:normal;vertical-align:baseline;white-space:pre-wrap">as an experimenta=
l release</span><span style=3D"font-size:11pt;background-color:transparent;=
font-variant-numeric:normal;font-variant-east-asian:normal;vertical-align:b=
aseline;white-space:pre-wrap">? Or if we can=E2=80=99t, another proposal,</=
span><span style=3D"font-size:11pt;background-color:transparent;font-weight=
:700;font-variant-numeric:normal;font-variant-east-asian:normal;vertical-al=
ign:baseline;white-space:pre-wrap"> is it possible for the community to hav=
e an entry in the </span><a href=3D"https://www.lustre.org/download/" style=
=3D"text-decoration-line:none"><span style=3D"font-size:11pt;background-col=
or:transparent;font-variant-numeric:normal;font-variant-east-asian:normal;t=
ext-decoration-line:underline;vertical-align:baseline;white-space:pre-wrap"=
>https://www.lustre.org/download/</span></a><span style=3D"font-size:11pt;b=
ackground-color:transparent;font-variant-numeric:normal;font-variant-east-a=
sian:normal;vertical-align:baseline;white-space:pre-wrap"> </span><span sty=
le=3D"font-size:11pt;background-color:transparent;font-weight:700;font-vari=
ant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;w=
hite-space:pre-wrap">point to the external Arm64 yum repo?</span></p></li><=
/ul><div><font color=3D"#000000" face=3D"Arial"><span style=3D"font-size:14=
.6667px;white-space:pre-wrap"><b><br></b></span></font></div><div><font col=
or=3D"#000000" face=3D"Arial"><span style=3D"font-size:14.6667px;white-spac=
e:pre-wrap">Thanks in advance and look forward to hearing from you soon. Re=
ally appreciate the help from Lustre upstream during the last several month=
s for Lustre on Arm64 bugfix and test.</span></font></div></span><div><br><=
/div>-- <br><div dir=3D"ltr" class=3D"gmail_signature" data-smartmail=3D"gm=
ail_signature"><div dir=3D"ltr"><div><div dir=3D"ltr"><div><div dir=3D"ltr"=
><div dir=3D"ltr"><b>Best Regards</b><div><div style=3D"margin:0px;padding:=
0px 0px 20px;width:1262px"><div><div style=3D"margin:8px 0px 0px;padding:0p=
x"><div><div dir=3D"ltr"><font><div dir=3D"ltr"><div dir=3D"ltr"><p class=
=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDra=
ft,Helvetica,Arial,sans-serif;font-size:medium"><b><span style=3D"font-size=
:11pt"><font color=3D"#38761d">Kevin Zhao</font></span></b></p><p class=3D"=
MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,H=
elvetica,Arial,sans-serif;font-size:medium"><font color=3D"#757b80"><span s=
tyle=3D"font-size:14.6667px">Tech Lead, LDCG Cloud Infrastructure</span></f=
ont></p><p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:=
Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"><font color=
=3D"#757b80"><span style=3D"font-size:14.6667px">Linaro Vertical Technologi=
es</span></font></p><p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);=
font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"=
><font color=3D"#757b80"><span style=3D"font-size:14.6667px">IRC(freenode):=
 kevinz</span></font></p><p class=3D"MsoNormal"><font color=3D"#757b80"><fo=
nt color=3D"#888888" face=3D"Roboto, RobotoDraft, Helvetica, Arial, sans-se=
rif"><span style=3D"font-size:14.6667px">Slack(</span></font><font face=3D"=
Roboto, RobotoDraft, Helvetica, Arial, sans-serif"><span style=3D"font-size=
:14.6667px"><a href=3D"http://kubernetes.slack.com" target=3D"_blank">kuber=
netes.slack.com</a>)</span></font><font color=3D"#888888" face=3D"Roboto, R=
obotoDraft, Helvetica, Arial, sans-serif"><span style=3D"font-size:14.6667p=
x">: kevinz</span></font></font></p><p class=3D"MsoNormal" style=3D"color:r=
gb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;f=
ont-size:medium"><font color=3D"#757b80"><span style=3D"font-size:14.6667px=
"><a href=3D"mailto:kevin.zhao@linaro.org" target=3D"_blank"><span>kevin.zh=
ao@linaro.org</span></a>=C2=A0| Mobile/Direct/Wechat:=C2=A0 +86 18818270915=
</span></font><span style=3D"color:rgb(117,123,128);font-size:11pt">=C2=A0<=
/span><br></p><div style=3D"color:rgb(136,136,136);font-family:Roboto,Robot=
oDraft,Helvetica,Arial,sans-serif;font-size:medium"><span style=3D"color:rg=
b(117,123,128);font-size:11pt"><br></span></div></div></div></font></div><d=
iv style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-=
size:medium"></div></div></div><div style=3D"font-family:Roboto,RobotoDraft=
,Helvetica,Arial,sans-serif;font-size:medium"></div></div></div></div></div=
></div></div></div></div></div></div></div>

--0000000000005be75505dd391ca6--

--===============1701319320134079993==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============1701319320134079993==--
