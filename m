Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9E4B4C3ABBE
	for <lustre-devel@archiver.kernel.org>; Tue,  6 May 2025 23:49:13 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZsZqY0Fwkz1xR7;
	Tue, 06 May 2025 16:49:13 -0700 (PDT)
Received: from mail-oa1-f49.google.com (mail-oa1-f49.google.com
 [209.85.160.49])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZsZqF0KqGz1wfw
 for <lustre-devel@lists.lustre.org>; Tue, 06 May 2025 16:48:56 -0700 (PDT)
Received: by mail-oa1-f49.google.com with SMTP id
 586e51a60fabf-2db0217abe4so1345815fac.1
 for <lustre-devel@lists.lustre.org>; Tue, 06 May 2025 16:48:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1746575335; x=1747180135; darn=lists.lustre.org;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:from:to:cc:subject:date:message-id:reply-to;
 bh=kpdzFM67vNwIhDGfXiAMBZJuzsZejjxX24mEZDZmWSU=;
 b=kivLG2UR/7kNy7vzNdhhgXRxw6Ehg5WpIjaiQ/H0YhvQaOSDrOUHYhZf1t+VI8TnUp
 ck0We89DD4ge8Jp29cZCSf8MfvTQ7XLWQVsTkLTsE1843mDwDPcJ0u7m6IXkUR1oNrcA
 z5Vgs6N0vPIHunPt9tJ3CptwX2HUO0FLwfhMGEEPGgERr+gv2MhNaYSpjoYxZ4tn1GpP
 SKdlf74J0CyydzhqrvDy+jmV5v+qZ84Eqp4zjyHD6CmTLABeneYRdVyb0hKI6BuyaH+X
 hoPXJGIleZOuTjCQPKqPyK3A7sRLaBp16bwXtsuBRaDruGL3acNzQ+wEY5NR/0eOPh8t
 l1eA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1746575335; x=1747180135;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
 :reply-to;
 bh=kpdzFM67vNwIhDGfXiAMBZJuzsZejjxX24mEZDZmWSU=;
 b=sxXTtJo2J6MO6LwgfIAAHdpQAn9isKY9qK9zfnQ180CkWFUrMTf5E59t/+ORt9vpUi
 0EeWoXi8KPztMQ6ziFF70awrBg/M3U07Ga2dm8HtkBaij2pSABI6oJXNNe+ajSwZhcFa
 MLpf9m7W0no4Z6Fx8M6srji82Odr4l4m5grHlfKkAJsRqEXD4w501MmaQi3qoGaXuXuE
 ROXiKUUbXUasWlvajZHgIyFpUkKL6poWFVoSHsJB63W2G8yEteLKhsrQtMylB2RIinzG
 +YN71NbShZINvqGVy4smbG+ceje4wkGRC+WH3u9FD7894irysaMrvIkCTT+i8LV7NDNQ
 Fi2A==
X-Gm-Message-State: AOJu0YwA5XuoBQ6xb2Uw3nAnlK2NALBuQ3LuD+V6rA2Gj/kmkiIEb67z
 FePbyKZm1DZ3pqdXO1ZtX160dComQLbtU9Nd2bb0OT5rjeML/UiQDY9KJO+WfW9ngx6qckvEltN
 tXczLL4/+RAFOVTyuMQerq9lF+tM=
X-Gm-Gg: ASbGnctyDBVhxjAi3yIbwATfSe1KFDPTlu6auS80hHY57Lttkpxo4DyqU652IC9r583
 m6t0+THGoz+x8sknHy6rSxa1pK3uCxk0y4hyMY3f4gUBj+L0bhMhEKD798GOjtGcTyzyE6AM1//
 C9KbYztftyrb/6o5+zy5prEA==
X-Google-Smtp-Source: AGHT+IFiSJGat7SbXm7pgEtVTQMT5J7Vfkz7GqewRMpWLlHzImVvDFApOwpbEj9zLRT8/8IAwWjBRBIzyWIKnmzofso=
X-Received: by 2002:a05:6871:3329:b0:2d4:d9d6:c8cf with SMTP id
 586e51a60fabf-2db5bd9056cmr851745fac.5.1746575334612; Tue, 06 May 2025
 16:48:54 -0700 (PDT)
