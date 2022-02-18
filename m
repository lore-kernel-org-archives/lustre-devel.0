Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 83229C433F5
	for <lustre-devel@archiver.kernel.org>; Fri, 18 Feb 2022 08:05:44 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EE12421CAF7;
	Fri, 18 Feb 2022 00:05:43 -0800 (PST)
Received: from mail-oo1-f54.google.com (mail-oo1-f54.google.com
 [209.85.161.54])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9772121CA3F
 for <lustre-devel@lists.lustre.org>; Fri, 18 Feb 2022 00:05:42 -0800 (PST)
Received: by mail-oo1-f54.google.com with SMTP id
 i10-20020a4aab0a000000b002fccf890d5fso2642524oon.5
 for <lustre-devel@lists.lustre.org>; Fri, 18 Feb 2022 00:05:42 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=IrzNotffqN0hBecqn/WKMqvepcJ9Nc9xSQ8wRdox22s=;
 b=BUmfaLXJmH/QY/AsGkQqOHHoLOXn0Nuis7JAOo0RwvyvmpDhg284gLSvrI9prsEJlZ
 4GuCi/LW4INQaUdDAr+Z6nFEpSAXTH1vhZjj9efR58V9c0VcJu79Y4VJpJELE/gx9mdA
 YRa2qnPI3QAubElCJRlBY12nV5biVwMK9GXw3yHyENw4G5XARAag9wBdMATfd0Fqc1Fp
 9T+D97RR4JKAEjFS8L9wNYreMiuOgWqsS6sfRUd9fZO5/rqBsAmN/C0oI3J4et+R/CWf
 NMh5PxQzUS91oTESLTCNl3RptDzms/vKwRlW2YmgJ0fzBtOPS0XjMHqddD4ArxY4Ckyh
 mIlg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=IrzNotffqN0hBecqn/WKMqvepcJ9Nc9xSQ8wRdox22s=;
 b=LZIcMR8RlvjDDQDjvau02H31R9mh184CXRYEmxHTSir6qXGofxK+iMftyIeu2ZQ408
 jOzygM9vqjLxjChAJPJlpYgXSUNd2N8oBUCiKwqRvLaUNfXWg8Oc8N0fOLMLM71/YxmW
 Ntqg44Zw2vdsCjykMLAk0O3T2eQcrtlbeMz2HYjQIW0ouX66hZ8D3Sk/mFQ1vBAnrxFx
 ob1bcdBoB2xmTwc7Bg4StFKj6WYVRZoGyiDf8NJd3tSsm5Rou3fYByI/h+Il2eSs2CRE
 FTeVResjoB7c5gXYFEhAzmqwnl5FSQ5upEfNelx2Z85dlFmY7Q2aozgP8NaiwqUMq5oo
 8mhA==
X-Gm-Message-State: AOAM530U+pbtcGT3Y6Zk78zv/wvYEVJEoR2d+SANPCmV1dwaqcZR/HKl
 R8v2dBhiCvgOgHnjagXKXMyECbSuUUIPZFEA7ir1
X-Google-Smtp-Source: ABdhPJx7g+D+P8FuomLs0IcarAW1EznvQwmFjhWV/TRoFtNebedKCxfQtUfUDMpTv9vCFeEqEphxtHB7u1JIdPhHKV8=
X-Received: by 2002:a05:6870:14cc:b0:ce:c0c9:649 with SMTP id
 l12-20020a05687014cc00b000cec0c90649mr4041327oab.155.1645171541552; Fri, 18
 Feb 2022 00:05:41 -0800 (PST)
MIME-Version: 1.0
References: <CAKoKPby+hn5+py-f11c31Po241871un0v=SQM+Cc6_hzvxW8uA@mail.gmail.com>
 <CAKoKPbxTcSxGzASKyVhiv_7W3OY6x3DRtkcTu8hzvLM+4-PzZw@mail.gmail.com>
 <6C592E3F-0437-4776-BB29-C5EE489C5FAE@whamcloud.com>
 <CAKoKPbxmvn7GVc6wsYrLP_HD8SpNMVFfSFdiZMo-5ZXqS-HSdg@mail.gmail.com>
 <7AAC4FDA-AC84-4E73-83AB-130B6BD3AE1B@whamcloud.com>
 <CAKoKPbxQymhN93F5oM_TxK6y0kk5_bv3p62FncUz6Ri_0jmABw@mail.gmail.com>
 <023CD146-E2BA-4B03-9459-C480E51EBE7E@whamcloud.com>
In-Reply-To: <023CD146-E2BA-4B03-9459-C480E51EBE7E@whamcloud.com>
Date: Fri, 18 Feb 2022 16:05:30 +0800
Message-ID: <CACzn6-XOJuca15j8sObDwoG3Wb6WgUGc0ptTCUHuQFkEM7S1XQ@mail.gmail.com>
To: Oleg Drokin <green@whamcloud.com>, mdiep@whamcloud.com
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
Content-Type: multipart/mixed; boundary="===============4003944723233794852=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============4003944723233794852==
Content-Type: multipart/alternative; boundary="00000000000054465005d84659d1"

