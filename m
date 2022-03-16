Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 23773C433F5
	for <lustre-devel@archiver.kernel.org>; Wed, 16 Mar 2022 01:25:17 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4C83321F3A2;
	Tue, 15 Mar 2022 18:25:17 -0700 (PDT)
Received: from mail-oi1-f181.google.com (mail-oi1-f181.google.com
 [209.85.167.181])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6BE2021F380
 for <lustre-devel@lists.lustre.org>; Tue, 15 Mar 2022 18:25:15 -0700 (PDT)
Received: by mail-oi1-f181.google.com with SMTP id w127so1123960oig.10
 for <lustre-devel@lists.lustre.org>; Tue, 15 Mar 2022 18:25:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=xdjuJOJJkKeMbnk1e5tuHMYPIA3kwj0oOgqZ7Xq+A7s=;
 b=EyCBQ4K5AgpqYzbx6AlEemmIEYCo72M4vjCs6K/BW/EEGiOuOWYeRMFN+EiqNNKhpF
 38b+4Suj35BbZ9LnkfT3RwWxLl+t2Hiq6wMxCU88AScPoM0ko2EBkwJ/y8srligm3q5t
 kt8WIud1MC/8kM+EiXVRpkDT4QtzgSOVpy5/cc5h/53UNOFvp4RSoXsafR+iza4zEDJ2
 JZCNQ5dQ1PpHEW94Zo8Y3Rq6V/06GnKGuJBBnRq61M1jbIWdqvrlcgmOp3QGCmw/MG4Q
 zdn5sOE8OetJ7RCNXVfXZCRfny0Qyjew1HQoltCmatXYtf4BJ+fwWaomluJfNkwFpoAF
 L4mA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=xdjuJOJJkKeMbnk1e5tuHMYPIA3kwj0oOgqZ7Xq+A7s=;
 b=dBLSIq5uI2k6MERNlRok8QowilQcNC7+0xezxuKDZXp6KQEEyKay1LnC7DVXYDUyX2
 hkNx7+CGTa2D7bnf7QQlbfJ4o0fp6IKNKcexRcx2aQmyNPc/tgdIR6fW+jErmVN+pEoG
 lrzn/b2ynXwM3ulo0OA81VIi/DDWvWqp9O+TXutUqgdXYO+bBTXbeFD/+2QbnBGrjCx6
 Lr41Ca3Vs4WaSZii3BGgspJMnuTPeUrlP2YOhE7NaTgITMK7IMR62V8SLg5Z1MKHu/C+
 0BKSD89MnXIvgeqMu9+FE/fOZl8zkcxkeIJEy3NyhHXe+MVs1Y6k1E0LLAws2VSpN0cg
 pECg==
X-Gm-Message-State: AOAM532N8c9K02+tDflvOozlF85ob8d3S4DgJuARLEVd3wKZ8KGmI6xW
 DchrA1TI8FC8k8TsLIzTtk2hoSkqRZvpFpppMcZL
X-Google-Smtp-Source: ABdhPJy20zAbnBoya61K3imkgE9Ug9G6RSLYpl/JJI8TaYcerrf9h0GcNKnTGsRM+3+6dZ1rDziO2QXtlJkLMxJ40pg=
X-Received: by 2002:a05:6808:f8a:b0:2da:1e9b:e85d with SMTP id
 o10-20020a0568080f8a00b002da1e9be85dmr3001442oiw.111.1647393914452; Tue, 15
 Mar 2022 18:25:14 -0700 (PDT)
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
 <CACzn6-V0Cvg+O1-DEWotBoZah2nZq=a65DVjtssF2RFj+aGqUQ@mail.gmail.com>
 <SA9PR09MB58089F742CA86BB6A89FF610D6109@SA9PR09MB5808.namprd09.prod.outlook.com>
