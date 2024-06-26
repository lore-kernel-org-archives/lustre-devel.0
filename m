Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 25D62C27C4F
	for <lustre-devel@archiver.kernel.org>; Wed, 26 Jun 2024 21:23:44 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4W8ZSY5Phdz1y6m;
	Wed, 26 Jun 2024 14:23:41 -0700 (PDT)
Received: from mail-pj1-f42.google.com (mail-pj1-f42.google.com
 [209.85.216.42])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4W8ZSW5yvXz1wP1
 for <lustre-devel@lists.lustre.org>; Wed, 26 Jun 2024 14:23:39 -0700 (PDT)
Received: by mail-pj1-f42.google.com with SMTP id
 98e67ed59e1d1-2c7b3c513f9so5539323a91.3
 for <lustre-devel@lists.lustre.org>; Wed, 26 Jun 2024 14:23:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1719437018; x=1720041818; darn=lists.lustre.org;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:from:to:cc:subject:date:message-id:reply-to;
 bh=bOGBJfyxkRwg52iiP1ZF1Khq8NPzdzsv1vWfYvX0aeg=;
 b=jZRud5zDxIFIQ1B92ORhBWBs26mwAYu0uXLuQlTWrDmDBCfd+nlPUbkqNQob8i9vg/
 YsJ8WFUNZbyczVNQNIXaViXiLRffEn+lbCiPYDR9ooqIe3feqRVlivA/0yMoz/5GEQNc
 DPCyRE3K/T/cIEtQH3zcTKLgaQxnLJKZAuQ55Z8HmR7EUnuZ5p8mTlej1i22JQoAtA05
 3XMBMxZHkrSlXIgK3zEUJfFQs8eToSPZSpKXCD4Re5mY8TPPU7LoLziB3d2SVvryCDFI
 QrNz0b0e1wDGGJ4feAXd/ItlwHGbzxjWAigFgVVfvyXDvGvMUjS3ScEVGo3yHhhf8XLn
 gChg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1719437018; x=1720041818;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
 :reply-to;
 bh=bOGBJfyxkRwg52iiP1ZF1Khq8NPzdzsv1vWfYvX0aeg=;
 b=jvU0/QdC+/mjqr1bDTV1xAUGhoVDLZKi2nzZz1jLDBvpacIwLIjslbSucmatb4bxQP
 Cu0fV/YDFm364VXeFmldu8AuCj4h/ASYvYyDidZVpiiNN0hbRPoW3SSB6k1FqRzeAUsp
 ztry8gMMfJrjXHnnTLh4tPPOVK6zL83/I+V2EWJzU1K2vqsCwsI2X9QrptA+C/KSGMU0
 ZkvRSpLzLqdG6lBhpIFn0yw8n7wowTdCO1ocliJQrtLnUqn64gPFkpXYMXldKYpR5Wm2
 L1zp+aeREUWKR168v9MadZhhCVSi1wTsVJj/3xpkvbvoY0mdsjNsD7FbCetOoUvvpkgg
 OjIQ==
X-Gm-Message-State: AOJu0YxnkgRrEvL3kNykgnpxiJ8+5RLDYocWlV0tmC1vNkbJSG/+auuz
 7ZF71o+1YwunPwlPtt4i+OAdwF8G0TkZhOaiSLwLBCFfYIno3QPcQs1GaDQZyp+7ZL6Gm2bE1tu
 ClO02GQy2a0jC6YbpsMO2VdcxnncccJvG
X-Google-Smtp-Source: AGHT+IFuEo+4j6QeCGEzCrghKa7VpqEESk9VsDwYmC3tN9bwyZGFpHUpUxi4QjTzO00NaBL7yaT0bg36GwB77el0k7E=
X-Received: by 2002:a17:90b:1245:b0:2c3:514:e0 with SMTP id
 98e67ed59e1d1-2c8505740d9mr10555459a91.35.1719437017671; Wed, 26 Jun 2024
 14:23:37 -0700 (PDT)