--00000000000054465005d84659d1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi All,


Greetings and thanks a lot for your comments! Xinliang and I are from Linar=
o
<https://www.linaro.org/>, an organization focusing on Arm open-source
ecosystem development. We have been working on Lustre on the Arm64 server
and client end for a while now, already fixing a few bugs on arm64.

As Xinliang said before, we want to enable the Arm64 CI, Oleg advises that
we can plug our own CI nodes into the Jenkins. Now we want to understand
and estimate how many machines resources can meet our requests, and doing
the next stage plan of our hardware to meet the Lustre test requirements.


As I understand, the test jobs will cover the ZFS and Ldiskfs backend with
2 scenarios:

   -

   Lustre Arm64 Server + Arm64 Client( High Priority )
   -

   Lustre Arm64 Server + x86_64 Client

After going through the Lustre test website:
https://testing.whamcloud.com/test_sessions, it is quite clear to show the
test info, and still remain some questions, that will be great if the
community can give me a clear answer.

1. Is there a link to show all the machine resources=EF=BC=9F Including the=
 machine
info, CPU, memory and peripheral info.

2. Do we have a CI infra arch overview diagram to show the machine usage
and communication?

3. How many machines are needed to meet the request of the Lustre Arm64
Server + Arm64 Client test?


Thanks a lot for your time, and look forward to your response.


On Tue, 28 Dec 2021 at 09:58, Oleg Drokin <green@whamcloud.com> wrote:

>
>
> On Dec 27, 2021, at 8:53 PM, Xinliang Liu <xinliang.liu@linaro.org> wrote=
:
>
> Maloo is just one place to link to to actually let people see the results=
,
>> but you can link to external resources too
>> like e.g. gatekeeper janitor helper does or assuming the information is
>> small enough it could be entirely contained
>> in the comment (like say for a build failure)
>>
>
> Ok, understand now. Is there any other reference external CI that posts
> results to Lustre gerrit now?
>
>
> Currently there are:
> - checkpatch and Misc code checks (smach) that post their results as 100%
> comment only. they share codebase pretty much
> - the Janitor (also started with above codebase but got changed and
> extended a lot)
>
> There was external interest in the past to post results to gerrit but it
> never materialized in the end
>


--=20
*Best Regards*

*Kevin Zhao*

Tech Lead, LDCG Cloud Infrastructure

Linaro Vertical Technologies

IRC(freenode): kevinz

Slack(kubernetes.slack.com): kevinz

kevin.zhao@linaro.org | Mobile/Direct/Wechat:  +86 18818270915

--00000000000054465005d84659d1
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><span id=3D"gmail-docs-internal-guid-546d83e7-7fff-79c4-f7=
64-aa4cccb7706c"><p style=3D"line-height:1.38;margin-top:0pt;margin-bottom:=
0pt"><span style=3D"font-size:11pt;font-family:Arial;background-color:trans=
parent;font-variant-numeric:normal;font-variant-east-asian:normal;vertical-=
align:baseline;white-space:pre-wrap">Hi All,</span></p><p style=3D"line-hei=
ght:1.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size:11pt;fo=
nt-family:Arial;background-color:transparent;font-variant-numeric:normal;fo=
nt-variant-east-asian:normal;vertical-align:baseline;white-space:pre-wrap">=
<br></span></p><p style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0p=
t"><span style=3D"font-size:11pt;font-family:Arial;background-color:transpa=
rent;font-variant-numeric:normal;font-variant-east-asian:normal;vertical-al=
ign:baseline;white-space:pre-wrap">Greetings and thanks a lot for your comm=
ents! Xinliang and I are from <a href=3D"https://www.linaro.org/">Linaro</a=
>, an organization focusing on </span><span style=3D"font-family:Arial;font=
-size:14.6667px;white-space:pre-wrap">Arm open-source ecosystem development=
</span><span style=3D"background-color:transparent;font-family:Arial;font-s=
ize:11pt;white-space:pre-wrap">. We have been working on Lustre on the Arm6=
4 server and client end for a while now, already fixing a few bugs on arm64=
. </span></p><p style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"=
><span style=3D"background-color:transparent;font-family:Arial;font-size:11=
pt;white-space:pre-wrap">As Xinliang said before, </span><span style=3D"bac=
kground-color:transparent;font-family:Arial;font-size:11pt;white-space:pre-=
wrap">we want to enable the Arm64 CI, Oleg advises that we can plug our own=
 CI nodes into</span>=C2=A0the Jenkins<span style=3D"background-color:trans=
parent;font-family:Arial;font-size:11pt;white-space:pre-wrap">. </span><spa=
n style=3D"font-family:Arial;font-size:14.6667px;white-space:pre-wrap">Now =
we want to understand and estimate how many machines resources can meet our=
 requests, and doing the next stage plan of our hardware to meet the Lustre=
 test requirements.</span></p><p style=3D"line-height:1.38;margin-top:0pt;m=
