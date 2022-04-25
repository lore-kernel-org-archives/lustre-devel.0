Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CB7E8C433EF
	for <lustre-devel@archiver.kernel.org>; Mon, 25 Apr 2022 01:31:50 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4F2B321F777;
	Sun, 24 Apr 2022 18:31:50 -0700 (PDT)
Received: from mail-yb1-f171.google.com (mail-yb1-f171.google.com
 [209.85.219.171])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 386F421F76C
 for <lustre-devel@lists.lustre.org>; Sun, 24 Apr 2022 18:31:48 -0700 (PDT)
Received: by mail-yb1-f171.google.com with SMTP id g28so5122928ybj.10
 for <lustre-devel@lists.lustre.org>; Sun, 24 Apr 2022 18:31:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=vJw+Tp9zRKmJV0o/tSwOmrR1kAejduKy8PTvOq2f9Bs=;
 b=E8ZBR5cJVEuOAZeCgPxPNE2I2MVQeIn3FHrIR3/QgSBilyP4HdrlzJJi3NxV2rrAyx
 Z/D9dP9181wf0Ojv8Xkj9abJ9Q+ekQsLhqhBTK6hUEl8k4tOhjp/JZcolLRhY3PfjDis
 m/nJHtyMfHA2b2PtZxBrTlCjCpkG2ouNxajrG2FU2/TbEzrzkCvJkDOBPNuTygCYqs7P
 8eUYdGfMS3l0Yywfk3eMML+qd708SpAGZExE8zjZVlt50nlC1sQu9cqoCjArWjltdwvr
 ElMGN55fPwvTjx5vqMrTvHS64XZGQYAJ5jb2XPA70nSVLy4bmG5fWJOM0jMSVmolSOv2
 rQWg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=vJw+Tp9zRKmJV0o/tSwOmrR1kAejduKy8PTvOq2f9Bs=;
 b=hTV5519KdmPBoRLZuGKNw919V5VyS8t40XxrTfFkpBiFKe70njwFlYRr+2EiBPcg9y
 ts9gYynCPnXh9rriUTbwX2M56Lac7DD6U/+csFmGGUewK2RGWvD+8ad9MMTJJYZ/DrP0
 /4DMjznA8nnAINkFAgly6+JAhWleMnhH2umeY9Xge7LFVzngbCYIM1jssUGbuDt++eo4
 hIT/+xAeIkxG6J0/VxZbwOUEbkjCtnB3syEvRtXePgE+73FAIsouCf1IeMg8luqaRYd3
 2cYfJWvhUaziUXM7ffunvQCCnfLtQjjq/mVK4UMBNxCe6gXJzutfz/M1pwcgiv5yhRZi
 QFgA==
X-Gm-Message-State: AOAM532HtZY8Q68EmahF3O1ktPViXe0kxQUuXat1ewB2e8Ni+PcJoBGp
 e8PQL/dOErChaSvzSe+6hHh3QrbRjElbyjab/CM+ig==
X-Google-Smtp-Source: ABdhPJyCXo6ifvpJ7STXmZoj5dpjUqzPPYw8OqUylTKwIL7vbHXwjkEbEnJmUlGMM38d44sJsMCQgKsCd9DrwH4dgIM=
X-Received: by 2002:a25:9d87:0:b0:641:3e61:5d10 with SMTP id
 v7-20020a259d87000000b006413e615d10mr14260232ybp.116.1650850307488; Sun, 24
 Apr 2022 18:31:47 -0700 (PDT)
MIME-Version: 1.0
References: <CACzn6-XNRn5DwANNghgEgUjOosJ1=PTzJ0TOfd0VtbVYmoZ8Mw@mail.gmail.com>
In-Reply-To: <CACzn6-XNRn5DwANNghgEgUjOosJ1=PTzJ0TOfd0VtbVYmoZ8Mw@mail.gmail.com>
Date: Mon, 25 Apr 2022 09:31:12 +0800
Message-ID: <CAKoKPbwrGZ8Qq_LJbQzuk_=ewyo0AQAnsuu843cCp8zAKwvXpw@mail.gmail.com>
To: Kevin Zhao <kevin.zhao@linaro.org>
Subject: Re: [lustre-devel] The Progress of Arm64 External Tester and Builder
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
Cc: Jian Yu <jiyu@whamcloud.com>, Li Xi <lixi@ddn.com>,
 "lustre-devel@lists.lustre.org lustre-devel"
 <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============3352402719530979064=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============3352402719530979064==