MIME-Version: 1.0
References: <CAGfFL-xAZf7-cL3iGaxL16Gh4L_bZvNZbUq42LGE2HdNs15z-Q@mail.gmail.com>
In-Reply-To: <CAGfFL-xAZf7-cL3iGaxL16Gh4L_bZvNZbUq42LGE2HdNs15z-Q@mail.gmail.com>
Date: Thu, 27 Jun 2024 06:23:01 +0900
Message-ID: <CAGfFL-wH3AGtGPC0XEJwNs0cg48DOE=EnVWn+qFGKb9Jiic1og@mail.gmail.com>
To: Lustre Developement <lustre-devel@lists.lustre.org>
Cc: Raju Rangaswami <rangaswami@gmail.com>, Hongpeng Jin <hjin008@fiu.edu>,
 Yanzhao Wu <yawu@fiu.edu>
Subject: Re: [lustre-devel] Survey request to help with LLM development for
 Lustre
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
From: John Bent via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: John Bent <johnbent@gmail.com>
Content-Type: multipart/mixed; boundary="===============3077548833437621959=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============3077548833437621959==
Content-Type: multipart/alternative; boundary="000000000000a6ef93061bd1a089"

--000000000000a6ef93061bd1a089
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello all,

Thanks to the respondents so far! Just a reminder that this survey is
available and we are still hoping to get more results. The early data does
show that human responses are preferred by almost a 3:1 ratio but there are
some LLM responses that are preferred.

Any time spent helping with this will be repaid by me personally beaming
loving kindness into the universe during my next meditation session. Please
let me know how many minutes of loving kindness you want beamed.

Thanks!

John

On Tue, Jun 11, 2024 at 10:05=E2=80=AFAM John Bent <johnbent@gmail.com> wro=
te:

> Dear Lustre Community Members,
>
>  We hope this message finds you well.
>
> We are a research team from FIU and LANL. Following up on my recent talk
> at last month=E2=80=99s Lustre User Group (LUG) meeting (LINK
> <https://www.depts.ttu.edu/hpcc/events/LUG24/slides/Day2/LUG_2024_Talk_09=
-TASSI_John_Bent_LUG24.pdf>),
> we are reaching out to invite you to participate in a survey to evaluate
> the accuracy of Large Language Models (LLMs) in answering questions about
> Lustre. Your expertise and experience are crucial for assessing how well
> LLMs compare to human experts within our community.
>
> Here are the details of the survey:
>
>    - Number of Questions: 10
>    - Estimated Completion Time: 15 ~ 30 minutes
>    - Link: https://forms.gle/MHEf2FBYTjyRioa16
>
> Note: We very much appreciate your time and contribution! Although it
> would be wonderful if all of you are able to answer all ten questions, we
> realize that this is a very large request. If you are able to help, pleas=
e
> try to respond to at least 3 questions and feel free to select the option
> =E2=80=9CI prefer not to answer=E2=80=9D for the others.
>
> In  this work, our ultimate goal is to improve the ability of local LLMs
> to help administrators, users, and developers of Lustre. We will publish
> the anonymized results of this survey back to this mailing list and hope =
to
> publish research results in peer-reviewed conferences as well as report
> back on our progress at future LUGs. Additionally, our work with local LL=
Ms
> will be done in open source. Finally, we recognize that LLMs are evolving
> rapidly so we plan to repeat this exercise with other systems such as Cep=
h
> as well as repeating this exercise at some point in the future with Lustr=
e.
> We hope to present results at a future LUG. Although, no future LUG could
> ever surpass the awesome one just organized by the great folks at Texas
> Tech, we know that they are all pretty great. :)
>
> Thank you for your time and dedication to the Lustre community. Your
> insights are invaluable, and we eagerly await your input.
>
> In addition to the survey, we welcome any and all feedback on this
> specific exercise as well as our research in general.
>
> Thanks,
>
> Hohnpeng, John, Raju, and Yanzhao
>