MIME-Version: 1.0
References: <CAFhHJg=GrakUdiZ713MjmDfUSFypNtc0HDfjVOsaWPrp+qzjQQ@mail.gmail.com>
 <AB2369CB-C2D2-4879-A5B6-2D428A213D6D@ddn.com>
In-Reply-To: <AB2369CB-C2D2-4879-A5B6-2D428A213D6D@ddn.com>
From: GEORGE ZHAO <georgezhaojobs@gmail.com>
Date: Tue, 6 May 2025 19:48:41 -0400
X-Gm-Features: ATxdqUFMltjadMPSaUGCJVonfZPWkF9-iwhNGBv_jT-y0P62gBHqyiOQ5H5WfEU
Message-ID: <CAFhHJgmyHMBY8bha2eAP1QRGvcBumgLViusKy-NNxoDeLQQt6A@mail.gmail.com>
To: Andreas Dilger <adilger@ddn.com>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Subject: Re: [lustre-devel] 
	=?utf-8?q?New_contributor_inquiry_=E2=80=93_statu?=
	=?utf-8?q?s_of_LU-1643_=28=E2=80=9Creserved_space=E2=80=9D_in_stat?=
	=?utf-8?q?fs/df=29_and_guidance_requested?=
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
Content-Type: multipart/mixed; boundary="===============7619570289454798224=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7619570289454798224==
Content-Type: multipart/alternative; boundary="00000000000064a3d60634804255"

--00000000000064a3d60634804255
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Andreas,

Could you or Simmons send me an invitation to this channel?
https://lustreupstreamclient.slack.com/messages/CAV4QF0ER/
An invitation from the workspace admin is required (James Simmons)

I have a question about how to retrieve data from /proc.
And I'd like to clarify the behavior of "lfs df --stats".

Thanks,
George

On Thu, May 1, 2025 at 1:52=E2=80=AFAM Andreas Dilger <adilger@ddn.com> wro=
te:

> There is a Slack channel, which is linked from wiki.lustre.org "lists"
> page that you can use for simple discussions. Email is probably better fo=
r
> complex questions.
>
> Cheers, Andreas
>
> On Apr 30, 2025, at 20:18, GEORGE ZHAO <georgezhaojobs@gmail.com> wrote:
>
> =EF=BB=BF
> Thank you, Andreas!
> I'm currently looking into LU-7880. Will follow up if I have an
> implementation plan or run into any questions (quite likely).
>
> By the way, should I reach out to the lustre-devel for questions like
> this, or is there a more specific channel?
>
> Thanks!
> George
>
> On Wed, Apr 30, 2025 at 4:44=E2=80=AFAM Andreas Dilger <adilger@ddn.com> =
wrote:
>
>> Hi George,
>> thanks for your interest.  There are definitely a number of open tickets
>> in the "easy" (and "medium") categories that you could work on, though
>> there have been a number of interns and new hires working on those ticke=
ts
>> recently and fewer are now available.
>>
>> LU-1643 happens to be the oldest "easy" ticket, but don't let that guide
>> your selection.  I would suggest you take a look through the whole list =
and
>> pick something that is of interest to you and/or matches your experience
>> level.
>>
>> - LU-16738 <https://jira.whamcloud.com/browse/LU-16738> - Improve
>> mount.lustre with many MGS NIDs
>> <https://jira.whamcloud.com/browse/LU-16738>: this is partly a userspace
>> (mount.lustre) change and partly in the kernel (though not incredibly
>> complex).  This is actually in the "useful" category that provides impro=
ved
>> functionality for something that is seen regularly.
>>
>>
>> If you are feeling more adventurous, you might look at one of the
>> "medium" tickets, which may not be too difficult:
>> - LU-7880 <https://jira.whamcloud.com/browse/LU-7880> - add OST/MDT
>> performance statistics to obd_statfs
>> <https://jira.whamcloud.com/browse/LU-7880>:  this is a very useful
>> feature that would allow clients/user applications to probe the IO load =
on
>> OSTs, and self-optimize checkpoint IO to times when the OSTs are less bu=
sy
>> - LU-13123 <https://jira.whamcloud.com/browse/LU-13123> - Add list of
>> client NIDs to job_stats output
>> <https://jira.whamcloud.com/browse/LU-13123>: this would associate all
>> of the clients that are contributing to the job_stats for a specific Job=
ID,
>> and would be useful for debugging and monitoring/
>>
>> On Apr 29, 2025, at 17:41, GEORGE ZHAO <georgezhaojobs@gmail.com> wrote:
>>
>>
>> I'm a storage engineer and a Lustre beginner who just figured out how to
>> deploy it. Did read a lot about it though.
>> My goal is using Lustre to support HPC/ML workload. And I believe doing
>> some tasks would help me proceed better.
>>
>> As wiki suggested, I found an "easy" ticket LU-1643: =E2=80=9CRequest to=
 remove