Content-Type: multipart/alternative; boundary="00000000000027d9e805dd708ad3"

--00000000000027d9e805dd708ad3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 22 Apr 2022 at 15:24, Kevin Zhao <kevin.zhao@linaro.org> wrote:

> Hi Lustre,
>
> Xinliang and I are from Linaro, and we=E2=80=99ve worked on Lustre on the=
 Arm64
> for several months. Now we=E2=80=99ve enabled the external Arm64 builder =
and test.
>
> The external arm64 CI architecture is like below:
>
> We=E2=80=99ve set up an external Jenkins to handle this. Currently, it is=
 on an
> self-setup jenkins  <http://213.146.155.72:8080/>
>
> Now we have:
>
>    -
>
>    Lustre Build Job
>    <http://213.146.155.72:8080/job/project-lustre-build-release-master/>:
>    watch gerrit change and build Lustre packages, then move them to a sel=
f
>    setup Yum repo. Now due to easy test, we just run it once every to gra=
b the
>    latest version. Will move to on-trigger after we get more machines.
>    -
>
>    Lustre test job
>    <http://213.146.155.72:8080/job/project-lustre-periodical-test/>:
>    Jenkins pipeline. Using Terraform to provision arm64 vms in an OpenSta=
ck
>    cluster. And then configure the test vms and run. Currently we just te=
st
>    sanity test suites. Usually cost 4-5 hours for the whole jobs.
>
> TODO:
>
>    -
>
>    Test: Cover more tests suites, needs to provision more machines for
>    this.
>    -
>
>    Move to Linaro Jenkins: https://ci.linaro.org  after the test becomes
>    stable.
>    -
>
>    Build more Arm64 Release and publish for experiment use.
>
>
> *And 2 things below need the community=E2=80=99s confirmation and help*:
>
>    -
>
>    We don=E2=80=99t have Maloo DB account or token, so currently we can n=
ot post
>    the data to Maloo DB for the upstream developers to see the test
>    consequence.
>
>
And I tried to upload test results to Maloo DB with my own account several
times following the guide
https://wiki.whamcloud.com/display/TEI/Test+results+format.
Either with maloo_upload.sh or through the website
https://testing.whamcloud.com/import_tasks/new. But can't see any upload in
the upload queue
https://testing.whamcloud.com/import_tasks?user_id=3Db8340029-197d-4ce0-a8f=
1-40f76d3bb8c7
.


>
>    -
>
>    We have now built and maintained a yum repository for Lustre and
>    e2fsprogs at http://213.146.155.48/repo/. We plan to share the tested
>    Arm64 RPMs in case anyone wants to try Lustre on Arm quickly, can we
>    put them into the Lustre official repo
>    https://downloads.whamcloud.com/public/lustre/ as an experimental
>    release? Or if we can=E2=80=99t, another proposal, is it possible for =
the
>    community to have an entry in the https://www.lustre.org/download/ poi=
nt
>    to the external Arm64 yum repo?
>
>
> Thanks in advance and look forward to hearing from you soon. Really
> appreciate the help from Lustre upstream during the last several months f=
or
> Lustre on Arm64 bugfix and test.
>
> --
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
> kevin.zhao@linaro.org | Mobile/Direct/Wechat:  +86 18818270915
>
>

--00000000000027d9e805dd708ad3
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><br><div class=3D"gmail_quote">=
<div dir=3D"ltr" class=3D"gmail_attr">On Fri, 22 Apr 2022 at 15:24, Kevin Z=
hao &lt;<a href=3D"mailto:kevin.zhao@linaro.org">kevin.zhao@linaro.org</a>&=
gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0=
px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><div =
dir=3D"ltr"><span id=3D"gmail-m_7662657995136405504gmail-docs-internal-guid=
-bf78b256-7fff-fed1-32e6-5692649117fe"><p dir=3D"ltr" style=3D"line-height:=
1.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size:11pt;font-f=
amily:Arial;color:rgb(0,0,0);background-color:transparent;font-variant-nume=
ric:normal;font-variant-east-asian:normal;vertical-align:baseline;white-spa=
ce:pre-wrap">Hi Lustre,</span></p><br><p dir=3D"ltr" style=3D"line-height:1=
.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size:11pt;font-fa=
mily:Arial;color:rgb(0,0,0);background-color:transparent;font-variant-numer=
ic:normal;font-variant-east-asian:normal;vertical-align:baseline;white-spac=
e:pre-wrap">Xinliang and I are from Linaro, and we=E2=80=99ve worked on Lus=
tre on the Arm64 for several months. Now we=E2=80=99ve enabled the external=
 Arm64 builder and test.</span></p><br><p dir=3D"ltr" style=3D"line-height:=
