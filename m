Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 2C8D4C433EF
	for <lustre-devel@archiver.kernel.org>; Tue, 29 Mar 2022 07:38:06 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B6A8721FBB9;
	Tue, 29 Mar 2022 00:38:05 -0700 (PDT)
Received: from mail-oi1-f171.google.com (mail-oi1-f171.google.com
 [209.85.167.171])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 214F321F74B
 for <lustre-devel@lists.lustre.org>; Tue, 29 Mar 2022 00:38:04 -0700 (PDT)
Received: by mail-oi1-f171.google.com with SMTP id b188so18190839oia.13
 for <lustre-devel@lists.lustre.org>; Tue, 29 Mar 2022 00:38:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=JS7hDF+RCE8txkg4Gs1S1XuYUal3bJlzd+7mMiU9KkA=;
 b=rzX22iRvnHmbdLkeT9NGXEpWYCLm9o7fEE3wk+z5bI9KusczXTpCbGboT8nLnxT7Ku
 JbW5jQVH7+w9TELrANKzv8M6Pvbh9abB9vcq4mMmEjlHyAlu0wzklYLKZGJwizzU2yGs
 xmF1agiFGM7xNXyn/eh+dv3deDiGr7t7an/hldaqDJTqbZRlbI5KDEPpVxq6a66YvOnw
 YFhnWp+fTFFPW3OAid1jpZ8gkxjRuEh+9pKfsqRARglgeL72A+yFMd3BRxWnfXYMOhBz
 EecS1bDzK5c8sqM/xegiERsKDVrS/B05EyF1F7q3uGwMfoU6l1XhDNlCfgwFfFQmgSxF
 5umQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=JS7hDF+RCE8txkg4Gs1S1XuYUal3bJlzd+7mMiU9KkA=;
 b=jQucGq+j2AJx2C5a0vDEb055YD/L8MTsEzGFVGZzrfU3OHH3d9lQ3IkljhvoxiIWoL
 BJh28HyxeogOnH3Bll84etdZRMxELzOVepaZGFj+PG2v6bITjxHUYNsZIilqDqJbs2/W
 rFG/q5pVQXmLdI5qaNdySXSRAOVwrkC0oAMGa86bcL71k2mxiZwkpGuHL38vWNPhUO7G
 oLX8CWOUBky0/RkIv4GQskmK2e7qA0j1COtjFzXIut/lWe75bdkTLwiQqdWYDs3P5aPE
 lmVrCbWZ0Mmbml4n6+R1beh14xiNY04NN8Gjfiu0YkN3oLOUA2pfj9OW8PvpBIyIthuh
 8Fpg==
X-Gm-Message-State: AOAM5328Eae1JhEgB8R5wjzi6hNZyvswyATMR/Vwv0fptU6Td4fw1Few
 w0oyHG6jyStKuX29egpF5KbOUR7Ljd3GEX8hOyYA
X-Google-Smtp-Source: ABdhPJwVfFXYhWsLPJgaeZo670Y6wtcLS/CDC407fFlWy1BsJROaU45APWqeDFTY3hUAiTtiCB6+VXaJDFEUbe4ImS8=
X-Received: by 2002:aca:d04:0:b0:2ef:8b45:d235 with SMTP id
 4-20020aca0d04000000b002ef8b45d235mr636071oin.253.1648539482658; Tue, 29 Mar
 2022 00:38:02 -0700 (PDT)