In-Reply-To: <SA9PR09MB58089F742CA86BB6A89FF610D6109@SA9PR09MB5808.namprd09.prod.outlook.com>
Date: Wed, 16 Mar 2022 09:25:03 +0800
Message-ID: <CACzn6-XWcAa_QouJP6PAh6S-m9ztyb1dDTmfNnuMOEADBS3GRQ@mail.gmail.com>
To: "Simmons, James" <simmonsja@ornl.gov>
Subject: Re: [lustre-devel] [EXTERNAL] Re: Lustre Arm stuff status and work
 plan
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
Cc: Xinliang Liu via lustre-devel <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============6841611430526068066=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============6841611430526068066==
Content-Type: multipart/alternative; boundary="00000000000013914605da4bc938"

--00000000000013914605da4bc938
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi James,

It would be great! Look forward to having a joint talk on LUG2022 :-).

Xinliang and I are now working on the test cluster setup and hopefully, we
will have some progress quite soon.

On Wed, 16 Mar 2022 at 06:09, Simmons, James <simmonsja@ornl.gov> wrote:

> Hello.
>
>     I have been watching your efforts to doing your own testing and this
> is something ORNL has been interested in as well.
> I was thinking would you be willing to do a joint talk at LUG on this
> effort. We can pool our knowledge on how to doing
> local testing and feeding it back to WC. Would you be interested?
> ------------------------------
> *From:* lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of
> Kevin Zhao via lustre-devel <lustre-devel@lists.lustre.org>
> *Sent:* Friday, March 11, 2022 1:28 AM
> *To:* Oleg Drokin <green@whamcloud.com>
> *Cc:* Li Xi <lixi@ddn.com>; Jian Yu <jiyu@whamcloud.com>;
> cloud-dev-request@op-lists.linaro.org <
> cloud-dev-request@op-lists.linaro.org>; Xinliang Liu via lustre-devel <
> lustre-devel@lists.lustre.org>
> *Subject:* [EXTERNAL] Re: [lustre-devel] Lustre Arm stuff status and work
> plan
>
> Thanks Oleg,
>
> I will update the progress for the test clusters setup on Arm64 platform.
>
> On Mon, 28 Feb 2022 at 13:36, Oleg Drokin <green@whamcloud.com> wrote:
>
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
>    Here=E2=80=99s stats for last 30 days. hxxps://imgur.com/lk2ogJv 1 ite=
m means
> single patch n processing. time in testing for a patch is typically about
> 3.5 hours.
>
> maloo shows the resources when you go into the test session, for example
> hxxps://testing.whamcloud.com/test_sessions/4de25b47-43fc-4bfc-87aa-15e49=
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
> Linaro, an organization focusing on Arm open-source ecosystem development=
.
> We have been working on Lustre on the Arm64 server and client end for a
> while now, already fixing a few bugs on arm64.
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
> hxxps://testing.whamcloud.com/test_sessions, it is quite clear to show
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
>
>
> On Dec 27, 2021, at 8:53 PM, Xinliang Liu <xinliang.liu@linaro.org> wrote=
:
>
> Maloo is just one place to link to to actually let people see the results=
,
> but you can link to external resources too
> like e.g. gatekeeper janitor helper does or assuming the information is
> small enough it could be entirely contained
> in the comment (like say for a build failure)
>
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

--=20
*Best Regards*

*Kevin Zhao*

Tech Lead, LDCG Cloud Infrastructure

Linaro Vertical Technologies

IRC(freenode): kevinz

Slack(kubernetes.slack.com): kevinz

kevin.zhao@linaro.org | Mobile/Direct/Wechat:  +86 18818270915

--00000000000013914605da4bc938
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi=C2=A0James,<div><br></div><div>It would be great! Look =
forward to having a joint talk on LUG2022 :-).=C2=A0</div><div><br></div><d=
iv>Xinliang and I are now working on the test cluster setup and hopefully, =
we will have some progress quite soon.</div></div><br><div class=3D"gmail_q=
uote"><div dir=3D"ltr" class=3D"gmail_attr">On Wed, 16 Mar 2022 at 06:09, S=
immons, James &lt;<a href=3D"mailto:simmonsja@ornl.gov">simmonsja@ornl.gov<=
/a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0=
px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">