1.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size:11pt;font-f=
amily:Arial;color:rgb(0,0,0);background-color:transparent;font-variant-nume=
ric:normal;font-variant-east-asian:normal;vertical-align:baseline;white-spa=
ce:pre-wrap">The external arm64 CI architecture is like below:</span></p><p=
 dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><s=
pan style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-c=
olor:transparent;font-variant-numeric:normal;font-variant-east-asian:normal=
;vertical-align:baseline;white-space:pre-wrap"><span style=3D"border:none;d=
isplay:inline-block;overflow:hidden;width:652px;height:367px"><img src=3D"h=
ttps://lh5.googleusercontent.com/rq2aUSmGeWYT0UNjeljCVRjzwbrmwy1z3ciMwoBT0s=
mgkZQ5g9LKPJEk75ZAdgXLb1CqOoo0v5qMA2Wsw1jUyPK0Anm1hbLxP543XWxikD95cwpa9v9tb=
BQW6WLc-q-ShbQNSnA" width=3D"652" height=3D"367" style=3D"margin-left: 0px;=
 margin-top: 0px;"></span></span></p><p dir=3D"ltr" style=3D"line-height:1.=
38;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size:11pt;font-fam=
ily:Arial;color:rgb(0,0,0);background-color:transparent;font-variant-numeri=
c:normal;font-variant-east-asian:normal;vertical-align:baseline;white-space=
:pre-wrap">We=E2=80=99ve set up an external Jenkins to handle this. Current=
ly, it is on </span><a href=3D"http://213.146.155.72:8080/" style=3D"text-d=
ecoration-line:none" target=3D"_blank"><span style=3D"font-size:11pt;font-f=
amily:Arial;background-color:transparent;font-variant-numeric:normal;font-v=
ariant-east-asian:normal;text-decoration-line:underline;vertical-align:base=
line;white-space:pre-wrap">an self-setup jenkins=C2=A0</span></a></p><p dir=
=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span =
style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color=
:transparent;font-variant-numeric:normal;font-variant-east-asian:normal;ver=
tical-align:baseline;white-space:pre-wrap">Now we have:</span></p><ul style=
=3D"margin-top:0px;margin-bottom:0px"><li dir=3D"ltr" style=3D"list-style-t=
ype:disc;font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color=
:transparent;font-variant-numeric:normal;font-variant-east-asian:normal;ver=
tical-align:baseline;white-space:pre-wrap"><p dir=3D"ltr" style=3D"line-hei=
ght:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><a href=3D=
"http://213.146.155.72:8080/job/project-lustre-build-release-master/" style=
=3D"text-decoration-line:none" target=3D"_blank"><span style=3D"font-size:1=
1pt;background-color:transparent;font-variant-numeric:normal;font-variant-e=
ast-asian:normal;text-decoration-line:underline;vertical-align:baseline;whi=
te-space:pre-wrap">Lustre Build Job</span></a><span style=3D"font-size:11pt=
;background-color:transparent;font-variant-numeric:normal;font-variant-east=
-asian:normal;vertical-align:baseline;white-space:pre-wrap">: watch gerrit =
change and build Lustre packages, then move them to a self setup Yum repo. =
Now due to easy test, we just run it once every to grab the latest version.=
 Will move to on-trigger after we get more machines.</span></p></li><li dir=
=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font-family:Arial;col=
or:rgb(0,0,0);background-color:transparent;font-variant-numeric:normal;font=
-variant-east-asian:normal;vertical-align:baseline;white-space:pre-wrap"><p=
 dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" ro=
le=3D"presentation"><a href=3D"http://213.146.155.72:8080/job/project-lustr=
e-periodical-test/" style=3D"text-decoration-line:none" target=3D"_blank"><=
span style=3D"font-size:11pt;background-color:transparent;font-variant-nume=
ric:normal;font-variant-east-asian:normal;text-decoration-line:underline;ve=
rtical-align:baseline;white-space:pre-wrap">Lustre test job</span></a><span=
 style=3D"font-size:11pt;background-color:transparent;font-variant-numeric:=