MIME-Version: 1.0
References: <CAKoKPby+hn5+py-f11c31Po241871un0v=SQM+Cc6_hzvxW8uA@mail.gmail.com>
 <CAKoKPbxTcSxGzASKyVhiv_7W3OY6x3DRtkcTu8hzvLM+4-PzZw@mail.gmail.com>
 <6C592E3F-0437-4776-BB29-C5EE489C5FAE@whamcloud.com>
 <CAKoKPbxmvn7GVc6wsYrLP_HD8SpNMVFfSFdiZMo-5ZXqS-HSdg@mail.gmail.com>
 <7AAC4FDA-AC84-4E73-83AB-130B6BD3AE1B@whamcloud.com>
 <CAKoKPbxQymhN93F5oM_TxK6y0kk5_bv3p62FncUz6Ri_0jmABw@mail.gmail.com>
 <023CD146-E2BA-4B03-9459-C480E51EBE7E@whamcloud.com>
 <CACzn6-XOJuca15j8sObDwoG3Wb6WgUGc0ptTCUHuQFkEM7S1XQ@mail.gmail.com>
 <F5AF3C10-6ED7-4EEC-BA63-EF8256DA94D7@whamcloud.com>
In-Reply-To: <F5AF3C10-6ED7-4EEC-BA63-EF8256DA94D7@whamcloud.com>
Date: Tue, 29 Mar 2022 15:37:51 +0800
Message-ID: <CACzn6-Vi95OmyWBZ3Xw=jC6VSmpQKvAXEtefQmkf9OmSZ8yT3A@mail.gmail.com>
To: Oleg Drokin <green@whamcloud.com>
Subject: Re: [lustre-devel] Lustre Arm stuff status and work plan
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
Cc: Li Xi <lixi@ddn.com>, Jian Yu <jiyu@whamcloud.com>,
 "cloud-dev-request@op-lists.linaro.org"
 <cloud-dev-request@op-lists.linaro.org>,
 Xinliang Liu via lustre-devel <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============8575929941454398462=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============8575929941454398462==
Content-Type: multipart/alternative; boundary="000000000000432fad05db5682dd"

--000000000000432fad05db5682dd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Oleg,

We are now defining the test process and setting up a trial test cluster as
the external Arm64 test resources.
Can I have an account to post consequences to Maloo DB? The trial arm64
external test cluster is under setup and hopefully, it will be finished
quite soon. I want to test if we can post data to Maloo DB. Btw, the doc
you point before:
https://wiki.whamcloud.com/display/TEI/Test+results+format can
not access, just 404.

On Mon, 28 Feb 2022 at 13:36, Oleg Drokin <green@whamcloud.com> wrote:

> Hello!
>
>   the sizing really depends on your test scaling requirements.
>   For example my own test infrastructure is a couple builders + 4 nodes
> for VMs (each has 256G RAM), 160 VM pairs in total,
>   and on a particularly busy day another 80 VM pairs can be added. This i=
s
> to ensure speedy feedback to developers.
>   You can operate a much smaller scale testing system if you want, just
> keep in mind what is the longest running test would take
>   to understand how many patches could be tested in parallel (sometimes
> patch bombs result in 20+ patches submission at the same time).
>    Here=E2=80=99s stats for last 30 days. https://imgur.com/lk2ogJv 1 ite=
m means
> single patch n processing. time in testing for a patch is typically about
> 3.5 hours.
>
> maloo shows the resources when you go into the test session, for example
> https://testing.whamcloud.com/test_sessions/4de25b47-43fc-4bfc-87aa-15e49=
68519a7
> - scroll down to see list of nodes
>
>
>
> On Feb 18, 2022, at 3:05 AM, Kevin Zhao <kevin.zhao@linaro.org> wrote:
>
> Hi All,
>
> Greetings and thanks a lot for your comments! Xinliang and I are from
> Linaro <https://www.linaro.org/>, an organization focusing on Arm
> open-source ecosystem development. We have been working on Lustre on the
> Arm64 server and client end for a while now, already fixing a few bugs on
> arm64.
> As Xinliang said before, we want to enable the Arm64 CI, Oleg advises
> that we can plug our own CI nodes into the Jenkins. Now we want to
> understand and estimate how many machines resources can meet our requests=
,
> and doing the next stage plan of our hardware to meet the Lustre test
> requirements.
>
> As I understand, the test jobs will cover the ZFS and Ldiskfs backend wit=
h
> 2 scenarios:
>
>    - Lustre Arm64 Server + Arm64 Client( High Priority )
>    - Lustre Arm64 Server + x86_64 Client
>
> After going through the Lustre test website:
> https://testing.whamcloud.com/test_sessions, it is quite clear to show
> the test info, and still remain some questions, that will be great if the
> community can give me a clear answer.
> 1. Is there a link to show all the machine resources=EF=BC=9F Including t=
he
> machine info, CPU, memory and peripheral info.
> 2. Do we have a CI infra arch overview diagram to show the machine usage
> and communication?
> 3. How many machines are needed to meet the request of the Lustre Arm64
> Server + Arm64 Client test?
>
> Thanks a lot for your time, and look forward to your response.
>
>
> On Tue, 28 Dec 2021 at 09:58, Oleg Drokin <green@whamcloud.com> wrote:
>
>>
>>
>> On Dec 27, 2021, at 8:53 PM, Xinliang Liu <xinliang.liu@linaro.org>
>> wrote:
>>
>> Maloo is just one place to link to to actually let people see the
>>> results, but you can link to external resources too
>>> like e.g. gatekeeper janitor helper does or assuming the information is
>>> small enough it could be entirely contained
>>> in the comment (like say for a build failure)
>>>
>>
>> Ok, understand now. Is there any other reference external CI that posts
>> results to Lustre gerrit now?
>>
>>
>> Currently there are:
>> - checkpatch and Misc code checks (smach) that post their results as 100=
%
>> comment only. they share codebase pretty much
>> - the Janitor (also started with above codebase but got changed and
>> extended a lot)
>>
>> There was external interest in the past to post results to gerrit but it
>> never materialized in the end
>>
>
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
>