<div dir=3D"ltr">
<div style=3D"font-family:Calibri,Arial,Helvetica,sans-serif;font-size:12pt=
;color:rgb(0,0,0)">
Hello.</div>
<div style=3D"font-family:Calibri,Arial,Helvetica,sans-serif;font-size:12pt=
;color:rgb(0,0,0)">
<br>
</div>
<div style=3D"font-family:Calibri,Arial,Helvetica,sans-serif;font-size:12pt=
;color:rgb(0,0,0)">
=C2=A0 =C2=A0 I have been watching your efforts to doing your own testing a=
nd this is something ORNL has been interested in as well.</div>
<div style=3D"font-family:Calibri,Arial,Helvetica,sans-serif;font-size:12pt=
;color:rgb(0,0,0)">
I was thinking would you be willing to do a joint talk at LUG on this effor=
t. We can pool our knowledge on how to doing</div>
<div style=3D"font-family:Calibri,Arial,Helvetica,sans-serif;font-size:12pt=
;color:rgb(0,0,0)">
local testing and feeding it back to WC. Would you be interested?</div>
<div id=3D"gmail-m_-7396076243517827728appendonsend"></div>
<hr style=3D"display:inline-block;width:98%">
<div id=3D"gmail-m_-7396076243517827728divRplyFwdMsg" dir=3D"ltr"><font fac=
e=3D"Calibri, sans-serif" style=3D"font-size:11pt" color=3D"#000000"><b>Fro=
m:</b> lustre-devel &lt;<a href=3D"mailto:lustre-devel-bounces@lists.lustre=
.org" target=3D"_blank">lustre-devel-bounces@lists.lustre.org</a>&gt; on be=
half of Kevin Zhao via lustre-devel &lt;<a href=3D"mailto:lustre-devel@list=
s.lustre.org" target=3D"_blank">lustre-devel@lists.lustre.org</a>&gt;<br>
<b>Sent:</b> Friday, March 11, 2022 1:28 AM<br>
<b>To:</b> Oleg Drokin &lt;<a href=3D"mailto:green@whamcloud.com" target=3D=
"_blank">green@whamcloud.com</a>&gt;<br>
<b>Cc:</b> Li Xi &lt;<a href=3D"mailto:lixi@ddn.com" target=3D"_blank">lixi=
@ddn.com</a>&gt;; Jian Yu &lt;<a href=3D"mailto:jiyu@whamcloud.com" target=
=3D"_blank">jiyu@whamcloud.com</a>&gt;; <a href=3D"mailto:cloud-dev-request=
@op-lists.linaro.org" target=3D"_blank">cloud-dev-request@op-lists.linaro.o=
rg</a> &lt;<a href=3D"mailto:cloud-dev-request@op-lists.linaro.org" target=
=3D"_blank">cloud-dev-request@op-lists.linaro.org</a>&gt;; Xinliang Liu via=
 lustre-devel &lt;<a href=3D"mailto:lustre-devel@lists.lustre.org" target=
=3D"_blank">lustre-devel@lists.lustre.org</a>&gt;<br>
<b>Subject:</b> [EXTERNAL] Re: [lustre-devel] Lustre Arm stuff status and w=
ork plan</font>
<div>=C2=A0</div>
</div>
<div>
<div dir=3D"ltr">Thanks Oleg,
<div><br>
</div>
<div>I will update the progress for the test clusters setup on Arm64 platfo=
rm.</div>
</div>
<br>
<div>
<div dir=3D"ltr">On Mon, 28 Feb 2022 at 13:36, Oleg Drokin &lt;<a href=3D"m=
ailto:green@whamcloud.com" target=3D"_blank">green@whamcloud.com</a>&gt; wr=
ote:<br>
</div>
<blockquote style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204=
,204,204);padding-left:1ex">
<div>Hello!
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
;white-space:pre-wrap;word-spacing:unset;text-decoration:unset"><a>hxxps://=
imgur.com/lk2ogJv</a>
 1 item means single patch n processing. time in testing for a patch is typ=
