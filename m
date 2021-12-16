Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7C795C433F5
	for <lustre-devel@archiver.kernel.org>; Thu, 16 Dec 2021 08:24:32 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CA17E21F414;
	Thu, 16 Dec 2021 00:24:31 -0800 (PST)
Received: from mail-yb1-f175.google.com (mail-yb1-f175.google.com
 [209.85.219.175])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D0FEB21E09F
 for <lustre-devel@lists.lustre.org>; Thu, 16 Dec 2021 00:24:29 -0800 (PST)
Received: by mail-yb1-f175.google.com with SMTP id v203so62566573ybe.6
 for <lustre-devel@lists.lustre.org>; Thu, 16 Dec 2021 00:24:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:from:date:message-id:subject:to:cc;
 bh=lCjaGpVFwvfa7wJNeITqhLE4fNKzOqU/Rf3CEDlc+n4=;
 b=FlxXzbkq9bW1cmj3cNneTO0qhnPcB55VVN9MOT4Bkg4KbTys3YNi/R4f4dO/r12b+7
 DpC7HFM2+4vieWmTUZiJ/u6PcVUZYifLe0pmImqMh4z79Xwp0ZF9bb9k+2xAJYtOhp1G
 pJTmZrqprYrAoZ8Lj+ls6+egZMa+TpOfZbl7B14hL6YInzDmJG+EfQynsEn1LypjhiBi
 Oi4MS6DPy0npcgjmrENKSiptoENsSiJKPuvYCAGkLjZRSY8j3NhcXNZv7begWAQG3zxE
 280Lv0OGgEZzXHRfh+cnfrUK0tdgcEDkHxw3dcYIdIf+WXUo0uNha1+Cfg8/FA1+GZtL
 OtjA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112;
 h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
 bh=lCjaGpVFwvfa7wJNeITqhLE4fNKzOqU/Rf3CEDlc+n4=;
 b=evGhB+iC0KHvm8qv3aw6+Gis6JU4m2WTxe/0UJk/q0eu75YFpLGa002bXtaHwReT6h
 zx0CbGLuozyFSTr/zEq935v1bbnyK2iu6m5w5AunRB9GktsEguZ6O/WC+1WmhQQYAGbZ
 VYz04jEbDLrCZFosUqqFX9Y09+WVxTZQBL7LdygKT0T8PdMSmmLOB/MH+Hc44iMN4RdK
 3Aq85zNElB0PVbxS2xrB9tWJA/f1dz25q/28lYPa3wKU3A8hEnDsuAjepGCDO3St8Rea
 lohPdl5XOBqYykoYM90GusJ15C6RzpNRr2w9D0G1SJ9vvq06n/ao6exIRSOSwP/Oaa+r
 +FWg==
X-Gm-Message-State: AOAM533z9ybPk5UZWkq/TU9GmSxs435vQEbyFJOA3RIYtDcDYyXttamr
 /po60vOcD2NZPIq/ManpMYI50fvm9cdAs4hhBTDQLg==
X-Google-Smtp-Source: ABdhPJyauk6CyZralcxXwxsmCGrKPMFsTYzaXpTuDeYYKR4xC7cLFPIQBDo7yL3uMuoOrauTPUIpVceqTjavdM1FBp4=
X-Received: by 2002:a25:d2ca:: with SMTP id
 j193mr11435603ybg.419.1639643068957; 
 Thu, 16 Dec 2021 00:24:28 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 16 Dec 2021 16:23:52 +0800
Message-ID: <CAKoKPby+hn5+py-f11c31Po241871un0v=SQM+Cc6_hzvxW8uA@mail.gmail.com>
To: Peter Jones <pjones@whamcloud.com>
Subject: [lustre-devel] Lustre Arm stuff status and work plan
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
Cc: Jian Yu <jiyu@whamcloud.com>, lixi@ddn.com,
 cloud-dev-request@op-lists.linaro.org, lustre-devel@lists.lustre.org
Content-Type: multipart/mixed; boundary="===============4761974771498739341=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============4761974771498739341==
Content-Type: multipart/alternative; boundary="000000000000af1da705d33f26cb"

--000000000000af1da705d33f26cb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

*Hi Peter and all,As Kevin(on cc) and I have been working on Lustre Arm
stuff for some time. We want to give a status and progress report to the
community and list our work plan for the next year. Please help to review
our work plan and give some comments and suggestions. Thanks.*Status and
Progress












*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DRelease - No A=
rm packages built on official community
release <https://downloads.whamcloud.com/public/lustre/> yet.Build -
Verified Lustre, openZFS build and multi-nodes setup on Arm64 CentOS 8, all
are ok.- Lbuild script support for Arm is on review
<https://review.whamcloud.com/#/c/45691/>, LU-15293
<https://jira.whamcloud.com/browse/LU-15293>.CI - No Arm server end CI
support yet.- Arm client with x86_64 server test is already in the CI
gate.- Only run a few ldiskfs test suites(sanity, sanity-sec,
sanctity-lnet, etc.), not a full test.- A full test
<https://review.whamcloud.com/#/c/44760/> (with empty GRANT_CHECK_LIST)
shows several Arm client related failed test cases, see test results page
<https://testing.whamcloud.com/test_sessions?jobs=3Dlustre-reviews&builds=
=3D82774&start_date=3D2021-08-26#redirect>-
sanity test 317: LU-11667 <https://jira.whamcloud.com/browse/LU-11667>
(Workaround fix landed)- sanityn test 16a: LU-11597
<https://jira.whamcloud.com/browse/LU-11597>, test 71a: LU-11787
<https://jira.whamcloud.com/browse/LU-11787>- conf-sanity test 98: LU-11785
<https://jira.whamcloud.com/browse/LU-11785>, test 112: LU-13813
<https://jira.whamcloud.com/browse/LU-13813>- sanity-flr test 50a: LU-14970
<https://jira.whamcloud.com/browse/LU-14970>- sanity-pcc test 7a: LU-14346
<https://jira.whamcloud.com/browse/LU-14346>Arm server end test on local
setup - Run a full ldiskfs test with all test suites.- Due to the multi
MDTs crash issue, some multi MDTs tests are not run.- Many new failed tests
come, see the google sheet
<https://docs.google.com/spreadsheets/d/1EE5zU96_lqlkS0uk6NJeeNBrikYpd_ZEO7=
hdVt5spsw/edit#gid=3D969410610>for
details.- The openZFS full test is not run, but heard that it should be
more stable than ldiskfs.Bugfix - Old Arm always_except bugs
https://jira.whamcloud.com/issues/?filter=3D15555
<https://jira.whamcloud.com/issues/?filter=3D15555> , the Arm related ones
are almost addressed.- LU-11596
<https://jira.whamcloud.com/browse/LU-11596>, LU-11597
<https://jira.whamcloud.com/browse/LU-11597>, LU-14067
<https://jira.whamcloud.com/browse/LU-14067>, LU-11787
<https://jira.whamcloud.com/browse/LU-11787>: addressed, patch sent and
waiting for Arm client CI recovery to land.- LU-10073
<https://jira.whamcloud.com/browse/LU-10073>, LU-11671
<https://jira.whamcloud.com/browse/LU-11671>: can't be reproduced on Arm or
happen on x86_64 also.- Other old Arm bugs  LU-11785
<https://jira.whamcloud.com/browse/LU-11785>, LU-13813
<https://jira.whamcloud.com/browse/LU-13813>, LU-14970
<https://jira.whamcloud.com/browse/LU-14970>, LU-14346
<https://jira.whamcloud.com/browse/LU-14346> to be fixed.- New created
server end bugs - LU-15122 <https://jira.whamcloud.com/browse/LU-15122> :
ASSERTION( iobuf->dr_rw =3D=3D 0 ) crash issue, fixed patch is landed. -
LU-15364 <https://jira.whamcloud.com/browse/LU-15364>: multi MDTs kernel
oops issue, related to atomic unaligned memory access, work in progress.-
LU-15223 <https://jira.whamcloud.com/browse/LU-15223>: 64K page size
read/write improvement, long-term work, in progress. - Full Arm related bug
list with label arm: https://jira.whamcloud.com/issues/?filter=3D16710
<https://jira.whamcloud.com/issues/?filter=3D16710>- is not that ready for
production.Reference to:James Simmons=E2=80=99 Lustre Arm update:
https://connect.linaro.org/resources/san19/san19-224/
<https://connect.linaro.org/resources/san19/san19-224/>*Work Plan