--000000000000a6ef93061bd1a089
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hello all,<div><br></div><div>Thanks to the respondents so=
 far! Just a reminder that this survey is available and we are still hoping=
 to get more results. The early data does show that human responses are pre=
ferred by almost a 3:1 ratio but there are some LLM responses that are pref=
erred.</div><div><br></div><div>Any time spent helping with this will be re=
paid by me personally beaming loving kindness into the universe during my n=
ext meditation session. Please let me know how many minutes of loving kindn=
ess you want beamed.</div><div><br></div><div>Thanks!</div><div><br></div><=
div>John</div></div><br><div class=3D"gmail_quote"><div dir=3D"ltr" class=
=3D"gmail_attr">On Tue, Jun 11, 2024 at 10:05=E2=80=AFAM John Bent &lt;<a h=
ref=3D"mailto:johnbent@gmail.com">johnbent@gmail.com</a>&gt; wrote:<br></di=
v><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;borde=
r-left-width:1px;border-left-style:solid;border-left-color:rgb(204,204,204)=
;padding-left:1ex"><div dir=3D"ltr">Dear Lustre Community Members,<br><br>=
=C2=A0We=C2=A0hope this message finds you well.<br><br>We are a research te=
am from FIU and LANL. Following up on my recent talk at last month=E2=80=99=
s Lustre User Group (LUG) meeting (<a href=3D"https://www.depts.ttu.edu/hpc=
c/events/LUG24/slides/Day2/LUG_2024_Talk_09-TASSI_John_Bent_LUG24.pdf" targ=
et=3D"_blank">LINK</a>), we are reaching out to invite you to participate i=
n a survey to evaluate the accuracy of Large Language Models (LLMs) in answ=
ering questions about Lustre. Your expertise and experience are crucial for=
 assessing how well LLMs compare to human experts within our community.<br>=
<br><div>Here are the details of the survey:<br><ul><li>Number of Questions=
: 10</li><li>Estimated Completion Time: 15 ~ 30 minutes</li><li>Link: <a hr=
ef=3D"https://forms.gle/MHEf2FBYTjyRioa16" target=3D"_blank">https://forms.=
gle/MHEf2FBYTjyRioa16</a></li></ul></div><div>Note: We very much appreciate=
 your time and contribution! Although it would be wonderful if all of you a=
re able to answer all ten questions, we realize that this is a very large r=
equest. If you are able to help, please try to respond to at least 3 questi=
ons and feel free to select=C2=A0the option =E2=80=9CI prefer not to answer=
=E2=80=9D for the others.<br><br>In =C2=A0this work, our ultimate goal is t=
o improve the ability of local LLMs to help administrators, users, and deve=
lopers of Lustre. We will publish the anonymized results of this survey bac=
k to this mailing list and hope to publish research results in peer-reviewe=
d conferences as well as report back on our progress at future LUGs. Additi=
onally, our work with local LLMs will be done in open source. Finally, we r=
ecognize that LLMs are evolving rapidly so we plan to repeat this exercise =
with other systems such as Ceph as well as repeating this exercise at some =
point in the future with Lustre. We hope to present results at a future LUG=
. Although, no future LUG could ever surpass the awesome one just organized=
 by the great folks at Texas Tech, we know that they are all pretty great. =
:)<br><br></div><div>Thank you for your time and dedication to the Lustre c=
ommunity. Your insights are invaluable, and we eagerly await your input.<br=
></div><div><br></div><div>In addition to the survey, we welcome any and al=
l feedback on this specific exercise as well as our research in general.</d=
iv><div><br></div><div>Thanks,</div><div><br></div><div>Hohnpeng, John, Raj=
u, and=C2=A0Yanzhao</div></div>
</blockquote></div>

--000000000000a6ef93061bd1a089--

--===============3077548833437621959==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3077548833437621959==--