--=20
*Best Regards*

*Kevin Zhao*

Tech Lead, LDCG Cloud Infrastructure

Linaro Vertical Technologies

IRC(freenode): kevinz

Slack(kubernetes.slack.com): kevinz

kevin.zhao@linaro.org | Mobile/Direct/Wechat:  +86 18818270915

--000000000000432fad05db5682dd
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Oleg,<div><br></div><div>We are now defining the=C2=A0t=
est process and setting up=C2=A0a trial test cluster as the external Arm64 =
test resources.</div><div>Can I have an account to post consequences to Mal=
oo DB? The trial arm64 external test cluster is under setup=C2=A0and hopefu=
lly, it will be finished quite soon. I want to test if we can post data to =
Maloo DB. Btw, the doc you point before:=C2=A0<a href=3D"https://wiki.whamc=
loud.com/display/TEI/Test+results+format" target=3D"_blank">https://wiki.wh=
amcloud.com/display/TEI/Test+results+format</a>=C2=A0can not access, just 4=
04.</div></div><br><div class=3D"gmail_quote"><div dir=3D"ltr" class=3D"gma=
il_attr">On Mon, 28 Feb 2022 at 13:36, Oleg Drokin &lt;<a href=3D"mailto:gr=
een@whamcloud.com">green@whamcloud.com</a>&gt; wrote:<br></div><blockquote =
class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px sol=
id rgb(204,204,204);padding-left:1ex">



<div style=3D"overflow-wrap: break-word;">
Hello!
<div><br>
</div>
<div>=C2=A0 the sizing really depends on your test scaling requirements.</d=
iv>
<div>=C2=A0 For example my own test infrastructure is a couple builders + 4=
 nodes for VMs (each has 256G RAM), 160 VM pairs in total,</div>
<div>=C2=A0 and on a particularly busy day another 80 VM pairs can be added=
. This is to ensure speedy feedback to developers.</div>
<div>=C2=A0 You can operate a much smaller scale testing system if you want=
, just keep in mind what is the longest running test would take</div>
<div>=C2=A0 to understand how many patches could be tested in parallel (som=
etimes patch bombs result in 20+ patches submission at the same time).</div=
>
<div>=C2=A0 =C2=A0Here=E2=80=99s stats for last 30 days.=C2=A0<span style=
=3D"color:unset;font-family:unset;font-size:unset;font-variant-caps:unset;l=
etter-spacing:unset;text-align:unset;text-indent:unset;text-transform:unset=
;white-space:pre-wrap;word-spacing:unset;text-decoration:unset"><a href=3D"=
https://imgur.com/lk2ogJv" target=3D"_blank">https://imgur.com/lk2ogJv</a>
 1 item means single patch n processing. time in testing for a patch is typ=