*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D - Lustre Server End Critical Bug Fix target=
 2022-06- Lustre
Multiple MDTs kernel OOPS when stripe issue: LU-15364
<https://jira.whamcloud.com/browse/LU-15364>- Lustre hangs at Sanity Test
807- Lustre Conf-sanity test 44 kernel crash- Lustre Conf sanity case 58
kernel crash- Lustre Conf sanity case 78 kernel crash- Lustre Conf sanity
case 79 crash- Lustre sanity-pcc 7a case hang the cluster- Lustre Server
End Non-critical Bug Fix target 2022-12- Lustre Sanity failure cases: 33
cases- Lustre server replay-single: 1 case- Lustre sanity-flr 200 cases
fix: 1 case - Lustre sanity-hsm failure cases: 25 cases- Lustre
lustre-rsync-test failure test: 3- Lustre recovery-small/sanity-scrub: 2-
Lustre sanityn test cases fix: 12- Lustre sanity-lfsck failure cases fix:
3- Lustre sanity-sec failure cases fix =EF=BC=9A7 - Lustre sanity-lnet fail=
ure
cases test fix: 2- Continuous add more test suites for Arm client CI ??-
Once a  test suite is all passed for Arm then add it into CI.- Server CI
support for Arm on Centos8 ??- Ideally, Arm server CI can come with Arm
server end fixes patches and ensure future patches merged don=E2=80=99t mak=
e any
regressions on Arm.- As the test infra is not open source and maintained by
whamcloud, it might need whamcloud to make it ??- Other works in future-
Test other distros like ubuntu, SUSE etc.- Test x86 client with Arm64
Server - Basic Optimised: CRC/AES- All-flash optimizationBest
Regards,Xinliang*

--000000000000af1da705d33f26cb
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><span id=3D"gmail-docs-internal-guid-9b12d089-7fff-4dcb-25=
87-1d0a5b342a3a"><h3 dir=3D"ltr" style=3D"line-height:1.38;margin-top:16pt;=
margin-bottom:4pt"><b style=3D"font-weight:normal" id=3D"gmail-docs-interna=
l-guid-e3b48fd0-7fff-044f-fe82-d7a88c0b9bc0"><p dir=3D"ltr" style=3D"line-h=
eight:1.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"background-colo=
r:transparent;color:rgb(0,0,0);font-family:Arial;font-size:11pt;white-space=
:pre-wrap">Hi Peter and all,</span><br></p><p dir=3D"ltr" style=3D"line-hei=
ght:1.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size:11pt;fo=
nt-family:Arial;color:rgb(0,0,0);background-color:transparent;font-weight:4=
00;font-style:normal;font-variant:normal;text-decoration:none;vertical-alig=
n:baseline;white-space:pre-wrap">As Kevin(on cc) and I have been working on=
 Lustre Arm stuff for some time. </span></p><p dir=3D"ltr" style=3D"line-he=
ight:1.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size:11pt;f=
ont-family:Arial;color:rgb(0,0,0);background-color:transparent;font-weight:=
400;font-style:normal;font-variant:normal;text-decoration:none;vertical-ali=
gn:baseline;white-space:pre-wrap">We want to give a status and progress rep=
ort to the community and list our work plan for the next year. </span></p><=
p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><=
span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-=
color:transparent;font-weight:400;font-style:normal;font-variant:normal;tex=
t-decoration:none;vertical-align:baseline;white-space:pre-wrap">Please help=
 to review our work plan and give some comments and suggestions. Thanks.</s=
pan></p></b></h3><h3 dir=3D"ltr" style=3D"line-height:1.38;margin-top:16pt;=
margin-bottom:4pt"><span style=3D"font-size:14pt;font-family:Arial;color:rg=
b(67,67,67);background-color:transparent;font-weight:400;font-style:normal;=
font-variant:normal;text-decoration:none;vertical-align:baseline;white-spac=
e:pre-wrap">Status and Progress</span></h3><h3 dir=3D"ltr" style=3D"line-he=
ight:1.38;margin-top:16pt;margin-bottom:4pt"><b style=3D"font-weight:normal=
"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt=
"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);backgrou=
nd-color:transparent;font-weight:400;font-style:normal;font-variant:normal;=
text-decoration:none;vertical-align:baseline;white-space:pre-wrap">=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D</span></p><p dir=3D"=
ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span styl=
e=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:tra=
nsparent;font-weight:400;font-style:normal;font-variant:normal;text-decorat=
ion:none;vertical-align:baseline;white-space:pre-wrap">Release</span></p><u=
l style=3D"margin-top:0px;margin-bottom:0px"><li dir=3D"ltr" style=3D"list-=
style-type:disc;font-size:11pt;font-family:Muli,sans-serif;color:rgb(0,0,0)=
;background-color:transparent;font-weight:400;font-style:normal;font-varian=
t:normal;text-decoration:none;vertical-align:baseline;white-space:pre"><p d=
ir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=
=3D"presentation"><span style=3D"font-size:11pt;font-family:Arial;color:rgb=
(0,0,0);background-color:transparent;font-weight:400;font-style:normal;font=
-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pr=
e-wrap">No Arm packages built on official community </span><a href=3D"https=
://downloads.whamcloud.com/public/lustre/" style=3D"text-decoration:none"><=
span style=3D"font-size:11pt;font-family:Arial;color:rgb(17,85,204);backgro=
und-color:transparent;font-weight:400;font-style:normal;font-variant:normal=
;text-decoration:underline;vertical-align:baseline;white-space:pre-wrap">re=
lease</span></a><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0=
,0,0);background-color:transparent;font-weight:400;font-style:normal;font-v=
ariant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-=
wrap"> yet.</span></p></li></ul><p dir=3D"ltr" style=3D"line-height:1.38;ma=
rgin-top:0pt;margin-bottom:0pt"><span style=3D"font-size:11pt;font-family:A=
rial;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-sty=
le:normal;font-variant:normal;text-decoration:none;vertical-align:baseline;=
white-space:pre-wrap">Build</span></p><ul style=3D"margin-top:0px;margin-bo=
ttom:0px"><li dir=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font=
-family:Muli,sans-serif;color:rgb(0,0,0);background-color:transparent;font-=
weight:400;font-style:normal;font-variant:normal;text-decoration:none;verti=
cal-align:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.3=
8;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span style=3D"fo=
nt-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparen=
t;font-weight:400;font-style:normal;font-variant:normal;text-decoration:non=
e;vertical-align:baseline;white-space:pre-wrap">Verified Lustre, openZFS bu=
ild and multi-nodes setup on Arm64 CentOS 8, all are ok.</span></p></li><li=
 dir=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font-family:Muli,=