argin-bottom:0pt"><span style=3D"background-color:transparent;font-family:A=
rial;font-size:11pt;white-space:pre-wrap"><br></span></p><p dir=3D"ltr" sty=
le=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"fon=
t-size:11pt;font-family:Arial;background-color:transparent;font-variant-num=
eric:normal;font-variant-east-asian:normal;vertical-align:baseline;white-sp=
ace:pre-wrap">As I understand, the test jobs will cover the ZFS and Ldiskfs=
 backend with 2 scenarios:</span></p><ul style=3D"margin-top:0px;margin-bot=
tom:0px"><li dir=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font-=
family:Arial;background-color:transparent;font-variant-numeric:normal;font-=
variant-east-asian:normal;vertical-align:baseline;white-space:pre"><p dir=
=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt" role=
=3D"presentation"><span style=3D"font-size:11pt;background-color:transparen=
t;font-variant-numeric:normal;font-variant-east-asian:normal;vertical-align=
:baseline;white-space:pre-wrap">Lustre Arm64 Server + Arm64 Client( High Pr=
iority )</span></p></li><li dir=3D"ltr" style=3D"list-style-type:disc;font-=
size:11pt;font-family:Arial;background-color:transparent;font-variant-numer=
ic:normal;font-variant-east-asian:normal;vertical-align:baseline;white-spac=
e:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-botto=
m:0pt" role=3D"presentation"><span style=3D"font-size:11pt;background-color=
:transparent;font-variant-numeric:normal;font-variant-east-asian:normal;ver=
tical-align:baseline;white-space:pre-wrap">Lustre Arm64 Server + x86_64 Cli=
ent</span></p></li></ul><p dir=3D"ltr" style=3D"line-height:1.656;margin-to=
p:0pt;margin-bottom:0pt"><span style=3D"font-size:11pt;font-family:Arial;ba=
ckground-color:transparent;font-variant-numeric:normal;font-variant-east-as=
ian:normal;vertical-align:baseline;white-space:pre-wrap">After going throug=
h the Lustre test website: </span><a href=3D"https://testing.whamcloud.com/=
test_sessions" style=3D"text-decoration-line:none"><span style=3D"font-size=
:11pt;font-family:Arial;background-color:transparent;font-variant-numeric:n=
ormal;font-variant-east-asian:normal;text-decoration-line:underline;vertica=
l-align:baseline;white-space:pre-wrap">https://testing.whamcloud.com/test_s=
essions</span></a><span style=3D"font-size:11pt;font-family:Arial;backgroun=
d-color:transparent;font-variant-numeric:normal;font-variant-east-asian:nor=
mal;vertical-align:baseline;white-space:pre-wrap">, it is quite clear to sh=
ow the test info, and still remain some questions, that will be great if th=
e community can give me a clear answer.</span></p><p dir=3D"ltr" style=3D"l=
ine-height:1.656;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size=
:11pt;font-family:Arial;background-color:transparent;font-variant-numeric:n=
ormal;font-variant-east-asian:normal;vertical-align:baseline;white-space:pr=
e-wrap">1. Is there a link to show all the machine resources=EF=BC=9F Inclu=
ding the machine info, CPU, memory and peripheral info.=C2=A0</span></p><p =
dir=3D"ltr" style=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt"><s=
pan style=3D"font-size:11pt;font-family:Arial;background-color:transparent;=
font-variant-numeric:normal;font-variant-east-asian:normal;vertical-align:b=
aseline;white-space:pre-wrap">2. Do we have a CI infra arch overview diagra=
m to show the machine usage and communication?=C2=A0</span></p><p dir=3D"lt=
r" style=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt"><span style=
=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-vari=
ant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;w=
hite-space:pre-wrap">3. How many machines are needed to meet the request of=
 the Lustre Arm64 Server + Arm64 Client test?</span></p><p dir=3D"ltr" styl=
e=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt"><span style=3D"fon=
t-size:11pt;font-family:Arial;background-color:transparent;font-variant-num=
eric:normal;font-variant-east-asian:normal;vertical-align:baseline;white-sp=
ace:pre-wrap"><br></span></p><p style=3D"line-height:1.656;margin-top:0pt;m=
argin-bottom:0pt"><span style=3D"font-size:11pt;font-family:Arial;backgroun=
d-color:transparent;font-variant-numeric:normal;font-variant-east-asian:nor=
mal;vertical-align:baseline;white-space:pre-wrap">Thanks a lot for your tim=
e, and look forward to your response.</span></p></span><br class=3D"gmail-A=
pple-interchange-newline"></div><br><div class=3D"gmail_quote"><div dir=3D"=
ltr" class=3D"gmail_attr">On Tue, 28 Dec 2021 at 09:58, Oleg Drokin &lt;<a =
href=3D"mailto:green@whamcloud.com">green@whamcloud.com</a>&gt; wrote:<br><=
/div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;bo=
rder-left:1px solid rgb(204,204,204);padding-left:1ex">



<div style=3D"overflow-wrap: break-word;">
<br>
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

--00000000000054465005d84659d1--

--===============4003944723233794852==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============4003944723233794852==--