ically about 3.5 hours.</span></div>
<div><span style=3D"white-space:pre-wrap"><br>
</span></div>
<div><span style=3D"white-space:pre-wrap">maloo shows the resources when yo=
u go into the test session, for example
<a href=3D"https://testing.whamcloud.com/test_sessions/4de25b47-43fc-4bfc-8=
7aa-15e4968519a7" target=3D"_blank">
https://testing.whamcloud.com/test_sessions/4de25b47-43fc-4bfc-87aa-15e4968=
519a7</a> - scroll down to see list of nodes</span></div>
<div><span style=3D"white-space:pre-wrap"><br>
</span></div>
<div><span style=3D"white-space:pre-wrap"><br>
</span>
<div><br>
<blockquote type=3D"cite">
<div>On Feb 18, 2022, at 3:05 AM, Kevin Zhao &lt;<a href=3D"mailto:kevin.zh=
ao@linaro.org" target=3D"_blank">kevin.zhao@linaro.org</a>&gt; wrote:</div>
<br>
<div>
<div dir=3D"ltr"><span id=3D"gmail-m_7393553657705266992gmail-docs-internal=
-guid-546d83e7-7fff-79c4-f764-aa4cccb7706c">
<div style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span styl=
e=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-var=
iant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;=
white-space:pre-wrap">Hi
 All,</span></div>
<div style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span styl=
e=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-var=
iant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;=
white-space:pre-wrap"><br>
</span></div>
<div style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span styl=
e=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-var=
iant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;=
white-space:pre-wrap">Greetings
 and thanks a lot for your comments! Xinliang and I are from <a href=3D"htt=
ps://www.linaro.org/" target=3D"_blank">
Linaro</a>, an organization focusing on </span><span style=3D"font-family:A=
rial;font-size:14.6667px;white-space:pre-wrap">Arm open-source ecosystem de=
velopment</span><span style=3D"background-color:transparent;font-family:Ari=
al;font-size:11pt;white-space:pre-wrap">.
 We have been working on Lustre on the Arm64 server and client end for a wh=
ile now, already fixing a few bugs on arm64.
</span></div>
<div style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span styl=
e=3D"background-color:transparent;font-family:Arial;font-size:11pt;white-sp=
ace:pre-wrap">As Xinliang said before,
</span><span style=3D"background-color:transparent;font-family:Arial;font-s=
ize:11pt;white-space:pre-wrap">we want to enable the Arm64 CI, Oleg advises=
 that we can plug our own CI nodes into</span>=C2=A0the Jenkins<span style=
=3D"background-color:transparent;font-family:Arial;font-size:11pt;white-spa=
ce:pre-wrap">.
</span><span style=3D"font-family:Arial;font-size:14.6667px;white-space:pre=
-wrap">Now we want to understand and estimate how many machines resources c=
an meet our requests, and doing the next stage plan of our hardware to meet=
 the Lustre test requirements.</span></div>
<div style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span styl=
e=3D"background-color:transparent;font-family:Arial;font-size:11pt;white-sp=
ace:pre-wrap"><br>
</span></div>
<div style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span styl=
e=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-var=
iant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;=
white-space:pre-wrap">As
 I understand, the test jobs will cover the ZFS and Ldiskfs backend with 2 =
scenarios:</span></div>
<ul style=3D"margin-top:0px;margin-bottom:0px">
<li dir=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font-family:Ar=
ial;background-color:transparent;font-variant-numeric:normal;font-variant-e=
ast-asian:normal;vertical-align:baseline;white-space:pre-wrap">
<div style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span styl=
e=3D"font-size:11pt;background-color:transparent;font-variant-numeric:norma=
l;font-variant-east-asian:normal;vertical-align:baseline;white-space:pre-wr=
ap">Lustre Arm64
 Server + Arm64 Client( High Priority )</span></div>