sans-serif;color:rgb(0,0,0);background-color:transparent;font-weight:400;fo=
nt-style:normal;font-variant:normal;text-decoration:none;vertical-align:bas=
eline;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:=
0pt;margin-bottom:0pt" role=3D"presentation"><span style=3D"font-size:11pt;=
font-family:Arial;color:rgb(0,0,0);background-color:transparent;font-weight=
:400;font-style:normal;font-variant:normal;text-decoration:none;vertical-al=
ign:baseline;white-space:pre-wrap">Lbuild script support for Arm is on </sp=
an><a href=3D"https://review.whamcloud.com/#/c/45691/" style=3D"text-decora=
tion:none"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(17,85,=
204);background-color:transparent;font-weight:400;font-style:normal;font-va=
riant:normal;text-decoration:underline;vertical-align:baseline;white-space:=
pre-wrap">review</span></a><span style=3D"font-size:11pt;font-family:Arial;=
color:rgb(0,0,0);background-color:transparent;font-weight:400;font-style:no=
rmal;font-variant:normal;text-decoration:none;vertical-align:baseline;white=
-space:pre-wrap">, </span><a href=3D"https://jira.whamcloud.com/browse/LU-1=
5293" style=3D"text-decoration:none"><span style=3D"font-size:10.5pt;font-f=
amily:Roboto,sans-serif;color:rgb(0,101,255);background-color:transparent;f=
ont-weight:400;font-style:normal;font-variant:normal;text-decoration:underl=
ine;vertical-align:baseline;white-space:pre-wrap">LU-15293</span></a><span =
style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color=
:transparent;font-weight:400;font-style:normal;font-variant:normal;text-dec=
oration:none;vertical-align:baseline;white-space:pre-wrap">.</span></p></li=
></ul><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom=
:0pt"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);back=
ground-color:transparent;font-weight:400;font-style:normal;font-variant:nor=
mal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap">CI</=
span></p><ul style=3D"margin-top:0px;margin-bottom:0px"><li dir=3D"ltr" sty=
le=3D"list-style-type:disc;font-size:11pt;font-family:Muli,sans-serif;color=
:rgb(0,0,0);background-color:transparent;font-weight:400;font-style:normal;=
font-variant:normal;text-decoration:none;vertical-align:baseline;white-spac=
e:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-botto=
m:0pt" role=3D"presentation"><span style=3D"font-size:11pt;font-family:Aria=
l;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-style:=
normal;font-variant:normal;text-decoration:none;vertical-align:baseline;whi=
te-space:pre-wrap">No Arm server end CI support yet.</span></p></li><li dir=
=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font-family:Muli,sans=
-serif;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-s=
tyle:normal;font-variant:normal;text-decoration:none;vertical-align:baselin=
e;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;=
margin-bottom:0pt" role=3D"presentation"><span style=3D"font-size:11pt;font=
-family:Arial;color:rgb(0,0,0);background-color:transparent;font-weight:400=
;font-style:normal;font-variant:normal;text-decoration:none;vertical-align:=
baseline;white-space:pre-wrap">Arm client with x86_64 server test is alread=
y in the CI gate.</span></p></li><ul style=3D"margin-top:0px;margin-bottom:=
0px"><li dir=3D"ltr" style=3D"list-style-type:circle;font-size:11pt;font-fa=
mily:Muli,sans-serif;color:rgb(0,0,0);background-color:transparent;font-wei=
ght:400;font-style:normal;font-variant:normal;text-decoration:none;vertical=
-align:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;m=
argin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span style=3D"font-=
size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent;f=
ont-weight:400;font-style:normal;font-variant:normal;text-decoration:none;v=
ertical-align:baseline;white-space:pre-wrap">Only run a few ldiskfs test su=
ites(sanity, sanity-sec, sanctity-lnet, etc.), not a full test.</span></p><=
/li><li dir=3D"ltr" style=3D"list-style-type:circle;font-size:11pt;font-fam=
ily:Muli,sans-serif;color:rgb(0,0,0);background-color:transparent;font-weig=
ht:400;font-style:normal;font-variant:normal;text-decoration:none;vertical-=
align:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;ma=
rgin-top:0pt;margin-bottom:0pt" role=3D"presentation"><a href=3D"https://re=
view.whamcloud.com/#/c/44760/" style=3D"text-decoration:none"><span style=
=3D"font-size:11pt;font-family:Arial;color:rgb(17,85,204);background-color:=
transparent;font-weight:400;font-style:normal;font-variant:normal;text-deco=
ration:underline;vertical-align:baseline;white-space:pre-wrap">A full test<=
/span></a><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);=
background-color:transparent;font-weight:400;font-style:normal;font-variant=
:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap">=
 (with empty GRANT_CHECK_LIST) shows several Arm client related failed test=
 cases, see </span><a href=3D"https://testing.whamcloud.com/test_sessions?j=