ically about 3.5 hours.</span></div>
<div><span style=3D"white-space:pre-wrap"><br>
</span></div>
<div><span style=3D"white-space:pre-wrap">maloo shows the resources when yo=
u go into the test session, for example
<a>hxxps://testing.whamcloud.com/test_sessions/4de25b47-43fc-4bfc-87aa-15e4=
968519a7</a> - scroll down to see list of nodes</span></div>
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
<div dir=3D"ltr"><span id=3D"gmail-m_-7396076243517827728x_gmail-m_-9171066=
69318353807gmail-docs-internal-guid-546d83e7-7fff-79c4-f764-aa4cccb7706c">
<div style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span styl=
e=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-var=
iant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;=
white-space:pre-wrap">Hi All,</span></div>
<div style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span styl=
e=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-var=
iant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;=
white-space:pre-wrap"><br>
</span></div>
<div style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span styl=
e=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-var=
iant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;=
white-space:pre-wrap">Greetings
 and thanks a lot for your comments! Xinliang and I are from <a>
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
white-space:pre-wrap">As I understand,
 the test jobs will cover the ZFS and Ldiskfs backend with 2 scenarios:</sp=
an></div>
<ul style=3D"margin-top:0px;margin-bottom:0px">
<li dir=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font-family:Ar=
ial;background-color:transparent;font-variant-numeric:normal;font-variant-e=
ast-asian:normal;vertical-align:baseline;white-space:pre-wrap">
<div style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span styl=
e=3D"font-size:11pt;background-color:transparent;font-variant-numeric:norma=
l;font-variant-east-asian:normal;vertical-align:baseline;white-space:pre-wr=
ap">Lustre Arm64 Server + Arm64
 Client( High Priority )</span></div>
</li><li dir=3D"ltr" style=3D"list-style-type:disc;font-size:11pt;font-fami=
ly:Arial;background-color:transparent;font-variant-numeric:normal;font-vari=
ant-east-asian:normal;vertical-align:baseline;white-space:pre-wrap">
<div style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span styl=
e=3D"font-size:11pt;background-color:transparent;font-variant-numeric:norma=
l;font-variant-east-asian:normal;vertical-align:baseline;white-space:pre-wr=
ap">Lustre Arm64 Server + x86_64
 Client</span></div>
</li></ul>
<div style=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt"><span sty=
le=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-va=
riant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline=
;white-space:pre-wrap">After
 going through the Lustre test website: </span><a style=3D"text-decoration-=
line:none"><span style=3D"font-size:11pt;font-family:Arial;background-color=
:transparent;font-variant-numeric:normal;font-variant-east-asian:normal;tex=
t-decoration-line:underline;vertical-align:baseline;white-space:pre-wrap">h=
xxps://testing.whamcloud.com/test_sessions</span></a><span style=3D"font-si=
ze:11pt;font-family:Arial;background-color:transparent;font-variant-numeric=
:normal;font-variant-east-asian:normal;vertical-align:baseline;white-space:=
pre-wrap">,
 it is quite clear to show the test info, and still remain some questions, =
that will be great if the community can give me a clear answer.</span></div=
>
<div style=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt"><span sty=
le=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-va=
riant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline=
;white-space:pre-wrap">1. Is
 there a link to show all the machine resources=EF=BC=9F Including the mach=
ine info, CPU, memory and peripheral info.=C2=A0</span></div>
<div style=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt"><span sty=
le=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-va=
riant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline=
;white-space:pre-wrap">2. Do
 we have a CI infra arch overview diagram to show the machine usage and com=
munication?=C2=A0</span></div>
<div style=3D"line-height:1.656;margin-top:0pt;margin-bottom:0pt"><span sty=
le=3D"font-size:11pt;font-family:Arial;background-color:transparent;font-va=
riant-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline=
;white-space:pre-wrap">3. How
 many machines are needed to meet the request of the Lustre Arm64 Server + =