normal;font-variant-east-asian:normal;vertical-align:baseline;white-space:p=
re-wrap">: Jenkins pipeline. Using Terraform to provision arm64 vms in an O=
penStack cluster. And then configure the test vms and run. Currently we jus=
t test sanity test suites. Usually cost 4-5 hours for the whole jobs.</span=
></p></li></ul><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;marg=
in-bottom:0pt"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,=
0,0);background-color:transparent;font-variant-numeric:normal;font-variant-=
east-asian:normal;vertical-align:baseline;white-space:pre-wrap">TODO:</span=
></p><ul style=3D"margin-top:0px;margin-bottom:0px"><li dir=3D"ltr" style=
=3D"list-style-type:disc;font-size:11pt;font-family:Arial;color:rgb(0,0,0);=
background-color:transparent;font-variant-numeric:normal;font-variant-east-=
asian:normal;vertical-align:baseline;white-space:pre-wrap"><p dir=3D"ltr" s=
tyle=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presenta=
tion"><span style=3D"font-size:11pt;background-color:transparent;font-varia=
nt-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;wh=
ite-space:pre-wrap">Test: Cover more tests suites, needs to provision more =
machines for this.</span></p></li><li dir=3D"ltr" style=3D"list-style-type:=
disc;font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:tra=
nsparent;font-variant-numeric:normal;font-variant-east-asian:normal;vertica=
l-align:baseline;white-space:pre-wrap"><p dir=3D"ltr" style=3D"line-height:=
1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span style=3D=
"font-size:11pt;background-color:transparent;font-variant-numeric:normal;fo=
nt-variant-east-asian:normal;vertical-align:baseline;white-space:pre-wrap">=
Move to Linaro Jenkins: </span><a href=3D"https://ci.linaro.org" style=3D"t=
ext-decoration-line:none" target=3D"_blank"><span style=3D"font-size:11pt;b=
ackground-color:transparent;font-variant-numeric:normal;font-variant-east-a=
sian:normal;text-decoration-line:underline;vertical-align:baseline;white-sp=
ace:pre-wrap">https://ci.linaro.org</span></a><span style=3D"font-size:11pt=
;background-color:transparent;font-variant-numeric:normal;font-variant-east=
-asian:normal;vertical-align:baseline;white-space:pre-wrap">=C2=A0 after th=
e test becomes stable.</span></p></li><li dir=3D"ltr" style=3D"list-style-t=
ype:disc;font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color=
:transparent;font-variant-numeric:normal;font-variant-east-asian:normal;ver=
tical-align:baseline;white-space:pre-wrap"><p dir=3D"ltr" style=3D"line-hei=
ght:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span styl=
e=3D"font-size:11pt;background-color:transparent;font-variant-numeric:norma=
l;font-variant-east-asian:normal;vertical-align:baseline;white-space:pre-wr=
ap">Build more Arm64 Release and publish for experiment use.</span></p></li=
></ul><br><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bo=
ttom:0pt"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);=
background-color:transparent;font-variant-numeric:normal;font-variant-east-=
asian:normal;vertical-align:baseline;white-space:pre-wrap"><b>And 2 things =
below need the community=E2=80=99s confirmation and help</b>:=C2=A0</span><=
/p><ul style=3D"margin-top:0px;margin-bottom:0px"><li dir=3D"ltr" style=3D"=
list-style-type:disc;font-size:11pt;font-family:Arial;color:rgb(0,0,0);back=
ground-color:transparent;font-variant-numeric:normal;font-variant-east-asia=
n:normal;vertical-align:baseline;white-space:pre-wrap"><p dir=3D"ltr" style=
=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation=
"><span style=3D"font-size:11pt;background-color:transparent;font-variant-n=
umeric:normal;font-variant-east-asian:normal;vertical-align:baseline;white-=
space:pre-wrap">We don=E2=80=99t have Maloo DB account or token, so current=
ly we can not post the data to Maloo DB for the upstream developers to see =
the test consequence.</span></p></li></ul></span></div></blockquote><div><b=
r></div><div>And I tried to upload test results to Maloo DB with my own acc=
ount several times following the guide=C2=A0<a href=3D"https://wiki.whamclo=
ud.com/display/TEI/Test+results+format">https://wiki.whamcloud.com/display/=
TEI/Test+results+format</a>.</div><div>Either with maloo_upload.sh or throu=
gh the website=C2=A0<a href=3D"https://testing.whamcloud.com/import_tasks/n=
ew">https://testing.whamcloud.com/import_tasks/new</a>. But can&#39;t see a=
ny upload in the upload queue=C2=A0</div><div><a href=3D"https://testing.wh=
amcloud.com/import_tasks?user_id=3Db8340029-197d-4ce0-a8f1-40f76d3bb8c7">ht=
tps://testing.whamcloud.com/import_tasks?user_id=3Db8340029-197d-4ce0-a8f1-=
40f76d3bb8c7</a>.<br></div><div>=C2=A0</div><blockquote class=3D"gmail_quot=
e" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204)=
;padding-left:1ex"><div dir=3D"ltr"><span id=3D"gmail-m_7662657995136405504=
gmail-docs-internal-guid-bf78b256-7fff-fed1-32e6-5692649117fe"><ul style=3D=
"margin-top:0px;margin-bottom:0px"><li dir=3D"ltr" style=3D"list-style-type=
:disc;font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:tr=
ansparent;font-variant-numeric:normal;font-variant-east-asian:normal;vertic=
al-align:baseline;white-space:pre-wrap"><p dir=3D"ltr" style=3D"line-height=
:1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span style=
=3D"font-size:11pt;background-color:transparent;font-variant-numeric:normal=
;font-variant-east-asian:normal;vertical-align:baseline;white-space:pre-wra=
p">We have now built and maintained a yum repository for Lustre and e2fspro=
gs at </span><a href=3D"http://213.146.155.48/repo/" style=3D"text-decorati=
on-line:none" target=3D"_blank"><span style=3D"font-size:11pt;background-co=
lor:transparent;font-variant-numeric:normal;font-variant-east-asian:normal;=
text-decoration-line:underline;vertical-align:baseline;white-space:pre-wrap=
">http://213.146.155.48/repo/</span></a><span style=3D"font-size:11pt;backg=
round-color:transparent;font-variant-numeric:normal;font-variant-east-asian=
:normal;vertical-align:baseline;white-space:pre-wrap">. We plan to share th=
e tested Arm64 RPMs in case anyone wants to try Lustre on Arm quickly, </sp=
an><span style=3D"font-size:11pt;background-color:transparent;font-weight:7=
00;font-variant-numeric:normal;font-variant-east-asian:normal;vertical-alig=
n:baseline;white-space:pre-wrap">can we put them into the Lustre official r=
epo</span><span style=3D"font-size:11pt;background-color:transparent;font-v=
ariant-numeric:normal;font-variant-east-asian:normal;vertical-align:baselin=
e;white-space:pre-wrap"> </span><a href=3D"https://downloads.whamcloud.com/=
public/lustre/" style=3D"text-decoration-line:none" target=3D"_blank"><span=
 style=3D"font-size:11pt;background-color:transparent;font-variant-numeric:=