obs=3Dlustre-reviews&amp;builds=3D82774&amp;start_date=3D2021-08-26#redirec=
t" style=3D"text-decoration:none"><span style=3D"font-size:11pt;font-family=
:Arial;color:rgb(17,85,204);background-color:transparent;font-weight:400;fo=
nt-style:normal;font-variant:normal;text-decoration:underline;vertical-alig=
n:baseline;white-space:pre-wrap">test results page</span></a></p></li><ul s=
tyle=3D"margin-top:0px;margin-bottom:0px"><li dir=3D"ltr" style=3D"list-sty=
le-type:square;font-size:12pt;font-family:Muli,sans-serif;color:rgb(0,0,0);=
background-color:transparent;font-weight:400;font-style:normal;font-variant=
:normal;text-decoration:none;vertical-align:baseline;white-space:pre"><p di=
r=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=
=3D"presentation"><span style=3D"font-size:11pt;font-family:Arial;color:rgb=
(0,0,0);background-color:transparent;font-weight:400;font-style:normal;font=
-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pr=
e-wrap">sanity test 317: </span><a href=3D"https://jira.whamcloud.com/brows=
e/LU-11667" style=3D"text-decoration:none"><span style=3D"font-size:10.5pt;=
font-family:Roboto,sans-serif;color:rgb(0,82,204);background-color:transpar=
ent;font-weight:400;font-style:normal;font-variant:normal;text-decoration:u=
nderline;vertical-align:baseline;white-space:pre-wrap">LU-11667</span></a><=
span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-=
color:transparent;font-weight:400;font-style:normal;font-variant:normal;tex=
t-decoration:none;vertical-align:baseline;white-space:pre-wrap"> (Workaroun=
d fix landed)</span></p></li><li dir=3D"ltr" style=3D"list-style-type:squar=
e;font-size:12pt;font-family:Muli,sans-serif;color:rgb(0,0,0);background-co=
lor:transparent;font-weight:400;font-style:normal;font-variant:normal;text-=
decoration:none;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" sty=
le=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentati=
on"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);backgr=
ound-color:transparent;font-weight:400;font-style:normal;font-variant:norma=
l;text-decoration:none;vertical-align:baseline;white-space:pre-wrap">sanity=
n test 16a: </span><a href=3D"https://jira.whamcloud.com/browse/LU-11597" s=
tyle=3D"text-decoration:none"><span style=3D"font-size:10.5pt;font-family:R=
oboto,sans-serif;color:rgb(0,82,204);background-color:transparent;font-weig=
ht:400;font-style:normal;font-variant:normal;text-decoration:underline;vert=
ical-align:baseline;white-space:pre-wrap">LU-11597</span></a><span style=3D=
"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transpa=
rent;font-weight:400;font-style:normal;font-variant:normal;text-decoration:=
none;vertical-align:baseline;white-space:pre-wrap">, test 71a: </span><a hr=
ef=3D"https://jira.whamcloud.com/browse/LU-11787" style=3D"text-decoration:=
none"><span style=3D"font-size:10.5pt;font-family:Roboto,sans-serif;color:r=
gb(0,82,204);background-color:transparent;font-weight:400;font-style:normal=
;font-variant:normal;text-decoration:underline;vertical-align:baseline;whit=
e-space:pre-wrap">LU-11787</span></a></p></li><li dir=3D"ltr" style=3D"list=
-style-type:square;font-size:12pt;font-family:Muli,sans-serif;color:rgb(0,0=
,0);background-color:transparent;font-weight:400;font-style:normal;font-var=
iant:normal;text-decoration:none;vertical-align:baseline;white-space:pre"><=
p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" r=
ole=3D"presentation"><span style=3D"font-size:11pt;font-family:Arial;color:=
rgb(0,0,0);background-color:transparent;font-weight:400;font-style:normal;f=
ont-variant:normal;text-decoration:none;vertical-align:baseline;white-space=
:pre-wrap">conf-sanity test 98: </span><a href=3D"https://jira.whamcloud.co=
m/browse/LU-11785" style=3D"text-decoration:none"><span style=3D"font-size:=
10.5pt;font-family:Roboto,sans-serif;color:rgb(0,101,255);background-color:=
transparent;font-weight:400;font-style:normal;font-variant:normal;text-deco=
ration:underline;vertical-align:baseline;white-space:pre-wrap">LU-11785</sp=
an></a><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);bac=
kground-color:transparent;font-weight:400;font-style:normal;font-variant:no=
rmal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap">, t=
est 112: </span><a href=3D"https://jira.whamcloud.com/browse/LU-13813" styl=
e=3D"text-decoration:none"><span style=3D"font-size:10.5pt;font-family:Robo=
to,sans-serif;color:rgb(0,82,204);background-color:transparent;font-weight:=
400;font-style:normal;font-variant:normal;text-decoration:underline;vertica=
l-align:baseline;white-space:pre-wrap">LU-13813</span></a></p></li><li dir=
=3D"ltr" style=3D"list-style-type:square;font-size:12pt;font-family:Muli,sa=
ns-serif;color:rgb(0,0,0);background-color:transparent;font-weight:400;font=
-style:normal;font-variant:normal;text-decoration:none;vertical-align:basel=
ine;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0p=
t;margin-bottom:0pt" role=3D"presentation"><span style=3D"font-size:11pt;fo=
nt-family:Arial;color:rgb(0,0,0);background-color:transparent;font-weight:4=
00;font-style:normal;font-variant:normal;text-decoration:none;vertical-alig=
n:baseline;white-space:pre-wrap">sanity-flr test 50a: </span><a href=3D"htt=
ps://jira.whamcloud.com/browse/LU-14970" style=3D"text-decoration:none"><sp=
an style=3D"font-size:10.5pt;font-family:Roboto,sans-serif;color:rgb(0,82,2=
04);background-color:transparent;font-weight:400;font-style:normal;font-var=
iant:normal;text-decoration:underline;vertical-align:baseline;white-space:p=
re-wrap">LU-14970</span></a></p></li><li dir=3D"ltr" style=3D"list-style-ty=
pe:square;font-size:12pt;font-family:Muli,sans-serif;color:rgb(0,0,0);backg=
round-color:transparent;font-weight:400;font-style:normal;font-variant:norm=
al;text-decoration:none;vertical-align:baseline;white-space:pre"><p dir=3D"=
ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"pr=
esentation"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0=
);background-color:transparent;font-weight:400;font-style:normal;font-varia=
nt:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap=
">sanity-pcc test 7a: </span><a href=3D"https://jira.whamcloud.com/browse/L=
U-14346" style=3D"text-decoration:none"><span style=3D"font-size:10.5pt;fon=
t-family:Roboto,sans-serif;color:rgb(0,82,204);background-color:transparent=
;font-weight:400;font-style:normal;font-variant:normal;text-decoration:unde=
rline;vertical-align:baseline;white-space:pre-wrap">LU-14346</span></a></p>=
</li></ul></ul></ul><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt=
;margin-bottom:0pt"><span style=3D"font-size:11pt;font-family:Arial;color:r=
gb(0,0,0);background-color:transparent;font-weight:400;font-style:normal;fo=
nt-variant:normal;text-decoration:none;vertical-align:baseline;white-space:=
pre-wrap">Arm server end test on local setup</span></p><ul style=3D"margin-=
top:0px;margin-bottom:0px"><li dir=3D"ltr" style=3D"list-style-type:disc;fo=
nt-size:11pt;font-family:Muli,sans-serif;color:rgb(0,0,0);background-color:=
transparent;font-weight:400;font-style:normal;font-variant:normal;text-deco=
ration:none;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" style=
=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation=
"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);backgrou=
nd-color:transparent;font-weight:400;font-style:normal;font-variant:normal;=
text-decoration:none;vertical-align:baseline;white-space:pre-wrap">Run a fu=
ll ldiskfs test with all test suites.</span></p></li><ul style=3D"margin-to=
p:0px;margin-bottom:0px"><li dir=3D"ltr" style=3D"list-style-type:circle;fo=
nt-size:11pt;font-family:Muli,sans-serif;color:rgb(0,0,0);background-color:=
transparent;font-weight:400;font-style:normal;font-variant:normal;text-deco=
ration:none;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" style=
=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation=
"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);backgrou=
nd-color:transparent;font-weight:400;font-style:normal;font-variant:normal;=
text-decoration:none;vertical-align:baseline;white-space:pre-wrap">Due to t=
he multi MDTs crash issue, some multi MDTs tests are not run.</span></p></l=
i><li dir=3D"ltr" style=3D"list-style-type:circle;font-size:11pt;font-famil=
y:Muli,sans-serif;color:rgb(0,0,0);background-color:transparent;font-weight=
:400;font-style:normal;font-variant:normal;text-decoration:none;vertical-al=
ign:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;marg=
in-top:0pt;margin-bottom:0pt" role=3D"presentation"><span style=3D"font-siz=
e:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent;font=
-weight:400;font-style:normal;font-variant:normal;text-decoration:none;vert=
ical-align:baseline;white-space:pre-wrap">Many new failed tests come, see t=
he google </span><a href=3D"https://docs.google.com/spreadsheets/d/1EE5zU96=
_lqlkS0uk6NJeeNBrikYpd_ZEO7hdVt5spsw/edit#gid=3D969410610" style=3D"text-de=
coration:none"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(17=
,85,204);background-color:transparent;font-weight:400;font-style:normal;fon=
t-variant:normal;text-decoration:underline;vertical-align:baseline;white-sp=
ace:pre-wrap">sheet </span></a><span style=3D"font-size:11pt;font-family:Ar=
ial;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-styl=
e:normal;font-variant:normal;text-decoration:none;vertical-align:baseline;w=
hite-space:pre-wrap">for details.</span></p></li></ul><li dir=3D"ltr" style=
=3D"list-style-type:disc;font-size:11pt;font-family:Muli,sans-serif;color:r=
gb(0,0,0);background-color:transparent;font-weight:400;font-style:normal;fo=
nt-variant:normal;text-decoration:none;vertical-align:baseline;white-space:=
pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:=
0pt" role=3D"presentation"><span style=3D"font-size:11pt;font-family:Arial;=
color:rgb(0,0,0);background-color:transparent;font-weight:400;font-style:no=
rmal;font-variant:normal;text-decoration:none;vertical-align:baseline;white=
-space:pre-wrap">The openZFS full test is not run, but heard that it should=
 be more stable than ldiskfs.</span></p></li></ul><p dir=3D"ltr" style=3D"l=