>> display of reserved space from statfs (df) total space.=E2=80=9D
>> Is it still unclaimed?
>> If it's already in progress, or there's a higher priority issue that
>> could use help, please point me in the right direction.
>>
>> Thanks in advance for any advice.
>>
>> Best regards,
>> George
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel@lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>>
>>
>> Cheers, Andreas
>> =E2=80=94
>> Andreas Dilger
>> Lustre Principal Architect
>> Whamcloud/DDN
>>
>>
>>
>>
>>

--00000000000064a3d60634804255
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Andreas,<div><br></div><div><div>Could you or Simmons s=
end me an invitation=C2=A0to this channel?</div><div><a href=3D"https://lus=
treupstreamclient.slack.com/messages/CAV4QF0ER/">https://lustreupstreamclie=
nt.slack.com/messages/CAV4QF0ER/</a><br>An invitation from the workspace ad=
min is required (James Simmons)</div><div><br></div><div>I have a question=
=C2=A0about how to retrieve=C2=A0data from /proc.</div><div>And I&#39;d lik=
e to clarify the behavior of &quot;lfs df --stats&quot;.</div><div><br></di=
v><div>Thanks,</div><div>George</div></div></div><br><div class=3D"gmail_qu=
ote gmail_quote_container"><div dir=3D"ltr" class=3D"gmail_attr">On Thu, Ma=
y 1, 2025 at 1:52=E2=80=AFAM Andreas Dilger &lt;<a href=3D"mailto:adilger@d=
dn.com">adilger@ddn.com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_=
quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,=
204);padding-left:1ex">



<div dir=3D"auto">
There is a Slack channel, which is linked from <a href=3D"http://wiki.lustr=
e.org" target=3D"_blank">wiki.lustre.org</a> &quot;lists&quot; page that yo=
u can use for simple discussions. Email is probably better for complex ques=
tions.=C2=A0
<div><br id=3D"m_-4661364368212878897lineBreakAtBeginningOfSignature">
<div dir=3D"ltr">Cheers, Andreas</div>
<div dir=3D"ltr"><br>
<blockquote type=3D"cite">On Apr 30, 2025, at 20:18, GEORGE ZHAO &lt;<a hre=
f=3D"mailto:georgezhaojobs@gmail.com" target=3D"_blank">georgezhaojobs@gmai=
l.com</a>&gt; wrote:<br>
<br>
</blockquote>
</div>
<blockquote type=3D"cite">
<div dir=3D"ltr">=EF=BB=BF
<div dir=3D"ltr">
<div dir=3D"ltr">Thank you, Andreas!<br>
I&#39;m currently looking into LU-7880. Will follow up if I have an impleme=
ntation plan or run into any questions (quite likely).<br>
<br>
By the way, should I reach out to the lustre-devel for questions like this,=
 or is there a more specific channel?<br>