Arm64 Client test?</span></div>
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
<div>
<div dir=3D"ltr">On Tue, 28 Dec 2021 at 09:58, Oleg Drokin &lt;<a href=3D"m=
ailto:green@whamcloud.com" target=3D"_blank">green@whamcloud.com</a>&gt; wr=
ote:<br>
</div>
<blockquote style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204=
,204,204);padding-left:1ex">
<div><br>
<div><br>
<blockquote type=3D"cite">
<div>On Dec 27, 2021, at 8:53 PM, Xinliang Liu &lt;<a href=3D"mailto:xinlia=
ng.liu@linaro.org" target=3D"_blank">xinliang.liu@linaro.org</a>&gt; wrote:=
</div>
<div>
<div dir=3D"ltr">
<div><br>
<blockquote style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204=
,204,204);padding-left:1ex">
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
<p style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica=
,Arial,sans-serif;font-size:inherit">
<b><span style=3D"font-size:11pt"><font color=3D"#38761d">Kevin Zhao</font>=
</span></b></p>
<p style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica=
,Arial,sans-serif;font-size:inherit">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">Tech Lead, LDCG=
 Cloud Infrastructure</span></font></p>
<p style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica=
,Arial,sans-serif;font-size:inherit">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">Linaro Vertical=
 Technologies</span></font></p>
<p style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica=
,Arial,sans-serif;font-size:inherit">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">IRC(freenode): =
kevinz</span></font></p>
<p><font color=3D"#757b80"><font color=3D"#888888" face=3D"Roboto, RobotoDr=
aft, Helvetica, Arial, sans-serif"><span style=3D"font-size:14.6667px">Slac=
k(</span></font><font face=3D"Roboto, RobotoDraft, Helvetica, Arial, sans-s=
erif"><span style=3D"font-size:14.6667px"><a>kubernetes.slack.com</a>)</spa=
n></font><font color=3D"#888888" face=3D"Roboto, RobotoDraft, Helvetica, Ar=
ial, sans-serif"><span style=3D"font-size:14.6667px">:
 kevinz</span></font></font></p>
<p style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica=
,Arial,sans-serif;font-size:inherit">
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
<p style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica=
,Arial,sans-serif;font-size:medium">
<b><span style=3D"font-size:11pt"><font color=3D"#38761d">Kevin Zhao</font>=
</span></b></p>
<p style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica=
,Arial,sans-serif;font-size:medium">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">Tech Lead, LDCG=
 Cloud Infrastructure</span></font></p>
<p style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica=
,Arial,sans-serif;font-size:medium">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">Linaro Vertical=
 Technologies</span></font></p>
<p style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica=
,Arial,sans-serif;font-size:medium">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">IRC(freenode): =
kevinz</span></font></p>
<p><font color=3D"#757b80"><font color=3D"#888888" face=3D"Roboto, RobotoDr=
aft, Helvetica, Arial, sans-serif"><span style=3D"font-size:14.6667px">Slac=
k(</span></font><font face=3D"Roboto, RobotoDraft, Helvetica, Arial, sans-s=
erif"><span style=3D"font-size:14.6667px"><a>kubernetes.slack.com</a>)</spa=
n></font><font color=3D"#888888" face=3D"Roboto, RobotoDraft, Helvetica, Ar=
ial, sans-serif"><span style=3D"font-size:14.6667px">:
 kevinz</span></font></font></p>
<p style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica=
,Arial,sans-serif;font-size:medium">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px"><a href=3D"mail=
to:kevin.zhao@linaro.org" target=3D"_blank"><span>kevin.zhao@linaro.org</sp=
an></a>=C2=A0| Mobile/Direct/Wechat:=C2=A0 +86 18818270915</span></font><sp=
an style=3D"color:rgb(117,123,128);font-size:11pt">=C2=A0</span><br>
</p>
<div style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helveti=
ca,Arial,sans-serif;font-size:medium">
<span style=3D"color:rgb(117,123,128);font-size:11pt"><br>
</span></div>
</div>
</div>
</font></div>
<div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;fon=
t-size:medium">
</div>
</div>
</div>
<div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;fon=
t-size:medium">
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

--00000000000013914605da4bc938--

--===============6841611430526068066==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6841611430526068066==--