ine-height:1.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size:=
11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent;font-w=
eight:400;font-style:normal;font-variant:normal;text-decoration:none;vertic=
al-align:baseline;white-space:pre-wrap">Bugfix</span></p><ul style=3D"margi=
n-top:0px;margin-bottom:0px"><li dir=3D"ltr" style=3D"list-style-type:disc;=
font-size:11pt;font-family:Muli,sans-serif;color:rgb(0,0,0);background-colo=
r:transparent;font-weight:400;font-style:normal;font-variant:normal;text-de=
coration:none;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" style=
=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation=
"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);backgrou=
nd-color:transparent;font-weight:400;font-style:normal;font-variant:normal;=
text-decoration:none;vertical-align:baseline;white-space:pre-wrap">Old Arm =
always_except bugs </span><a href=3D"https://jira.whamcloud.com/issues/?fil=
ter=3D15555" style=3D"text-decoration:none"><span style=3D"font-size:11pt;f=
ont-family:Arial;color:rgb(17,85,204);background-color:transparent;font-wei=
ght:400;font-style:normal;font-variant:normal;text-decoration:underline;ver=
tical-align:baseline;white-space:pre-wrap">https://jira.whamcloud.com/issue=
s/?filter=3D15555</span></a><span style=3D"font-size:11pt;font-family:Arial=
;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-style:n=
ormal;font-variant:normal;text-decoration:none;vertical-align:baseline;whit=
e-space:pre-wrap"> , the Arm related ones are almost addressed.</span></p><=
/li><ul style=3D"margin-top:0px;margin-bottom:0px"><li dir=3D"ltr" style=3D=
"list-style-type:circle;font-size:11pt;font-family:Muli,sans-serif;color:rg=
b(0,0,0);background-color:transparent;font-weight:400;font-style:normal;fon=
t-variant:normal;text-decoration:none;vertical-align:baseline;white-space:p=
re"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0=
pt" role=3D"presentation"><a href=3D"https://jira.whamcloud.com/browse/LU-1=
1596" style=3D"text-decoration:none"><span style=3D"font-size:10.5pt;font-f=
amily:Roboto,sans-serif;color:rgb(0,82,204);background-color:transparent;fo=
nt-weight:400;font-style:normal;font-variant:normal;text-decoration:underli=
ne;vertical-align:baseline;white-space:pre-wrap">LU-11596</span></a><span s=
tyle=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:=
transparent;font-weight:400;font-style:normal;font-variant:normal;text-deco=
ration:none;vertical-align:baseline;white-space:pre-wrap">, </span><a href=
=3D"https://jira.whamcloud.com/browse/LU-11597" style=3D"text-decoration:no=
ne"><span style=3D"font-size:10.5pt;font-family:Roboto,sans-serif;color:rgb=
(0,82,204);background-color:transparent;font-weight:400;font-style:normal;f=
ont-variant:normal;text-decoration:underline;vertical-align:baseline;white-=
space:pre-wrap">LU-11597</span></a><span style=3D"font-size:11pt;font-famil=
y:Arial;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-=
style:normal;font-variant:normal;text-decoration:none;vertical-align:baseli=
ne;white-space:pre-wrap">, </span><a href=3D"https://jira.whamcloud.com/bro=
wse/LU-14067" style=3D"text-decoration:none"><span style=3D"font-size:10.5p=
t;font-family:Roboto,sans-serif;color:rgb(0,101,255);background-color:trans=
parent;font-weight:400;font-style:normal;font-variant:normal;text-decoratio=
n:underline;vertical-align:baseline;white-space:pre-wrap">LU-14067</span></=
a><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);backgrou=
nd-color:transparent;font-weight:400;font-style:normal;font-variant:normal;=
text-decoration:none;vertical-align:baseline;white-space:pre-wrap">, </span=
><a href=3D"https://jira.whamcloud.com/browse/LU-11787" style=3D"text-decor=
ation:none"><span style=3D"font-size:10.5pt;font-family:Roboto,sans-serif;c=
olor:rgb(0,82,204);background-color:transparent;font-weight:400;font-style:=
normal;font-variant:normal;text-decoration:underline;vertical-align:baselin=
e;white-space:pre-wrap">LU-11787</span></a><span style=3D"font-size:10.5pt;=
font-family:Roboto,sans-serif;color:rgb(0,82,204);background-color:transpar=
ent;font-weight:400;font-style:normal;font-variant:normal;text-decoration:n=
one;vertical-align:baseline;white-space:pre-wrap">: </span><span style=3D"f=
ont-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transpare=
nt;font-weight:400;font-style:normal;font-variant:normal;text-decoration:no=
ne;vertical-align:baseline;white-space:pre-wrap">addressed, patch sent and =
waiting for Arm client CI recovery to land.</span></p></li><li dir=3D"ltr" =
style=3D"list-style-type:circle;font-size:11pt;font-family:Muli,sans-serif;=
color:rgb(0,0,0);background-color:transparent;font-weight:400;font-style:no=
rmal;font-variant:normal;text-decoration:none;vertical-align:baseline;white=
-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-=
bottom:0pt" role=3D"presentation"><a href=3D"https://jira.whamcloud.com/bro=
wse/LU-10073" style=3D"text-decoration:none"><span style=3D"font-size:10.5p=
t;font-family:Roboto,sans-serif;color:rgb(0,82,204);background-color:transp=
arent;font-weight:400;font-style:normal;font-variant:normal;text-decoration=
:underline;vertical-align:baseline;white-space:pre-wrap">LU-10073</span></a=
><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);backgroun=
d-color:transparent;font-weight:400;font-style:normal;font-variant:normal;t=
ext-decoration:none;vertical-align:baseline;white-space:pre-wrap">, </span>=
<a href=3D"https://jira.whamcloud.com/browse/LU-11671" style=3D"text-decora=
tion:none"><span style=3D"font-size:10.5pt;font-family:Roboto,sans-serif;co=
lor:rgb(0,82,204);background-color:transparent;font-weight:400;font-style:n=
ormal;font-variant:normal;text-decoration:underline;vertical-align:baseline=
;white-space:pre-wrap">LU-11671</span></a><span style=3D"font-size:10.5pt;f=
ont-family:Roboto,sans-serif;color:rgb(0,82,204);background-color:transpare=
nt;font-weight:400;font-style:normal;font-variant:normal;text-decoration:no=
ne;vertical-align:baseline;white-space:pre-wrap">: </span><span style=3D"fo=
nt-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparen=
t;font-weight:400;font-style:normal;font-variant:normal;text-decoration:non=
e;vertical-align:baseline;white-space:pre-wrap">can&#39;t be reproduced on =
Arm or happen on x86_64 also.</span></p></li></ul><li dir=3D"ltr" style=3D"=
list-style-type:disc;font-size:11pt;font-family:Muli,sans-serif;color:rgb(0=
,0,0);background-color:transparent;font-weight:400;font-style:normal;font-v=
ariant:normal;text-decoration:none;vertical-align:baseline;white-space:pre"=
><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"=
 role=3D"presentation"><span style=3D"font-size:11pt;font-family:Arial;colo=
r:rgb(0,0,0);background-color:transparent;font-weight:400;font-style:normal=
;font-variant:normal;text-decoration:none;vertical-align:baseline;white-spa=
ce:pre-wrap">Other old Arm bugs=C2=A0 </span><a href=3D"https://jira.whamcl=
oud.com/browse/LU-11785" style=3D"text-decoration:none"><span style=3D"font=
-size:10.5pt;font-family:Roboto,sans-serif;color:rgb(0,101,255);background-=
color:transparent;font-weight:400;font-style:normal;font-variant:normal;tex=
t-decoration:underline;vertical-align:baseline;white-space:pre-wrap">LU-117=
85</span></a><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,=
0);background-color:transparent;font-weight:400;font-style:normal;font-vari=
ant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wra=
p">, </span><a href=3D"https://jira.whamcloud.com/browse/LU-13813" style=3D=
"text-decoration:none"><span style=3D"font-size:10.5pt;font-family:Roboto,s=
ans-serif;color:rgb(0,82,204);background-color:transparent;font-weight:400;=
font-style:normal;font-variant:normal;text-decoration:underline;vertical-al=
ign:baseline;white-space:pre-wrap">LU-13813</span></a><span style=3D"font-s=
ize:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent;fo=
nt-weight:400;font-style:normal;font-variant:normal;text-decoration:none;ve=
rtical-align:baseline;white-space:pre-wrap">, </span><a href=3D"https://jir=
a.whamcloud.com/browse/LU-14970" style=3D"text-decoration:none"><span style=
=3D"font-size:10.5pt;font-family:Roboto,sans-serif;color:rgb(0,82,204);back=
ground-color:transparent;font-weight:400;font-style:normal;font-variant:nor=
mal;text-decoration:underline;vertical-align:baseline;white-space:pre-wrap"=
>LU-14970</span></a><span style=3D"font-size:11pt;font-family:Arial;color:r=
gb(0,0,0);background-color:transparent;font-weight:400;font-style:normal;fo=
nt-variant:normal;text-decoration:none;vertical-align:baseline;white-space:=
pre-wrap">, </span><a href=3D"https://jira.whamcloud.com/browse/LU-14346" s=
tyle=3D"text-decoration:none"><span style=3D"font-size:10.5pt;font-family:R=
oboto,sans-serif;color:rgb(0,82,204);background-color:transparent;font-weig=
ht:400;font-style:normal;font-variant:normal;text-decoration:underline;vert=
ical-align:baseline;white-space:pre-wrap">LU-14346</span></a><span style=3D=
"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transpa=
rent;font-weight:400;font-style:normal;font-variant:normal;text-decoration:=
none;vertical-align:baseline;white-space:pre-wrap"> to be fixed.</span></p>=
</li><li dir=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font-fami=
ly:Muli,sans-serif;color:rgb(0,0,0);background-color:transparent;font-weigh=
t:400;font-style:normal;font-variant:normal;text-decoration:none;vertical-a=
lign:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;mar=
gin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span style=3D"font-si=
ze:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent;fon=
t-weight:400;font-style:normal;font-variant:normal;text-decoration:none;ver=
tical-align:baseline;white-space:pre-wrap">New created server end bugs=C2=
=A0</span></p></li><ul style=3D"margin-top:0px;margin-bottom:0px"><li dir=
=3D"ltr" style=3D"list-style-type:circle;font-size:11pt;font-family:Muli,sa=
ns-serif;color:rgb(0,0,0);background-color:transparent;font-weight:400;font=
-style:normal;font-variant:normal;text-decoration:none;vertical-align:basel=
ine;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0p=
t;margin-bottom:0pt" role=3D"presentation"><a href=3D"https://jira.whamclou=
d.com/browse/LU-15122" style=3D"text-decoration:none"><span style=3D"font-s=
ize:10.5pt;font-family:Roboto,sans-serif;color:rgb(0,82,204);background-col=
or:transparent;font-weight:400;font-style:normal;font-variant:normal;text-d=
ecoration:underline;vertical-align:baseline;white-space:pre-wrap">LU-15122<=
/span></a><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);=
background-color:transparent;font-weight:400;font-style:normal;font-variant=
:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap">=
 : ASSERTION( iobuf-&gt;dr_rw =3D=3D 0 ) crash issue, fixed patch is landed=