<div><br>
</div>
<div>Thanks!</div>
<div>George</div>
</div>
<br>
<div class=3D"gmail_quote">
<div dir=3D"ltr" class=3D"gmail_attr">On Wed, Apr 30, 2025 at 4:44=E2=80=AF=
AM Andreas Dilger &lt;<a href=3D"mailto:adilger@ddn.com" target=3D"_blank">=
adilger@ddn.com</a>&gt; wrote:<br>
</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left:1px solid rgb(204,204,204);padding-left:1ex">
<div>Hi George,
<div>thanks for your interest.=C2=A0 There are definitely a number of open =
tickets in the &quot;easy&quot; (and &quot;medium&quot;) categories that yo=
u could work on, though there have been a number of interns and new hires w=
orking on those tickets recently and fewer are now available.</div>
<div><br>
</div>
<div>LU-1643 happens to be the oldest &quot;easy&quot; ticket, but don&#39;=
t let that guide your selection.=C2=A0 I would suggest you take a look thro=
ugh the whole list and pick something that is of interest to you and/or mat=
ches your experience level.</div>
<div><br>
</div>
<div>-=C2=A0<a href=3D"https://jira.whamcloud.com/browse/LU-16738" id=3D"m_=
-4661364368212878897m_1429994837881312626key-val" rel=3D"75582" target=3D"_=
blank">LU-16738</a>=C2=A0-=C2=A0<a href=3D"https://jira.whamcloud.com/brows=
e/LU-16738" target=3D"_blank">Improve mount.lustre with many MGS NIDs</a>: =
this is
 partly a userspace (mount.lustre) change and partly in the kernel (though =
not incredibly complex).=C2=A0 This is actually in the &quot;useful&quot; c=
ategory that provides improved functionality for something that is seen reg=
ularly.</div>
<div><br>
</div>
<div><br>
</div>
<div>If you are feeling more adventurous, you might look at one of the &quo=
t;medium&quot; tickets, which may not be too difficult:</div>
<div>-=C2=A0<a href=3D"https://jira.whamcloud.com/browse/LU-7880" target=3D=
"_blank">LU-7880</a>=C2=A0-=C2=A0<a href=3D"https://jira.whamcloud.com/brow=
se/LU-7880" target=3D"_blank">add OST/MDT performance statistics to obd_sta=
tfs</a>: =C2=A0this is a very useful feature that would allow
 clients/user applications to probe the IO load on OSTs, and self-optimize =
checkpoint IO to times when the OSTs are less busy</div>
<div>-=C2=A0<a href=3D"https://jira.whamcloud.com/browse/LU-13123" target=
=3D"_blank">LU-13123</a>=C2=A0-=C2=A0<a href=3D"https://jira.whamcloud.com/=
browse/LU-13123" target=3D"_blank">Add list of client NIDs to job_stats out=
put</a>: this would associate all of the clients that are
 contributing to the job_stats for a specific JobID, and would be useful fo=
r debugging and monitoring/<br id=3D"m_-4661364368212878897m_14299948378813=
12626lineBreakAtBeginningOfMessage">
<div><br>
<div>
<div>On Apr 29, 2025, at 17:41, GEORGE ZHAO &lt;<a href=3D"mailto:georgezha=
ojobs@gmail.com" target=3D"_blank">georgezhaojobs@gmail.com</a>&gt; wrote:<=
/div>
</div>
<blockquote type=3D"cite">
<div>
<div>
<div>
<div dir=3D"ltr">
<div><br>
</div>
<div>I&#39;m a storage engineer and a Lustre=C2=A0beginner who just figured=
 out how to deploy it. Did read a lot about it though.</div>
<div>My goal is using Lustre to support=C2=A0HPC/ML workload. And I believe=
 doing some tasks would help me proceed better.</div>
<div><br>
</div>
<div>As wiki suggested, I found an &quot;easy&quot; ticket LU-1643: =E2=80=
=9CRequest to remove display of reserved space from statfs (df) total space=
.=E2=80=9D</div>
<div>Is it still unclaimed?=C2=A0</div>
<div>If it&#39;s already in progress, or there&#39;s a higher priority issu=
e that could use help, please point me in the right direction.</div>
<div><br>
</div>
<div>Thanks in advance for any advice.<br>
<br>
Best regards,</div>
<div>George</div>
</div>
</div>
</div>
_______________________________________________<br>
lustre-devel mailing list<br>
<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-d=
evel@lists.lustre.org</a><br>
<a href=3D"http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org" ta=
rget=3D"_blank">http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.or=
g</a><br>
</div>
</blockquote>
</div>
<br>
<div>
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div>Cheers, Andreas</div>
<div>=E2=80=94</div>
<div>Andreas Dilger</div>
<div>Lustre Principal Architect</div>
<div>Whamcloud/DDN</div>
</div>
<br>
</div>
<br>
<br>
</div>
<br>
</div>
</div>
</blockquote>
</div>
</div>
</div>
</blockquote>
</div>
</div>

</blockquote></div>

--00000000000064a3d60634804255--

--===============7619570289454798224==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7619570289454798224==--