</li><li dir=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font-fami=
ly:Arial;background-color:transparent;font-variant-numeric:normal;font-vari=
ant-east-asian:normal;vertical-align:baseline;white-space:pre-wrap">
<div style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span styl=
e=3D"font-size:11pt;background-color:transparent;font-variant-numeric:norma=
l;font-variant-east-asian:normal;vertical-align:baseline;white-space:pre-wr=
ap">Lustre Arm64
 Server + x86_64 Client</span></div>
</li></ul>
<div style=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt"><span sty=
le=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-va=
riant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline=
;white-space:pre-wrap">After
 going through the Lustre test website: </span><a href=3D"https://testing.w=
hamcloud.com/test_sessions" style=3D"text-decoration-line:none" target=3D"_=
blank"><span style=3D"font-size:11pt;font-family:Arial;background-color:tra=
nsparent;font-variant-numeric:normal;font-variant-east-asian:normal;text-de=
coration-line:underline;vertical-align:baseline;white-space:pre-wrap">https=
://testing.whamcloud.com/test_sessions</span></a><span style=3D"font-size:1=
1pt;font-family:Arial;background-color:transparent;font-variant-numeric:nor=
mal;font-variant-east-asian:normal;vertical-align:baseline;white-space:pre-=
wrap">,
 it is quite clear to show the test info, and still remain some questions, =
that will be great if the community can give me a clear answer.</span></div=
>
<div style=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt"><span sty=
le=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-va=
riant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline=
;white-space:pre-wrap">1.
 Is there a link to show all the machine resources=EF=BC=9F Including the m=
achine info, CPU, memory and peripheral info.=C2=A0</span></div>
<div style=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt"><span sty=
le=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-va=
riant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline=
;white-space:pre-wrap">2.
 Do we have a CI infra arch overview diagram to show the machine usage and =
communication?=C2=A0</span></div>
<div style=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt"><span sty=
le=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-va=
riant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline=
;white-space:pre-wrap">3.
 How many machines are needed to meet the request of the Lustre Arm64 Serve=
r + Arm64 Client test?</span></div>
<div style=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt"><span sty=
le=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-va=
riant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline=
;white-space:pre-wrap"><br>
</span></div>
<div style=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt"><span sty=
le=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-va=
riant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline=
;white-space:pre-wrap">Thanks
 a lot for your time, and look forward to your response.</span></div>
</span><br>
</div>
<br>
<div class=3D"gmail_quote">
<div dir=3D"ltr" class=3D"gmail_attr">On Tue, 28 Dec 2021 at 09:58, Oleg Dr=
okin &lt;<a href=3D"mailto:green@whamcloud.com" target=3D"_blank">green@wha=
mcloud.com</a>&gt; wrote:<br>
</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left:1px solid rgb(204,204,204);padding-left:1ex">
<div><br>
<div><br>
<blockquote type=3D"cite">
<div>On Dec 27, 2021, at 8:53 PM, Xinliang Liu &lt;<a href=3D"mailto:xinlia=
ng.liu@linaro.org" target=3D"_blank">xinliang.liu@linaro.org</a>&gt; wrote:=
</div>
<div>
<div dir=3D"ltr">
<div class=3D"gmail_quote"><br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left:1px solid rgb(204,204,204);padding-left:1ex">
Maloo is just one place to link to to actually let people see the results, =
but you can link to external resources too<br>
like e.g. gatekeeper janitor helper does or assuming the information is sma=
ll enough it could be entirely contained<br>
in the comment (like say for a build failure)<br>
</blockquote>
<div><br>
</div>
<div>Ok, understand now. Is there any other reference external CI that post=
s results to Lustre gerrit now?</div>
</div>
</div>
</div>
</blockquote>
<div><br>
</div>
Currently there are:</div>
<div>- checkpatch and Misc code checks (smach) that post their results as 1=
00% comment only. they share codebase pretty much</div>
<div>- the Janitor (also started with above codebase but got changed and ex=
tended a lot)</div>
<div><br>
</div>
<div>There was external interest in the past to post results to gerrit but =
it never materialized in the end</div>
</div>
</blockquote>
</div>
<br clear=3D"all">
<div><br>
</div>
-- <br>
<div dir=3D"ltr">
<div dir=3D"ltr">
<div>
<div dir=3D"ltr">
<div>
<div dir=3D"ltr">
<div dir=3D"ltr"><b>Best Regards</b>
<div>
<div style=3D"margin:0px;padding:0px 0px 20px;width:1262px">
<div>
<div style=3D"margin:8px 0px 0px;padding:0px">
<div>
<div dir=3D"ltr"><font>
<div dir=3D"ltr">
<div dir=3D"ltr">
<p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto,R=
obotoDraft,Helvetica,Arial,sans-serif;font-size:inherit">
<b><span style=3D"font-size:11pt"><font color=3D"#38761d">Kevin Zhao</font>=
</span></b></p>
<p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto,R=
obotoDraft,Helvetica,Arial,sans-serif;font-size:inherit">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">Tech Lead, LDCG=
 Cloud Infrastructure</span></font></p>