.=C2=A0</span></p></li><li dir=3D"ltr" style=3D"list-style-type:circle;font=
-size:11pt;font-family:Muli,sans-serif;color:rgb(0,0,0);background-color:tr=
ansparent;font-weight:400;font-style:normal;font-variant:normal;text-decora=
tion:none;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" style=3D"=
line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><a=
 href=3D"https://jira.whamcloud.com/browse/LU-15364" style=3D"text-decorati=
on:none"><span style=3D"font-size:10.5pt;font-family:Roboto,sans-serif;colo=
r:rgb(0,101,255);background-color:transparent;font-weight:400;font-style:no=
rmal;font-variant:normal;text-decoration:underline;vertical-align:baseline;=
white-space:pre-wrap">LU-15364</span></a><span style=3D"font-size:11pt;font=
-family:Arial;color:rgb(0,0,0);background-color:transparent;font-weight:400=
;font-style:normal;font-variant:normal;text-decoration:none;vertical-align:=
baseline;white-space:pre-wrap">: multi MDTs kernel oops issue, related to a=
tomic unaligned memory access, work in progress.</span></p></li><li dir=3D"=
ltr" style=3D"list-style-type:circle;font-size:11pt;font-family:Muli,sans-s=
erif;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-sty=
le:normal;font-variant:normal;text-decoration:none;vertical-align:baseline;=
white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;ma=
rgin-bottom:0pt" role=3D"presentation"><a href=3D"https://jira.whamcloud.co=
m/browse/LU-15223" style=3D"text-decoration:none"><span style=3D"font-size:=
10.5pt;font-family:Roboto,sans-serif;color:rgb(0,82,204);background-color:t=
ransparent;font-weight:400;font-style:normal;font-variant:normal;text-decor=
ation:underline;vertical-align:baseline;white-space:pre-wrap">LU-15223</spa=
n></a><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);back=
ground-color:transparent;font-weight:400;font-style:normal;font-variant:nor=
mal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap">: 64=
K page size read/write improvement, long-term work, in progress.=C2=A0</spa=
n></p></li></ul><li dir=3D"ltr" style=3D"list-style-type:disc;font-size:11p=
t;font-family:Muli,sans-serif;color:rgb(0,0,0);background-color:transparent=
;font-weight:400;font-style:normal;font-variant:normal;text-decoration:none=
;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-heig=
ht:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span style=
=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:tran=
sparent;font-weight:400;font-style:normal;font-variant:normal;text-decorati=
on:none;vertical-align:baseline;white-space:pre-wrap">Full Arm related bug =
list with label arm: </span><a href=3D"https://jira.whamcloud.com/issues/?f=
ilter=3D16710" style=3D"text-decoration:none"><span style=3D"font-size:11pt=
;font-family:Arial;color:rgb(17,85,204);background-color:transparent;font-w=
eight:400;font-style:normal;font-variant:normal;text-decoration:underline;v=
ertical-align:baseline;white-space:pre-wrap">https://jira.whamcloud.com/iss=
ues/?filter=3D16710</span></a></p></li><li dir=3D"ltr" style=3D"list-style-=
type:disc;font-size:11pt;font-family:Arial;color:rgb(255,255,255);backgroun=
d-color:transparent;font-weight:400;font-style:normal;font-variant:normal;t=
ext-decoration:none;vertical-align:baseline;white-space:pre"><p dir=3D"ltr"=
 style=3D"line-height:1.26;margin-top:0pt;margin-bottom:0pt" role=3D"presen=
tation"><span style=3D"font-size:16pt;font-family:Arial;color:rgb(255,255,2=
55);background-color:transparent;font-weight:400;font-style:normal;font-var=
iant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wr=
ap">is not that ready for production.</span></p></li></ul><p dir=3D"ltr" st=
yle=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"fo=
nt-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparen=
t;font-weight:400;font-style:normal;font-variant:normal;text-decoration:non=
e;vertical-align:baseline;white-space:pre-wrap">Reference to:</span></p><p =
dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><sp=
an style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-co=
lor:transparent;font-weight:400;font-style:normal;font-variant:normal;text-=
decoration:none;vertical-align:baseline;white-space:pre-wrap">James Simmons=
=E2=80=99 Lustre Arm update: </span><a href=3D"https://connect.linaro.org/r=
esources/san19/san19-224/" style=3D"text-decoration:none"><span style=3D"fo=
nt-size:11pt;font-family:Arial;color:rgb(17,85,204);background-color:transp=
arent;font-weight:400;font-style:normal;font-variant:normal;text-decoration=
:underline;vertical-align:baseline;white-space:pre-wrap">https://connect.li=
naro.org/resources/san19/san19-224/</span></a></p><p dir=3D"ltr" style=3D"l=
ine-height:1.38;margin-top:0pt;margin-bottom:0pt"><b style=3D"font-weight:n=
ormal"><br></b></p></b></h3><h3 dir=3D"ltr" style=3D"line-height:1.38;margi=
n-top:16pt;margin-bottom:4pt"><span style=3D"font-size:14pt;font-family:Ari=
al;color:rgb(67,67,67);background-color:transparent;font-weight:400;font-st=
yle:normal;font-variant:normal;text-decoration:none;vertical-align:baseline=
;white-space:pre-wrap">Work Plan</span></h3><h3 dir=3D"ltr" style=3D"line-h=
eight:1.38;margin-top:16pt;margin-bottom:4pt"><b style=3D"font-weight:norma=
l"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0p=
t"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);backgro=
und-color:transparent;font-weight:400;font-style:normal;font-variant:normal=
;text-decoration:none;vertical-align:baseline;white-space:pre-wrap">=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D</span></p><ul style=3D"margin-top:0px;margin-botto=
m:0px"><li dir=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font-fa=
mily:Arial;color:rgb(0,0,0);background-color:transparent;font-weight:400;fo=
nt-style:normal;font-variant:normal;text-decoration:none;vertical-align:bas=
eline;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:=
0pt;margin-bottom:0pt" role=3D"presentation"><span style=3D"font-size:11pt;=
font-family:Arial;color:rgb(0,0,0);background-color:transparent;font-weight=
:400;font-style:normal;font-variant:normal;text-decoration:none;vertical-al=
ign:baseline;white-space:pre-wrap">Lustre Server End Critical Bug Fix targe=
t 2022-06</span></p></li><ul style=3D"margin-top:0px;margin-bottom:0px"><li=
 dir=3D"ltr" style=3D"list-style-type:circle;font-size:11pt;font-family:Ari=