normal;font-variant-east-asian:normal;text-decoration-line:underline;vertic=
al-align:baseline;white-space:pre-wrap">https://downloads.whamcloud.com/pub=
lic/lustre/</span></a><span style=3D"font-size:11pt;background-color:transp=
arent;font-variant-numeric:normal;font-variant-east-asian:normal;vertical-a=
lign:baseline;white-space:pre-wrap"> </span><span style=3D"font-size:11pt;b=
ackground-color:transparent;font-weight:700;font-variant-numeric:normal;fon=
t-variant-east-asian:normal;vertical-align:baseline;white-space:pre-wrap">a=
s an experimental release</span><span style=3D"font-size:11pt;background-co=
lor:transparent;font-variant-numeric:normal;font-variant-east-asian:normal;=
vertical-align:baseline;white-space:pre-wrap">? Or if we can=E2=80=99t, ano=
ther proposal,</span><span style=3D"font-size:11pt;background-color:transpa=
rent;font-weight:700;font-variant-numeric:normal;font-variant-east-asian:no=
rmal;vertical-align:baseline;white-space:pre-wrap"> is it possible for the =
community to have an entry in the </span><a href=3D"https://www.lustre.org/=
download/" style=3D"text-decoration-line:none" target=3D"_blank"><span styl=
e=3D"font-size:11pt;background-color:transparent;font-variant-numeric:norma=
l;font-variant-east-asian:normal;text-decoration-line:underline;vertical-al=
ign:baseline;white-space:pre-wrap">https://www.lustre.org/download/</span><=
/a><span style=3D"font-size:11pt;background-color:transparent;font-variant-=
numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;white=
-space:pre-wrap"> </span><span style=3D"font-size:11pt;background-color:tra=
nsparent;font-weight:700;font-variant-numeric:normal;font-variant-east-asia=
n:normal;vertical-align:baseline;white-space:pre-wrap">point to the externa=
l Arm64 yum repo?</span></p></li></ul><div><font color=3D"#000000" face=3D"=
Arial"><span style=3D"font-size:14.6667px;white-space:pre-wrap"><b><br></b>=
</span></font></div><div><font color=3D"#000000" face=3D"Arial"><span style=
=3D"font-size:14.6667px;white-space:pre-wrap">Thanks in advance and look fo=
rward to hearing from you soon. Really appreciate the help from Lustre upst=
ream during the last several months for Lustre on Arm64 bugfix and test.</s=
pan></font></div></span><div><br></div>-- <br><div dir=3D"ltr"><div dir=3D"=
ltr"><div><div dir=3D"ltr"><div><div dir=3D"ltr"><div dir=3D"ltr"><b>Best R=
egards</b><div><div style=3D"margin:0px;padding:0px 0px 20px;width:1262px">=
<div><div style=3D"margin:8px 0px 0px;padding:0px"><div><div dir=3D"ltr"><f=
ont><div dir=3D"ltr"><div dir=3D"ltr"><p class=3D"MsoNormal" style=3D"color=
:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif=
;font-size:medium"><b><span style=3D"font-size:11pt"><font color=3D"#38761d=
">Kevin Zhao</font></span></b></p><p class=3D"MsoNormal" style=3D"color:rgb=
(136,136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;fon=
t-size:medium"><font color=3D"#757b80"><span style=3D"font-size:14.6667px">=
Tech Lead, LDCG Cloud Infrastructure</span></font></p><p class=3D"MsoNormal=
" style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica,=
Arial,sans-serif;font-size:medium"><font color=3D"#757b80"><span style=3D"f=
ont-size:14.6667px">Linaro Vertical Technologies</span></font></p><p class=
=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDra=
ft,Helvetica,Arial,sans-serif;font-size:medium"><font color=3D"#757b80"><sp=
an style=3D"font-size:14.6667px">IRC(freenode): kevinz</span></font></p><p =
class=3D"MsoNormal"><font color=3D"#757b80"><font color=3D"#888888" face=3D=
"Roboto, RobotoDraft, Helvetica, Arial, sans-serif"><span style=3D"font-siz=
e:14.6667px">Slack(</span></font><font face=3D"Roboto, RobotoDraft, Helveti=
ca, Arial, sans-serif"><span style=3D"font-size:14.6667px"><a href=3D"http:=
//kubernetes.slack.com" target=3D"_blank">kubernetes.slack.com</a>)</span><=
/font><font color=3D"#888888" face=3D"Roboto, RobotoDraft, Helvetica, Arial=
, sans-serif"><span style=3D"font-size:14.6667px">: kevinz</span></font></f=
ont></p><p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:=
Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"><font color=
=3D"#757b80"><span style=3D"font-size:14.6667px"><a href=3D"mailto:kevin.zh=
ao@linaro.org" target=3D"_blank"><span>kevin.zhao@linaro.org</span></a>=C2=
=A0| Mobile/Direct/Wechat:=C2=A0 +86 18818270915</span></font><span style=
=3D"color:rgb(117,123,128);font-size:11pt">=C2=A0</span><br></p><div style=
=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial,s=
ans-serif;font-size:medium"><span style=3D"color:rgb(117,123,128);font-size=
:11pt"><br></span></div></div></div></font></div><div style=3D"font-family:=
Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"></div></div=
></div><div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-se=
rif;font-size:medium"></div></div></div></div></div></div></div></div></div=
></div></div></div>
</blockquote></div></div>

--00000000000027d9e805dd708ad3--

--===============3352402719530979064==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3352402719530979064==--