<p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto,R=
obotoDraft,Helvetica,Arial,sans-serif;font-size:inherit">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">Linaro Vertical=
 Technologies</span></font></p>
<p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto,R=
obotoDraft,Helvetica,Arial,sans-serif;font-size:inherit">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">IRC(freenode): =
kevinz</span></font></p>
<p class=3D"MsoNormal"><font color=3D"#757b80"><font color=3D"#888888" face=
=3D"Roboto, RobotoDraft, Helvetica, Arial, sans-serif"><span style=3D"font-=
size:14.6667px">Slack(</span></font><font face=3D"Roboto, RobotoDraft, Helv=
etica, Arial, sans-serif"><span style=3D"font-size:14.6667px"><a href=3D"ht=
tp://kubernetes.slack.com/" target=3D"_blank">kubernetes.slack.com</a>)</sp=
an></font><font color=3D"#888888" face=3D"Roboto, RobotoDraft, Helvetica, A=
rial, sans-serif"><span style=3D"font-size:14.6667px">:
 kevinz</span></font></font></p>
<p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto,R=
obotoDraft,Helvetica,Arial,sans-serif;font-size:inherit">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px"><a href=3D"mail=
to:kevin.zhao@linaro.org" target=3D"_blank"><span>kevin.zhao@linaro.org</sp=
an></a>=C2=A0| Mobile/Direct/Wechat:=C2=A0 +86 18818270915</span></font><sp=
an style=3D"color:rgb(117,123,128);font-size:11pt">=C2=A0</span><br>
</p>
<div style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helveti=
ca,Arial,sans-serif;font-size:inherit">
<span style=3D"color:rgb(117,123,128);font-size:11pt"><br>
</span></div>
</div>
</div>
</font></div>
<div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;fon=
t-size:inherit">
</div>
</div>
</div>
<div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;fon=
t-size:inherit">
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
<br>
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
e:14.6667px"><a href=3D"mailto:kevin.zhao@linaro.org" target=3D"_blank"><sp=
an>kevin.zhao@linaro.org</span></a>=C2=A0| Mobile/Direct/Wechat:=C2=A0 +86 =
18818270915</span></font><span style=3D"color:rgb(117,123,128);font-size:11=
pt">=C2=A0</span><br></p><div style=3D"color:rgb(136,136,136);font-family:R=
oboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"><span style=
=3D"color:rgb(117,123,128);font-size:11pt"><br></span></div></div></div></f=
ont></div><div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans=
-serif;font-size:medium"></div></div></div><div style=3D"font-family:Roboto=
,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"></div></div></div=
></div></div></div></div></div></div></div></div>

--000000000000432fad05db5682dd--

--===============8575929941454398462==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============8575929941454398462==--