al;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-style=
:normal;font-variant:normal;text-decoration:none;vertical-align:baseline;wh=
ite-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;marg=
in-bottom:0pt" role=3D"presentation"><span style=3D"font-size:11pt;font-fam=
ily:Arial;color:rgb(0,0,0);background-color:transparent;font-weight:400;fon=
t-style:normal;font-variant:normal;text-decoration:none;vertical-align:base=
line;white-space:pre-wrap">Lustre Multiple MDTs kernel OOPS when stripe iss=
ue: </span><a href=3D"https://jira.whamcloud.com/browse/LU-15364" style=3D"=
text-decoration:none"><span style=3D"font-size:10.5pt;font-family:Roboto,sa=
ns-serif;color:rgb(0,101,255);background-color:transparent;font-weight:400;=
font-style:normal;font-variant:normal;text-decoration:underline;vertical-al=
ign:baseline;white-space:pre-wrap">LU-15364</span></a></p></li><li dir=3D"l=
tr" style=3D"list-style-type:circle;font-size:11pt;font-family:Arial;color:=
rgb(0,0,0);background-color:transparent;font-weight:400;font-style:normal;f=
ont-variant:normal;text-decoration:none;vertical-align:baseline;white-space=
:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom=
:0pt" role=3D"presentation"><span style=3D"font-size:11pt;font-family:Arial=
;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-style:n=
ormal;font-variant:normal;text-decoration:none;vertical-align:baseline;whit=
e-space:pre-wrap">Lustre hangs at Sanity Test 807</span></p></li><li dir=3D=
"ltr" style=3D"list-style-type:circle;font-size:11pt;font-family:Arial;colo=
r:rgb(0,0,0);background-color:transparent;font-weight:400;font-style:normal=
;font-variant:normal;text-decoration:none;vertical-align:baseline;white-spa=
ce:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bott=
om:0pt" role=3D"presentation"><span style=3D"font-size:11pt;font-family:Ari=
al;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-style=
:normal;font-variant:normal;text-decoration:none;vertical-align:baseline;wh=
ite-space:pre-wrap">Lustre Conf-sanity test 44 kernel crash</span></p></li>=
<li dir=3D"ltr" style=3D"list-style-type:circle;font-size:11pt;font-family:=
Arial;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-st=
yle:normal;font-variant:normal;text-decoration:none;vertical-align:baseline=
;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;m=
argin-bottom:0pt" role=3D"presentation"><span style=3D"font-size:11pt;font-=
family:Arial;color:rgb(0,0,0);background-color:transparent;font-weight:400;=
font-style:normal;font-variant:normal;text-decoration:none;vertical-align:b=
aseline;white-space:pre-wrap">Lustre Conf sanity case 58 kernel crash</span=
></p></li><li dir=3D"ltr" style=3D"list-style-type:circle;font-size:11pt;fo=
nt-family:Arial;color:rgb(0,0,0);background-color:transparent;font-weight:4=
00;font-style:normal;font-variant:normal;text-decoration:none;vertical-alig=
n:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin=
-top:0pt;margin-bottom:0pt" role=3D"presentation"><span style=3D"font-size:=
11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent;font-w=
eight:400;font-style:normal;font-variant:normal;text-decoration:none;vertic=
al-align:baseline;white-space:pre-wrap">Lustre Conf sanity case 78 kernel c=
rash</span></p></li><li dir=3D"ltr" style=3D"list-style-type:circle;font-si=
ze:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent;fon=
t-weight:400;font-style:normal;font-variant:normal;text-decoration:none;ver=
tical-align:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1=
.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span style=3D"=
font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transpar=
ent;font-weight:400;font-style:normal;font-variant:normal;text-decoration:n=
one;vertical-align:baseline;white-space:pre-wrap">Lustre Conf sanity case 7=
9 crash</span></p></li><li dir=3D"ltr" style=3D"list-style-type:circle;font=
-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent;=
font-weight:400;font-style:normal;font-variant:normal;text-decoration:none;=
vertical-align:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-heigh=
t:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span style=
=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:tran=
sparent;font-weight:400;font-style:normal;font-variant:normal;text-decorati=
on:none;vertical-align:baseline;white-space:pre-wrap">Lustre sanity-pcc 7a =
case hang the cluster</span></p></li></ul><li dir=3D"ltr" style=3D"list-sty=
le-type:disc;font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-c=
olor:transparent;font-weight:400;font-style:normal;font-variant:normal;text=
-decoration:none;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" st=
yle=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentat=
ion"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);backg=
round-color:transparent;font-weight:400;font-style:normal;font-variant:norm=
al;text-decoration:none;vertical-align:baseline;white-space:pre-wrap">Lustr=
e Server End Non-critical Bug Fix target 2022-12</span></p></li><ul style=
=3D"margin-top:0px;margin-bottom:0px"><li dir=3D"ltr" style=3D"list-style-t=
ype:circle;font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-col=
or:transparent;font-weight:400;font-style:normal;font-variant:normal;text-d=
ecoration:none;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" styl=
e=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentatio=
n"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);backgro=
und-color:transparent;font-weight:400;font-style:normal;font-variant:normal=
;text-decoration:none;vertical-align:baseline;white-space:pre-wrap">Lustre =
Sanity failure cases: 33 cases</span></p></li><li dir=3D"ltr" style=3D"list=
-style-type:circle;font-size:11pt;font-family:Arial;color:rgb(0,0,0);backgr=
ound-color:transparent;font-weight:400;font-style:normal;font-variant:norma=
l;text-decoration:none;vertical-align:baseline;white-space:pre"><p dir=3D"l=
tr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"pre=
sentation"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0)=
;background-color:transparent;font-weight:400;font-style:normal;font-varian=
t:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap"=
>Lustre server replay-single: 1 case</span></p></li><li dir=3D"ltr" style=
=3D"list-style-type:circle;font-size:11pt;font-family:Arial;color:rgb(0,0,0=
);background-color:transparent;font-weight:400;font-style:normal;font-varia=
nt:normal;text-decoration:none;vertical-align:baseline;white-space:pre"><p =
dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" rol=
e=3D"presentation"><span style=3D"font-size:11pt;font-family:Arial;color:rg=
b(0,0,0);background-color:transparent;font-weight:400;font-style:normal;fon=
t-variant:normal;text-decoration:none;vertical-align:baseline;white-space:p=
re-wrap">Lustre sanity-flr 200 cases fix: 1 case=C2=A0</span></p></li><li d=
ir=3D"ltr" style=3D"list-style-type:circle;font-size:11pt;font-family:Arial=
;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-style:n=
ormal;font-variant:normal;text-decoration:none;vertical-align:baseline;whit=
e-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin=
-bottom:0pt" role=3D"presentation"><span style=3D"font-size:11pt;font-famil=
y:Arial;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-=
style:normal;font-variant:normal;text-decoration:none;vertical-align:baseli=
ne;white-space:pre-wrap">Lustre sanity-hsm failure cases: 25 cases</span></=
p></li><li dir=3D"ltr" style=3D"list-style-type:circle;font-size:11pt;font-=
family:Arial;color:rgb(0,0,0);background-color:transparent;font-weight:400;=
font-style:normal;font-variant:normal;text-decoration:none;vertical-align:b=
aseline;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-to=
p:0pt;margin-bottom:0pt" role=3D"presentation"><span style=3D"font-size:11p=
t;font-family:Arial;color:rgb(0,0,0);background-color:transparent;font-weig=
ht:400;font-style:normal;font-variant:normal;text-decoration:none;vertical-=
align:baseline;white-space:pre-wrap">Lustre lustre-rsync-test failure test:=
 3</span></p></li><li dir=3D"ltr" style=3D"list-style-type:circle;font-size=
:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent;font-=
weight:400;font-style:normal;font-variant:normal;text-decoration:none;verti=
cal-align:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.3=
8;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span style=3D"fo=
nt-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparen=
t;font-weight:400;font-style:normal;font-variant:normal;text-decoration:non=
e;vertical-align:baseline;white-space:pre-wrap">Lustre recovery-small/sanit=
y-scrub: 2</span></p></li><li dir=3D"ltr" style=3D"list-style-type:circle;f=
ont-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transpare=
nt;font-weight:400;font-style:normal;font-variant:normal;text-decoration:no=
ne;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-he=
ight:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span sty=
le=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:tr=
ansparent;font-weight:400;font-style:normal;font-variant:normal;text-decora=
tion:none;vertical-align:baseline;white-space:pre-wrap">Lustre sanityn test=
 cases fix: 12</span></p></li><li dir=3D"ltr" style=3D"list-style-type:circ=
le;font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:trans=
parent;font-weight:400;font-style:normal;font-variant:normal;text-decoratio=
n:none;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" style=3D"lin=
e-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span=
 style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-colo=
r:transparent;font-weight:400;font-style:normal;font-variant:normal;text-de=
coration:none;vertical-align:baseline;white-space:pre-wrap">Lustre sanity-l=
fsck failure cases fix: 3</span></p></li><li dir=3D"ltr" style=3D"list-styl=
e-type:circle;font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-=
color:transparent;font-weight:400;font-style:normal;font-variant:normal;tex=
t-decoration:none;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" s=
tyle=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presenta=
tion"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);back=
ground-color:transparent;font-weight:400;font-style:normal;font-variant:nor=
mal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap">Lust=
re sanity-sec failure cases fix =EF=BC=9A7=C2=A0</span></p></li><li dir=3D"=
ltr" style=3D"list-style-type:circle;font-size:11pt;font-family:Arial;color=
:rgb(0,0,0);background-color:transparent;font-weight:400;font-style:normal;=
font-variant:normal;text-decoration:none;vertical-align:baseline;white-spac=
e:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-botto=
m:0pt" role=3D"presentation"><span style=3D"font-size:11pt;font-family:Aria=
l;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-style:=
normal;font-variant:normal;text-decoration:none;vertical-align:baseline;whi=
te-space:pre-wrap">Lustre sanity-lnet failure cases test fix: 2</span></p><=
/li></ul><li dir=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font-=
family:Arial;color:rgb(0,0,0);background-color:transparent;font-weight:400;=
font-style:normal;font-variant:normal;text-decoration:none;vertical-align:b=
aseline;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-to=
p:0pt;margin-bottom:0pt" role=3D"presentation"><span style=3D"font-size:11p=
t;font-family:Arial;color:rgb(0,0,0);background-color:transparent;font-weig=
ht:400;font-style:normal;font-variant:normal;text-decoration:none;vertical-=
align:baseline;white-space:pre-wrap">Continuous add more test suites for Ar=
m client CI ??</span></p></li><ul style=3D"margin-top:0px;margin-bottom:0px=
"><li dir=3D"ltr" style=3D"list-style-type:circle;font-size:11pt;font-famil=
y:Arial;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-=
style:normal;font-variant:normal;text-decoration:none;vertical-align:baseli=
ne;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt=
;margin-bottom:0pt" role=3D"presentation"><span style=3D"font-size:11pt;fon=
t-family:Arial;color:rgb(0,0,0);background-color:transparent;font-weight:40=
0;font-style:normal;font-variant:normal;text-decoration:none;vertical-align=
:baseline;white-space:pre-wrap">Once a=C2=A0 test suite is all passed for A=
rm then add it into CI.</span></p></li></ul><li dir=3D"ltr" style=3D"list-s=
tyle-type:disc;font-size:11pt;font-family:Arial;color:rgb(0,0,0);background=
-color:transparent;font-weight:400;font-style:normal;font-variant:normal;te=
xt-decoration:none;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" =
style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"present=
ation"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);bac=
kground-color:transparent;font-weight:400;font-style:normal;font-variant:no=
rmal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap">Ser=
ver CI support for Arm on Centos8 ??</span></p></li><ul style=3D"margin-top=
:0px;margin-bottom:0px"><li dir=3D"ltr" style=3D"list-style-type:circle;fon=
t-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent=
;font-weight:400;font-style:normal;font-variant:normal;text-decoration:none=
;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-heig=
ht:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span style=
=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:tran=
sparent;font-weight:400;font-style:normal;font-variant:normal;text-decorati=
on:none;vertical-align:baseline;white-space:pre-wrap">Ideally, Arm server C=
I can come with Arm server end fixes patches and ensure future patches merg=
ed don=E2=80=99t make any regressions on Arm.</span></p></li><li dir=3D"ltr=
" style=3D"list-style-type:circle;font-size:11pt;font-family:Arial;color:rg=
b(0,0,0);background-color:transparent;font-weight:400;font-style:normal;fon=
t-variant:normal;text-decoration:none;vertical-align:baseline;white-space:p=
re"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0=
pt" role=3D"presentation"><span style=3D"font-size:11pt;font-family:Arial;c=
olor:rgb(0,0,0);background-color:transparent;font-weight:400;font-style:nor=
mal;font-variant:normal;text-decoration:none;vertical-align:baseline;white-=
space:pre-wrap">As the test infra is not open source and maintained by wham=
cloud, it might need whamcloud to make it ??</span></p></li></ul><li dir=3D=
"ltr" style=3D"list-style-type:disc;font-size:11pt;font-family:Arial;color:=
rgb(0,0,0);background-color:transparent;font-weight:400;font-style:normal;f=
ont-variant:normal;text-decoration:none;vertical-align:baseline;white-space=
:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom=
:0pt" role=3D"presentation"><span style=3D"font-size:11pt;font-family:Arial=
;color:rgb(0,0,0);background-color:transparent;font-weight:400;font-style:n=
ormal;font-variant:normal;text-decoration:none;vertical-align:baseline;whit=
e-space:pre-wrap">Other works in future</span></p></li><ul style=3D"margin-=
top:0px;margin-bottom:0px"><li dir=3D"ltr" style=3D"list-style-type:circle;=
font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transpar=
ent;font-weight:400;font-style:normal;font-variant:normal;text-decoration:n=
one;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-h=
eight:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span st=
yle=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:t=
ransparent;font-weight:400;font-style:normal;font-variant:normal;text-decor=
ation:none;vertical-align:baseline;white-space:pre-wrap">Test other distros=
 like ubuntu, SUSE etc.</span></p></li><li dir=3D"ltr" style=3D"list-style-=
type:circle;font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-co=
lor:transparent;font-weight:400;font-style:normal;font-variant:normal;text-=
decoration:none;vertical-align:baseline;white-space:pre"><p dir=3D"ltr" sty=
le=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentati=
on"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);backgr=
ound-color:transparent;font-weight:400;font-style:normal;font-variant:norma=
l;text-decoration:none;vertical-align:baseline;white-space:pre-wrap">Test x=
86 client with Arm64 Server=C2=A0</span></p></li><li dir=3D"ltr" style=3D"l=
ist-style-type:circle;font-size:11pt;font-family:Arial;color:rgb(0,0,0);bac=
kground-color:transparent;font-weight:400;font-style:normal;font-variant:no=
rmal;text-decoration:none;vertical-align:baseline;white-space:pre"><p dir=
=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=
=3D"presentation"><span style=3D"font-size:11pt;font-family:Arial;color:rgb=
(0,0,0);background-color:transparent;font-weight:400;font-style:normal;font=
-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pr=
e-wrap">Basic Optimised: CRC/AES</span></p></li><li dir=3D"ltr" style=3D"li=
st-style-type:circle;font-size:11pt;font-family:Arial;color:rgb(0,0,0);back=
ground-color:transparent;font-weight:400;font-style:normal;font-variant:nor=
mal;text-decoration:none;vertical-align:baseline;white-space:pre"><p dir=3D=
"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"p=
resentation"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,=
0);background-color:transparent;font-weight:400;font-style:normal;font-vari=
ant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wra=
p">All-flash optimization</span></p></li></ul></ul><p dir=3D"ltr" style=3D"=
line-height:1.38;margin-top:0pt;margin-bottom:0pt"><b style=3D"font-weight:=
normal"><br></b></p><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt=
;margin-bottom:0pt"><span style=3D"font-size:11pt;font-family:Arial;color:r=
gb(0,0,0);background-color:transparent;font-weight:400;font-style:normal;fo=
nt-variant:normal;text-decoration:none;vertical-align:baseline;white-space:=
pre-wrap">Best Regards,</span></p><p style=3D"line-height:1.38;margin-top:0=
pt;margin-bottom:0pt">Xinliang</p></b></h3></span></div>

--000000000000af1da705d33f26cb--

--===============4761974771498739341==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============4761974771498739341==--
